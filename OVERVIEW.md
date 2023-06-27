# What is Apache Spark™?

Apache Spark™ is a multi-language engine for executing data engineering, data science, and machine learning on single-node machines or clusters. It provides high-level APIs in Scala, Java, Python, and R, and an optimized engine that supports general computation graphs for data analysis. It also supports a rich set of higher-level tools including Spark SQL for SQL and DataFrames, pandas API on Spark for pandas workloads, MLlib for machine learning, GraphX for graph processing, and Structured Streaming for stream processing.

https://spark.apache.org/

## Online Documentation

You can find the latest Spark documentation, including a programming guide, on the [project web page](https://spark.apache.org/documentation.html). This README file only contains basic setup instructions.

## Interactive Scala Shell

The easiest way to start using Spark is through the Scala shell:

```
docker run -it apache/spark /opt/spark/bin/spark-shell
```

Try the following command, which should return 1,000,000,000:

```
scala> spark.range(1000 * 1000 * 1000).count()
```

## Interactive Python Shell

The easiest way to start using PySpark is through the Python shell:

```
docker run -it apache/spark /opt/spark/bin/pyspark
```

And run the following command, which should also return 1,000,000,000:

```
>>> spark.range(1000 * 1000 * 1000).count()
```

## Interactive R Shell

The easiest way to start using R on Spark is through the R shell:

```
docker run -it apache/spark:r /opt/spark/bin/sparkR
```

## Running Spark on Kubernetes

https://spark.apache.org/docs/latest/running-on-kubernetes.html

## Supported tags and respective Dockerfile links

Currently, the `apache/spark` docker image supports 4 types for each version:

Such as for v3.4.0:
- [3.4.0-scala2.12-java11-python3-ubuntu, 3.4.0-python3, 3.4.0, python3, latest](https://github.com/apache/spark-docker/tree/fe05e38f0ffad271edccd6ae40a77d5f14f3eef7/3.4.0/scala2.12-java11-python3-ubuntu)
- [3.4.0-scala2.12-java11-r-ubuntu, 3.4.0-r, r](https://github.com/apache/spark-docker/tree/fe05e38f0ffad271edccd6ae40a77d5f14f3eef7/3.4.0/scala2.12-java11-r-ubuntu)
- [3.4.0-scala2.12-java11-ubuntu, 3.4.0-scala, scala](https://github.com/apache/spark-docker/tree/fe05e38f0ffad271edccd6ae40a77d5f14f3eef7/3.4.0/scala2.12-java11-ubuntu)
- [3.4.0-scala2.12-java11-python3-r-ubuntu](https://github.com/apache/spark-docker/tree/fe05e38f0ffad271edccd6ae40a77d5f14f3eef7/3.4.0/scala2.12-java11-python3-r-ubuntu)

## Environment Variable

The environment variables of entrypoint.sh are listed below:

| Environment Variable | Meaning |
|----------------------|-----------|
| SPARK_EXTRA_CLASSPATH | The extra path to be added to the classpath, see also in https://spark.apache.org/docs/latest/running-on-kubernetes.html#dependency-management |
| PYSPARK_PYTHON | Python binary executable to use for PySpark in both driver and workers (default is python3 if available, otherwise python). Property spark.pyspark.python take precedence if it is set |
| PYSPARK_DRIVER_PYTHON | Python binary executable to use for PySpark in driver only (default is PYSPARK_PYTHON). Property spark.pyspark.driver.python take precedence if it is set |
| SPARK_DIST_CLASSPATH | Distribution-defined classpath to add to processes |
| SPARK_DRIVER_BIND_ADDRESS | Hostname or IP address where to bind listening sockets. See also `spark.driver.bindAddress` |
| SPARK_EXECUTOR_JAVA_OPTS | The Java opts of Spark Executor |
| SPARK_APPLICATION_ID | A unique identifier for the Spark application |
| SPARK_EXECUTOR_POD_IP | The Pod IP address of spark executor |
| SPARK_RESOURCE_PROFILE_ID | The resource profile ID |
| SPARK_EXECUTOR_POD_NAME | The executor pod name |
| SPARK_CONF_DIR |  Alternate conf dir. (Default: ${SPARK_HOME}/conf) |
| SPARK_EXECUTOR_CORES | Number of cores for the executors (Default: 1) |
| SPARK_EXECUTOR_MEMORY | Memory per Executor (e.g. 1000M, 2G) (Default: 1G) |
| SPARK_DRIVER_MEMORY | Memory for Driver (e.g. 1000M, 2G) (Default: 1G) |

See also in https://spark.apache.org/docs/latest/configuration.html and https://spark.apache.org/docs/latest/running-on-kubernetes.html

