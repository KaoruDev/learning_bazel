def _sum(ctx):
    print("label name: %s" % ctx.label.name)
    print("Package name: %s" % ctx.label.package)

    # For debugging, consider using `dir` to explore the existing fields.
    print("============================== Printing attributes and methods of ctx:")
    print(dir(ctx))  # prints all the fields and methods of ctx

    print("============================== Printing attributes and methods of ctx.attr:")
    print(dir(ctx.attr))  # prints all the attributes of the rule

sum = rule(
    implementation = _sum,
    attrs = {
        "number": attr.int(default = 1),
        "srcs": attr.label_list(),
        "deps": attr.label_list(),
    }
)