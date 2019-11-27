load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library")
load("@io_bazel_rules_scala//thrift:thrift.bzl", "thrift_library")
load("@io_bazel_rules_scala//twitter_scrooge:twitter_scrooge.bzl", "scrooge_scala_library")

load("//:bazel_extensions/demo_fortune_haiku.bzl", "haiku_fortune")

scala_library(
    name = "vehicles",
    srcs = glob(["src/main/scala/com/kaoruk/**/*.scala"]),
    deps = [
        "@global//:org_clapper_grizzled_slf4j_2_12",
        ":scrooge"
    ],
    visibility = ["//visibility:public"]
)

scala_library(
    name = "scrooge_jars",
    exports = [
        "@global//:com_twitter_finagle_core_2_12", # Adds Finagle classes to the classpath.
        "@global//:com_twitter_scrooge_core_2_12"
    ],
    visibility = ["//visibility:public"]
)

haiku_fortune(
    name = "haiku",
    srcs = glob(["src/main/resources/**/*"]),
)

thrift_library(
    name = "thrift",
    srcs = glob(["src/main/thrift/**/*.thrift"]),
)

# TODO - Figure out why the scrooge jar gets added to the binary script (it shouldn't)
scrooge_scala_library(
    name = "scrooge",
    visibility = ["//visibility:public"],
    deps = [
        ":thrift"
    ],
)
