#!/bin/bash


################################################################
########### Define Agency, CertName and Central User ############
################################################################

agency="es51agencydyn"
#agency="es6agencydyn"
agencyRabbitUser="client.agency"
centralRabbitUser="client.federal"

################################################################
#################### START MAIN PROGRAM ########################
################################################################

printf   "\nAdmin Account for RabbitMQ":
read -s rabbitMQAdmin

printf   "\nPassword for Admin Account":
read -s rabbitMQAdminPassword

#validates all values have been found
if [ -z $rabbitMQAdmin ] || [ -z $rabbitMQAdminPassword ]; then
  echo "Please supply Admin Account and Password."
  exit 1
fi


# Install Pre-req

# Prerequisites
#rabbitmq-plugins enable rabbitmq_management rabbitmq_shovel rabbitmq_shovel_management rabbitmq_auth_mechanism_ssl 2> /dev/null && sleep 2

# create the Agency user with the given password
rabbitmqctl add_user $agencyRabbitUser "no-password"
rabbitmqctl clear_password $agencyRabbitUser

# add a new virtual host for the new Agency reporting data
rabbitmqctl add_vhost central.vh${agency}

# add permissions to the virtual host for the admin, the central user, and the agency user
rabbitmqctl set_permissions -p central.vh${agency} $rabbitMQAdmin  ".*" ".*" ".*"
rabbitmqctl set_permissions -p central.vh${agency} $agencyRabbitUser ".*" ".*" ".*"
rabbitmqctl set_permissions -p central.vhgovdown $agencyRabbitUser  "^$" "^central.${agency}.qholddown" "^central.${agency}.qholddown"

# Add an exchange named "central.all.xholdup" to "central.vhAGENCYNAME"
host="0.0.0.0"
rabbitmqadmin --host=${host} --port=15671 --username=${rabbitMQAdmin} --password=${rabbitMQAdminPassword} --ssl -k --vhost="central.vh${agency}" declare exchange name="central.all.xholdup" type="topic"

# Add a queue named "central.AGENCYNAME.qholddown" to "central.vhgovdown" and bind it with "gov.AGENCYNAME.#" and "gov.all.#" to central.all.xholddown
rabbitmqadmin --host=${host} --port=15671 --username=${rabbitMQAdmin} --password=${rabbitMQAdminPassword} --ssl -k --vhost="central.vhgovdown" declare queue name="central.${agency}.qholddown"

rabbitmqadmin --host=${host} --port=15671 --username=${rabbitMQAdmin} --password=${rabbitMQAdminPassword} --ssl -k --vhost="central.vhgovdown" declare binding source="central.all.xholddown" destination="central.${agency}.qholddown" destination_type="queue"  routing_key="gov.all.#"

rabbitmqadmin --host=${host} --port=15671 --username=${rabbitMQAdmin} --password=${rabbitMQAdminPassword} --ssl -k --vhost="central.vhgovdown" declare binding source="central.all.xholddown" destination="central.${agency}.qholddown" destination_type="queue"  routing_key="gov.${agency}.#"

# Add a queue named "central.all.qholdup" in "central.vhAGENCYNAME" and bind it to "central.all.xholdup" with "AGENCYNAME.gov.*"
rabbitmqadmin --host=${host} --port=15671 --username=${rabbitMQAdmin} --password=${rabbitMQAdminPassword} --ssl -k --vhost="central.vh${agency}" declare queue name="central.all.qholdup"

rabbitmqadmin --host=${host} --port=15671 --username=${rabbitMQAdmin} --password=${rabbitMQAdminPassword} --ssl -k --vhost="central.vh${agency}" declare binding source="central.all.xholdup" destination="central.all.qholdup" destination_type="queue"  routing_key="*.gov.#"

# Define the shovel JSON object
shovelname="Shovel.central.${agency}.get"
shovelURI='{"src-protocol":"amqp091","src-uri":"amqp:///central.vh'${agency}'","src-queue":"central.all.qholdup","dest-protocol":"amqp091","dest-uri":"amqp:///central.vhgovup","dest-exchange":"central.all.xholdup","add-forward-headers":false,"ack-mode":"on-confirm","delete-after":"never"}'

# Create the shovel
rabbitmqctl set_parameter -p central.vhgovup shovel $shovelname "$shovelURI"


################## END MAIN PROGRAM #####################
