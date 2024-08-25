#!/bin/bash
set -ex
cd /var/lib/mysql

# Determine binlog position of cloned data, if any.
if [[ -f xtrabackup_slave_info && "x$(<xtrabackup_slave_info)" != "x" ]]; then
  # XtraBackup already generated a partial "CHANGE MASTER TO" query
  # because we're cloning from an existing replica. (Need to remove the tailing semicolon!)
  cat xtrabackup_slave_info | sed -E 's/;$//g' > change_master_to.sql.in
  # Ignore xtrabackup_binlog_info in this case (it's useless).
  rm -f xtrabackup_slave_info xtrabackup_binlog_info
elif [[ -f xtrabackup_binlog_info ]]; then
  # We're cloning directly from primary. Parse binlog position.
  [[ $(cat xtrabackup_binlog_info) =~ ^(.*?)[[:space:]]+(.*?)$ ]] || exit 1
  rm -f xtrabackup_binlog_info xtrabackup_slave_info
  echo "CHANGE MASTER TO MASTER_LOG_FILE='${BASH_REMATCH[1]}',\
        MASTER_LOG_POS=${BASH_REMATCH[2]}" > change_master_to.sql.in
fi

# Check if we need to complete a clone by starting replication.
if [[ -f change_master_to.sql.in ]]; then
  echo "Waiting for mysqld to be ready (accepting connections)"
  until mysql -h 127.0.0.1 -u root -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1"; do sleep 1; done

  echo "Initializing replication from clone position"
  echo $MYSQL_ROOT_PASSWORD
  mysql -h 127.0.0.1 -u root -p"$MYSQL_ROOT_PASSWORD" \
        -e "$(<change_master_to.sql.in), \
                MASTER_HOST='mysql-0.mysql', \
                MASTER_USER='root', \
                MASTER_PASSWORD='$MYSQL_ROOT_PASSWORD', \
                MASTER_CONNECT_RETRY=10; \
              START SLAVE;" || exit 1
  # In case of container restart, attempt this at-most-once.
  mv change_master_to.sql.in change_master_to.sql.orig
fi

# Start a server to send backups when requested by peers.
exec ncat --listen --keep-open --send-only --max-conns=1 3307 -c \
  "xtrabackup --backup --slave-info --stream=xbstream --host=127.0.0.1 --user=root --password=$MYSQL_ROOT_PASSWORD"