#script to execute inside one of the containers
#create the topic first
kafka-topics --create --zookeeper node-1.cluster:2181 --topic aod --partitions 1 --replication-factor 1
cd /tmp
#get the python code from git repo
wget -q https://raw.githubusercontent.com/academyofdata/clusterdock/master/kafka-streaming.py
#submit the job
spark-submit --master yarn --deploy-mode client --conf "spark.dynamicAllocation.enabled=false" kafka-streaming.py node-1.cluster:2181 aod
#start publishing in another window with this command
#kafka-console-producer --broker-list node-2.cluster:9092 --topic aod

