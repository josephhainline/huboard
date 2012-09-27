#!/bin/bash

if [ `ps -ef | grep huboard/bin/rackup | grep -v grep | awk '{print $2}'` ]
then
  # process was found
  echo "Huboard is already running..."
else
  # process not found
  echo "Starting Huboard..."
  pushd /home/dev1/huboard
  bundle exec rackup -D
  popd
fi

