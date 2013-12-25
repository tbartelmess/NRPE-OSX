#!/usr/bin/env sh

USER_NAME=nagios
GROUP_NAME=nagios

# Check if user exists

dscl . read /Users/$USER_NAME > /dev/null 2>&1
if [[ $? == 0 ]]; then
  dscl . -delete /Users/$USER_NAME
  echo "Deleted user ${USER_NAME}"
fi


# Check if group exists

dscl . read /Groups/$GROUP_NAME > /dev/null 2>&1
if [[ $? == 0 ]]; then
  dscl . -delete /Groups/$GROUP_NAME
  echo "Deleted group ${GROUP_NAME}"
fi