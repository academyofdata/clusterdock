#!/bin/bash
#script to create a bunch of directors and copy data files into them
users=$(cat $1)
for i in $users
do
        echo "processing $i"
        HADOOP_USER_NAME=hdfs hdfs dfs -mkdir /data/$i
        HADOOP_USER_NAME=hdfs hdfs dfs -cp  /data/movielens-1M/* /data/$i
done
