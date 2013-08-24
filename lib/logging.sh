#!/bin/bash
##
#  /usr/lib/lxc-tools/logging.sh
#
#  logging utilities
#
##

logging_file()
{
	start="= Start logging of $1 ="
	scriptname=$(basename $0)
	if [ "$SYSLOG" == 'true' ]; then
		if [ "$VERBOSE" == 'true' ]; then
			DEBUG='-s'
		else
			DEBUG=''
		fi
		logger "$DEBUG" $start
	fi
	# create a new logging file
	LOGFILE="$LOGDIR/$1.log"
	# echo "[$(date +"%D %T")] $start" > $LOGFILE
	echo "`date +"%D %T"` $scriptname : $start" > $LOGFILE
	# echo "`date` - $start\n" >> $LOGFILE
	
}

# log a message
# $1 level
# $2 message
#log {
#    "`date` - ${1} - ${2}\n" >> $LOGFILE
#}

logData() 
{
	message="$*"
	printf %s "$message" | while IFS= read -r line
	do
		echo "aca: $line" >> $LOGFILE
	done
}

logMessage () {
  scriptname=$(basename $0)
  echo "`date +"%D %T"` $scriptname : $@" >> $LOGFILE
}
