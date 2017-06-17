#run in container
for file in ratings.avro ratings-all.avro users.avro movies.avro
do
  wget -O- https://raw.githubusercontent.com/academyofdata/clusterdock/master/get-avro-schema.sh | bash -s "/data/1m/$file"
  HADOOP_USER_NAME=hdfs hdfs dfs -put /tmp/schema.avsc /metadata/$file
done
