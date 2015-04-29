# LOGIN digipost VPN

# change these variables for your setup

keychainItem=digipostVPN      # this name has to match "Account" in keychain
VPNName="VPN (Cisco IPSec)"   # match the name of the VPN service to run

get_pw () {
   security 2>&1 >/dev/null find-generic-password -ga $keychainItem \
   |ruby -e 'print $1 if STDIN.gets =~ /^password: "(.*)"$/'
}

echo "fetching VPN credentials from keychain account \"$keychainItem\""
echo "Using VPN service: $VPNName"

scutil --nc stop "$VPNName"

scutil --nc start "$VPNName"

osascript -e "if application \"scutil\" is running then"
osascript -e "     tell application \"System Events\" to keystroke \"$(get_pw)\""
osascript -e "     tell application \"System Events\" to keystroke return"
osascript -e "end if"



exit
