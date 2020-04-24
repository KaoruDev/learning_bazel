def _rename_impl(ctx):
    src = ctx.file.src
    outfilename = ctx.var.get("NEW_NAME", ctx.attr.new_name)
    new_out_file = ctx.actions.declare_file(outfilename)

    ctx.actions.run_shell(
        outputs = [new_out_file],
        inputs = [src],
        command = "echo {src}; echo {out}; cp -f {src} {out}".format(
            src = src.path,
            out = new_out_file.path
        )
    )

    runfiles = ctx.runfiles(files = [new_out_file])
    return DefaultInfo(runfiles=runfiles)

rename = rule(
    implementation = _rename_impl,
    attrs = {
        "new_name": attr.string(default = "default_name"),
        "src": attr.label(
            allow_single_file = True,
            mandatory = True,
        )
    }
)
