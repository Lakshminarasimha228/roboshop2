#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-032739b3c91414e33" # replace with your SG ID
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z04271653U7W4X8SKWK80" # replace with your ZONE ID
DOMAIN_NAME="lakshmi.cyou" # replace with your domain

# Use script arguments if provided, otherwise use full list
if [ $# -eq 0 ]; then
  TARGET_INSTANCES=("${INSTANCES[@]}")
else
  TARGET_INSTANCES=("$@")
fi

for instance in "${TARGET_INSTANCES[@]}"
do
  INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
  
  if [ "$instance" != "frontend" ]; then
    IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
  else
    IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
  fi
  
  echo "$instance IP address: $IP"
done
