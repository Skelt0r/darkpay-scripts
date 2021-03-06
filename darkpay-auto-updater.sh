#!/bin/bash

json=$(curl --silent -X GET  "https://raw.githubusercontent.com/DarkPayCoin/releases/master/clientBinaries.json" -H "accept: application/json")
latestVersion=$(echo $json | jq .clients | jq .darkpayd | jq .version | tr -d \")

currentVersion=$(/usr/local/bin/darkpay-cli getnetworkinfo | grep subversion | cut -d : -f 3 | cut -d / -f 1)
currentVersionShort=${currentVersion%.*}

if [ "$latestVersion" = "$currentVersionShort"  -o "$latestVersion" = "$currentVersion" ]; then
    echo "Already at latest version." #> /dev/null
else
   cd /root
   fullpath=$(echo $json | jq .clients | jq .darkpayd | jq .platforms | jq .linux | jq .x64 | jq .download | jq .url | tr -d \")
   bin=$(echo $json | jq .clients | jq .darkpayd | jq .platforms | jq .linux | jq .x64 | jq .download | jq .bin | tr -d \")
   filename=$(echo $fullpath | rev | cut -d \/ -f 1 | rev)
   folder=$(echo $bin | cut -d \/ -f 1)
   wget $fullpath
   if [ -e $filename ]; then
      tar -xzvf $filename
      service darkpay stop && rm /usr/local/bin/darkpayd
      cp $bin /usr/local/bin/
      service darkpay start
      rm -R $folder
      rm $filename
    fi
fi
