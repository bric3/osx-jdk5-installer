#!/bin/bash

# This script is edited by Brice Dutheil
# See there in french http://blog.arkey.fr/2012/07/30/script-pour-installer-le-jdk-5-sur-macosx-lion/
# Translate button is broken for now, please use Google to translate this website.
#
# 2015/05/24 Updated the script to run on OSX 10.10.x Yosemite.
#            This version may not work for older versions of OSX. For other versions 
#            use https://gist.github.com/bric3/1163008.
#
# 2014/02/10 Updated the script to run on OSX 10.9 Maverick
#
# 2013/05/11 Added a few more guidance when Java Preferences is not available anymore 
#            Added a simple example of a JDK switch function.
#
# 2012/08/25 This script didn't behave correctly when ran on 10.8.1
#            Added recommendation to always run this script after updates such as Java, XCode, OSX, etc.
#
# 2O12/07/29 Added Mountain Lion support => Choose the 64bit JVM !
#            Can dowload the Java DMG itself if not present in same directory
#            Colored the output a bit, works well on a black background
#            Added tips for using the different JVMs
#            Removed 32bit mode for Mountain Lion (Thanks to Henri Gomez for pointing me to 'ditto')
#
# 2011/12/04 Added warnings and some more information on gotchas
#
# 2011/08/25 Updated this very comments
#
# 2011/08/22 Initial version (Thanks to Benjamin Morin for his blog post)
#            This script heavily inspired/copied from http://www.s-seven.net/java_15_lion






#some variables
javadmgurl='http://support.apple.com/downloads/DL1359/en_US/JavaForMacOSX10.5Update10.dmg'
javapkg='JavaForMacOSX10.5Update10'
jvmver='1.5.0_30'
jvms_path='/System/Library/Java/JavaVirtualMachines'
java_frmwk_path='/System/Library/Frameworks/JavaVM.framework/Versions'
pushd `dirname $0` > /dev/null
script_location=`pwd -P`
popd > /dev/null

# locate Java Preferences in /Applications
java_prefs=`mdfind -onlyin /Applications "Java Preferences.app"`



declare "osxname_14=OS 11"
declare "osxname_13=Mavericks"
declare "osxname_12=Mountain Lion"
declare "osxname_11=Lion"

get_osx_name() {
  local array="osxname" key=$1
  local declare_name="${array}_${key}"
  printf '%s' "${!declare_name}"
}

# 13.0.0 = Mavericks = 10.9.0
# 12.1.0 = Mountain Lion = 10.8.1
# 12.0.0 = Mountain Lion = 10.8
# 11.0.0 = Lion = 10.7

darwin_version=`uname -r`
osx_version=`sw_vers -productVersion`
osx_commercial_name=$(get_osx_name ${darwin_version%.[0-9].[0-9]})
test ${darwin_version/1[2-9]./} != $darwin_version && is_mountain_lion=true



# colors and style
RESET=`tput sgr0`
RED=`tput setaf 1`
BLUE=`tput setaf 4`
PURPLE=`tput setaf 5`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
UNDERLINED=`tput smul`
BOLD=`tput bold`



# escape aware echo
echo() { builtin echo -e $@; }  



# Make sure only root can run the script
if [ $EUID -ne 0 ]; then
   echo $RED'This script must be run as root in order to install the JDK! If unsure why check the script.'$RESET 1>&2
   exit 1
fi




# Make sure the user understand he is all alone if something goes wrong
if [ $is_mountain_lion ]; then
    echo $BLUE'==>'$RESET' You are using '$BOLD$osx_commercial_name$RESET', the script has been updated to work, however 
'$osx_commercial_name' kernel works in 64bit. This shouldn'"'"'t be an issue, as event the JDK 6 32bit is working,
however 32bit mode doesn'"'"'t work for this hacky install of JDK 5. '$YELLOW'It means that only 
the 64bit version of the JDK5 will work on your OS.'$RESET
    echo
