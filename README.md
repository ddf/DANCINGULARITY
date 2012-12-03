DANCINGULARITY
==============

THE DANCINGULARITY is a Processing sketch, which must be run in Processing 1.5.1 due to the graphics library we use.

REQUIRED LIBRARIES

* GLGraphics (http://glgraphics.sourceforge.net/)
* OCD (http://gdsstudios.com/processing/libraries/ocd/)
* proCONTROLL (http://creativecomputing.cc/p5libs/procontroll/)

REQUIRED HARDWARE

THE DANCINGULARITY is controlled by 9 DDR dance mats, specifically XBox 360 DDR dance mats. Due to these controller requirements, it must be run in Linux using the xboxdrv controller driver (http://pingus.seul.org/~grumbel/xboxdrv/). Create a config file with the following:

[xboxdrv]
#1
dpad-as-button=true
#2
next-controller=true
dpad-as-button=true
#3
next-controller=true
dpad-as-button=true
#4
next-controller=true
dpad-as-button=true
#5
next-controller=true
dpad-as-button=true
#6
next-controller=true
dpad-as-button=true
#7
next-controller=true
dpad-as-button=true
#8
next-controller=true
dpad-as-button=true
#9
next-controller=true
dpad-as-button=true

[xboxdrv-daemon]
dbus=disabled

And then before launcing THE DANCINGULARITY, run this from a terminal: 

sudo xboxdrv --daemon -d --config YOUR_CONFIG_FILE_NAME

If you do not run the driver, the xpad driver included in Linux will probably see the pads, but they will not be mapped correctly. If you don't have dance mats and would like to run THE DANCINGULARITY in a non-interactive mode, then you need not start the driver. If THE DANCINGULARITY does not find exactly 9 controllers, it will go into "auto-play" mode and simulate people stepping on the buttons.



