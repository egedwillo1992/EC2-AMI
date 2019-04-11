#!/bin/sh

client=celnova
retention=7
countlinesami=$(cat /root/awsscript/$client/ami.log | wc -l)
imageid=$(sed -n 1p /root/awsscript/$client/ami.log)
countinstances=$(cat /root/awsscript/$client/id_instance | wc -l)
countamiweekly=$(($countinstances * $retention))
amisobrantes=$(($countlinesami - $countamiweekly))

echo $amisobrantes
echo $countamiweekly

if [ $amisobrantes -gt 0 ];
then
for ((count=1; count<=$amisobrantes; count++))
do
    imageid=$(sed -n "$count"p /root/awsscript/$client/ami.log)
    aws ec2 describe-images --image-id $imageid --profile $client > /root/awsscript/$client/amidetail.log
if [ $? -ne '0' ]
then
    output=1
else
    output=0
fi
    grep snap- /root/awsscript/$client/amidetail.log | cut -c 40-61 >> /root/awsscript/$client/snapid.log
done

for ((count=1; count<=$amisobrantes; count++))
do
    imageid=$(sed -n "$count"p /root/awsscript/$client/ami.log)
    aws ec2 deregister-image --image-id $imageid --profile $client
if [ $? -ne '0' ]
then
    output=1
else
    output=0
fi
done

sed -i 1,"$amisobrantes"d /root/awsscript/$client/ami.log

countlinessnap=$(cat /root/awsscript/$client/snapid.log | wc -l)
snapid=$(sed -n 1p /root/awsscript/$client/snapid.log)

for ((count=1; count<=$countlinessnap; count++))
do
    snapid=$(sed -n "$count"p /root/awsscript/$client/snapid.log)
    aws ec2 delete-snapshot --snapshot-id $snapid --profile $client
if [ $? -ne '0' ]
then
    output=1
else
    output=0
fi
done
rm -rf /root/awsscript/$client/amidetail.log
rm -rf /root/awsscript/$client/snapid.log
else
echo 'La cantidad de ami no excede las semana'
fi
echo $output
exit $output
