load("//:bazel_extensions/expand_rpm_template.bzl", "RpmSpecFileProvider")

_script = """#!/bin/bash
set -e

echo "making tmp dir"
mktemp -d tmp
echo "rpmbuilding.."
rpmbuild -v --define='_topdir {top_dir}' --define='_tmppath ./tmp' -bb {spec_file}
"""

def _generate_rpm_impl(ctx):
    rpm_nvr = ctx.attr.rpm_spec[RpmSpecFileProvider].nvr
    rpm_file = ctx.actions.declare_file(rpm_nvr)
    rpm_dir = ctx.attr.rpm_dir.files.to_list()[0]

    rpm_spec = ctx.actions.declare_file("rpm.spec")
    ctx.actions.expand_template(
        template = ctx.file.rpm_spec,
        substitutions = {
            "{FILES}": "%{_sourcedir}/" + rpm_dir.short_path,
        },
        output = rpm_spec
    )

    script_file = ctx.actions.declare_file("script")
    ctx.actions.write(
        output = script_file,
        content = _script.format(
            top_dir = rpm_dir.path,
            spec_file = rpm_spec.path,
        ),
        is_executable = True,
    )

    ctx.actions.run(
        inputs = [rpm_dir, rpm_spec],
        outputs = [rpm_file],
        executable = script_file,
        mnemonic = "BuildRpm"
    )

    return [DefaultInfo(files = depset([rpm_file]))]

generate_rpm = rule(
    implementation = _generate_rpm_impl,
    attrs = {
        "rpm_dir": attr.label(mandatory = True, allow_single_file = True),
        "rpm_spec": attr.label(mandatory = True, allow_single_file = True, providers = [RpmSpecFileProvider]),
    }
)