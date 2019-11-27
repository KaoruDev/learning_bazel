
def _md5_convert(ctx):
    src = ctx.file.src
    tmp = ctx.actions.declare_file("hooo_ha")
    work_dir = ctx.actions.declare_directory("app")

    # Compute the hash
    out = ctx.outputs.text
    ctx.actions.run_shell(
        outputs = [out, tmp, work_dir],
        inputs = [src],
        command = "find . && md5sum < {src} > {out} && echo 'FOOBAR' > {tmp} && cp {tmp} {dir}".format(
            src = src.path,
            out = out.path,
            tmp = tmp.path,
            dir = work_dir.path,
        )
    )

    return [OutputGroupInfo(work_dir = [work_dir])]


md5_sum = rule(
   implementation = _md5_convert,
   attrs = {
       "src": attr.label(mandatory = True, allow_single_file = True),
   },
   outputs = {"text": "%{name}.txt"},
)