_rpmbuild_script = """mv {rpm_spec_file_list} {rpm_work_dir}/rpmbuild/BUILD
mv {spec_file} {rpm_work_dir}

WORKDIR_ROOT=$PWD

cd {rpm_work_dir}

echo "making tmp dir"
mkdir tmp rpmbuild/RPMS

echo "rpmbuilding..."
rpmbuild -v \
    --define="_topdir $(pwd)/rpmbuild" \
    --define="_tmppath $(pwd)/tmp" \
    --target=x86_64-linux \
    -bb $(basename {spec_file})

echo "Inside of RPMS:"
find rpmbuild/RPMS

cd $WORKDIR_ROOT

cp {rpm_work_dir}/rpmbuild/RPMS/x86_64/person-1-1.x86_64.rpm {rpm_file_path}
"""

def _package_rpm_impl(ctx):
    server_name = ctx.attr.server_name
    work_dir = ctx.actions.declare_directory("%s_workdir" % server_name)
    workspace_name = ctx.workspace_name

    systemd_file = ctx.actions.declare_file("%s.service" % server_name)

    systemd_exectuable = "/opt/tally/{server_name}/scripts/{controller_script_name}".format(
        server_name = server_name,
        controller_script_name = ctx.file.controller_script.basename,
    )

    ctx.actions.expand_template(
        template = ctx.file.systemd_template,
        output = systemd_file,
        substitutions = {
            "{DESCRIPTION}": "Demo package to learn bazel and RPMs",
            "{START_CMD}": "%s start" % systemd_exectuable,
            "{STOP_CMD}": "%s stop" % systemd_exectuable,
            "{RESTART_CMD}": "%s restart" % systemd_exectuable,
        },
    )

    java_runfiles = []
    java_runfile_paths = []
    java_runfile_short_paths = []
    dest_rpm_root_dir = "/opt/tally/{server_name}/{server_name}.runfiles".format(server_name = server_name)

    for file in ctx.attr.java_package[DefaultInfo].default_runfiles.files.to_list():
        java_runfiles.append(file)
        java_runfile_paths.append(file.path)

        short_path = file.short_path

        if short_path.startswith("../"):
            java_runfile_short_paths.append(short_path.replace("..", dest_rpm_root_dir, 1))
        else:
            java_runfile_short_paths.append("%s/%s/%s" % (dest_rpm_root_dir, workspace_name, short_path))

    rpm_spec_file_list = ctx.actions.declare_file("rpm_spec_file_list")
    ctx.actions.run(
        mnemonic = "JavaFileSorter",
        inputs = java_runfiles + [
            systemd_file,
            ctx.file.controller_script,
        ],
        outputs = [work_dir, rpm_spec_file_list],
        arguments = java_runfile_paths,
        executable = ctx.file._sort_script,
        env = {
            "BIN_DIR": ctx.bin_dir.path,
            "SERVER_NAME": server_name,
            "WORKDIR": work_dir.path,
            "WORKSPACE_NAME": workspace_name,
            "EXTERNAL_JAR_PATTERN": "^.*external/(.*)/.*\.jar",
            "TARGET_RUNTIME_DEP_PATTERN": "bin\/([a-zA-Z0-9\/_-]*)\/.*",
            "SHELL_SCRIPT_PATTERN": "\/%s$" % ctx.attr.java_package.label.name,
            "IGNORE_PATTERN": ".*\/local_jdk\/",
            "RPM_SPEC_FILE_PATH": rpm_spec_file_list.path,
            "SYSTEMD_UNIT_FILE": systemd_file.path,
            "CONTROL_SCRIPT": ctx.file.controller_script.path,
        }
    )

    rpm_version = ctx.var.get("RPM_VERSION", "1")
    rpm_release = ctx.var.get("RPM_RELEASE", "1")

    spec_file = ctx.actions.declare_file("%s.spec" % ctx.attr.server_name)

    ctx.actions.expand_template(
        template = ctx.file.rpm_spec_file,
        substitutions = {
            "{NAME}": server_name,
            "{VERSION}": rpm_version,
            "{RELEASE}": rpm_release,
            "{SUMMARY}": "Demo package to learn bazel and RPMs",
            "{WORKDIR}": work_dir.path,
            "{SERVER_NAME}": server_name,
            "{FILES_DIRECTIVE_LIST_PATH}": rpm_spec_file_list.basename,
        },
        output = spec_file
    )

    nvr = "%s-%s-%s.x86_64.rpm" % (server_name, rpm_version, rpm_release)
    rpm_file = ctx.actions.declare_file(nvr)
    rpmbuild_script = ctx.actions.declare_file("rpmbuild_script")

    ctx.actions.write(
        output = rpmbuild_script,
        content = _rpmbuild_script.format(
            rpm_work_dir = work_dir.path,
            spec_file = spec_file.path,
            rpm_spec_file_list = rpm_spec_file_list.path,
            rpm_file_path = rpm_file.path,
        ),
        is_executable = True,
    )

    ctx.actions.run(
        mnemonic = "PackageRPM",
        inputs = [work_dir, spec_file, rpm_spec_file_list, rpmbuild_script],
        outputs = [rpm_file],
        executable = rpmbuild_script,
    )

    return [DefaultInfo(files = depset([
        rpm_spec_file_list,
        work_dir,
        spec_file,
        rpm_file,
    ]))]

package_rpm = rule(
    implementation = _package_rpm_impl,
    attrs = {
        "server_name": attr.string(mandatory = True),
        "java_package": attr.label(mandatory = True, providers = [JavaInfo]),
        "rpm_spec_file": attr.label(
            allow_single_file = True,
            default = Label("//bazel_extensions/rpms2:rpm_spec.template")
        ),
        "_sort_script": attr.label(
            allow_single_file = True,
            default = Label("//bazel_extensions/rpms2:rpmbuild.sh")
        ),
        "systemd_template": attr.label(default = Label("//bazel_extensions/shell:systemd_service.template"), allow_single_file = True),
        "controller_script": attr.label(default = Label("//bazel_extensions/shell:controller.sh"), allow_single_file = True),
    }
)