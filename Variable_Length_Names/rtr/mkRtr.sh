#!/bin/bash

source ../hosts

if [ $# -eq 4 ]
then
  COUNT=$1
  PROTO=$2
  NUM_COMPONENTS=$3
  COMPONENT_LEN=$4
else
  echo "Usage: $0 <count> <proto> <num name components> <component length>"
  exit 0
fi

NUM_CLIENT_HOSTS=0
INDEX=0
for s in $CLIENT_HOSTS 
do
 #echo $s
 CLIENT_HOST_LIST[$INDEX]="$s"
 INDEX=$(($INDEX+1))
 NUM_CLIENT_HOSTS=$(($NUM_CLIENT_HOSTS+1))
done

NUM_SERVER_HOSTS=0
INDEX=0
for s in $SERVER_HOSTS 
do
 #echo $s
 SERVER_HOST_LIST[$INDEX]="$s"
 INDEX=$(($INDEX+1))
 NUM_SERVER_HOSTS=$(($NUM_SERVER_HOSTS+1))
done

echo "#!/bin/bash" > ./configRtr.sh
chmod 755 ./configRtr.sh

# We have to figure out what the first one will be... guess for now
#START_FACE_ID=7
#START_FACE_ID=8
#START_FACE_ID=6
START_FACE_ID=4
INDEX=0
HOSTINDEX=0
FACE_ID=$START_FACE_ID
# Add faces for Client Hosts
#echo "NUM_CLIENT_HOSTS = $NUM_CLIENT_HOSTS"

export LD_LIBRARY_PATH="$CWD/../NFD_current_git/usr/local/lib:$LD_LIBRARY_PATH"

echo "# Client Faces" >> ./configRtr.sh
while [ $HOSTINDEX -lt $NUM_CLIENT_HOSTS ]
do
  # create face
  echo "../../NFD_current_git/usr/local/bin/nfdc create -P ${PROTO}://${CLIENT_HOST_LIST[$HOSTINDEX]}:6363 # FaceID: $FACE_ID" >> ./configRtr.sh
  HOSTINDEX=$(($HOSTINDEX + 1))
  # Count the Client faces so we can remember where the Server Faces start
  FACE_ID=$(($FACE_ID + 2))
done
echo " " >> ./configRtr.sh

# Record where first server face will be
START_FACE_ID=$FACE_ID
HOSTINDEX=0
# Add faces for Server Hosts
#echo "NUM_SERVER_HOSTS = $NUM_SERVER_HOSTS"
echo "# Server Faces" >> ./configRtr.sh
while [ $HOSTINDEX -lt $NUM_SERVER_HOSTS ]
do
  # create face
  echo "../../NFD_current_git/usr/local/bin/nfdc create -P ${PROTO}://${SERVER_HOST_LIST[$HOSTINDEX]}:6363 # FaceID: $FACE_ID" >> ./configRtr.sh
  HOSTINDEX=$(($HOSTINDEX + 1))
  # Record FACE ID so we have the last Server Face
  MAX_FACE_ID=$FACE_ID
  FACE_ID=$(($FACE_ID + 2))
done

echo " " >> ./configRtr.sh
echo "# Next Hops" >> ./configRtr.sh

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

# Add a next hop FIB entry for each NAME we are going to generate
#FACE_ID=$START_FACE_ID
HOSTINDEX=0
#echo "START_FACE_ID=$START_FACE_ID MAX_FACE_ID=$MAX_FACE_ID"
while [ $INDEX -lt $COUNT ]
do
  # generate the NAME extension
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
  INDEX=$(($INDEX + 1))
  # add next hop
  #echo "nfdc add-nexthop /example/ABCDE/FGHIJ/KLMNO/PQRST/UVWXY/Z/ABCDE/FGHIJ/KLMNO/PQRST/UVWXY/Z/ABCDE/FGHIJ/KLMNO/PQRST/UVWXY/Z/ABCDE/FGHIJ/KLMNO/PQRST/UVWXY/Z/$EXT $FACE_ID 1 " >> ./configRtr.sh
  #echo "nfdc add-nexthop -c 1 ${NAME}${EXT} $FACE_ID " >> ./configRtr.sh
  echo  "../../NFD_current_git/usr/local/bin/nfdc add-nexthop -c 1 ${NAME}${EXT} ${PROTO}://${SERVER_HOST_LIST[$HOSTINDEX]}:6363 " >> ./configRtr.sh
  #FACE_ID=$(($FACE_ID + 2))
  # if we have reached the last server first Server 
  HOSTINDEX=$(($HOSTINDEX + 1))
  if [ $HOSTINDEX -ge $NUM_SERVER_HOSTS ]
  then
    echo " " >> ./configRtr.sh
    HOSTINDEX=0
  fi
  ## if we have reached the last server face, go back to first Server face
  #if [ $FACE_ID -gt $MAX_FACE_ID ]
  #then
  #  echo " " >> ./configRtr.sh
  #  FACE_ID=$START_FACE_ID
  #fi
done

