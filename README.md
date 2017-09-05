# clusterdock

To setup a cluster based on [clusterdock](https://github.com/cloudera/clusterdock) on a 'fresh' system, simply do

```
wget -qO- https://raw.githubusercontent.com/academyofdata/clusterdock/master/cluster-setup.sh|
 bash -s
```

once the docker cluster is running (there should be two nodes started with the default startup options) issue the following command to download all the files required and put them onto HDFS

```
sudo docker exec -ti \`sudo docker ps | grep clusterdock | grep secondary | head -1 | awk '{print $1}'\` bash -c "wget -qO- https://raw.githubusercontent.com/academyofdata/clusterdock/master/get2hdfs.sh | bash -s"
```

Otherwise, one can log in to one of the containers (the secondary node in the example below) with the following command

```
sudo docker exec -ti `sudo docker ps | grep clusterdock | grep secondary | head -1 | awk '{print $1}'` bash
```

## (Re)starting containers

If you followed the steps above to start a two node cluster and for whatever reason the containers have stopped and need to be restarted, simply issue the following command

```
sudo docker ps -a | grep cloudera | grep node | grep cdh | awk '{print $1}' | xargs sudo docker start
```

**NOTE: in the standard setup, when restarting the containers, HBase server tends to not start - that is most of the times due to an overcommitment of the heap memory on the Region Server. If you see that the status of HBase in the CM console is red, go to HBase/Configuration and look for the parameter called "Java Heap Size of HBase RegionServer in Bytes". It is probably set to something like 10GB which, for these small sandboxes is an overkill. Set it to 1GB, save the config and restart (or just start) HBase



## Google Cloud Engine usage

Should you wish to start a sandbox environment onto GCE please take note of the resource requirements. With the default services enabled by clusterdock, the minimum machine instance is n1-standard-4 (which comes with 15 GB RAM) - anything with less RAM will not succcessfully create the cluster

The command can be something like this (change zone and/or add --project as required; change instance name as you wish)

```
gcloud compute instances create cdock --zone us-east4-a --machine-type n1-standard-4 --maintenance-policy "MIGRATE" --image "https://www.googleapis.com/compute/v1/projects/ubuntu-os-clo
ud/global/images/family/ubuntu-1604-lts" --boot-disk-size "50" --boot-disk-type "pd-standard" --boot-disk-device-name "cdockdisk1"
```

once the machine started simply do 

```
gcloud compute ssh cdock --zone us-east4-a --command "wget -qO- https://raw.githubusercontent.com/academyofdata/clusterdock/master/cluster-setup.sh|
 bash -s"
```
 
(the first step described above, to setup the cluster)
followed by 

```
gcloud compute ssh cdock --zone us-east4-a --command "wget -O- https://raw.githubusercontent.com/academyofdata/clusterdock/master/getindocker.sh | bash -s"
```

