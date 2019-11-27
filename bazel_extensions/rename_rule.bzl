def _rename_impl(ctx):
    src = ctx.file.src
    ctx.expand_make_variables("new_name", ctx.attr.new_name, {})

    outfilename = ctx.var.get("new_name", "%s-tar" % ctx.label.name)
    new_out_file = ctx.actions.declare_file(ctx.attr.new_name)

    ctx.actions.run_shell(
        outputs = [new_out_file],
        inputs = [src],
        command = "echo {src}; echo {out}; find .; cp -f {src} {out}".format(
            src = src.path,
            out = new_out_file.path
        )
    )

    runfiles = ctx.runfiles(files = [new_out_file])
    return DefaultInfo(runfiles=runfiles)

rename = rule(
    implementation = _rename_impl,
    attrs = {
        "new_name": attr.string(default = ""),
        "src": attr.label(
            allow_single_file = True,
            mandatory = True,
        )
    }
)