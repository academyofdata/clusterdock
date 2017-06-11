# clusterdock

To setup a cluster based on clusterdock on a 'fresh' system, simply do
`wget -qO- https://raw.githubusercontent.com/academyofdata/clusterdock/master/script.sh|
 bash -s`

once the docker cluster is running (there should be two nodes started with the default startup options) issue the following command to download all the files required and put them onto HDFS

`sudo docker exec -ti \`sudo docker ps | grep clusterdock | grep secondary | head -1 | awk '{print $1}'\` bash -c "wget -qO- https://raw.githubusercontent.com/academyofdata/clusterdock/master/get2hdfs.sh | bash -s"`


Otherwise, one can log in to one of the containers (the secondary node in the example below) with the following command

sudo docker exec -ti \`sudo docker ps | grep clusterdock | grep secondary | head -1 | awk '{print $1}'\` bash

