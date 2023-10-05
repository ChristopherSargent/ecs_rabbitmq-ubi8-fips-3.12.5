#!/bin/bash
# Christopher Sargent updated 10012023
set -x #echo on

# dos2unix files
dos2unix certs/cert.pem certs/chain.pem certs/key.pem rabbitmq.conf advanced.config enabled_plugins

# Copy certs and rabbitmq.conf
docker cp certs/cert.pem rabbitmq-fips3.12.5-6.0:/etc/rabbitmq/
docker cp certs/chain.pem rabbitmq-fips3.12.5-6.0:/etc/rabbitmq/
docker cp certs/key.pem rabbitmq-fips3.12.5-6.0:/etc/rabbitmq/
docker cp rabbitmq.conf rabbitmq-fips3.12.5-6.0:/etc/rabbitmq/ 
docker cp advanced.config rabbitmq-fips3.12.5-6.0:/etc/rabbitmq/
docker cp enabled_plugins rabbitmq-fips3.12.5-6.0:/etc/rabbitmq/

# Update permissions
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.12.5-6.0 chmod 644 cert.pem
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.12.5-6.0 chmod 644 chain.pem 
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.12.5-6.0 chmod 644 key.pem
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.12.5-6.0 chmod 644 rabbitmq.conf
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.12.5-6.0 chmod 644 advanced.config
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.12.5-6.0 chmod 644 enabled_plugins

# Update ownerships
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.12.5-6.0 chown rabbitmq:rabbitmq cert.pem
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.12.5-6.0 chown rabbitmq:rabbitmq chain.pem 
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.12.5-6.0 chown rabbitmq:rabbitmq key.pem
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.12.5-6.0 chown rabbitmq:rabbitmq rabbitmq.conf
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.12.5-6.0 chown rabbitmq:rabbitmq advanced.config
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.12.5-6.0 chown rabbitmq:rabbitmq enabled_plugins

# Restart container
docker restart rabbitmq-fips3.12.5-6.0

# Verify FIPS enabled in the kernel and openssl versions
docker exec -u:0 rabbitmq-fips3.12.5-6.0 cat /proc/cmdline
docker exec -u:0 rabbitmq-fips3.12.5-6.0 openssl version

# Sleep for 5
sleep 5;

# Enabled FIPS for Rabbit Erlang
#docker exec -u:0 rabbitmq-fips3.12.5-6.0 rabbitmqctl eval 'crypto:enable_fips_mode(true).'
docker exec -u:0 rabbitmq-fips3.12.5-6.0 rabbitmqctl eval 'crypto:info_fips().'
