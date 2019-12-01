#!/bin/bash

if [ -s /etc/repmgr.conf ]; then
    return
fi

PGHOST=${PRIMARY_NAME}

installed=$(psql -qAt -h ${PGHOST} repmgr -c "SELECT 1 FROM pg_tables WHERE tablename='nodes'")
my_node=1

if [ "${installed}" == "1" ]; then
    my_node=$(psql -qAt -h ${PGHOST} repmgr -c 'SELECT max(node_id)+1 FROM repmgr.nodes')
fi

cat << EOF >>/etc/repmgr.conf
node_id=${my_node}
node_name=${NODE}
conninfo='host=${NODE} user=repmgr dbname=repmgr'
data_directory='${PGDATA}'

pg_bindir='/usr/lib/postgresql/10/bin'
use_replication_slots=1

failover=automatic
promote_command='repmgr standby promote'
follow_command='repmgr standby follow -W'

service_start_command='pg_ctl -D ${PGDATA} start'
service_stop_command='pg_ctl -D ${PGDATA} stop -m fast'
service_restart_command='pg_ctl -D ${PGDATA} restart -m fast'
service_reload_command='pg_ctl -D ${PGDATA} reload'
EOF
echo "---------------------------"
cat /etc/repmgr.conf
