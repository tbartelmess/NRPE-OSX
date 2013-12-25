#!/usr/bin/env zsh

NRPE_DOWNLOAD_URL=http://softlayer-ams.dl.sourceforge.net/project/nagios/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz
PLUGINS_DOWNLOAD_URL=https://www.nagios-plugins.org/download/nagios-plugins-1.5.tar.gz
WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BUILD_DIR="${WORKING_DIR}/build"

PACKAGE_MAKER=""

echo "\n"

function find_packages() {
    echo -n "Looking for Packages... "
    which packagesbuild > /dev/null
    if [[ $? == 0 ]]; then
        echo "OK"
    else
        echo "Did not find Packages."
        echo "Please download Packages from http://s.sudre.free.fr/Software/Packages/ and install it"
        exit 1
    fi

}

function check_preconditions() {
    echo "Checking Preconditions"
    echo "======================"
    find_packages

    if [ -d "$BUILD_DIR" ]; then
      echo -n "Cleaning build directory... "
      rm -rf "$BUILD_DIR"
      print_status
    fi
    echo -n "Create Build directory... "
    print_status
    mkdir -p "$BUILD_DIR"
    echo "\n\n"


}

function print_status () {
    STATUS=$?
    if [[ $STATUS != 0 ]]; then
        echo "ERROR"
    else
        echo "OK"
    fi
}

function build_nrpe() {

  echo "Building NRPE"
  echo "================"
  cd "$BUILD_DIR"
  echo -n "Downloading... "
  curl $NRPE_DOWNLOAD_URL > nrpe.tar.gz 2> nrpe-download-err.log
  print_status
  tar xfvz nrpe.tar.gz 2> nrpe-unpack.log
  mv nrpe-2.15 nrpe

  cd "$BUILD_DIR/nrpe"
  echo -n "Configuring NRPE... "
  ./configure > "../configure.log" 2>&1
  print_status
  echo -n "Patching to run as standalone daemon"
  patch "${BUILD_DIR}/nrpe/src/nrpe.c" "${WORKING_DIR}/patches/nrpe_no_daemon.patch"
  print_status
  echo -n "Build NRPE... "
  make > "../build.log" 2>&1
  print_status
  echo "\n\n"

}


function build_nagios_plugins() {
  echo "Building Nagios Plugins"
  echo "=========================="
  cd "$BUILD_DIR"
  echo -n "Downloading... "
  curl $PLUGINS_DOWNLOAD_URL > plugins.tar.gz 2> plugins-download-err.log
  print_status
  echo -n "Unpacking... "
  tar xfvz plugins.tar.gz 2> plugins-unpack.log
  print_status
  mv nagios-plugins-1.5 nagios-plugins
  cd nagios-plugins
  echo -n "Configuring Nagios Plugins... "
  ./configure > "../plugins-configure.log" 2>&1
  print_status
  echo -n "Build Nagios Plugins... "
  make > "../plugins-build.log" 2>&1
  print_status

  echo


}

function build_package() {
  echo "Building Package"
  echo "================"

  packagesbuild "${WORKING_DIR}/NRPE.pkgproj"
}

check_preconditions
build_nagios_plugins
build_nrpe
build_package
