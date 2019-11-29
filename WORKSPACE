workspace(name = "learning_bazel")
RULES_SCALA_VERSION="e56840204179b1f668ba2f6f8f23f28d00d96794" # update this as needed
RULES_SCALA_SHA="0fbe2387eb59c73278a192f797327c0895d412299c8e2f00867d655770796edc"

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "io_bazel_rules_scala",
    strip_prefix = "rules_scala-%s" % RULES_SCALA_VERSION,
    sha256 = RULES_SCALA_SHA,
    type = "zip",
    url = "https://github.com/bazelbuild/rules_scala/archive/%s.zip" % RULES_SCALA_VERSION,
)

load("@io_bazel_rules_scala//scala:toolchains.bzl", "scala_register_toolchains")
scala_register_toolchains()

load("@io_bazel_rules_scala//scala:scala.bzl", "scala_repositories")
load("//:bazel_extensions/scala_helpers.bzl", "SCALA_MAJOR_VERSION", "SCALA_VERSION", "scala_dep")
scala_repositories((
    SCALA_VERSION,
    {
       "scala_compiler": "f34e9119f45abd41e85b9e121ba19dd9288b3b4af7f7047e86dc70236708d170",
       "scala_library": "321fb55685635c931eba4bc0d7668349da3f2c09aee2de93a70566066ff25c28",
       "scala_reflect": "4d6405395c4599ce04cea08ba082339e3e42135de9aae2923c9f5367e957315a"
    }
))

protobuf_version="09745575a923640154bcf307fba8aedff47f240a"
protobuf_version_sha256="416212e14481cff8fd4849b1c1c1200a7f34808a54377e22d7447efdf54ad758"

http_archive(
    name = "com_google_protobuf",
    url = "https://github.com/protocolbuffers/protobuf/archive/%s.tar.gz" % protobuf_version,
    strip_prefix = "protobuf-%s" % protobuf_version,
    sha256 = protobuf_version_sha256,
)

# bazel-skylib 0.8.0 released 2019.03.20 (https://github.com/bazelbuild/bazel-skylib/releases/tag/0.8.0)
skylib_version = "0.8.0"
http_archive(
    name = "bazel_skylib",
    type = "tar.gz",
    url = "https://github.com/bazelbuild/bazel-skylib/releases/download/{}/bazel-skylib.{}.tar.gz".format (skylib_version, skylib_version),
    sha256 = "2ef429f5d7ce7111263289644d233707dba35e39696377ebab8b0bc701f7818e",
)

RULES_JVM_EXTERNAL_TAG = "2.10"
RULES_JVM_EXTERNAL_SHA = "1bbf2e48d07686707dd85357e9a94da775e1dbd7c464272b3664283c9c716d26"

http_archive(
    name = "rules_jvm_external",
    strip_prefix = "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
    sha256 = RULES_JVM_EXTERNAL_SHA,
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % RULES_JVM_EXTERNAL_TAG,
)

load("@rules_jvm_external//:defs.bzl", "maven_install")

load("//:bazel_extensions/global.bzl",
    GLOBAL_ARTIFACTS = "ARTIFACTS",
    GLOBAL_REPOSITORIES = "REPOSITORIES",
)

maven_install(
    name = "global",
    artifacts = GLOBAL_ARTIFACTS,
    repositories = GLOBAL_REPOSITORIES,
    maven_install_json = "//:bazel_extensions/dependency_snapshots/global_install.json",
    fetch_sources = True,
)

load("@global//:defs.bzl", pinned_global_install = "pinned_maven_install")
pinned_global_install()
