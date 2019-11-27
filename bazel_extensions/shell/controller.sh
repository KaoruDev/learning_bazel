#!/bin/bash

# Expected ENV variables:
#
# SERVER_NAME - name of the server you're running, used for logging purposes
# JAVA_EXEC - Path to java exec script
# RUN_DIR - Directory to place pid
# JAVABIN - location of executable to run java. Defaults to /usr/bin/java

[[ -z ${JAVA_EXEC} ]] && JAVA_EXEC=/opt/tally/person/person.runfiles/person #TODO(Kaoru) need to make a template ugh
[[ -z ${SERVER_NAME} ]] && SERVER_NAME=person #TODO(Kaoru) need to make a template ugh
[[ -z ${RUN_DIR} ]] && RUN_DIR=/usr/run/$SERVER_NAME
[[ -z ${JAVABIN} ]] && JAVABIN=/usr/bin/java

mkdir -p $RUN_DIR

PID_PATH_NAME="${RUN_DIR}/${SERVER_NAME}.pid"

start_server() {
  JAVABIN=$JAVABIN nohup $JAVA_EXEC >> "/var/log/${SERVER_NAME}/${SERVER_NAME}_script.log" 2>&1 &
  local exit_code=$?
  local pid=$!

  if [[ $exit_code -eq 0 ]]; then
    echo $pid > $PID_PATH_NAME
    echo "$SERVER_NAME started ... at pid: $pid"
  fi

  return $exit_code
}

case $1 in 
start)
  echo "Starting $SERVER_NAME ..."
  if [ ! -f $PID_PATH_NAME ]; then
    start_server
  else
    echo "$SERVER_NAME is already running ..."
  fi
;;
stop)
  if [ -f $PID_PATH_NAME ]; then
    PID=$(cat $PID_PATH_NAME);
    echo "$SERVER_NAME stoping ..."
    exit_code=$(kill $PID;)
    echo "$SERVER_NAME stopped ..."
    rm $PID_PATH_NAME
    exit $exit_code
  else          
    echo "$SERVER_NAME is not running ..."
    exit 137
  fi
;;
restart)
  if [ -f $PID_PATH_NAME ]; then
    PID=$(cat $PID_PATH_NAME);
    echo "$SERVER_NAME stopping ...";
    kill $PID;
    echo "$SERVER_NAME stopped ...";
    rm $PID_PATH_NAME
    echo "$SERVER_NAME starting ..."
    start_server
    echo "$SERVER_NAME started ..."
  else           
    echo "$SERVER_NAME is not running ..."
  fi     ;;
 esac