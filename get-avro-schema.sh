#script that tries to get the schema from an Avro file
#to be run in one of the containers
#uses an utility avro-tools.jar that ships with the Avro distribution
#in CDH it is wrapped in a script /usr/bin/avro-tools
cd /tmp
FILE=`hdfs dfs -ls -d $1/*.avro | head -1 | awk '{print $8}'`
hdfs dfs -cat $FILE | head --bytes 10K > sample.avro
avro-tools getschema ./sample.avro > schema.avsc
rm ./sample.avro
cat ./schema.avsc
