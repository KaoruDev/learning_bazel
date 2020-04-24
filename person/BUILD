load("@io_bazel_rules_scala//scala:scala.bzl", "scala_binary", "scala_test")
load("//:bazel_extensions/demo_count_file_type_aspect.bzl", "file_count_rule")
load("//:bazel_extensions/expand_rpm_template.bzl", "expand_rpm_template")
load("//:bazel_extensions/demo_define_variable.bzl", "shout")
load("//:bazel_extensions/group_java_files.bzl", "group_java_files")
load("//:bazel_extensions/rename_rule.bzl", "rename")
load("//bazel_extensions/rpms:setup.bzl", "setup_rpm_dirs")
load("//bazel_extensions/rpms:generate.bzl", "generate_rpm")
load("//:bazel_extensions/rpm.bzl", "package_rpm")

scala_binary(
    name = "person",
    srcs = glob(["src/main/scala/com/kaoruk/**/*"]),
    main_class = "com.kaoruk.Runner",
    deps = [
        "//pets",
        "//vehicles",
        "@global//:ch_qos_logback_logback_classic",
        "@global//:ch_qos_logback_logback_core",
        "@global//:org_clapper_grizzled_slf4j_2_12",
    ]
)

scala_test(
    name = "test",
    data = ["src/test/resources/hello_world_test.txt"],
    srcs = glob(["src/test/scala/com/kaoruk/**/*"]),
    deps = [
    ]
)

file_count_rule(
    name = "count",
    deps = [":person"],
    extension = "*"
)

expand_rpm_template(
    name = "rpm_template",
    input = "//:bazel_extensions/templates/rpm_spec.template",
    substitutions = {
        "{NAME}": "Person",
        "{RELEASE}": "1",
        "{SUMMARY}": "Foo bar summary",
        "{LICENSE}": "Properitery",
        "{URL}": "https://www.meettally.com",
    },
    output = "person.spec",
#    data = [":package_jar"]
)

group_java_files(
    name = "package_jar",
    src = ":person",
    app_name = "person_app"
)

shout(
    name = "shout",
)

setup_rpm_dirs(
    name = "setup_rpm_dirs",
    app_name = "person",
    app_dir= ":package_jar",
)

package_rpm(
    name = "rpm",
    server_name = "person",
    java_package = ":person"
)

genrule(
  name = "gentest",
  cmd = "printenv > $@",
  outs = ["envs.txt"]
)

rename(
  name = "rename",
  src = ":gentest",
)
