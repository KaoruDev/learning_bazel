def _shout_define_var(ctx):
    ctx.expand_make_variables("some_var", ctx.attr.some_var, {})
    print("found var some_var: %s" % ctx.var.get("some_var", "no key!"))

shout = rule(
    implementation = _shout_define_var,
    attrs = {
        "some_var": attr.string(default = "{SOME_VAR}")
    }
)