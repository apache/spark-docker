#!/bin/bash

#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This test script runs a simple smoke test in standalone cluster:
# - create docker network
# - start up a master
# - start up a worker
# - wait for the web UI endpoint to return successfully
# - run a simple smoke test in standalone cluster
# - clean up test resource

CURL_TIMEOUT=1
CURL_COOLDOWN=1
CURL_MAX_TRIES=30

NETWORK_NAME=spark-net-bridge

SUBMIT_CONTAINER_NAME=spark-submit
MASTER_CONTAINER_NAME=spark-master
WORKER_CONTAINER_NAME=spark-worker
SPARK_MASTER_PORT=7077
SPARK_MASTER_WEBUI_CONTAINER_PORT=8080
SPARK_MASTER_WEBUI_HOST_PORT=8080
SPARK_WORKER_WEBUI_CONTAINER_PORT=8081
SPARK_WORKER_WEBUI_HOST_PORT=8081

SCALA_VERSION="2.12"
SPARK_VERSION="3.3.0"
IMAGE_URL=

# Create a new docker bridge network
function create_network() {
  if [ ! -z $(docker network ls --filter name=^${NETWORK_NAME}$ --format="{{ .Name }}") ]; then
    # bridge network already exists, need to kill containers attached to the network and remove network
    cleanup
    remove_network
  fi
  docker network create --driver bridge "$NETWORK_NAME" > /dev/null
}

# Remove docker network
function remove_network() {
    docker network rm "$NETWORK_NAME" > /dev/null
}

# Find and kill any remaining containers attached to the network
function cleanup() {
  local containers 
  containers="$(docker ps --quiet --filter network="$NETWORK_NAME")"

  if [ -n "$containers" ]; then
    echo >&2 -n "==> Killing $(echo -n "$containers" | grep -c '^') orphaned container(s)..."
    echo "$containers" | xargs docker kill > /dev/null
    echo >&2 " done."
  fi
}

# Exec docker run command
function docker_run() {
  local container_name="$1"
  local docker_run_command="$2"
  local args="$3"

  echo >&2 "===> Starting ${container_name}"
  if [ "$container_name" = "$MASTER_CONTAINER_NAME" -o "$container_name" = "$WORKER_CONTAINER_NAME" ]; then
    # --detach: Run spark-master and spark-worker in background, like spark-daemon.sh behaves
    eval "docker run --rm --detach --network $NETWORK_NAME --name ${container_name} ${docker_run_command} $IMAGE_URL ${args}"
  else
    eval "docker run --rm --network $NETWORK_NAME --name ${container_name} ${docker_run_command} $IMAGE_URL ${args}"
  fi
}

# Start up a spark master
function start_spark_master() {
  docker_run \
    "$MASTER_CONTAINER_NAME" \
    "--publish $SPARK_MASTER_WEBUI_HOST_PORT:$SPARK_MASTER_WEBUI_CONTAINER_PORT $1" \
    "/opt/spark/bin/spark-class org.apache.spark.deploy.master.Master" > /dev/null
}

# Start up a spark worker
function start_spark_worker() {
  docker_run \
    "$WORKER_CONTAINER_NAME" \
    "--publish $SPARK_WORKER_WEBUI_HOST_PORT:$SPARK_WORKER_WEBUI_CONTAINER_PORT $1" \
    "/opt/spark/bin/spark-class org.apache.spark.deploy.worker.Worker spark://$MASTER_CONTAINER_NAME:$SPARK_MASTER_PORT" > /dev/null
}

# Wait container ready until endpoint returns successfully
function wait_container_ready() {
  local container_name="$1"
  local host_port="$2"
  i=0
  echo >&2 "===> Waiting for ${container_name} to be ready..."
  while true; do
    i=$((i+1))

    set +e

    curl \
      --silent \
      --max-time "$CURL_TIMEOUT" \
      localhost:"${host_port}" \
      > /dev/null

    result=$?

    set -e

    if [ "$result" -eq 0 ]; then
      break
    fi

    if [ "$i" -gt "$CURL_MAX_TRIES" ]; then
      echo >&2 "===> \$CURL_MAX_TRIES exceeded waiting for ${container_name} to be ready"
      return 1
    fi

    sleep "$CURL_COOLDOWN"
  done

  echo >&2 "===> ${container_name} is ready."
}

# Run spark pi
function run_spark_pi() {
  docker_run \
    "$SUBMIT_CONTAINER_NAME" \
    "$1" \
    "/opt/spark/bin/spark-submit --master spark://$MASTER_CONTAINER_NAME:$SPARK_MASTER_PORT --class org.apache.spark.examples.SparkPi /opt/spark/examples/jars/spark-examples_$SCALA_VERSION-$SPARK_VERSION.jar 20"
}

# Run smoke standalone test
function run_smoke_test_in_standalone() {
  local docker_run_command=$1

  create_network
  cleanup

  start_spark_master "${docker_run_command}"
  start_spark_worker "${docker_run_command}"

  wait_container_ready "$MASTER_CONTAINER_NAME" "$SPARK_MASTER_WEBUI_HOST_PORT"
  wait_container_ready "$WORKER_CONTAINER_NAME" "$SPARK_WORKER_WEBUI_HOST_PORT"

  run_spark_pi "${docker_run_command}"

  cleanup
  remove_network
}

# Run a master and worker and verify they start up and connect to each other successfully.
# And run a smoke test in standalone cluster.
function smoke_test() {
  if [ -z "$IMAGE_URL" ]; then
    echo >&2 "Image url is need, please set it with --image-url"
    exit -1
  fi

  echo >&2 "===> Smoke test for $IMAGE_URL as root"
  run_smoke_test_in_standalone

  echo >&2 "===> Smoke test for $IMAGE_URL as non-root"
  run_smoke_test_in_standalone "--user spark"
}

# Parse arguments
while (( "$#" )); do
  case $1 in
    --scala-version)
      SCALA_VERSION="$2"
      shift
      ;;
    --spark-version)
      SPARK_VERSION="$2"
      shift
      ;;
    --image-url)
      IMAGE_URL="$2"
      shift
      ;;
    *)
      echo "Unexpected command line flag $2 $1."
      exit 1
      ;;
  esac
  shift
done

# Run smoke test
smoke_test
