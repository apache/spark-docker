#!/bin/bash -e

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

CURL_TIMEOUT=1
CURL_COOLDOWN=1
CURL_MAX_TRIES=30

NETWORK_NAME=spark-net-bridge

SUBMIT_CONTAINER_NAME=spark-submit
MASTER_CONTAINER_NAME=spark-master
WORKER_CONTAINER_NAME=spark-work
SPARK_MASTER_PORT=7077
SPARK_MASTER_WEBUI_CONTAINER_PORT=8080
SPARK_MASTER_WEBUI_HOST_PORT=8080
SPARK_WORKER_WEBUI_CONTAINER_PORT=8081
SPARK_WORKER_WEBUI_HOST_PORT=8081

# Create a new docker bridge network
function create_network() {
    docker network create --driver bridge "$NETWORK_NAME" > /dev/null
}

# Remove docker network
function remove_network() {
    docker network remove "$NETWORK_NAME" > /dev/null
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

function docker_run() {
    local container_name="$1"
    local docker_run_command="$2"
    local args="$3"

    echo >&2 "===> Starting ${container_name}"
    if [ "$container_name" = "$MASTER_CONTAINER_NAME" ]; then
      eval "docker run --rm --detach --network $NETWORK_NAME --name ${container_name} ${docker_run_command} $image_url ${args}"
    elif [ "$container_name" = "$WORKER_CONTAINER_NAME" ]; then
      eval "docker run --rm --detach --network $NETWORK_NAME --name ${container_name} ${docker_run_command} $image_url ${args}"
    else
      eval "docker run --rm --network $NETWORK_NAME --name ${container_name} ${docker_run_command} $image_url ${args}"
    fi
}

function start_spark_master() {
    docker_run \
      "$MASTER_CONTAINER_NAME" \
      "--publish $SPARK_MASTER_WEBUI_HOST_PORT:$SPARK_MASTER_WEBUI_CONTAINER_PORT $1" \
      "/opt/spark/bin/spark-class org.apache.spark.deploy.master.Master" > /dev/null
}

function start_spark_worker() {
    docker_run \
    "$WORKER_CONTAINER_NAME" \
    "--publish $SPARK_WORKER_WEBUI_HOST_PORT:$SPARK_WORKER_WEBUI_CONTAINER_PORT $1" \
    "/opt/spark/bin/spark-class org.apache.spark.deploy.worker.Worker spark://$MASTER_CONTAINER_NAME:$SPARK_MASTER_PORT" > /dev/null
}

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

function run_spark_pi() {
    docker_run \
      "$SUBMIT_CONTAINER_NAME" \
      "$1" \
      "/opt/spark/bin/spark-submit --master spark://$MASTER_CONTAINER_NAME:$SPARK_MASTER_PORT --class org.apache.spark.examples.SparkPi /opt/spark/examples/jars/spark-examples_${scala_spark_version}.jar 20"
}

# Run smoke test
function run_smoke_test() {
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

# Run a master and work and verify they start up and connect to each other successfully.
# And run a Spark Pi to complete smoke test.
function smoke_test() {
    local test_repo="$1"
    local image_name="$2"
    local unique_image_tag="$3"
    local scala_spark_version="$4"
    local image_url=${test_repo}/${image_name}:${unique_image_tag}

    echo >&2 "===> Smoke test for $image_url"
    run_smoke_test ""

    echo >&2 "===> Smoke test for $image_url as non-root"
    run_smoke_test "--user spark"
}
