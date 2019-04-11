#!/bin/sh

date=$(date +%Y%m%d%H%M%S)
client=celnova

countinstances=$(cat /root/awsscript/$client/id_instance | wc -l)

for ((count=1; count<=$countinstances; count++))
do
  instanceid=$(sed -n "$count"p /root/awsscript/$client/id_instance)
  aws ec2 create-image --instance-id $instanceid --name $instanceid$date --description $client --no-reboot --profile $client > /root/awsscript/$client/amitmp.log
if [ $? -ne '0' ]; then
  exit 1
else
  echo 0
  grep ami- /root/awsscript/$client/amitmp.log | cut -c 17-37 >> /root/awsscript/$client/ami.log
fi 
done
rm -rf /root/awsscript/$client/amitmp.log
