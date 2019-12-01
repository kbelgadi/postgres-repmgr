#!/bin/bash

PGHOST=${PRIMARY_NAME}

installed=$(psql -qAt -h ${PGHOST} repmgr -c "SELECT 1 FROM pg_tables WHERE tablename='nodes'")

if [ "${installed}" != "1" ]; then
    repmgr primary register
    exit
fi

my_node=$(grep node_id /etc/repmgr.conf | cut -d= -f 2)
is_reg=$(psql -qAt -h ${PGHOST} repmgr -c "SELECT 1 FROM repmgr.nodes WHERE node_id=${my_node}")

if [ "${is_reg}" != "1" ] && [ ${my_node} -gt 1 ]; then
    pg_ctl -D ${PGDATA} stop -m fast
    rm -Rf ${PGDATA}/*
    repmgr -h ${PRIMARY_NAME} -d repmgr standby clone --fast-checkpoint
    pg_ctl -D ${PGDATA} start &
    sleep 1
    repmgr -h ${PRIMARY_NAME} -d repmgr standby register    
fi
