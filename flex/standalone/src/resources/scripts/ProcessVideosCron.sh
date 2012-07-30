#!/bin/sh

#Checks if the video transcoding script is running and if so exits without launching it
if ps -ef | grep -v grep | grep ProcessVideosCron.php ; then
	exit 0
else
	#This script should be placed in the same folder as the php script for the pwd to work
	/usr/bin/php `pwd`/ProcessVideosCron.php >>/var/www/babelium/logs/transcode.log &
	exit 0
fi
