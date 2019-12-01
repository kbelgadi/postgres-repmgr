#!/bin/bash

if [ $(grep -c "replication repmgr" ${PGDATA}/pg_hba.conf) -gt 0 ]; then
    return
fi

createuser -U "$POSTGRES_USER" -s --replication repmgr
createdb -U "$POSTGRES_USER" -O repmgr repmgr

echo "host replication repmgr all trust" >> ${PGDATA}/pg_hba.conf
echo "host all repmgr all trust" >> ${PGDATA}/pg_hba.conf

sed -i "s/#*\(shared_preload_libraries\).*/\1='repmgr'/;" ${PGDATA}/postgresql.conf

pg_ctl -D ${PGDATA} stop -m fast
pg_ctl -D ${PGDATA} start &

sleep 1
