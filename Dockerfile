FROM postgres:10.10

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg-testing main 10" \
          >> /etc/apt/sources.list.d/pgdg.list; \
    apt-get update -y; \
    apt-get install -y postgresql-10-repmgr repmgr-common=5.0\*

RUN touch /etc/repmgr.conf; \
    chown postgres:postgres /etc/repmgr.conf

ENV PRIMARY_NAME=localhost

COPY scripts/*.sh /docker-entrypoint-initdb.d/
