#!/bin/bash
# Christopher Sargent 04202023
set -x #echo on

# dos2unix files
dos2unix agency_rabbit_config_cas.sh client.agency.key client.agency.pem agency_rabbit_config_cas.sh enabled_plugins

# Copy files
docker cp agency_rabbit_config_cas.sh rabbitmq-fips3.11.6-6.0:/etc/rabbitmq/
docker cp client.agency.key rabbitmq-fips3.11.6-6.0:/etc/rabbitmq/
docker cp client.agency.pem rabbitmq-fips3.11.6-6.0:/etc/rabbitmq/
docker cp enabled_plugins rabbitmq-fips3.11.6-6.0:/etc/rabbitmq/

# Update permissions
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.11.6-6.0 chmod 644 client.agency.key
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.11.6-6.0 chmod 644 client.agency.pem
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.11.6-6.0 chmod 644 enabled_plugins
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.11.6-6.0 chmod +x agency_rabbit_config_cas.sh

# Update ownerships
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.11.6-6.0 chown rabbitmq:rabbitmq client.agency.key
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.11.6-6.0 chown rabbitmq:rabbitmq client.agency.pem
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.11.6-6.0 chown rabbitmq:rabbitmq enabled_plugins
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.11.6-6.0 chown rabbitmq:rabbitmq agency_rabbit_config_cas.sh

# Symbolic link for rabbitmqadmin 
docker exec -u:0 rabbitmq-fips3.11.6-6.0 ln -s /plugins/rabbitmq_management-3.11.6/priv/www/cli/rabbitmqadmin /usr/local/bin/rabbitmqadmin

# Verify FIPS enabled in the kernel and openssl versions
docker exec -u:0 rabbitmq-fips3.11.6-6.0 cat /proc/cmdline
docker exec -u:0 rabbitmq-fips3.11.6-6.0 openssl version
