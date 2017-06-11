# clusterdock

The script(s) here can be used by simply invoking e.g.

`wget -qO- https://raw.githubusercontent.com/academyofdata/clusterdock/master/script.sh|
 bash -s`

once the docker cluster is running (there should be two nodes started with the default startup options), one can log in to one of the containers with the following command

docker exec -ti \`docker ps | grep clusterdock | grep secondary | head -1 | awk '{print $1}'\` bash

