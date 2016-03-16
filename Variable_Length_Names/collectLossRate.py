import os
import sys

thisCwd = os.getcwd()
#directory = os.path.join(thisCwd, sys.argv[1])
directory = os.path.join(thisCwd, "client")

cltRes = []

for root, dirs, files in os.walk(directory):
    for logFile in files:
       if logFile.endswith(".log"):
           with open(os.path.join(directory, logFile)) as inf:
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

print "loss rate (%):", (totalIntSent - totalDataRecv)/totalIntSent * 100
