#!/bin/bash
user=$1
passwd=$2

if [[ -z $user ]]; then
  echo "Provide User"
  exit 1
fi

if [[ -z $passwd ]]; then
  echo "Provide Passwd"
  exit 1
fi

sensordata=$(sudo digitemp_DS9097 -a -q -c /etc/digitemp.conf)
# Output: "Feb 11 15:36:06 Sensor 0 C: 19.62 F: 67.32"
sensor=$(echo $sensordata | cut -d' ' -f4,5 | tr ' ' '_')
value=$(echo $sensordata | cut -d' ' -f7)
echo $sensor
echo $value
mqtt_topic="sensor/studio/$sensor"

ts=$(date +"%Y-%m-%d_%H-%M")
eval "mosquitto_pub -h raspi-3b-1 -u $user -P $passwd -i raspi-1b-1 -t $mqtt_topic -m '{\"temperature\":$value, \"timestamp\":\"$ts\"}'"

