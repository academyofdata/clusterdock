#this should run in one of the clusterdock containers!
#first get the file from the grouplens.org site
yum install -y unzip
cd /tmp
wget http://files.grouplens.org/datasets/movielens/ml-20m.zip
unzip ml-20m.zip
#HADOOP_USER_NAME=hive hdfs dfs -put /tmp/ml-20m
