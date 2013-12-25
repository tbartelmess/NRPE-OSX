#!/usr/bin/env sh

USER_NAME=nagios
GROUP_NAME=nagios

USER_EXISTS=false
GROUP_EXISTS=false

# Check if user exists

dscl . read /Users/$USER_NAME > /dev/null 2>&1
if [[ $? == 0 ]]; then
  USER_EXISTS=true
fi


# Check if group exists

dscl . read /Groups/$GROUP_NAME > /dev/null 2>&1
if [[ $? == 0 ]]; then
  GROUP_EXISTS=true
fi

if ! $USER_EXISTS; then
  dscl . create /Users/$USER_NAME
  dscl . create /Users/$USER_NAME RealName "NPRE Account"
fi

if ! $GROUP_EXISTS; then
  dscl . create /Groups/$GROUP_NAME
  dscl . -append /Groups/$GROUP_NAME GroupMembership $USER_NAME
fi