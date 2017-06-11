#!/bin/bash
# we assume that this script runs on a freshly installed system
#so we first install docker
sudo apt-get update && sudo apt-get install -y docker.io
#then we source the clusterdock prerequisites, see https://blog.cloudera.com/blog/2016/08/multi-node-clusters-with-cloudera-quickstart-for-docker/
source /dev/stdin <<< "$(curl -sL http://tiny.cloudera.com/clusterdock.sh)"
#now everything is prepared to start the cluster
clusterdock_run ./bin/start_cluster cdh
