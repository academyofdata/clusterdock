#this should run in one of the clusterdock containers!
#first get the file from the grouplens.org site
yum install -y unzip
cd /tmp
wget http://files.grouplens.org/datasets/movielens/ml-20m.zip
unzip ml-20m.zip
#if everything went fine we should have all the movielens data files in /tmp/ml-20m, so put them in HDFS
HADOOP_USER_NAME=hive hdfs dfs -mkdir /input/ml20m
HADOOP_USER_NAME=hive hdfs dfs -put /tmp/ml-20m/* /input/ml20m
