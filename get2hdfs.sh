#for some reason not always the name resolution is good in these containers, so add the google DNS before running this, just in case
#echo "nameserver 8.8.8.8" >> /etc/resolv.conf
#make a temporary directory to store the downloaded csv files
mkdir /tmp/data
#go there
cd /tmp/data
#run the script that will download all the csv files
wget -qO- https://raw.githubusercontent.com/academyofdata/clusterdock/master/getrawdata.sh | bash -s
#if everything went fine we should have some csv files in /tmp/data, put them onto hdfs
#first do a little setup - create a few directories and give everyone in HDFS unrestricted access
HADOOP_USER_NAME=hdfs hdfs dfs -mkdir /data
HADOOP_USER_NAME=hdfs hdfs dfs -chmod a+w /data
HADOOP_USER_NAME=hdfs hdfs dfs -mkdir /metadata
HADOOP_USER_NAME=hdfs hdfs dfs -chmod a+w /metadata
HADOOP_USER_NAME=hdfs hdfs dfs -mkdir /input
HADOOP_USER_NAME=hdfs hdfs dfs -chmod a+w /input
#now put the files in there
HADOOP_USER_NAME=hdfs hdfs dfs -put /tmp/data/movies.csv /input/movies/movies.csv
HADOOP_USER_NAME=hdfs hdfs dfs -put /tmp/data/users.csv /input/users/users.csv
HADOOP_USER_NAME=hdfs hdfs dfs -put /tmp/data/ratings.csv /input/movies/ratings.csv
