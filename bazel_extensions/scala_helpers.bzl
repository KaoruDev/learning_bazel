load("@io_bazel_rules_scala//scala:scala_cross_version.bzl", _mvn_artifact = "scala_mvn_artifact", _extract_major = "extract_major_version")

SCALA_VERSION = "2.12.8"
SCALA_MAJOR_VERSION = _extract_major(SCALA_VERSION)

def scala_dep(artifact_name):
    return _mvn_artifact(artifact_name, SCALA_MAJOR_VERSION)
