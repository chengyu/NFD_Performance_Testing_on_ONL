import os
import sys

thisCwd = os.getcwd()
#directory = os.path.join(thisCwd, sys.argv[1])
cltDir = os.path.join(thisCwd, "client")

cltRes = []

for root, dirs, files in os.walk(cltDir):
    for logFile in files:
       if logFile.endswith(".log"):
           with open(os.path.join(cltDir, logFile)) as inf:
               tailLines = inf.readlines()
               last10Lines = tailLines[-10: -1]
               sentInterest = 0
               recvData = 0
               for line in last10Lines:
                   # Total Interests Sent        = 100000
                   # Total Responses Received    = 680 
                   if not (line.startswith("Total Interests Sent") or line.startswith("Total Responses Received")):
                       continue
                   if line.startswith("Total Interests Sent"):
                       line = line.strip()
                       items = line.split('=')
                       # two items, Total Interets Sent vs #
                       sentInterest = items[1]
                   if line.startswith("Total Responses Received"):
                       line = line.strip()
                       items = line.split('=')
                       recvData = items[1]
               cltRes.append([sentInterest, recvData])

totalIntSent = 0               
totalDataRecv = 0               
for i, val in enumerate(cltRes):
    totalIntSent += float(val[0])
    totalDataRecv += float(val[1])
print "client side:"
print "totalIntSent = %s" % totalIntSent, "totalDataRecv = %s" % totalDataRecv
print "loss rate (percentage) = %s" % ((totalIntSent - totalDataRecv)/totalIntSent * 100)


print "--------------------------------"

srvDir = os.path.join(thisCwd, "server")
srvRes = []

for root, dirs, files in os.walk(srvDir):
    for logFile in files:
       if logFile.endswith(".log"):
           with open(os.path.join(srvDir, logFile)) as inf:
               tailLines = inf.readlines()
               last5Lines = tailLines[-5: -1]
               recvInt = 0
               for line in last5Lines:
                   # Total Interests Sent        = 100000
                   # Total Responses Received    = 680 
                   if not line.startswith("Total Interests Received"):
                       continue
                   if line.startswith("Total Interests Received"):
                       line = line.strip()
                       items = line.split('=')
                       # two items, Total Interets Sent vs #
                       recvInt = items[1]
               srvRes.append(recvInt)

totalIntRecv = 0               
for i, val in enumerate(srvRes):
    totalIntRecv += float(val)
print "server side:"
print "totalIntRecv = %s" % totalIntRecv
