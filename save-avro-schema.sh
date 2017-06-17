#run in container
for file in ratings.avro ratings.parquet 
do
  wget -O- https://raw.githubusercontent.com/academyofdata/clusterdock/master/get-avro-schema.sh | bash -s "/data/1m/$file"
  
done
