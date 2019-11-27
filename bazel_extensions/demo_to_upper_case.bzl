def _convert_to_uppercase_impl(ctx):
    # Both the input and output files are specified by the BUILD file.
    in_file = ctx.file.input
    out_file = ctx.outputs.output
    ctx.actions.run_shell(
        outputs = [out_file],
        inputs = [in_file],
        arguments = [in_file.path, out_file.path],
        command = "tr '[:lower:]' '[:upper:]' < \"$1\" > \"$2\"",
    )
    # No need to return anything telling Bazel to build `out_file` when
    # building this target -- It's implied because the output is declared
    # as an attribute rather than with `declare_file()`.

convert_to_uppercase = rule(
    implementation = _convert_to_uppercase_impl,
    attrs = {
        "input": attr.label(
            allow_single_file = True,
            mandatory = True,
            doc = "The file to transform",
        ),
        "output": attr.output(doc = "The generated file"), # This create a file
    },
    doc = "Transforms a text file by changing its characters to uppercase.",
)