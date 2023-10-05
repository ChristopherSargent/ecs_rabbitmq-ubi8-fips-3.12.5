#!/bin/bash

################################################################
### Define Federal CertName, Cert file Path and Key File path ###
################################################################

federalCertCN="client.federal"
centralHostUrl="fdb-rabb-cen-doc.cdm.local"
caCertFile="/etc/rabbitmq/chain.pem"
certFile="/etc/rabbitmq/clientfed.pem"
keyFile="/etc/rabbitmq/clientfed_key.pem"

federalRabbitUser=$federalCertCN

################################################################
#################### START MAIN PROGRAM ########################
################################################################

echo "Admin Account for RabbitMQ:"
read -s rabbitMQAdmin

echo -e "\nPassword for Admin Account:"
read -s rabbitMQAdminPassword

if [ -z "$rabbitMQAdmin" ] || [ -z "$rabbitMQAdminPassword" ]; then
  echo "Please supply Admin Account and Password"
  exit 1
fi

# Install Pre-req

# Prerequisites
#rabbitmq-plugins enable rabbitmq_management rabbitmq_shovel rabbitmq_shovel_management rabbitmq_auth_mechanism_ssl 2> /dev/null && sleep 2


# create the 'gov' user with the given password
rabbitmqctl add_user ${federalRabbitUser} "no-password"
rabbitmqctl clear_password ${federalRabbitUser}

# Add a virtual host to the Central broker named "gov.vhgov"
rabbitmqctl add_vhost gov.vhgov

# Add permissions to "central.vhgovup" for the admin and the gov user
rabbitmqctl set_permissions -p gov.vhgov ${federalRabbitUser} ".*" ".*" ".*"
rabbitmqctl set_permissions -p gov.vhgov "$rabbitMQAdmin" ".*"  ".*" ".*"

# Add an exchange named "gov.all.xsend" to "gov.vhgov"
host="0.0.0.0"

rabbitmqadmin --host="$host" --port=15671 --username="$rabbitMQAdmin" --password="$rabbitMQAdminPassword" --ssl -k --vhost=gov.vhgov declare exchange name="gov.all.xsend" type="topic"

# Add a queue named "gov.all.qsend" to "gov.vhgov" and bind it to "gov.all.xsend" with gov.#
rabbitmqadmin --host="$host" --port=15671 --username="$rabbitMQAdmin" --password="$rabbitMQAdminPassword" --ssl -k --vhost=gov.vhgov  declare queue name="gov.all.qsend" durable=true
rabbitmqadmin --host="$host" --port=15671 --username="$rabbitMQAdmin" --password="$rabbitMQAdminPassword" --ssl -k --vhost=gov.vhgov declare binding source="gov.all.xsend" destination_type="queue" destination="gov.all.qsend" routing_key="gov.#"

# Add an exchange named "gov.all.xget" to "gov.vhgov"
rabbitmqadmin --host="$host" --port=15671 --username="$rabbitMQAdmin" --password="$rabbitMQAdminPassword" --ssl -k --vhost=gov.vhgov declare exchange name="gov.all.xget" type="topic"

# Add a queue named "gov.all.qget" to "gov.vhgov" and bind it to "gov.all.xget" with *gov.#
rabbitmqadmin --host="$host" --port=15671 --username="$rabbitMQAdmin" --password="$rabbitMQAdminPassword" --ssl -k --vhost=gov.vhgov declare queue name="gov.all.qget" durable=true
rabbitmqadmin --host="$host" --port=15671 --username="$rabbitMQAdmin" --password="$rabbitMQAdminPassword" --ssl -k --vhost=gov.vhgov declare binding source="gov.all.xget" destination_type="queue" destination="gov.all.qget" routing_key="*.gov.#"

# Add a queue named "gov.all.qarchive" to "gov.vhgov" and bind it to "gov.all.xget" with #
rabbitmqadmin --host="$host" --port=15671 --username="$rabbitMQAdmin" --password="$rabbitMQAdminPassword" --ssl -k --vhost=gov.vhgov declare queue name="gov.all.qarchive" durable=true
rabbitmqadmin --host="$host" --port=15671 --username="$rabbitMQAdmin" --password="$rabbitMQAdminPassword" --ssl -k --vhost=gov.vhgov declare binding source="gov.all.xget" destination_type="queue" destination="gov.all.qarchive" routing_key="#"

# Creating Shovel.all.gov.get
shovelname="Shovel.all.${federalRabbitUser}.get"
shovelURI="{\"src-protocol\":\"amqp091\",\"src-uri\":\"amqps://${centralHostUrl}:5671/central.vhgovup?cacertfile=${caCertFile}&certfile=${certFile}&keyfile=${keyFile}&verify=verify_peer&fail_if_no_peer_cert=true&auth_mechanism=external\",\"src-queue\":\"central.all.qholdup\",\"dest-protocol\":\"amqp091\",\"dest-uri\":\"amqp:///gov.vhgov\",\"dest-exchange\":\"gov.all.xget\",\"add-forward-headers\":false,\"ack-mode\":\"on-confirm\",\"delete-after\":\"never\"}"
rabbitmqctl set_parameter -p gov.vhgov shovel $shovelname "$shovelURI"

# Creating Shovel.all.gov.send
shovelname="Shovel.all.${federalRabbitUser}.send"
shovelURI="{\"src-protocol\":\"amqp091\",\"src-uri\":\"amqp:///gov.vhgov\",\"src-queue\":\"gov.all.qsend\",\"dest-protocol\":\"amqp091\",\"dest-uri\":\"amqps://${centralHostUrl}:5671/central.vhgovdown?cacertfile=${caCertFile}&certfile=${certFile}&keyfile=${keyFile}&verify=verify_peer&fail_if_no_peer_cert=true&auth_mechanism=external\",\"dest-exchange\":\"central.all.xholddown\",\"add-forward-headers\":false,\"ack-mode\":\"on-confirm\",\"delete-after\":\"never\"}"
rabbitmqctl set_parameter -p gov.vhgov shovel $shovelname "$shovelURI"

############################### END MAIN PROGRAM ###############################
