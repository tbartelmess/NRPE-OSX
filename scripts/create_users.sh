#!/usr/bin/env zsh

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

gid=200
if ! $GROUP_EXISTS; then

  gid_ok=false
  while [ $gid_ok != true ]; do
    echo -n "Checking if GID ${gid} is available... "
    dscl . -list /Groups UniqueID | grep $gid > /dev/null
    if [ $? != 0 ]; then
      echo "YES"
      break
    else
      echo "NO"
    fi
    gid=$(($gid + 1))
  done
  dscl . -create /Groups/$GROUP_NAME
  dscl . -create /Groups/$GROUP_NAME PrimaryGroupID $gid
  dscl . -create /Groups/$GROUP_NAME RealName "Nagios Group"
fi

uid=200
if ! $USER_EXISTS; then
  uid_ok=false
  while [ $uid_ok != true ]; do
    echo -n "Checking if UID ${uid} is available... "
    dscl . -list /Users UniqueID | grep $uid > /dev/null
    if [ $? != 0 ]; then
      echo "YES"
      break
    else
      echo "NO"
    fi
    uid=$(($uid + 1))
  done
  dscl . -create /Users/$USER_NAME
  dscl . -create /Users/$USER_NAME UniqueID $uid
  dscl . -create /Users/$USER_NAME RealName "Nagios Account"
  dscl . -create /Users/$USER_NAME UserShell "/usr/local/bin/zsh"
  dscl . -create /Users/$USER_NAME NFSHomeDirectory "/var/empty"
  dscl . -create /Users/$USER_NAME PrimaryGroupID $gid

fi

mkdir -p /Library/Logs/nrpe/
chown -R nagios:nagios /Library/Logs/nrpe
