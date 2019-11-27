RpmSpecFileProvider = provider("nvr")

def _expand_rpm_template_impl(ctx):
    files = []
#    for target in ctx.attr.data:
#        for file in target[DefaultInfo].files.to_list():
#            files.append("/%s" % file.path)

    rpm_version = ctx.var.get("RPM_VERSION", "1")

    subs = {
        "{VERSION}": rpm_version,
        "{SOURCE_URL}": "",
        "{PATCH_URL}": "",
        "{BUILD_REQUIRES}": "",
        "{DESCRIPTION}": "",
        "{PREP}": "",
        "{SETUP}": "",
        "{BUILD}": "",
        "{INSTALL}": "",
#        "{FILES}": "\n".join(files),
        "{LICENSE}": "",
        "{CHANGELOG}": "",
    }
    subs.update(ctx.attr.substitutions)

    ctx.actions.expand_template(
        template = ctx.file.input,
        substitutions = subs,
        output = ctx.outputs.output
    )

    nvr = "{name}-{version}-{release}.{arch}.rpm".format(
        name = ctx.outputs.output.basename,
        version = rpm_version,
        release = "1",
        arch = "noarch" # TODO(Kaoru) should we make this configurable?
    )

    return [
        DefaultInfo(files = depset(direct = [ctx.outputs.output])),
        RpmSpecFileProvider(nvr = nvr)
    ]

expand_rpm_template = rule(
    implementation = _expand_rpm_template_impl,
    attrs = {
        "input": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "substitutions": attr.string_dict(),
        "_version": attr.string(default = "{RPM_VERSION}"),
        "output": attr.output(
            doc = "The label name of the generated template."
        ),
#        "data": attr.label_list(default = [], allow_files = True)
    },
)