fi
echo $BLUE'==>'$RESET' The present script has been tested on my current setup and is far from 
bulletproof, it might not work at all on your system. And there is '$RED'*no 
uninstall script*'$RESET' for now!'
echo 
echo $BLUE'==>'$RESET' Again '$RED'this script touches system files'$RESET', please be advised you are the sole
responsible to run or '$BOLD'TO NOT'$RESET' run this script on your machine.'
echo


# Reminder about Apple JDK updates
echo $YELLOW$UNDERLINED'NOTES :'$RESET
echo $BLUE'==>'$RESET' Generally speaking it seems that '$YELLOW'applying updates'$RESET' on your system Java, XCode, OSX, etc.
might cause problems with your current install, '$RED'reapply this script after any update if you
experience issues with your Java 5 install.'$RESET
echo $BLUE'==>'$RESET' When '$YELLOW'applying a Java update from Apple'$RESET', some important 
symbolic names that refer to this install are resetted to factory default 
values, you can just re-apply this script.'$RESET
echo
if [[ -n "$java_prefs" && $is_mountain_lion ]]; then
echo $BLUE'==>'$RESET' For people that where upgrading OS X, it seems this scripts fail to open 
Java Preferences app at the end of the script, with an error like that:'
echo $PURPLE'\tLSOpenURLsWithRole() failed with error -10810 for the application /Applications/Utilities/Java Preferences.app.'
echo $PURPLE'\tFSPathMakeRef(/Applications/Utilities/Java Preferences.app) failed with error -43.'
echo
echo $YELLOW'   If this is happening, '$RED'you have to (re)install Java 6 !'
echo $YELLOW'   You can enter these commands yourself in root mode :'
echo $YELLOW'\tsudo rm -rf /System/Library/Java/JavaVirtualMachines/1.6.0.jdk'
echo '\tsudo rm -rf /System/Library/Java/JavaVirtualMachines'
echo '\tjava'
echo 
echo $RESET'   This last command will trigger the Java 6 install, then you can run again this script.'$RESET
echo
fi

printf "%s " 'Do you still want to proceed ? (y/n)'
read answer
[ $answer != 'y' ] && echo 'You'"'"'re fine, JDK5 Hacky Install script has been aborted' && exit 1
echo



echo
echo $UNDERLINED'Here we go...'$RESET
# ===================================
echo

if [ ! -f $javapkg.dmg ]; then
    echo 'The "Java for Mac OS X 10.5 Update 10" DMG ('"$javapkg.dmg"') was not found locally.'
    echo 'Now trying to download the DMG file from Apple website (http://support.apple.com/kb/DL1359).'
    echo $javadmgurl' -> '$script_location/$javapkg.dmg
    echo -n $BLUE
    curl -C - -# -L $javadmgurl -o $script_location/$javapkg.dmg
    echo -n $RESET

    if [ ! -f $script_location/$javapkg.dmg ]; then
        echo 'Couldn'"'"'t download the uptate. Please download it from Apple at : 
http://support.apple.com/kb/DL1359'
        echo 'And place it in the same folder as this script : '$script_location
        exit 1
    fi
else
    echo 'Using '$javapkg'.dmg file to install "Java for Mac OS X 10.5 Update 10".'
fi





# Extracting the DMG content in temporary location
echo
echo 'Extracting Java for Mac OS X package'
mkdir /tmp/jdk5dmg
hdiutil attach -quiet -nobrowse -mountpoint /tmp/jdk5dmg/ $script_location/$javapkg.dmg
cd /tmp/jdk5dmg/
# too bad pkgutil nor xar cannot stream package content
pkgutil --expand $javapkg.pkg /tmp/jdk5pkg

cd ..
hdiutil detach -quiet -force /tmp/jdk5dmg/
rm -rf /tmp/jdk5dmg/




