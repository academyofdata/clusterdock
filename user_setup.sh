#!/bin/bash
export HADOOP_USER_NAME=hdfs
baseCmd="hdfs dfs"
#make root dir
rootDir="/data/movielens"
${baseCmd} -mkdir ${rootDir}

dirs="movies users ratings ratings-all"

for d in $dirs
do
        echo "making:${rootDir}/${d}"
        ${baseCmd} -mkdir ${rootDir}/${d}
done
#movies_internal_hive separately

${baseCmd} -mkdir ${rootDir}/movies_internal_hive

localDir="/tmp/data"

echo "copying from local filesys (in ${localDir})"

for d in $dirs
do
        echo "copying ${localDir}/${d}"
        ${baseCmd} -put ${localDir}/${d}.csv ${rootDir}/${d}/${d}.csv
done

#movies_internal_hive separately
${baseCmd} -put ${localDir}/movies.csv ${rootDir}/movies_internal_hive/movies.csv

#script to create a bunch of directors and copy data files into them
users=$(cat $1)
for i in $users
do
        echo "processing $i"
        HADOOP_USER_NAME=hdfs hdfs dfs -mkdir /data/$i
        HADOOP_USER_NAME=hdfs hdfs dfs -cp  {$rootDir}/* /data/$i
done
