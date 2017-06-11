#for some reason not always the name resolution is good in these containers, so add the google DNS just in case
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
#make a temporary directory to store the downloaded csv files
mkdir /tmp/data
#go there
cd /tmp/data
#run the script that will download all the csv files
wget -qO- https://raw.githubusercontent.com/academyofdata/clusterdock/master/getrawdata.sh | bash -s
