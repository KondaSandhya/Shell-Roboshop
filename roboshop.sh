#!/bin/bash

#creating the ec2 instances automatically through script using aws cli
AMI_ID="ami-09c813fb71547fc4f"
INSTANCE_TYPE="t3.micro"
SG="sg-0b3869c561a82bbce"

INSTANCE_ID="$(aws ec2 run-instances --image-id $AMI_ID --instance-type $INSTANCE_TYPE --security-group-ids $SG --count 1 --query "Instances[0].InstanceId" --output text)"
echo "Instance created successfully with instance id: $INSTANCE_ID"