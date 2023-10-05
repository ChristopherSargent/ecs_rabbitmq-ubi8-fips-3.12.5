#!/bin/bash
# Christopher Sargent updated 07062023
set -x #echo on

# dos2unix files
dos2unix central_rabbit_config.sh linker_rabbit_config.sh

# Copy files
docker cp central_rabbit_config.sh rabbitmq-fips3.11.6-6.0:/etc/rabbitmq/
docker cp linker_rabbit_config.sh rabbitmq-fips3.11.6-6.0:/etc/rabbitmq/

# Update permissions
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.11.6-6.0 chmod +x central_rabbit_config.sh
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.11.6-6.0 chmod +x linker_rabbit_config.sh

# Update ownerships
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.11.6-6.0 chown rabbitmq:rabbitmq central_rabbit_config.sh
docker exec -u:0 --workdir /etc/rabbitmq/ rabbitmq-fips3.11.6-6.0 chown rabbitmq:rabbitmq linker_rabbit_config.sh

# Symbolic link for rabbitmqadmin this is no longer needed when deploying the new rabbitmq 3.11.6 OTP 25.2 Openssl 3.0.9 container image 036436800059.dkr.ecr.us-gov-west-1.amazonaws.com/rabbitmq-fips:3.11.6.25.2.3.0.9
# docker exec -u:0 rabbitmq-fips3.11.6-6.0 ln -s /plugins/rabbitmq_management-3.11.6/priv/www/cli/rabbitmqadmin /usr/local/bin/rabbitmqadmin

# Verify FIPS enabled in the kernel and openssl versions
docker exec -u:0 rabbitmq-fips3.11.6-6.0 cat /proc/cmdline
docker exec -u:0 rabbitmq-fips3.11.6-6.0 openssl version
