#!/bin/bash
ZONE="europe-west3-a"
SID=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 6 | tr '[:upper:]' '[:lower:]'| head -n 1`
INSTANCE="cdock-${SID}"
gcloud compute instances create ${INSTANCE} --zone ${ZONE} --machine-type n1-standard-4 --maintenance-policy "MIGRATE" --image "https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts" --boot-disk-size "50" --boot-disk-type "pd-standard" --boot-disk-device-name "${INSTANCE}disk"

echo "waiting for the machine ${INSTANCE} to come up"
sleep 30

gcloud compute ssh ${INSTANCE} --zone ${ZONE} --command "wget -qO- https://raw.githubusercontent.com/academyofdata/clusterdock/master/cluster-setup.sh | bash -s"

gcloud compute ssh ${INSTANCE} --zone ${ZONE} --command "wget -qO- https://raw.githubusercontent.com/academyofdata/clusterdock/master/getindocker.sh | bash -s"
