_script = """#!/bin/bash

mkdir -p {top_dir}/SOURCES/{app_name} {top_dir}/BUILDROOT {top_dir}/RPMS {top_dir}/SPECS {top_dir}/BUILD

cp -r {app_dir}/* {top_dir}/SOURCES/{app_name}
"""

def _setup_dir_impl(ctx):
    top_dir = ctx.actions.declare_directory(ctx.attr.top_dir)

    # create RPM directories, need to export them too....hrmmm maybe i don't
    # I have to put some things in SOURCE/opt/tally/<name> others in /etc/systemd/system etc
    app_files = ctx.attr.app_dir[DefaultInfo].files.to_list()
    if len(app_files) != 1:
        fail("app_dir target's DefaultInfo may only have 1 directory, contained: %s" % len(app_files))

    app_dir = app_files[0]

    script = _script.format(
        top_dir = top_dir.path,
        app_name = ctx.attr.app_name,
        app_dir = app_dir.path,
    )

    ctx.actions.run_shell(
        outputs = [top_dir],
        inputs = [app_dir],
        command = script,
    )

    return [DefaultInfo(files = depset([top_dir]))]

setup_rpm_dirs = rule(
    implementation = _setup_dir_impl,
    attrs = {
        "top_dir": attr.string(default="top_dir"),
        "app_name": attr.string(mandatory = True),
        "app_dir": attr.label(mandatory = True, allow_files = True),
#       "systemd_config": attr.label_list(mandatory = True, allow_single_file = True),
    }
)