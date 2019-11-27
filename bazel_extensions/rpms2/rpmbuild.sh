#!/bin/bash

# ENVs
# PACAKGE_DIR_BASENAME - the name of the directory
# PACKAGE_DIR_PATH - the directory where everything should go to
# SERVER_NAME - name of the server we're packaging

#RUNFILE_DIR="{app_dir}/{target_name}.runfiles"
#EXTERNAL_JAR_PATTERN="^.*external/(.*)/.*\.jar"
#TARGET_RUNTIME_DEP_PATTERN="bin\/([a-zA-Z0-9\/_-]*)\/.*"
#SHELL_SCRIPT_PATTERN="\/{target_name}$"
#IGNORE_PATTERN=".*\/local_jdk\/"

BUILD_DIR=$WORKDIR/rpmbuild/BUILD

mkdir -p $BUILD_DIR $WORKDIR/rpmbuild/BUILDROOT $WORKDIR/rpmbuild/RPMS
BAZEL_WORK_ROOT=$PWD

cd $BUILD_DIR

SERVER_DIR=opt/tally/${SERVER_NAME}
touch tmp_spec_file
echo "%dir /${SERVER_DIR}" >> tmp_spec_file

RUNFILE_DIR=$SERVER_DIR/$SERVER_NAME.runfiles

# BUILT_EXEC_DIR is where all of the executables produced by Bazel live in
BUILT_EXEC_DIR=$RUNFILE_DIR/$WORKSPACE_NAME

mkdir -p $RUNFILE_DIR $BUILT_EXEC_DIR

add_to_spec_file() {
  local FILE_BASENAME=$(basename $1)
  # . refers to the PWD where the function is called, not where the function is defined
  local FILE_PATH=$(find . -type f -name $FILE_BASENAME)
  echo "${FILE_PATH}" | sed 's/^\.//' >> tmp_spec_file
}

for RUNFILE in "$@"
do
    if [[ $RUNFILE =~ $IGNORE_PATTERN ]]; then
        echo "Ignoring: $RUNFILE" > /dev/null
    elif [[ $RUNFILE =~ $EXTERNAL_JAR_PATTERN ]]; then
        JAR_DIR="$RUNFILE_DIR/${BASH_REMATCH[1]}"
        mkdir -p $JAR_DIR
        cp "${BAZEL_WORK_ROOT}/${RUNFILE}" $JAR_DIR
        add_to_spec_file $RUNFILE
    elif [[ $RUNFILE =~ $SHELL_SCRIPT_PATTERN ]]; then
        cp "${BAZEL_WORK_ROOT}/${RUNFILE}" $RUNFILE_DIR
        add_to_spec_file $RUNFILE
    elif [[ $RUNFILE =~ $TARGET_RUNTIME_DEP_PATTERN ]]; then
        RUNTIME_DEP="$BUILT_EXEC_DIR/${BASH_REMATCH[1]}"
        mkdir -p $RUNTIME_DEP
        cp "${BAZEL_WORK_ROOT}/${RUNFILE}" $RUNTIME_DEP
        add_to_spec_file $RUNFILE
    else
        echo "[IGNORING] - FAILED TO MATCH $RUNFILE"
    fi
done

mkdir -p etc/systemd/system opt/tally/${SERVER_NAME}/scripts

mv "${BAZEL_WORK_ROOT}/$SYSTEMD_UNIT_FILE" "etc/systemd/system/"
mv "${BAZEL_WORK_ROOT}/$CONTROL_SCRIPT" "${SERVER_DIR}/scripts/"

echo "/etc/systemd/system/$(basename $SYSTEMD_UNIT_FILE)" >> tmp_spec_file
echo "/${SERVER_DIR}/scripts/$(basename $CONTROL_SCRIPT)" >> tmp_spec_file

cat tmp_spec_file | sort -u > "${BAZEL_WORK_ROOT}/${RPM_SPEC_FILE_PATH}"
