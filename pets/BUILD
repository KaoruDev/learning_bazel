load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library")
load("//:bazel_extensions/demo_sum_rule.bzl", "sum")
load("//:bazel_extensions/demo_to_upper_case.bzl", "convert_to_uppercase")
load("//:bazel_extensions/demo_md5_declare_files.bzl", "md5_sum")

scala_library(
    name = "pets",
    srcs = glob(["src/main/scala/com/kaoruk/**/*.scala"]),
    deps = [
        "@global//:org_clapper_grizzled_slf4j_2_12",
        "@global//:joda_time_joda_time",
    ],
    visibility = ["//visibility:public"]
)

sum(name = "sum_it")

sum(
    name = "sum_twice",
    srcs = [
        ":pets"
    ],
    deps = [
        ":sum_it"
    ],
)

# This is a generated file, thus the file doesn't exist in git, it exists under bazel-genfiles/pets/src/main/resources
# bazel-genfiles is a symlink
convert_to_uppercase(
    name = "convert",
    input = "src/main/resources/pet_names.txt",
    output = "src/main/resources/pet_names_cap.txt"
)

# Similarly, creates a file and places it in bazel-genfiles/pets. outs may not cross package boundaries.
# Path is relative to package.
# bazel build //pets:hello to run this
genrule(
    name = "hello",
    outs = ["demo.txt"], # this is the attribute whether we create a file or not
    srcs = [":convert"],
    cmd = "echo 'This is the src file: $(SRCS)' > $@" # $@ is the output files, $(SRCS) is the input files
)

convert_to_uppercase(
    name = "uppercase_hello",
    input = ":hello",
    output = "demo_cat.txt"
)

md5_sum(
    name = "md5_hello",
    src = ":hello"
)
