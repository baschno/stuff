#!/bin/bash

usage() {
  cat <<EndOfMessage
  NAME:
    $(basename $0) - Become space developer
  USAGE:
     bin/$(basename $0) [<options>]
  OPTIONS:
    -h|--help            Print this help
    --mq-user            Mosquitto User
    --mq-pwd             Moquitto Pwd

EndOfMessage
exit
}

while [[ $# -gt 0 ]] ;do
  case "$1" in
    -h|--help)
      usage
    ;;
    --cf-admin-pwd)
      [ -z "$2" ] && die "ERROR: ${1} requires a non-empty option argument."
      CONTROLLER_PASSWORD="$2"
      shift
    ;;
    --cf-user)
      [ -z "$2" ] && die "ERROR: ${1} requires a non-empty option argument."
      CF_USER="$2"
      shift
    ;;
    --)              # End of all options.
      shift
      break
    ;;
    -?*)
      printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
    ;;
    *)               # Default case: No more options, so break out of the loop.
      break
  esac
  shift
done

if [[ -z $CONTROLLER_PASSWORD ]]; then
  usage
fi
if [[ -z $CF_USER ]]; then
  usage
fi

for sensor_path in /sys/bus/w1/devices/28-* ; do 
  echo $sensor_path
  sensor_name=$(echo $sensor_path | cut -d'/' -f6)
  echo $sensor_name
  sensor_val=$(cat /sys/bus/w1/devices/28-00000595f59e/w1_slave | grep 't=' | cut -d'=' -f2)
  sensor_temp=$(echo $sensor_val | awk '{print $1 / 1000}')
  echo $sensor_temp
done

