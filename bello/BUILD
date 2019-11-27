load("@rules_pkg//:pkg.bzl", "pkg_tar")
load("@rules_pkg//:rpm.bzl", "pkg_rpm")
load("//:bazel_extensions/expand_rpm_template.bzl", "expand_rpm_template")

filegroup(
    name = "bello",
    srcs = [
        "src/main.sh"
    ],
)

pkg_tar(
    name = "tar",
    srcs = [":bello"],
    extension = "tar.gz",
    mode = "0755",
)

expand_rpm_template(
    name = "rpm_template",
    input = "//:bazel_extensions/templates/rpm_spec.template",
    substitutions = {
        "{NAME}": "Person_App",
        "{RELEASE}": "1",
        "{SUMMARY}": "Foo bar summary",
        "{LICENSE}": "properitery",
        "{URL}": "https://www.meettally.com",
    },
    output = "person_rpm.spec",
    data = [":bello"]
)

pkg_rpm(
    name = "rpm",
    spec_file = ":rpm_template",
    version = "1",
    release = "1",
    data = [":bello"],
    architecture = "x86_64",
    target_platform = "x86_64-linux"
)

