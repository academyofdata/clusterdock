#this script enables ssh password login on a newly created GCE machine (they default allow only key logins)
# run it like this (INSTANCE and ZONE represent your instance name and ZONE), hduser is the newly added user
# gcloud compute ssh ${INSTANCE} --zone ${ZONE} --command "wget -qO- https://raw.githubusercontent.com/academyofdata/clusterdock/master/cluster-setup.sh | bash -s hduser"


echo "enabling Password Login"
sudo sed -i -e 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

echo "reloading sshd"
sudo /etc/init.d/ssh reload

echo "adding user '$1'"
sudo adduser $1 --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password

PASSWD=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1`
echo "setting user password to: $PASSWD"
echo "$1:$PASSWD" | sudo chpasswd

echo "adding user to sudo group"
sudo usermod -G docker,$1 $1
