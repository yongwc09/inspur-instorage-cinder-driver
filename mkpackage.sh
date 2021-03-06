#!/bin/bash

set -e

VERSION="1.0.0.0"
COMMAND=$0

# show help
function show_usage() {
    echo "Usage: $COMMAND [-h | -v | -t [j|k|l|m|o|p|q]]"
    echo ""
    echo "A tool to generate the package of inspur instorage cinder driver for specify Openstack version"
    echo ""
    echo "Options:"
    echo "    -h    show this help"
    echo "    -v    show the version"
    echo "    -t V  specify the openstack version which"
    echo "          we want generate package for, now we"
    echo "          support version j k l m n o p q"
}

# deal with option
while getopts "t:hv" arg
do
    case $arg in
    t)
        # openstack version as the arg, and fixup the version str
        OS_VERSION=${OPTARG:0:1}
        case $OS_VERSION in
          'j'|'J') 
                 OS_VERSION='JUNO'
                 ;;
          'k'|'K')
                 OS_VERSION='KILO'
                 ;;
          'l'|'L') 
                 OS_VERSION='LIBERTY'
                 ;;
          'm'|'M') 
                 OS_VERSION='MITAKA'
                 ;;
          'n'|'N')
                 OS_VERSION='NEWTON'
                 ;;
          'o'|'O') 
                 OS_VERSION='OCATA'
                 ;;
          'p'|'P') 
                 OS_VERSION='PIKE'
                 ;;
          'q'|'Q') 
                 OS_VERSION='QUEENS'
                 ;;
          *) 
            echo "OpenStack version $OPTARG not support"
            show_usage
            exit 1
            ;;
        esac
        ;;
    h)
        show_usage
        exit 0
        ;;
    v)
        echo Version: $VERSION
        exit 0
        ;;
    ?)
        show_usage
        exit 1
        ;;
    esac
done

echo "Generate Package for OpenStack version ${OS_VERSION}"

# package name is InStorage_VERSION_cinder
PACKAGE_NAME=InStorage_${OS_VERSION}_cinder

# create the directory
mkdir $PACKAGE_NAME

# copy code and modify the RUN_VERSION placeholder
cp -rf cinder/volume/drivers/inspur $PACKAGE_NAME/
sed -i "s/@RUN_VERSION@/${OS_VERSION}/" $PACKAGE_NAME/inspur/instorage/*

# copy readme
cp README.md $PACKAGE_NAME/

# copy opt only when version early than mitaka
if [[ $OS_VERSION > 'LIBERTY' ]]
then
  OS_VERSION=$(echo $OS_VERSION | tr -t [A-Z] [a-z])
  cp cinder/opts-${OS_VERSION}.py $PACKAGE_NAME/opts.py
fi
