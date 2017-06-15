cd /tmp
wget -q https://raw.githubusercontent.com/academyofdata/clusterdock/master/random-string-for-kafka-producer.sh
chmod +x ./random-string-for-kafka-producer.sh
./random-string-for-kafka-producer.sh > kafka-console-producer --broker-list node-2.cluster:9092 --topic aod
