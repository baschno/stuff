#/bin/env bash

FILES=(
configuration
secrets
groups
automations
customize
scripts
)

echo "sync config to hassio"
for file in ${FILES[*]}; do
  #echo $file
  scp -i ~/.ssh/hassio_rsa hass_cfg/${file}.yaml root@192.168.178.51:/config/${file}.yaml
done



