# jdk5 install script for OSX starting from Lion.

Automate the install of JDK 5 on Lion, Mountain Lion, Mavericks.
 
## The story behind this script

Apple decided to ship JDK6 with Lion and thus abandoned his own crafted JDK5. Also the Apple JDK5 dmg doesn't
install anymore on Lion and newer versions of OSX. This script uses technics that have proven useful to get 
around that.
At this moment this script has been tested up to Maverics. Hopefully it can work on later versions of OSX, but eventually Apple will change OSX significantly enough so that these hacks ar eno longer possible.

As a reminder this is an Apple implementation and the Sun implementation is not anymore maintained since quite some time.

## Script in action

![script in action](http://blog.arkey.fr/wp-content/uploads/2011/08/jdk5_install_mountain_lion.png)
French post http://blog.arkey.fr/2012/07/30/script-pour-installer-le-jdk-5-sur-macosx-lion/

## Changes

| Date       | Changes |
| ---------- | ----------------------------------------------------------------------------------------------- |
| 2014/02/10 | Updated the script to run on OSX 10.9 Maverick |
| 2013/05/11 | Added a few more guidance when Java Preferences is not available anymore  |
|            | Added a simple example of a JDK switch function. |
| 2012/08/25 | This script didn't behave correctly when ran on 10.8.1 |
|            | Added recommendation to always run this script after updates such as Java, XCode, OSX, etc. |
| 2012/07/29 | Added Mountain Lion support => Choose the 64bit JVM ! |
|            | Can dowload the Java DMG itself if not present in same directory |
|            | Colored the output a bit, works well on a black background |
|            | Added tips for using the different JVMs |
|            | Removed 32bit mode for Mountain Lion (Thanks to Henri Gomez for pointing me to 'ditto') |
| 2011/12/04 | Added warnings and some more information on gotchas |
| 2011/08/25 | Updated this very comments |
| 2011/08/22 | Initial version (Thanks to Benjamin Morin for his blog post) |
|            | This script heavily inspired/copied from http://www.s-seven.net/java_15_lion |

## Note from the author

> This project was orignally a [gist](https://gist.github.com/bric3/1163008), but given I don't have time to 
> maintain it, I'd prefer to have a proper project that can accept _pull requests_ that may keep this script 
> up to date.

There's valuable comments on that gist!

## LICENSE or WARRANTY

This free for everyone, but if can improve the script this would be very welcome.

**There's NO warranty at all, this can break havoc on your machine.** I am not responsible for any of that that's your responsibility to use this script or not. This script has been working on my machine.

Since I've decided to use updated software, and develop on updated JDK, I don't have to use JDK5 anymore. So that means that I can't provide help anymore. Nor update that script frequently.
