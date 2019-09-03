#!/bin/bash

################################################################################
#  Licensed to the Apache Software Foundation (ASF) under one
#  or more contributor license agreements.  See the NOTICE file
#  distributed with this work for additional information
#  regarding copyright ownership.  The ASF licenses this file
#  to you under the Apache License, Version 2.0 (the
#  "License"); you may not use this file except in compliance
#  with the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

### If unspecified, the hostname of the container is taken as the JobManager address
JOB_MANAGER_RPC_ADDRESS=${JOB_MANAGER_RPC_ADDRESS:-$(hostname -f)}
FLINK_ADD_CONFIG=${FLINK_ADD_CONFIG}
drop_privs_cmd() {
    if [ -x /sbin/su-exec ]; then
        # Alpine
        echo su-exec
    else
        # Others
        echo gosu
    fi
}
add_config(){
       stringarray=$FLINK_ADD_CONFIG
       OLD_IFS="$IFS"
       IFS="|"
       array=($stringarray)
       IFS="$OLD_IFS"
       i=0
        while [ $i -lt ${#array[@]} ]
        do
                echo "${array[i]}: ${array[i+1]}" >> "$FLINK_HOME/conf/flink-conf.yaml"
                let i=i+2
        done
}

if [ "$1" = "help" ]; then
    echo "Usage: $(basename "$0") (jobmanager|taskmanager|local|help)"
    exit 0
elif [ "$1" = "jobmanager" ]; then
    echo "Starting Job Manager"
    sed -i -e "s/jobmanager.rpc.address: localhost/jobmanager.rpc.address: ${JOB_MANAGER_RPC_ADDRESS}/g" "$FLINK_HOME/conf/flink-conf.yaml"
    add_config
    echo "config file: " && grep '^[^\n#]' "$FLINK_HOME/conf/flink-conf.yaml"
    exec $(drop_privs_cmd) flink "$FLINK_HOME/bin/jobmanager.sh" start-foreground 
elif [ "$1" = "taskmanager" ]; then
    echo "Starting Task Manager"
    sed -i -e "s/jobmanager.rpc.address: localhost/jobmanager.rpc.address: ${JOB_MANAGER_RPC_ADDRESS}/g" $FLINK_HOME/conf/flink-conf.yaml
    add_config
    echo "config file: " && grep '^[^\n#]' "$FLINK_HOME/conf/flink-conf.yaml"
    exec $(drop_privs_cmd) flink "$FLINK_HOME/bin/taskmanager.sh" start-foreground 
elif [ "$1" = "local" ]; then
    echo "Starting local cluster"
    exec $(drop_privs_cmd) flink "$FLINK_HOME/bin/jobmanager.sh" start-foreground local
fi

exec "$@"
