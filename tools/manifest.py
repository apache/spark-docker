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
from statistics import mode


def parse_opts():
    parser = ArgumentParser(prog="manifest.py")

    parser.add_argument(
        dest="mode",
        choices=["tags"],
        type=str,
        help="The path to specific dockerfile",
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


if __name__ == "__main__":
    main()
