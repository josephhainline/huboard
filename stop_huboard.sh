#!/bin/bash

if [ `ps -ef | grep huboard/bin/rackup | grep -v grep | awk '{print $2}'` ]
then
  # process was found
  echo "Killing Huboard..."
  kill `ps -ef | grep huboard/bin/rackup | grep -v grep | awk '{print $2}'`
else
  # process not found
  echo "Huboard is already stopped."
fi

