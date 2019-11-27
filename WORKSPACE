workspace(name = "learning_bazel")
RULES_SCALA_VERSION="177e2eeb665899a0f116d20876c8c77b4ef27b98" # update this as needed
RULES_SCALA_SHA="86398dd83575fe25648c395bea90b87b8400fbbbc69605b7ec7d7f4e17e61935"

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

load("@io_bazel_rules_scala//twitter_scrooge:twitter_scrooge.bzl", "twitter_scrooge")
twitter_scrooge(SCALA_VERSION)

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

RULES_JVM_EXTERNAL_TAG = "2.7"
RULES_JVM_EXTERNAL_SHA = "f04b1466a00a2845106801e0c5cec96841f49ea4e7d1df88dc8e4bf31523df74"

http_archive(
    name = "rules_jvm_external",
    strip_prefix = "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
    sha256 = RULES_JVM_EXTERNAL_SHA,
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % RULES_JVM_EXTERNAL_TAG,
)

load("@rules_jvm_external//:defs.bzl", "maven_install")
load("@rules_jvm_external//:specs.bzl", "maven")


maven_install(
    name = "global",
    artifacts = [
        "joda-time:joda-time:2.10.1",
        "ch.qos.logback:logback-classic:1.2.3",
        "ch.qos.logback:logback-core:1.2.3",
        scala_dep("org.clapper:grizzled-slf4j:1.3.4"),
        scala_dep("com.twitter:finagle-core:18.6.0"),
        scala_dep("com.twitter:scrooge-core:18.6.0"),
    ],
    repositories = [
        "https://repo1.maven.org/maven2",
        "https://maven.google.com",
        "https://jcenter.bintray.com",
        "https://oss.sonatype.org/content/repositories/releases/",
    ],
    maven_install_json = "//:bazel_extensions/dependency_snapshots/global_install.json",
    fetch_sources = True,
)
load("@global//:defs.bzl", pinned_global_install = "pinned_maven_install")
pinned_global_install()

bind(
    name = "io_bazel_rules_scala/dependency/thrift/scrooge_core",
    actual = "//vehicles:scrooge_jars"
)

RULES_PKG_VERSION = "0.2.4"
RULES_PKG_SHA = "4ba8f4ab0ff85f2484287ab06c0d871dcb31cc54d439457d28fd4ae14b18450a"

#http_archive(
#    name = "rules_pkg",
#    sha256 = RULES_PKG_SHA,
#    url = "https://github.com/bazelbuild/rules_pkg/releases/download/{version}/rules_pkg-{version}.tar.gz".format(
#        version = RULES_PKG_VERSION
#    )
#)

local_repository(
    name = "rules_pkg",
    path = "../rules_pkg/pkg",
)
load("@rules_pkg//:deps.bzl", "rules_pkg_dependencies")
rules_pkg_dependencies()
