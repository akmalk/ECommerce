#!/bin/bash

# VARIABLES
CONTR_HOST=dev.demo.appdynamics.com
CONTR_PORT=8090
APP_NAME=ECommerce-Rob
VERSION=latest
ACCOUNT_NAME=customer1_f16aea9b-844d-476d-92db-60f3acaa620d
ACCESS_KEY=4dea0c08-003b-4732-b07d-7abec9c098ba
EVENT_ENDPOINT=https://analytics.api.appdynamics.com
UNIQUE_HOST_ID=bolton
SHARED_LOGS=/Users/rbolton/Documents/Code/appd/sharedAppDLogs

echo -n "oracle-db: "; docker run --name oracle-db -d -p 1521:1521 -p 2222:22 appddemo/ecommerce-oracle
echo -n "db: "; docker run --name db -e MYSQL_ROOT_PASSWORD=singcontroller -p 3306:3306 -p 2223:22 -d appddemo/ecommerce-mysql
echo -n "jms: "; docker run --name jms -d appddemo/ecommerce-activemq
echo -n "analytics: "; docker run -d -h ecommerce-analytics --name machine-agent -P -v ${SHARED_LOGS}:/appdynamics/shared-logs -v `pwd`/ecommerce-web1-log4j.job:/appdynamics/agents/machine-agent//monitors/analytics-agent/conf/job/ecommerce-web1-log4j.job -e APPDYNAMICS_ANALYTICS_ACCOUNT_NAME=customer1_f16aea9b-844d-476d-92db-60f3acaa620d -e APPDYNAMICS_ANALYTICS_ENDPOINT=https://analytics.api.appdynamics.com/v1 -e APPDYNAMICS_CONTROLLER_HOST_NAME=dev.demo.appdynamics.com -e APPDYNAMICS_CONTROLLER_PORT=80 -e APPDYNAMICS_AGENT_ACCOUNT_NAME=customer1 -e APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY=4dea0c08-003b-4732-b07d-7abec9c098ba appddemo/machineagent-analytics:4.2.0.2
sleep 30

echo -n "ws: "; docker run --name ws -h ${APP_NAME}-ws -e create_schema=true -e ws=true \
	-e ACCOUNT_NAME=${ACCOUNT_NAME} -e ACCESS_KEY=${ACCESS_KEY} -e EVENT_ENDPOINT=${EVENT_ENDPOINT} \
	-e CONTROLLER=${CONTR_HOST} -e APPD_PORT=${CONTR_PORT} \
	-e NODE_NAME=${APP_NAME}_WS_NODE -e APP_NAME=$APP_NAME -e TIER_NAME=Inventory-Services \
	-e APPDYNAMICS_AGENT_UNIQUE_HOST_ID=${UNIQUE_HOST_ID} --link db:db \
	--link jms:jms --link oracle-db:oracle-db -d appddemo/ecommerce-tomcat:$VERSION

echo -n "web: "; docker run --name web -h ${APP_NAME}-web -v ${SHARED_LOGS}/web1:/tomcat/logs -e JVM_ROUTE=route1 -e web=true \
	-e ACCOUNT_NAME=${ACCOUNT_NAME} -e ACCESS_KEY=${ACCESS_KEY} -e EVENT_ENDPOINT=${EVENT_ENDPOINT} \
	-e CONTROLLER=${CONTR_HOST} -e APPD_PORT=${CONTR_PORT} \
	-e NODE_NAME=${APP_NAME}_WEB1_NODE -e APP_NAME=$APP_NAME -e TIER_NAME=ECommerce-Services \
	-e APPDYNAMICS_AGENT_UNIQUE_HOST_ID=${UNIQUE_HOST_ID} \
	--link db:db --link oracle-db:oracle-db --link ws:ws --link jms:jms --link machine-agent:machine-agent -d appddemo/ecommerce-tomcat:$VERSION

sleep 30

