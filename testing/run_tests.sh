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
set -exo errexit

SCALA_VERSION="2.12"
SPARK_VERSION="3.3.0"

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
    *)
      echo "Unexpected command line flag $2 $1."
      exit 1
      ;;
  esac
  shift
done

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

. "${SCRIPT_DIR}/testing.sh"

smoke_test

echo "Test successfully finished"