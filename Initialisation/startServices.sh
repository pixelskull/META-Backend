#!/bin/bash

# echo "starting rabbitMQ Docker container"
# docker container start rabbitmq
# sleep .5

echo ""
echo "################################################################"
echo "change pwd to ./ResultService/"
cd ./ResultService
echo "removing logs: meta-create-queue-service.log and nohup.out"

rm meta-create-queue-service.log nohup.out
echo "starting: message queue deployment service..."

nohup python ./meta-result-log-service.py &
RES_PID=$!
sleep .5
echo "started with PID: $RES_PID"
cd ..


echo ""
echo "################################################################"
echo "change pwd to ./Deployment/"
cd ./Deployment
echo "removing logs: meta-deployment-service.log and nohup.out"

rm meta-deployment-service.log nohup.out
echo "starting: message queue deployment service..."

nohup ./meta-deployment-service.py &
DP_PID=$!
sleep .5
echo "started with PID: $DP_PID"
cd ..


echo ""
echo "################################################################"
echo "change pwd to ./MessageQueue/"
cd ./MessageQueue
echo "removing logs: meta-create-queue-service.log and nohup.out"

rm meta-create-queue-service.log nohup.out
echo "starting: message queue deployment service..."

nohup python ./meta-create-queue.py &
MQ_PID=$!
sleep .5
echo "started with PID: $MQ_PID"
cd ..


echo ""
echo "################################################################"
echo "change pwd to ./Compiler\ Process"
cd ./Compiler\ Process

echo "removing logs: meta-compilation-service.log and nohup.out"
rm meta-compilation-service.log nohup.out

echo "starting: compilation servie..."
nohup python ./meta-compilation-service.py &
CS_PID=$!
sleep .5
echo "started with PID: $CS_PID"
cd ..


echo ""
echo "################################################################"
echo "change pwd to ./Compiler\ Process"
cd ./Compiler\ Process

echo "removing logs: meta-transformator-service.log"
rm meta-transformator-service.log

echo "starting: IR transformation service..."
nohup python ./meta-transformator-service.py &
TR_PID=$!
sleep .5
echo "started with PID: $TR_PID"
cd ..


echo ""
echo "################################################################"
echo "change pwd to ./Filehandler"
cd ./Filehandler

echo "removing logs: nohup.out"
rm nohub.out

echo "starting: IR file handler service..."
nohup go run ./metaIRFileUploadServer.go &
IR_PID=$!
sleep .5
echo "started with PID: $IR_PID"
cd ..


echo ""
echo "################################################################"
echo "to clean up and stop the created processes use:"
echo ""
echo "  kill $RES_PID $DP_PID $MQ_PID $CS_PID $TR_PID $IR_PID"
echo ""
