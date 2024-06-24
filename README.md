# Apache Spark Official Dockerfiles

## What is Apache Spark?

Spark is a unified analytics engine for large-scale data processing. It provides
high-level APIs in Scala, Java, Python, and R, and an optimized engine that
supports general computation graphs for data analysis. It also supports a
rich set of higher-level tools including Spark SQL for SQL and DataFrames,
pandas API on Spark for pandas workloads, MLlib for machine learning, GraphX for graph processing,
and Structured Streaming for stream processing.

https://spark.apache.org/

## Create a new version 

### Step 1 Add dockerfiles for a new version.

You can see [3.4.0 PR](https://github.com/apache/spark-docker/pull/33) as reference.

- 1.1 Add gpg key to [tools/template.py](https://github.com/apache/spark-docker/blob/master/tools/template.py#L24)

    This gpg key will be used by Dockerfiles (such as [3.4.0](https://github.com/apache/spark-docker/blob/04e85239a8fcc9b3dcfe146bc144ee2b981f8f42/3.4.0/scala2.12-java11-ubuntu/Dockerfile#L41)) to verify the signature of the Apache Spark tarball.

- 1.2 Add image build workflow (such as [3.4.0 yaml](https://github.com/apache/spark-docker/blob/04e85239a8fcc9b3dcfe146bc144ee2b981f8f42/.github/workflows/build_3.4.0.yaml))

    This file will be used by GitHub Actions to build the Docker image when you submit the PR to make sure dockerfiles are correct and pass all tests (build/standalone/kubernetes).

- 1.3 Using `./add-dockerfiles.sh [version]` to add Dockerfiles.

    You will get a new directory with the Dockerfiles for the specified version.

- 1.4 Add version and tag info to versions.json, publish.yml and test.yml.

    This version file will be used by image build workflow (such as [3.4.0](https://github.com/apache/spark-docker/commit/47c357a52625f482b8b0cb831ccb8c9df523affd) reference) and docker official image.

### Step 2. Publish apache/spark Images.

Click [Publish (Java 17 only)](https://github.com/apache/spark-docker/actions/workflows/publish-java17.yaml) (such as 4.x) or [Publish](https://github.com/apache/spark-docker/actions/workflows/publish.yml) (such as 3.x) to publish images.

After this, the [apache/spark](https://hub.docker.com/r/apache/spark) docker images will be published.


### Step 3. Publish spark Docker Official Images.

Submit the PR to [docker-library/official-images](https://github.com/docker-library/official-images/), see (link)[https://github.com/docker-library/official-images/pull/15363] as reference.

You can type `tools/manifest.py manifest` to generate the content.

After this, the [spark](https://hub.docker.com/_/spark) docker images will be published.

## About images

|               | Apache Spark Image                                     | Spark Docker Official Image                            |
|---------------|--------------------------------------------------------|--------------------------------------------------------|
| Name          | apache/spark                                           | spark                                                  |
| Maintenance   | Reviewed, published by Apache Spark community          | Reviewed, published and maintained by Docker community |
| Update policy | Only build and push once when specific version release | Actively rebuild for updates and security fixes        |
| Link          | https://hub.docker.com/r/apache/spark                  | https://hub.docker.com/_/spark                         |
| source        | [apache/spark-docker](https://github.com/apache/spark-docker)                                           | [apache/spark-docker](https://github.com/apache/spark-docker) and [docker-library/official-images](https://github.com/docker-library/official-images/blob/master/library/spark)     |

We recommend using [Spark Docker Official Image](https://hub.docker.com/_/spark), the [Apache Spark Image](https://hub.docker.com/r/apache/spark) are provided in case of delays in the review process by Docker community.

## About this repository

This repository contains the Dockerfiles used to build the Apache Spark Docker Image.

See more in [SPARK-40513: SPIP: Support Docker Official Image for Spark](https://issues.apache.org/jira/browse/SPARK-40513).
