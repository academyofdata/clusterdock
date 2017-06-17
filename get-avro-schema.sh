#scripts that tries to get the schema from an Avro file
#to be run in one of the containers
#uses an utility avro-tools.jar that ships with the Avro distribution
#in CDH it is wrapped in a script /usr/bin/avro-tools
hdfs dfs -ls -d $1/*.avro | head -1 | awk '{print $8}'
