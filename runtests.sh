#!/bin/bash


# Replace the .app path with path to your local app install in simulator

# LOGIN digipost QA

get_pw () {
  security 2>&1 >/dev/null find-generic-password -ga test \
  |ruby -e 'print $1 if STDIN.gets =~ /^password: "(.*)"$/'
}


# Default values

RUNS=1
APPNAME="Digipost-Test-QA-2"
HELP="0"
for i in "$@"
do
case $i in
    -p=*|--prefix=*)
    PREFIX="${i#*=}"

    ;;
    -a=*|--app=*)
    APPNAME="${i#*=}"

    ;;
    -v|--vpn)
    VPN="1"

    ;;
    -r=*|--runs=*)
    RUNS="${i#*=}"

    ;;

    -h|--help)
    HELP="1"

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
## Show help
if [ "${HELP}" == "1" ];then
    echo "usage    : --app=[name of app to run] --runs=[number of runs to run scripts] --vpn [if set, connects to vpn]"
    echo "example  : --app=\"Digipost-Test-Dpost.app\" --runs=10 --vpn"
fi

SCRIPT="realpath -s $APPNAME"
SCRIPTPATH='dirname $SCRIPT'
s=test1
s=$s"test2"
DIR=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

scriptPath="/iPhoneTemplate.traceTemplate"

fullTracetemplatePath="$DIR$scriptPath"

simulator="iPhone 6 (8.1 Simulator)"

appPath="$(find ~/Library/Developer/CoreSimulator/Devices -name "${APPNAME}" | head -n 1)"
traceTemplatePath="/Applications/Xcode.app/Contents/Applications/Instruments.app/Contents/PlugIns/AutomationInstrument.xrplugin/Contents/Resources/Automation.tracetemplate"
script="uiauto/scripts/allScripts.js"
COUNTER=0

echo ${appPath}
echo ${APPNAME}
echo "dfjksdlf"
while [  $COUNTER -lt $RUNS ]; do
  echo RUN NUMBER = $COUNTER
  let COUNTER=COUNTER+1
echo `instruments -w "${simulator}" -t "${traceTemplatePath}" "${appPath}" -e UIASCRIPT "${script}" 1>&2`

done



#
#echo ""
#echo `instruments -w "${simulator}" -t "${fullTracetemplatePath}" "${appPath}" 1>&2`
