
_script_template = """\
#!/bin/bash
RUNFILE_DIR="{app_dir}/{target_name}.runfiles"
TARGET_DIR="$RUNFILE_DIR/{workspace_name}"
EXTERNAL_JAR_PATTERN="^.*external/(.*)/.*\.jar"
TARGET_RUNTIME_DEP_PATTERN="bin\/([a-zA-Z0-9\/_-]*)\/.*"
SHELL_SCRIPT_PATTERN="\/{target_name}$"
IGNORE_PATTERN=".*\/local_jdk\/"

for RUNFILE in "$@"
do
    if [[ $RUNFILE =~ $IGNORE_PATTERN ]]; then
        echo "Ignoring: $RUNFILE" > /dev/null
    elif [[ $RUNFILE =~ $EXTERNAL_JAR_PATTERN ]]; then
        JAR_DIR="$RUNFILE_DIR/${{BASH_REMATCH[1]}}"
        mkdir -p $JAR_DIR
        mv $RUNFILE $JAR_DIR
    elif [[ $RUNFILE =~ $SHELL_SCRIPT_PATTERN ]]; then
        mv $RUNFILE {app_dir}
    elif [[ $RUNFILE =~ $TARGET_RUNTIME_DEP_PATTERN ]]; then
        PACKAGE_DIR="$TARGET_DIR/${{BASH_REMATCH[1]}}"
        mkdir -p $PACKAGE_DIR
        mv $RUNFILE $PACKAGE_DIR
    else
        echo "[IGNORING] - FAILED TO MATCH $RUNFILE"
    fi
done
"""

def _group_java_files_impl(ctx):
    src_runfiles = []
    src_runfile_paths = []
    src_target = ctx.attr.src

    for file in src_target[DefaultInfo].default_runfiles.files.to_list():
        src_runfiles.append(file)
        src_runfile_paths.append(file.path)

    target_name = src_target.label.name
    workspace_name = src_target.label.workspace_name

    if not workspace_name:
        workspace_name = ctx.workspace_name

    app_dir = ctx.actions.declare_directory(ctx.attr.app_name)

    script_file = ctx.actions.declare_file("partitioner.sh")
    script_content = _script_template.format(
        app_dir = app_dir.path,
        target_name = target_name,
        workspace_name = workspace_name,
    )
    ctx.actions.write(script_file, script_content, is_executable = True)

    ctx.actions.run(
        inputs = src_runfiles,
        outputs = [app_dir],
        arguments = src_runfile_paths,
        executable = script_file
    )

    output_depset = depset(direct = [app_dir])
    return [DefaultInfo(files = output_depset)]

group_java_files = rule(
    implementation = _group_java_files_impl,
    attrs = {
        "src": attr.label(mandatory = True),
        "app_name": attr.string(mandatory = True, doc = "Name of the application.")
    },
)