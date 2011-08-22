#!/bin/bash

# By the way this script heavily inspired/copied from http://www.s-seven.net/java_15_lion
# script edited by Brice Dutheil

# Make sure only root can run the script
if [ $EUID -ne 0 ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Make sure the user understand he is all alone if something goes wrong
echo 'The present script has been tested on my current setup, and far from bulletproof,
 it might not work at all on your system. No uninstall script for now!'
echo 'Again this scripts touches system files, please be advised you are the sole
 responsible to run or TO NOT run this script on your machine.'
echo -n 'Proceed ? (y/n)'
read answer
[ $answer != 'y' ] && echo 'JDK5 Lion Install script aborted' && exit 1

#some variables
javapkg='JavaForMacOSX10.5Update10'
jvmver='1.5.0_30'

if [ ! -f $javapkg.dmg ];
then
    echo 'The "Java for Mac OS X 10.5 Update 10" DMG ('"$javapkg.dmg"') was not found.
 Please download it from Apple at : http://support.apple.com/kb/DL1359'
fi

echo
echo 'Extracting Java for Mac OS X package'
mkdir /tmp/jdk5dmg
hdiutil attach -quiet -nobrowse -mountpoint /tmp/jdk5dmg/ $javapkg.dmg
cd /tmp/jdk5dmg/
# too bad pkgutil nor xar can stream package content
pkgutil --expand $javapkg.pkg /tmp/jdk5pkg

cd ..
hdiutil detach -quiet -force /tmp/jdk5dmg/
rm -rf /tmp/jdk5dmg/

echo
echo 'Removing previous Java 1.5 file / directory or symbolic links in :'
cd /System/Library/Java/JavaVirtualMachines
pwd
rm -rf 1.5.0
cd /System/Library/Frameworks/JavaVM.framework/Versions
pwd
rm 1.5/ > /dev/null 2>&1 || rm -rf 1.5 > /dev/null 2>&1
rm 1.5.0/ > /dev/null 2>&1 || rm -rf 1.5.0 > /dev/null 2>&1
rm -rf $jvmver 2>&1

echo
echo 'Preparing JavaVM framework'
echo '========================'

echo
echo 'Extracting JDK 1.5.0 from package payload in :'
cd /System/Library/Frameworks/JavaVM.framework/Versions
pwd
gzip -cd /tmp/jdk5pkg/JavaForMacOSX10.5Update10.pkg/Payload | pax -r -s ',./System/Library/Frameworks/JavaVM.framework/Versions/1.5.0,./'"$jvmver"',' './System/Library/Frameworks/JavaVM.framework/Versions/1.5.0'
ls -Fld 1.5*

rm -rf /tmp/jdk5pkg/

echo
echo 'Recreating symbolic links to ./'"$jvmver"' for 1.5 and 1.5.0 :'
pwd
ln -sivh ./$jvmver 1.5
ln -sivh ./$jvmver 1.5.0

echo
echo 'Changing values in config files to make JDK work with Lion'
cd $jvmver
/usr/libexec/PlistBuddy -c "Set :JavaVM:JVMMaximumFrameworkVersion 14.*.*" ./Resources/Info.plist
/usr/libexec/PlistBuddy -c "Set :JavaVM:JVMMaximumSystemVersion 10.7.*" ./Resources/Info.plist
/usr/libexec/PlistBuddy -c "Add :CFBundleExecutable string libjava.jnilib" ./Resources/Info.plist
ln -siv ./Resources/Info.plist .

echo
echo 'Preparing native wraping'
mkdir ./MacOS
ln -siv ../Libraries/libjava.jnilib ./MacOS

echo
echo 'Preparing Java Virtual Machines'
echo '==============================='
cd /System/Library/Java/JavaVirtualMachines
mkdir -v 1.5.0
cd 1.5.0
pwd
ln -sivh /System/Library/Frameworks/JavaVM.framework/Versions/$jvmver ./Contents

echo
echo 'And finally check that JDK 5 appears in Java Preference App'
open "/Applications/Utilities/Java Preferences.app"
