#!/bin/bash


# Replace the .app path with path to your local app install in simulator

# LOGIN digipost QA

get_pw () {
  security 2>&1 >/dev/null find-generic-password -ga test \
  |ruby -e 'print $1 if STDIN.gets =~ /^password: "(.*)"$/'
}


# Default values

RUNS=1

for i in "$@"
do
case $i in
    -p=*|--prefix=*)
    PREFIX="${i#*=}"

    ;;
    -v|--vpn)
    VPN="1"
    ;;
    -r=*|--runs=*)
    RUNS="${i#*=}"
    ;;
    --default)
    DEFAULT=YES
    ;;
    *)
            # unknown option
    ;;
esac
done

## Login VPN
if [ "${VPN}" == "1" ];then
  echo  "fetching VPN credentials from keychain \"test\""
  scutil --nc start "VPN (Cisco IPSec)"
  sleep 2
  osascript -e "tell application \"System Events\" to keystroke \"$(get_pw)\""
  osascript -e "tell application \"System Events\" to keystroke return"
fi


SCRIPT="realpath -s $0"
SCRIPTPATH='dirname $SCRIPT'
s=test1
s=$s"test2"
DIR=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
appName="s"
if [ "${1}" == "" ];then
  appName="MinPosten QA.app"
else
  appName=$1
fi

scriptPath="/testTemplate.traceTemplate"

fullTracetemplatePath="$DIR$scriptPath"

simulator="iPhone 6 (8.0 Simulator)"

appPath="$(find ~/Library/Developer/CoreSimulator/Devices -name "${appName}" | head -n 1)"
COUNTER=1
while [  $COUNTER -lt $RUNS ]; do
  echo RUN NUMBER = $COUNTER
  let COUNTER=COUNTER+1
  echo `instruments -w "${simulator}" -t "${fullTracetemplatePath}" "${appPath}" 1>&2`
done



#
#echo ""
#echo `instruments -w "${simulator}" -t "${fullTracetemplatePath}" "${appPath}" 1>&2`
