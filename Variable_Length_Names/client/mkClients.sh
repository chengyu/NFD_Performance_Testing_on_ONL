#!/bin/bash

if [ $# -eq 5 ]
then
  COUNT=$1
  PROTO=$2
  INTERVAL=$3
  NUM_SEGMENTS=$4
  SEGMENT_LEN=$5
else
  echo "Usage: $0 <count> <proto> <interval> <num name segments> <segment length>"
  exit 0
fi

source ../hosts

INDEX=0
#CLIENT_HOSTS="h1x2 h1x3 h1x4 h1x5 h4x2 h4x3 h4x4 h4x5"
NUMHOSTS=0
INDEX=0
echo "#!/bin/bash" > ../configClients.sh
chmod 755 ../configClients.sh
echo "source ~/.topology" >> ../configClients.sh
echo "CWD=\`pwd\`" >> ../configClients.sh
for s in $CLIENT_HOSTS 
do
 #echo $s
 HOST_LIST[$INDEX]="$s"
 INDEX=$(($INDEX+1))
 NUMHOSTS=$(($NUMHOSTS+1))
 echo " ssh \$$s \"cd \$CWD/client ; ./config_client.sh ${PROTO}\" " >> ../configClients.sh
done

CWD=`pwd`
echo "#!/bin/bash" > ../runTrafficClients.sh
chmod 755 ../runTrafficClients.sh
echo "source ~/.topology" >> ../runTrafficClients.sh
echo "CWD=\`pwd\`" >> ../runTrafficClients.sh
echo "INTERVAL=$INTERVAL"   >> ../runTrafficClients.sh
echo "if [ \$# -eq 1 ]"      >> ../runTrafficClients.sh
echo "then"                 >> ../runTrafficClients.sh
echo "  INTERVAL=\$1"        >> ../runTrafficClients.sh
echo "fi"                   >> ../runTrafficClients.sh


## This creates an array consisting of lower case letters, indexed
## from 0
#A=(a b c d e f g h i j k l m n o p q r s t u v w x y z)
#
## Index through the array
#for (( i=0 ; $((i<=25)) ; $((i++)) ))
#do
#        echo "A[$i] = ${A[$i]} "
#
#done

ALPHA_LIST=(a b c d e f g h i j k l m n o p q r s t u v w x y z)
k=0
i=0
NAME="/"
while [ $i -lt $NUM_SEGMENTS ]
do
  j=0
  while [ $j -lt $SEGMENT_LEN ]
  do
    NAME="$NAME""${ALPHA_LIST[$k]}"
    j=$(($j+1))
    k=$(($k+1))
    if [ $k -ge 26 ]
    then
      k=0
    fi
  done
  i=$(($i+1))
  NAME="$NAME""/"
done

echo "NAME: $NAME"
#exit 0
INDEX=0
HOSTINDEX=0
while [ $INDEX -ne $COUNT ]
do
#echo "INDEX=$INDEX COUNT=$COUNT"
  if [ $INDEX -lt 10 ]
  then
    EXT="00${INDEX}"
  else if [ $INDEX -lt 100 ]
    then
      EXT="0${INDEX}"
    else
      EXT="${INDEX}"
    fi
  fi
  FILENAME="NDN_Traffic_Client_$EXT"
  echo "TrafficPercentage=100" >  $FILENAME
  #echo "Name=/example/$EXT" >> $FILENAME
  echo "Name=${NAME}${EXT}" >> $FILENAME
  echo "MustBeFresh=1" >> $FILENAME
  echo "NameAppendSequenceNumber=1" >> $FILENAME
  echo " ssh \$${HOST_LIST[$HOSTINDEX]} \"cd \$CWD/client ; ndn-traffic -i \$INTERVAL $FILENAME >& client_$EXT.log &\"  " >> ../runTrafficClients.sh


  HOSTINDEX=$(($HOSTINDEX + 1))
  if [ $HOSTINDEX -ge $NUMHOSTS ]
  then 
    HOSTINDEX=0
  fi
  INDEX=$(($INDEX + 1))

done

#TrafficPercentage=100
#Name=/example/A
#MustBeFresh=1
#NameAppendSequenceNumber=1

