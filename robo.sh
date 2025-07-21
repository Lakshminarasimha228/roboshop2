#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-032739b3c91414e33"
ZONE_ID="Z04271653U7W4X8SKWK80"
DOMAIN_NAME="lakshmi.cyou"

# Validate input
if [ $# -eq 0 ]; then
  echo "Usage: $0 <instance1> <instance2> ..."
  exit 1
fi

for instance in "$@"
do
  echo "Launching instance: $instance"
  INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.micro \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query "Instances[0].InstanceId" \
    --output text)

  echo "Instance ID for $instance: $INSTANCE_ID"

  # Wait a few seconds to ensure instance is ready
  sleep 5

  if [ "$instance" != "frontend" ]; then
    IP=$(aws ec2 describe-instances \
      --instance-ids $INSTANCE_ID \
      --query "Reservations[0].Instances[0].PrivateIpAddress" \
      --output text)
  else
    IP=$(aws ec2 describe-instances \
      --instance-ids $INSTANCE_ID \
      --query "Reservations[0].Instances[0].PublicIpAddress" \
      --output text)
  fi

  echo "$instance IP address: $IP"

  # Optional: Add Route53 DNS update here if needed
done
