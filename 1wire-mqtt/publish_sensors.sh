#!/bin/bash

usage() {
  cat <<EndOfMessage
  NAME:
    $(basename $0) - Read onewire ds sensor and publish to mqtt
  USAGE:
     bin/$(basename $0) [<options>]
  OPTIONS:
    -h|--help            Print this help
    --mq-user            Mosquitto User
    --mq-pwd             Moquitto Pwd
    --mq-host

EndOfMessage
exit
}

while [[ $# -gt 0 ]] ;do
  case "$1" in
    -h|--help)
      usage
    ;;
    --mq-user)
      [ -z "$2" ] && die "ERROR: ${1} requires a non-empty option argument."
      MQ_USER="$2"
      shift
    ;;
    --mq-pwd)
      [ -z "$2" ] && die "ERROR: ${1} requires a non-empty option argument."
      MQ_PWD="$2"
      shift
    ;;
    --mq-host)
      [ -z "$2" ] && die "ERROR: ${1} requires a non-empty option argument."
      MQ_HOST="$2"
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

if [[ -z $MQ_HOST ]]; then
  usage
fi
if [[ -z $MQ_USER ]]; then
  usage
fi
if [[ -z $MQ_PWD ]]; then
  usage
fi

for sensor_path in /sys/bus/w1/devices/28-* ; do
  echo $sensor_path
  sensor_name=$(echo $sensor_path | cut -d'/' -f6)
  echo "K: $sensor_name"
  sensor_val=$(cat "$sensor_path/w1_slave" | grep 't=' | cut -d'=' -f2)
  sensor_temp=$(echo $sensor_val | awk '{print $1 / 1000}')
  echo "V: $sensor_temp"
  mqtt_topic="sensors/onewire/$sensor_name"
  ts=$(date +"%Y-%m-%d_%H-%M")
  sending_host=$(hostname)
  eval "mosquitto_pub -h $MQ_HOST -u $MQ_USER -P $MQ_PWD -i raspi-1b-1 -t $mqtt_topic -m '{\"temperature\":$sensor_temp, \"timestamp\":\"$ts\", \"publisher\":\"$sending_host\"}'"

done
