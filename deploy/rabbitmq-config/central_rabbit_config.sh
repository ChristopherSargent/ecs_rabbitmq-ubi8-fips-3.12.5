#!/bin/bash

################################################################
### Define Agency CertName, Cert file Path and Key File path ###
################################################################.

centralRabbitUser="client.federal"


################################################################
#################### START MAIN PROGRAM ########################
################################################################


printf   "Admin Account for RabbitMQ":
read -s rabbitMQAdmin

printf   "\nPassword for Admin Account":
read -s rabbitMQAdminPassword

if [ -z $rabbitMQAdmin ] || [ -z $rabbitMQAdminPassword ]; then
  echo "Please supply Admin Account and Password"
  exit 1
fi


# Install Pre-req

# Prerequisites
#rabbitmq-plugins enable rabbitmq_management rabbitmq_shovel rabbitmq_shovel_management rabbitmq_auth_mechanism_ssl 2> /dev/null && sleep 2
rabbitmqctl add_user ${centralRabbitUser} "no-password"
rabbitmqctl clear_password ${centralRabbitUser}

# Add a virtual host to the Central broker named "central.vhgovup"
rabbitmqctl add_vhost central.vhgovup
rabbitmqctl add_vhost central.vhgovdown

# Add permissions to "central.vhgovup" for the admin and the gov user
rabbitmqctl set_permissions -p central.vhgovup ${centralRabbitUser} ".*" ".*" ".*"
rabbitmqctl set_permissions -p central.vhgovup ${rabbitMQAdmin} ".*"  ".*" ".*"

# Add permissions to "central.vhgovdown" for the admin and the gov user
rabbitmqctl set_permissions -p central.vhgovdown ${centralRabbitUser} ".*"  ".*"  ".*"
rabbitmqctl set_permissions -p central.vhgovdown ${rabbitMQAdmin} ".*"  ".*"  ".*"

# Add an exchange named "central.all.xholdup" to "central.vhgovup"
rabbitmqadmin --host="0.0.0.0" --port=15671 --username=${rabbitMQAdmin} --password=${rabbitMQAdminPassword} --ssl -k --vhost="central.vhgovup" declare exchange name="central.all.xholdup" type=topic

# Add an exchange named "central.all.xholddown" to "central.vhgovdown"
rabbitmqadmin --host="0.0.0.0" --port=15671 --username=${rabbitMQAdmin} --password=${rabbitMQAdminPassword}  --ssl -k --vhost=central.vhgovdown declare exchange name="central.all.xholddown" type=topic

# Add a queue named "central.all.qholdup" to "central.vhgovup" and bind it to "central.all.xholdup" with *gov.#
rabbitmqadmin --host="0.0.0.0" --port=15671 --username=${rabbitMQAdmin} --password=${rabbitMQAdminPassword} --ssl -k --vhost=central.vhgovup  declare queue name="central.all.qholdup" durable=true
rabbitmqadmin --host="0.0.0.0" --port=15671 --username=${rabbitMQAdmin} --password=${rabbitMQAdminPassword} --ssl -k --vhost=central.vhgovup declare binding source="central.all.xholdup" destination_type="queue" destination="central.all.qholdup" routing_key="*.gov.#"

######################### END MAIN PROGRAM #############################
