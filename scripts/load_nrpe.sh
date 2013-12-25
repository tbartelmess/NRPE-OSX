#!/usr/bin/env sh

launchctl list | grep "com.nagios.nrpe"

if [[ $? != 0 ]]; then
  sudo launchctl load "/Library/LaunchDaemons/com.nagios.nrpe.plist"
fi