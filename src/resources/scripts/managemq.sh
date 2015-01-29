#!/bin/sh
 
WORKERS=5;

wfilename="worker.php"
wfullpath="/var/www/babeliumlms/scripts/$wfilename"

x=0
 
while [ "$x" -lt "$WORKERS" ];
do
        WORKER_COUNT=`pgrep -f $wfilename | wc -l`
        if [ $WORKER_COUNT -ge $WORKERS ]; then
                exit 0
        fi
        x=`expr $x + 1`
        php -f $wfullpath &
done
exit 0
