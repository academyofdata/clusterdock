# clusterdock

To setup a cluster based on clusterdock on a 'fresh' system, simply do

`wget -qO- https://raw.githubusercontent.com/academyofdata/clusterdock/master/cluster_setup.sh|
 bash -s`

once the docker cluster is running (there should be two nodes started with the default startup options) issue the following command to download all the files required and put them onto HDFS

sudo docker exec -ti \`sudo docker ps | grep clusterdock | grep secondary | head -1 | awk '{print $1}'\` bash -c "wget -qO- https://raw.githubusercontent.com/academyofdata/clusterdock/master/get2hdfs.sh | bash -s"


Otherwise, one can log in to one of the containers (the secondary node in the example below) with the following command

sudo docker exec -ti \`sudo docker ps | grep clusterdock | grep secondary | head -1 | awk '{print $1}'\` bash

## Google Cloud Engine usage

Should you wish to start a sandbox environment onto GCE please take note of the resource requirements. With the default services enabled by clusterdock, the minimum machine instance is n1-standard-4 (which comes with 15 GB RAM) - anything with less ram will not succcessfully create the cluster

The command can be something like this (change zone and/or add --project as required; change instance name as you wish)

gcloud compute instances create cdock --zone us-east4-a --machine-type n1-standard-4 --maintenance-policy "MIGRATE" --image "https://www.googleapis.com/compute/v1/projects/ubuntu-os-clo
ud/global/images/family/ubuntu-1604-lts" --boot-disk-size "50" --boot-disk-type "pd-standard" --boot-disk-device-name "cdockdisk1"

once the machine started simply do 

`gcloud compute ssh cdock --zone us-east4-a --command "wget -qO- https://raw.githubusercontent.com/academyofdata/clusterdock/master/cluster_setup.sh|
 bash -s"`
 
(the first step described above, to setup the cluster)
followed by 

gcloud compute ssh cdock --zone us-east4-a --command "sudo docker exec -ti \`sudo docker ps | grep clusterdock | grep secondary | head -1 | awk '{print $1}'\` bash -c \\"wget -qO- https://raw.githubusercontent.com/academyofdata/clusterdock/master/get2hdfs.sh | bash -s\\""