# Prepare the System JVM path
if [ ! -e $jvms_path ]; then
    echo 'Create '$jvms_path', as it does not exist on your system (it might be because 
you don'"'"' t have another Java install).'
    mkdir -v -p $jvms_path
fi

echo
echo 'Removing previous Java 1.5 file / directory or symbolic links in :'
cd $jvms_path
pwd
rm -rf 1.5
rm -rf 1.5.0
cd $java_frmwk_path
pwd
rm 1.5/ > /dev/null 2>&1 || rm -rf 1.5 > /dev/null 2>&1
rm 1.5.0/ > /dev/null 2>&1 || rm -rf 1.5.0 > /dev/null 2>&1
rm -rf $jvmver 2>&1




echo
echo $UNDERLINED'Preparing JavaVM framework'$RESET
# ================================================
echo

echo 'Extracting JDK 1.5.0 from package payload in :'
cd $java_frmwk_path
pwd
gzip -cd /tmp/jdk5pkg/$javapkg.pkg/Payload | pax -r -s \
		',.'$java_frmwk_path'/1.5.0,./'$jvmver','      \
		'.'$java_frmwk_path'/1.5.0'
ls -Fld 1.5*

rm -rf /tmp/jdk5pkg/

echo
echo 'Recreating symbolic links to ./'"$jvmver"' for 1.5 and 1.5.0 :'
pwd
ln -svhF ./$jvmver 1.5
ln -svhF ./$jvmver 1.5.0

echo
echo 'Changing values in config files to make JDK work with '$osx_commercial_name
cd $jvmver
/usr/libexec/PlistBuddy -c "Delete :JavaVM:JVMMaximumFrameworkVersion" ./Resources/Info.plist
/usr/libexec/PlistBuddy -c "Delete :JavaVM:JVMMaximumSystemVersion" ./Resources/Info.plist
/usr/libexec/PlistBuddy -c "Add :CFBundleExecutable string libjava.jnilib" ./Resources/Info.plist
ln -siv ./Resources/Info.plist .

echo
echo 'Linking Apple native wrapper'
mkdir ./MacOS
ln -siv ../Libraries/libjava.jnilib ./MacOS




echo
echo $UNDERLINED'Preparing Java Virtual Machine'$RESET
# ====================================================
cd $jvms_path
mkdir -v 1.5.0
cd 1.5.0
pwd
ln -sivh $java_frmwk_path/$jvmver ./Contents


if [ $is_mountain_lion ]; then
    echo
    echo $BOLD'REMINDER'$RESET' : You are using '$osx_commercial_name' which is running a '$BOLD'64 bit kernel'$RESET', this causes segfaults
when the Java 5 JVM is run in 32 bit mode. For this reason this script removes 32bit mode on this JVM.'$RESET

    ditto --arch x86_64 $java_frmwk_path/$jvmver $java_frmwk_path/$jvmver-x64
    rm -rf $java_frmwk_path/$jvmver
    mv $java_frmwk_path/$jvmver-x64 $java_frmwk_path/$jvmver
fi




echo
echo $UNDERLINED'Almost over...'$RESET
# ====================================
echo

# opening Java Preferences
if [ -n "$java_prefs" ]; then
    # open -a "/Applications/Utilities/Java Preferences.app"
echo $BLUE'==> TIP'$YELLOW' : If you are using applications that need Java 6, but some other command line apps that require JDK 5 :'
echo ' - keep the "Java SE 6" entry at the top in "Java Preferences"'
echo ' - use the Apple "/usr/libexec/java_home" tool, for example to choose the "J2SE 5.0 64-bit" version :'
echo $PURPLE'\texport JAVA_HOME=`/usr/libexec/java_home -F -v 1.5 -a x86_64 -d64`'$RESET
echo

echo 'Now check that JDK 5 appears in Java Preference App, if yes the install is successful, otherwise 
try asking the internet :-/'

    open -a "$java_prefs"
