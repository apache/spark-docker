#!/usr/bin/env bash

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

# Usage: $0 [version]
# Generate dockerfiles for specified spark version.
#
# Examples:
# - Add 3.3.0 dockerfiles:
#   $ ./add-dockerfiles.sh
# - Add 3.3.1 dockerfiles:
#   $ ./add-dockerfiles.sh 3.3.1

VERSION=${1:-"3.5.0"}

if echo $VERSION | grep -Eq "^4."; then
    # 4.x default
    TAGS="
    scala2.13-java17-python3-r-ubuntu
    scala2.13-java17-python3-ubuntu
    scala2.13-java17-r-ubuntu
    scala2.13-java17-ubuntu
    scala2.13-java21-python3-r-ubuntu
    scala2.13-java21-python3-ubuntu
    scala2.13-java21-r-ubuntu
    scala2.13-java21-ubuntu
    "
elif echo $VERSION | grep -Eq "^3."; then
    # 3.x default
    TAGS="
    scala2.12-java11-python3-r-ubuntu
    scala2.12-java11-python3-ubuntu
    scala2.12-java11-r-ubuntu
    scala2.12-java11-ubuntu
    "
    # java17 images were added in 3.5.0. We need to skip java17 for 3.3.x and 3.4.x
    if ! echo $VERSION | grep -Eq "^3.3|^3.4"; then
        TAGS+="
        scala2.12-java17-python3-r-ubuntu
        scala2.12-java17-python3-ubuntu
        scala2.12-java17-r-ubuntu
        scala2.12-java17-ubuntu
        "
    fi
fi

for TAG in $TAGS; do
    OPTS=""
    if echo $TAG | grep -q "python"; then
        OPTS+=" --pyspark"
    fi

    if echo $TAG | grep -q "r-"; then
        OPTS+=" --sparkr"
    fi
    
    if echo $TAG | grep -q "scala2.12"; then
        OPTS+=" --scala-version 2.12"
    elif echo $TAG | grep -q "scala2.13"; then
        OPTS+=" --scala-version 2.13"
    fi

    if echo $TAG | grep -q "java21"; then
        OPTS+=" --java-version 21 --image eclipse-temurin:21-jammy"
    elif echo $TAG | grep -q "java17"; then
        OPTS+=" --java-version 17 --image eclipse-temurin:17-jammy"
    elif echo $TAG | grep -q "java11"; then
        OPTS+=" --java-version 11 --image eclipse-temurin:11-jammy"
    fi
    
    OPTS+=" --spark-version $VERSION"

    mkdir -p $VERSION/$TAG

    if [ "$TAG" == "scala2.12-java11-ubuntu" ] || [ "$TAG" == "scala2.12-java17-ubuntu" ] || [ "$TAG" == "scala2.13-java17-ubuntu" ] || [ "$TAG" == "scala2.13-java21-ubuntu" ]; then
        python3 tools/template.py $OPTS > $VERSION/$TAG/Dockerfile
        python3 tools/template.py $OPTS -f entrypoint.sh.template > $VERSION/$TAG/entrypoint.sh
        chmod a+x $VERSION/$TAG/entrypoint.sh
    else
        python3 tools/template.py $OPTS -f r-python.template > $VERSION/$TAG/Dockerfile
    fi

done
