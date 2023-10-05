#!/bin/bash
# Christopher Sargent 03202023
set -x #echo on

# dos2unix files
dos2unix federal_rabbit_config_cas3.sh 

# Copy files
docker cp federal_rabbit_config_cas3.sh rabbitmq-fips3.11.6-6.0:/etc/rabbitmq/
docker cp clientfed.pem rabbitmq-fips3.11.6-6.0:/etc/rabbitmq/
docker cp clientfed_key.pem rabbitmq-fips3.11.6-6.0:/etc/rabbitmq/
docker cp enabled_plugins rabbitmq-fips3.11.6-6.0:/etc/rabbitmq/

# Update permissions
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.11.6-6.0 chmod 644 clientfed.pem
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.11.6-6.0 chmod 644 clientfed_key.pem
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.11.6-6.0 chmod 644 federal_rabbit_config_cas3.sh
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.11.6-6.0 chmod +x federal_rabbit_config_cas3.sh

# Update ownerships
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.11.6-6.0 chown rabbitmq:rabbitmq clientfed.pem
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.11.6-6.0 chown rabbitmq:rabbitmq clientfed_key.pem
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.11.6-6.0 chown rabbitmq:rabbitmq enabled_plugins
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.11.6-6.0 chown rabbitmq:rabbitmq federal_rabbit_config_cas3.sh

# Symbolic link for rabbitmqadmin 
docker exec -u:0 rabbitmq-fips3.11.6-6.0 ln -s /plugins/rabbitmq_management-3.11.6/priv/www/cli/rabbitmqadmin /usr/local/bin/rabbitmqadmin

# Verify FIPS enabled in the kernel and openssl versions
docker exec -u:0 rabbitmq-fips3.11.6-6.0 cat /proc/cmdline
docker exec -u:0 rabbitmq-fips3.11.6-6.0 openssl version