echo -n "fulfillment: "; docker run --name fulfillment -h ${APP_NAME}-fulfillment -e web=true \
	-e ACCOUNT_NAME=${ACCOUNT_NAME} -e ACCESS_KEY=${ACCESS_KEY} -e EVENT_ENDPOINT=${EVENT_ENDPOINT} \
	-e CONTROLLER=${CONTR_HOST} -e APPD_PORT=${CONTR_PORT} \
	-e NODE_NAME=Fulfillment -e APP_NAME=${APP_NAME}-Fulfillment -e TIER_NAME=Fulfillment-Services \
	-e AWS_ACCESS_KEY=${AWS_ACCESS_KEY} -e AWS_SECRET_KEY=${AWS_SECRET_KEY} \
	-e APPDYNAMICS_AGENT_UNIQUE_HOST_ID=${UNIQUE_HOST_ID} \
	--link db:db --link ws:ws --link jms:jms --link oracle-db:oracle-db -d appddemo/ecommerce-tomcat:$VERSION

sleep 30

echo -n "fulfillment-client: "; docker run --name fulfillment-client -h ${APP_NAME}-fulfillment-client \
	-e ACCOUNT_NAME=${ACCOUNT_NAME} -e ACCESS_KEY=${ACCESS_KEY} \
        -e CONTROLLER=${CONTR_HOST} -e APPD_PORT=${CONTR_PORT} \
	-e NODE_NAME=FulfillmentClient1 -e APP_NAME=${APP_NAME}-Fulfillment -e TIER_NAME=Fulfillment-Client-Services \
	-e AWS_ACCESS_KEY=${AWS_ACCESS_KEY} -e AWS_SECRET_KEY=${AWS_SECRET_KEY} \
	-e APPDYNAMICS_AGENT_UNIQUE_HOST_ID=${UNIQUE_HOST_ID} \
	-d appddemo/ecommerce-fulfillment-client:$VERSION

sleep 30

echo -n "web1: "; docker run --name web1 -h ${APP_NAME}-web1 -v ${SHARED_LOGS}/web2:/tomcat/logs -e JVM_ROUTE=route2 -e web=true \
	-e ACCOUNT_NAME=${ACCOUNT_NAME} -e ACCESS_KEY=${ACCESS_KEY} -e EVENT_ENDPOINT=${EVENT_ENDPOINT} \
	-e CONTROLLER=${CONTR_HOST} -e APPD_PORT=${CONTR_PORT} \
	-e NODE_NAME=${APP_NAME}_WEB2_NODE -e APP_NAME=$APP_NAME -e TIER_NAME=ECommerce-Services \
	-e SIM_HIERARCHY_2=${SIM_HIERARCHY_2} -e APPDYNAMICS_AGENT_UNIQUE_HOST_ID=${UNIQUE_HOST_ID} \
	--link db:db --link oracle-db:oracle-db --link ws:ws --link jms:jms --link machine-agent:machine-agent -d appddemo/ecommerce-tomcat:$VERSION

sleep 30

echo -n "lbr: "; docker run --name=lbr -h ${APP_NAME}-lbr \
	-e CONTROLLER=${CONTR_HOST} -e APPD_PORT=${CONTR_PORT} \
	-e APP_NAME=${APP_NAME} -e TIER_NAME=Web-Tier-Services -e NODE_NAME=${APP_NAME}-Apache \
	-e ACCOUNT_NAME=${ACCOUNT_NAME} -e ACCESS_KEY=${ACCESS_KEY} -e EVENT_ENDPOINT=${EVENT_ENDPOINT} \
	-e APPDYNAMICS_AGENT_UNIQUE_HOST_ID=${UNIQUE_HOST_ID} \
	--link web:web --link web1:web1 -p 80:80 -d appddemo/ecommerce-lbr:$VERSION

echo -n "msg: "; docker run --name msg -h ${APP_NAME}-msg -e jms=true \
	-e ACCOUNT_NAME=${ACCOUNT_NAME} -e ACCESS_KEY=${ACCESS_KEY} -e EVENT_ENDPOINT=${EVENT_ENDPOINT} \
	-e CONTROLLER=${CONTR_HOST} -e APPD_PORT=${CONTR_PORT} \
	-e NODE_NAME=${APP_NAME}_JMS_NODE -e APP_NAME=$APP_NAME -e TIER_NAME=Order-Processing-Services \
	-e APPDYNAMICS_AGENT_UNIQUE_HOST_ID=${UNIQUE_HOST_ID} \
	--link db:db --link jms:jms --link oracle-db:oracle-db --link fulfillment:fulfillment -d appddemo/ecommerce-tomcat:$VERSION

exit 0

