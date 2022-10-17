#!/usr/bin/env python3

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

from argparse import ArgumentParser

from jinja2 import Environment, FileSystemLoader


def parse_opts():
    parser = ArgumentParser(prog="template")

    parser.add_argument(
        "-f",
        "--template-file",
        help="The Dockerfile template file path.",
        default="Dockerfile.template",
    )

    parser.add_argument(
        "-v",
        "--spark-version",
        help="The Spark version of Dockerfile.",
        default="3.3.0",
    )

    parser.add_argument(
        "-i",
        "--image",
        help="The base image tag of Dockerfile.",
        default="eclipse-temurin:11-jre-focal",
    )

    parser.add_argument(
        "-p",
        "--pyspark",
        action="store_true",
        help="Have PySpark support or not.",
    )

    parser.add_argument(
        "-r",
        "--sparkr",
        action="store_true",
        help="Have SparkR support or not.",
    )

    args, unknown = parser.parse_known_args()
    if unknown:
        parser.error("Unsupported arguments: %s" % " ".join(unknown))
    return args


def main():
    opts = parse_opts()
    env = Environment(loader=FileSystemLoader("./"))
    template = env.get_template(opts.template_file)
    print(
        template.render(
            BASE_IMAGE=opts.image,
            HAVE_PY=opts.pyspark,
            HAVE_R=opts.sparkr,
            SPARK_VERSION=opts.spark_version,
        )
    )


if __name__ == "__main__":
    main()
