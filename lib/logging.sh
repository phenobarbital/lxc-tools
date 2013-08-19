#!/bin/bash
##
#  /usr/lib/lxc-tools/logging.sh
#
#  logging utilities
#
##

function log() 
{
  while read data
  do
      echo "[$(date +"%D %T")] $data" 
  done
}

log () {
  echo $@
  echo "[$(date +"%D %T")] $@" >> $logfile
}

function log_warning()
{
}

function log_error()
{
}
