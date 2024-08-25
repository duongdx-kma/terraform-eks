#!/bin/bash
set -ex
# Generate mysql server-id from pod ordinal index.
[[ $HOSTNAME =~ -([0-9]+)$ ]] || exit 1
ordinal=${BASH_REMATCH[1]}
echo [mysqld] > /mnt/conf.d/server-id.cnf
# Add an offset to avoid reserved server-id=0 value.
echo server-id=$((100 + $ordinal)) >> /mnt/conf.d/server-id.cnf
# Copy appropriate conf.d files from config-map to emptyDir.
if [[ $ordinal -eq 0 ]]; then
  cp /mnt/config-map/primary.cnf /mnt/conf.d/
else
  cp /mnt/config-map/replica.cnf /mnt/conf.d/
fi
