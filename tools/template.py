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

GPG_KEY_DICT = {
    # issuer "maxgekk@apache.org"
    "3.3.0": "80FB8EBE8EBA68504989703491B5DC815DBF10D3",
    # issuer "yumwang@apache.org"
    "3.3.1": "86727D43E73A415F67A0B1A14E68B3E6CD473653",
    # issuer "viirya@apache.org"
    "3.3.2": "C56349D886F2B01F8CAE794C653C2301FEA493EE",
    # issuer "yumwang@apache.org"
    "3.3.3": "F6468A4FF8377B4F1C07BC2AA077F928A0BF68D8",
    # issuer "xinrong@apache.org"
    "3.4.0": "CC68B3D16FE33A766705160BA7E57908C7A4E1B1",
    # issuer "dongjoon@apache.org"
    "3.4.1": "F28C9C925C188C35E345614DEDA00CE834F0FC5C",
    # issuer "dongjoon@apache.org"
    "3.4.2": "F28C9C925C188C35E345614DEDA00CE834F0FC5C",
    # issuer "dongjoon@apache.org"
    "3.4.3": "F28C9C925C188C35E345614DEDA00CE834F0FC5C",
    # issuer "dongjoon@apache.org"
    "3.4.4": "F28C9C925C188C35E345614DEDA00CE834F0FC5C",
    # issuer "liyuanjian@apache.org"
    "3.5.0": "FC3AE3A7EAA1BAC98770840E7E1ABCC53AAA2216",
    # issuer "kabhwan@apache.org"
    "3.5.1": "FD3E84942E5E6106235A1D25BD356A9F8740E4FF",
    # issuer "yao@apache.org"
    "3.5.2": "D76E23B9F11B5BF6864613C4F7051850A0AF904D",
    # issuer "haejoon@apache.org"
    "3.5.3": "0A2D660358B6F6F8071FD16F6606986CF5A8447C",
    # issuer "yangjie01@apache.org"
    "3.5.4": "19F745C40A0E550420BB2C522541488DA93FE4B4",
    # issuer "dongjoon@apache.org"
    "3.5.5": "F28C9C925C188C35E345614DEDA00CE834F0FC5C",
    # issuer "gurwls223@apache.org"
    "3.5.6": "0FE4571297AB84440673665669600C8338F65970",
    # issuer "wenchen@apache.org"
    "4.0.0-preview1": "4DC9676CEF9A83E98FCA02784D6620843CD87F5A",
    # issuer "dongjoon@apache.org"
    "4.0.0-preview2": "F28C9C925C188C35E345614DEDA00CE834F0FC5C",
    # issuer "wenchen@apache.org"
    "4.0.0": "4DC9676CEF9A83E98FCA02784D6620843CD87F5A"
}


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
        "-j",
        "--java-version",
        help="Java version of Dockerfile.",
        default="11",
    )

    parser.add_argument(
        "-s",
        "--scala-version",
        help="The Spark version of Dockerfile.",
        default="2.12",
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
            SPARK_GPG_KEY=GPG_KEY_DICT.get(opts.spark_version),
            JAVA_VERSION=opts.java_version,
            SCALA_VERSION=opts.scala_version,
        )
    )


if __name__ == "__main__":
    main()
