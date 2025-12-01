#!/bin/bash

#creating the ec2 instances automatically through script using aws cli
AMI_ID="ami-09c813fb71547fc4f"
INSTANCE_TYPE="t3.micro"
SG="sg-0b3869c561a82bbce"
instance_names=("frontend" "catalogue" "cart" "checkout" "payment" "shipping" "dispatch" "mongodb" "mysql" "redis" "rabbitmq")


for instance in "${instance_names[@]}" 
do

    INSTANCE_ID="$(aws ec2 run-instances --image-id $AMI_ID --instance-type $INSTANCE_TYPE --security-group-ids $SG --count 1 --tag-specifications 'ResouceType=instance,Tags=[{Key=Name,Value=$instance_names}]' --query "Instances[0].InstanceId" --output text)"
    echo "Instance created successfully with instance id: $INSTANCE_ID"

    if [ $instance =="frontend" ]
    then
        IP="$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)"
        echo "$instance Ip address is: $IP"
    else
        IP="$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)"
        echo "$instance Ip address is: $IP"
    fi

done