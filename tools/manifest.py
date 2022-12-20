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
import json
import subprocess


def run_cmd(cmd):
    if isinstance(cmd, list):
        return subprocess.check_output(cmd).decode("utf-8")
    else:
        return subprocess.check_output(cmd.split(" ")).decode("utf-8")


def generate_manifest(versions):
    output = (
        "Maintainers: Apache Spark Developers <dev@spark.apache.org> (@ApacheSpark)\n"
        "GitRepo: https://github.com/apache/spark-docker.git\n\n"
    )
    git_commit = run_cmd("git rev-parse HEAD").replace("\n", "")
    content = (
        "Tags: %s\n"
        "Architectures: amd64, arm64v8\n"
        "GitCommit: %s\n"
        "Directory: ./%s\n\n"
    )
    for version in versions:
        tags = ", ".join(version["tags"])
        path = version["path"]
        output += content % (tags, git_commit, path)
    return output


def parse_opts():
    parser = ArgumentParser(prog="manifest.py")

    parser.add_argument(
        dest="mode",
        choices=["tags", "manifest"],
        type=str,
        help="The print mode of script",
    )

    parser.add_argument(
        "-p",
        "--path",
        type=str,
        help="The path to specific dockerfile",
    )

    parser.add_argument(
        "-i",
        "--image",
        type=str,
        help="The complete image registry url (such as `apache/spark`)",
    )

    parser.add_argument(
        "-f",
        "--file",
        type=str,
        default="versions.json",
        help="The version json of image meta.",
    )

    args, unknown = parser.parse_known_args()
    if unknown:
        parser.error("Unsupported arguments: %s" % " ".join(unknown))
    return args


def main():
    opts = parse_opts()
    filepath = opts.path
    image = opts.image
    mode = opts.mode
    version_file = opts.file

    if mode == "tags":
        tags = []
        with open(version_file, "r") as f:
            versions = json.load(f).get("versions")
            # Filter the specific dockerfile
            versions = list(filter(lambda x: x.get("path") == filepath, versions))
            # Get matched version's tags
            tags = versions[0]["tags"] if versions else []
        print(",".join(["%s:%s" % (image, t) for t in tags]))
    elif mode == "manifest":
        with open(version_file, "r") as f:
            versions = json.load(f).get("versions")
            print(generate_manifest(versions))


if __name__ == "__main__":
    main()
