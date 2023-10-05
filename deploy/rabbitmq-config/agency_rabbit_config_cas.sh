#!/bin/bash


################################################################
### Define Agency CertName, Cert file Path and Key File path ###
################################################################

agency="es6agencydyn"
#agency="es51agencydyn"
agencyRabbitUser="client.agency" #This user name must match with the Client Certificate CNAME
centralHostUrl="fdb-rabb-cen-doc.cdm.local"
centralHostPort="5671"

caCertFile="/etc/rabbitmq/chain.pem"
certFile="/etc/rabbitmq/client.agency.pem"
keyFile="/etc/rabbitmq/client.agency.key"

################################################################
#################### START MAIN PROGRAM ########################
################################################################

printf   "\nAdmin Account for RabbitMQ":
read -s rabbitMQAdmin

printf   "\nPassword for Admin Account":
read -s rabbitMQAdminPassword

if [ -z "$rabbitMQAdmin" ] || [ -z "$rabbitMQAdminPassword" ]; then
  echo "Please supply Admin Account and Password"
  exit 1
fi


# Install Pre-req

# Prerequisites
#rabbitmq-plugins enable rabbitmq_management rabbitmq_shovel rabbitmq_shovel_management rabbitmq_auth_mechanism_ssl 2> /dev/null && sleep 2


# create the Agency  user with the given password
rabbitmqctl add_user ${agencyRabbitUser} "No-Password"
rabbitmqctl clear_password ${agencyRabbitUser}

# Add a virtual host to the Agency broker and set permissions
rabbitmqctl add_vhost agency.vh${agency}
rabbitmqctl set_permissions -p agency.vh${agency} ${agencyRabbitUser} ".*" ".*" ".*"
rabbitmqctl set_permissions -p agency.vh${agency} "${rabbitMQAdmin}" ".*"  ".*" ".*"

host="0.0.0.0"
# Add exchanges named "agency.all.xsend" and "agency.all.xget" to "agency.vhAGENCYNAME"
rabbitmqadmin --host=${host} --port=15671 --username="${rabbitMQAdmin}" --password="${rabbitMQAdminPassword}" --ssl -k --vhost=agency.vh${agency} declare exchange name="${agency}.all.xsend"  type=topic
rabbitmqadmin --host=${host} --port=15671 --username="${rabbitMQAdmin}" --password="${rabbitMQAdminPassword}" --ssl -k --vhost=agency.vh${agency} declare exchange name="${agency}.all.xget"  type=topic

# Add queues and bindings
rabbitmqadmin --host=${host} --port=15671 --username="${rabbitMQAdmin}"  --password="${rabbitMQAdminPassword}" --ssl -k --vhost=agency.vh${agency}  declare queue name="${agency}.all.qsend" durable=true
rabbitmqadmin --host=${host} --port=15671 --username="${rabbitMQAdmin}"  --password="${rabbitMQAdminPassword}" --ssl -k --vhost=agency.vh${agency} declare binding source="${agency}.all.xsend" destination_type="queue"  destination="${agency}.all.qsend" routing_key="${agency}.#"

rabbitmqadmin --host=${host} --port=15671 --username="${rabbitMQAdmin}"  --password="${rabbitMQAdminPassword}" --ssl -k --vhost=agency.vh${agency}  declare queue name=${agency}.all.qget durable=true
rabbitmqadmin --host=${host} --port=15671 --username="${rabbitMQAdmin}"  --password="${rabbitMQAdminPassword}" --ssl -k --vhost=agency.vh${agency} declare binding source="${agency}.all.xget" destination_type="queue"  destination="${agency}.all.qget" routing_key="gov.#"


# Create Shovel.agency.all.send
#shovelname="Shovel.${agency}.all.send"
#shovelURI="{'src-protocol':'amqp091','src-uri':'amqp:///agency.vh${agency}','src-queue':'${agency}.all.qsend','dest-protocol':'amqp091','dest-uri':'amqps://${centralHostUrl}:${centralHostPort}/central.vh${agency}?cacertfile=${caCertFile}&certfile=${certFile}&keyfile=${keyFile}&verify=verify_peer&fail_if_no_peer_cert=true&auth_mechanism=external','dest-exchange':'central.all.xholdup','add-forward-headers':false,'ack-mode':'on-confirm','delete-after':'never'}"
#rabbitmqctl set_parameter -p agency.vh${agency} shovel $shovelname "$shovelURI"

# Create Shovel.agency.all.send
shovelname="Shovel.${agency}.all.send"
shovelURI="{\"src-protocol\":\"amqp091\",\"src-uri\":\"amqp:///agency.vh${agency}\",\"src-queue\":\"${agency}.all.qsend\",\"dest-protocol\":\"amqp091\",\"dest-uri\":\"amqps://${centralHostUrl}:${centralHostPort}/central.vh${agency}?cacertfile=${caCertFile}&certfile=${certFile}&keyfile=${keyFile}&verify=verify_peer&fail_if_no_peer_cert=true&auth_mechanism=external\",\"dest-exchange\":\"central.all.xholdup\",\"add-forward-headers\":false,\"ack-mode\":\"on-confirm\",\"delete-after\":\"never\"}"
rabbitmqctl set_parameter -p agency.vh${agency} shovel $shovelname "$shovelURI"

#Create Shovel.agency.all.get
#shovelname="Shovel.${agency}.all.get"
#shovelURI="{'src-protocol':'amqp091','src-uri':'amqps://${centralHostUrl}:${centralHostPort}/central.vhgovdown?cacertfile=${caCertFile}&certfile=${certFile}&keyfile=${keyFile}&verify=verify_peer&fail_if_no_peer_cert=true&auth_mechanism=external','src-queue':'central.${agency}.qholddown','dest-protocol':'amqp091','dest-uri':'amqp:///agency.vh${agency}','dest-exchange':'${agency}.all.xget','add-forward-headers':false,'ack-mode':'on-confirm','delete-after':'never'}"
#rabbitmqctl set_parameter -p agency.vh${agency} shovel $shovelname "$shovelURI"

#Create Shovel.agency.all.get
shovelname="Shovel.${agency}.all.get"
shovelURI="{\"src-protocol\":\"amqp091\",\"src-uri\":\"amqps://${centralHostUrl}:${centralHostPort}/central.vhgovdown?cacertfile=${caCertFile}&certfile=${certFile}&keyfile=${keyFile}&verify=verify_peer&fail_if_no_peer_cert=true&auth_mechanism=external\",\"src-queue\":\"central.${agency}.qholddown\",\"dest-protocol\":\"amqp091\",\"dest-uri\":\"amqp:///agency.vh${agency}\",\"dest-exchange\":\"${agency}.all.xget\",\"add-forward-headers\":false,\"ack-mode\":\"on-confirm\",\"delete-after\":\"never\"}"
rabbitmqctl set_parameter -p agency.vh${agency} shovel $shovelname "$shovelURI"

################ END MAIN PROGRAM ######################
