#!/bin/bash

AMI_ID=ami-0220d79f3f480ecf5
ZONE_ID=Z04147652PUCQQ3YN19ND
DOMAIN_NAME=saivishnu.shop

for instance in $@
do 
echo "launching instance: $instance"
instance_id=$(aws ec2 run-instances \
--image-id ami-0220d79f3f480ecf5 \
--instance-type t3.micro \
--security-groups "common_roboshop" "roboshop-$instance" \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]' \
--query 'Instances[0].InstanceId' \
--output text
)
echo "instance id:$instance_id"

if [ $instance == "frontend" ]; then
    IP=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
    R53_RECORD="$DOMAIN_NAME"
else
   IP=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)
   R53_RECORD="$instance.$DOMAIN_NAME"
fi
aws route53 change-resource-record-sets \
--hosted-zone-id ZONE_ID \
--change-batch '{
    "Comment": "Update A record to new IP",
    "Changes": [
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "'$R53_RECORD'",
          "Type": "A",
          "TTL": 1,
          "ResourceRecords": [
            { "Value": "'$IP'" }
          ]
        }
      }
    ]
  }'
done 