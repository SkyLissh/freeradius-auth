FROM debian:bullseye-slim

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    freeradius \
    freeradius-mysql \
    freeradius-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY ./clients.conf /etc/freeradius/3.0/
RUN ln -s /etc/freeradius/3.0/mods-available/sql /etc/freeradius/3.0/mods-enabled/
COPY ./sql /etc/freeradius/3.0/mods-enabled/

RUN chgrp -h freerad /etc/freeradius/3.0/mods-available/sql
RUN chown -h freerad:freerad /etc/freeradius/3.0/mods-enabled/sql
