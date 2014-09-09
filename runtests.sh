#!/bin/bash
# Replace the .app path with path to your local app install in simulator

get_pw () {
  security 2>&1 >/dev/null find-generic-password -ga test \
  |ruby -e 'print $1 if STDIN.gets =~ /^password: "(.*)"$/'
}
scutil --nc start "VPN (Cisco IPSec)"
sleep 2
osascript -e "tell application \"System Events\" to keystroke \"$(get_pw)\""
osascript -e "tell application \"System Events\" to keystroke return"
instruments -t "/Users/hakonbogen/dev/Digi2Real/testTemplate.tracetemplate" \
"/Users/hakonbogen/Library/Application Support/iPhone Simulator/7.1/Applications/3269F567-CDAF-468E-AD88-1CBBB7B5BE40/Digipost-Test-Dpost.app"
