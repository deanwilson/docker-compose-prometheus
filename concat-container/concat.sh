#!/bin/sh

# store the combined config file here
mkdir -p /fragments/complete
# the final, combined config file
completed_config=/fragments/complete/prometheus.yml

# set a default sha for /fragments/complete/prometheus.yml
# as it won't exist on first run
old_sha=hello

# loop around and concatenate any fragment files from the docker volume
while true
do
  # combine all the yml fragments to the end of /base_prometheus.yml
  cat /base_prometheus.yml /fragments/*.yml > /prometheus.yml 2>/dev/null

  new_sha=$(sha256sum /prometheus.yml | cut -d ' ' -f1)

  if [ -e $completed_config ];then
    old_sha=$(sha256sum $completed_config | cut -d ' ' -f1)
  fi

  # only replace the config if it's changed. prometheus restarts on change
  if [ "$new_sha" != "$old_sha" ];then
    mv /prometheus.yml $completed_config
  fi

  sleep 60
done