else
    echo $RED'This script could not find the Java Preferences, maybe you moved it elsewhere, or maybe you are running
a recent version of MacOSX.'$RESET

    echo 'In recents MacOSX, Apple decided to remove the Java Preference app, which means you
cannot reorder the JDK Preferences, hence you cannot choose JDK5 as a defaukt JDK for the whole OS, 
you can only specify it in the terminal via the $PATH variable.'
    echo
    echo 'Check that /usr/libexec/java_home knows about JDK5, other wise try asking the internet :-/'
fi

echo '(starting here : '$YELLOW'https://gist.github.com/1163008#comments'$RESET')'
echo

echo
echo $UNDERLINED'/usr/libexec/java_home says :'$RESET
# ===================================================
# listing JVMs on local machine
echo $(/usr/libexec/java_home -V 2>&1 | sed -E 's,$,\\n,g' | sed -E 's,.*J2SE 5.0.*,\\033[0;33m&\\033[00m,')

echo $UNDERLINED'java -version says :'$RESET
echo $(/usr/libexec/java_home -F -v 1.5 -a x86_64 --exec java -version 2>&1 | sed -E 's,$,\\n,g' | sed -E 's,java version.*,\\033[0;33m&\\033[00m,')
echo 

echo $UNDERLINED'You can also try the java 5 command yourself'$RESET
# ==================================================================
# possible commands
echo $GREEN'\t/usr/libexec/java_home -F -v 1.5 -a x86_64 --exec java -version'$RESET
echo $GREEN'\t`/usr/libexec/java_home -F -v 1.5 -a x86_64`/bin/java -version'$RESET
echo
echo 'Don'"'"'forget to update the JAVA_HOME accordingly!'
echo


printf "%s" 'Yeah I got it ! (Press Enter) '
read -s -n 0 key_press
echo

echo
echo
echo $BLUE'==> TIP'$RESET' : To switch the JDK version in your shell you can use the great '$BOLD'jenv'$RESET' project ('$YELLOW'https://github.com/gcuisinier/jenv'$RESET'), 
that can easily switch your JDK version globally or per shell or folder.'
echo 'jenv pretty much covers for the terminal what the Java Preference app did, but in much usable way for terminal users.'
echo
echo 'The old school way would be to change the java runtime with the correct runtime path in $JAVA_HOME and $PATH'
echo 'Below is a simple function that you can put in your shell rc (.bashrc, .zshrc, ...) that automates steps
to switch the JDK to the wanted version. Adapt it to your needs. It uses the Apple tool : /usr/libexec/java_home'
echo
# /System/Library/Java/JavaVirtualMachines/1.5.0/Contents/Home/bin
# /Library/Java/JavaVirtualMachines/jdk1.7.0_13.jdk/Contents/Home/bin
echo $GREEN'\tfunction switch_jdk() {'
echo '\t\tlocal wanted_java_version=$1'
echo '\t\texport JAVA_HOME=`/usr/libexec/java_home -F -v $wanted_java_version -a x86_64 -d64`'
echo '\t'
echo '\t\t# cleaned PATH'
echo '\t\texport PATH=$(echo $PATH | sed -E "s,(/System)?/Library/Java/JavaVirtualMachines/[a-zA-Z0-9._]+/Contents/Home/bin:,,g")'
echo '\t'
echo '\t\t# prepend wanted JAVA_HOME'
echo '\t\texport PATH=$JAVA_HOME/bin:$PATH'
echo '\t'
echo '\t\techo "Now using : "'
echo '\t\tjava -version'
echo '\t}'$RESET
echo

echo 'And just use it this way :'
echo $GREEN'\tswitch_jdk 1.5'$RESET
echo $GREEN'\tswitch_jdk 1.7.0_45'$RESET
echo $GREEN'\tswitch_jdk 1.7.0_51'$RESET



echo
echo $RESET'.'
