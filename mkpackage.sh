#!/bin/bash

set -e

# fixup the version str
VERSION=${1:0:1}
case $VERSION in
  'j'|'J') 
         VERSION='JUNO'
         ;;
  'k'|'K')
         VERSION='KILO'
         ;;
  'l'|'L') 
         VERSION='LIBERTY'
         ;;
  'm'|'M') 
         VERSION='MITAKA'
         ;;
  'n'|'N')
         VERSION='NEWTON'
         ;;
  'o'|'O') 
         VERSION='OCATA'
         ;;
  'p'|'P') 
         VERSION='PIKE'
         ;;
  *) 
    echo "Version $1 not support"
    echo "Usage $0 [j|k|l|m|n|o|p]"
    exit 1
    ;;
  
esac

# package name is G2_VERSION_cinder
PACKAGE_NAME=G2_${VERSION}_cinder

# create the directory
mkdir $PACKAGE_NAME

# copy code and modify the RUN_VERSION placeholder
cp -rf cinder/volume/drivers/inspur $PACKAGE_NAME/
sed -i "s/@RUN_VERSION@/${VERSION}/" $PACKAGE_NAME/inspur/instorage/*

# copy readme
cp README.md $PACKAGE_NAME/

# copy opt only when version early than mitaka
if [[ $VERSION > 'LIBERTY' ]]
then
  VERSION=$(echo $VERSION | tr -t [A-Z] [a-z])
  cp cinder/opts-${VERSION}.py $PACKAGE_NAME/opts.py
fi
