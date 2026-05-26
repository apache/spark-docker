# Security policy

## Reporting a vulnerability

To report a security vulnerability in apache/spark-docker,
follow the ASF security process at
<https://www.apache.org/security/>. Reports can be sent privately
to security@apache.org or to private@spark.apache.org.

## Threat model

This repository builds the official container images for
Apache Spark. Apache Spark's security guidance for operators
— including the trust boundaries the published images
inherit — is documented at:

<https://spark.apache.org/docs/latest/security.html>

That document covers authentication, encryption, access
control, Kerberos integration, trust boundaries, environmental
assumptions, security properties provided and not provided,
and downstream operator responsibilities.

Automated security scanning agents should consult that
document for the project's in-scope / out-of-scope
declarations before reporting issues.
