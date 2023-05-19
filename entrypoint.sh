#!/bin/bash

wait-for-it -t ${STARTUP_TIMEOUT:-30} $DB_HOST:$DB_PORT
if [[ $? == 0 ]]
then
   exec $@
fi

