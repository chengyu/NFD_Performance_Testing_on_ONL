#!/bin/bash

if [ $# -eq 5 ]
then
  COUNT=$1
  PROTO=$2
  NUM_COMPONENTS=$3
  COMPONENT_LEN=$4
  CONTENT_PAYLOAD=$5
else
  echo "Usage: $0 <count> <proto> <num name components> <component length> <content payload>"
  exit 0
fi

source ../hosts
#SERVER_HOSTS="h3x2 h3x3 h3x4 h3x5 h5x2 h5x3 h5x4 h5x5"
NUMHOSTS=0
INDEX=0
echo "#!/bin/bash" > ../configServers.sh
chmod 755 ../configServers.sh
echo "source ~/.topology" >> ../configServers.sh
echo "CWD=\`pwd\`" >> ../configServers.sh
for s in $SERVER_HOSTS 
do
 #echo $s
 HOST_LIST[$INDEX]="$s"
 INDEX=$(($INDEX+1))
 NUMHOSTS=$(($NUMHOSTS+1))
 echo " ssh \$$s \"cd \$CWD/server ; ./config_server.sh ${PROTO}\" " >> ../configServers.sh
done

echo "#!/bin/bash" > ../runTrafficServers.sh
chmod 755 ../runTrafficServers.sh
echo "source ~/.topology" >> ../runTrafficServers.sh
echo "CWD=\`pwd\`" >> ../runTrafficServers.sh

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
while [ $i -lt $NUM_COMPONENTS ]
do
  j=0
  while [ $j -lt $COMPONENT_LEN ]
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

INDEX=0
HOSTINDEX=0
while [ $INDEX -lt $COUNT ]
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
  FILENAME="NDN_Traffic_Server_$EXT"
  #echo "Name=/example/ABCDE/FGHIJ/KLMNO/PQRST/UVWXY/Z/ABCDE/FGHIJ/KLMNO/PQRST/UVWXY/Z/ABCDE/FGHIJ/KLMNO/PQRST/UVWXY/Z/ABCDE/FGHIJ/KLMNO/PQRST/UVWXY/Z/$EXT" > $FILENAME
  echo "Name=${NAME}${EXT}" >> $FILENAME
  echo "ContentType=1" >> $FILENAME
  echo "ContentBytes=${CONTENT_PAYLOAD}" >> $FILENAME
  echo "SigningInfo=id:/localhost/identity/digest-sha256" >> $FILENAME
  #echo "ContentBytes=4000" >> $FILENAME
  #echo  "Content=AAAAAAAAAA" >> $FILENAME


  #echo " ssh \$${HOST_LIST[$HOSTINDEX]}  \"cd \$CWD/server ; ndn-traffic-server -q $FILENAME >& server_$EXT.log &\"  " >> ../runTrafficServers.sh
  #echo " ssh \$${HOST_LIST[$HOSTINDEX]}  \"cd \$CWD/server ; ndn-traffic-server $FILENAME >& server_$EXT.log &\"  " >> ../runTrafficServers.sh
  echo " ssh \$${HOST_LIST[$HOSTINDEX]} \"cd \$CWD/server ; export LD_LIBRARY_PATH='\$CWD/../NFD_current_git/usr/local/lib:\$LD_LIBRARY_PATH\' ; ../../NFD_current_git/usr/local/bin/ndn-traffic-server $FILENAME >& server_$EXT.log &\"  " >> ../runTrafficServers.sh

  INDEX=$(($INDEX + 1))
  HOSTINDEX=$(($HOSTINDEX + 1))
  if [ $HOSTINDEX -ge $NUMHOSTS ]
  then 
    HOSTINDEX=0
  fi

done

#Name=/example/A
#ContentType=1
#ContentBytes=10

