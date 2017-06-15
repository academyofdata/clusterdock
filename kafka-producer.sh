wget -qO- https://raw.githubusercontent.com/academyofdata/clusterdock/master/random-string-for-kafka-producer.sh | bash | kafka-console-producer --broker-list node-2.cluster:9092 --topic aod
