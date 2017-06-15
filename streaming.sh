#script to execute inside one of the containers
#create the topic first
kafka-topics --create --zookeeper node-1.cluster:2181 --topic aod --partitions 1 --replication-factor 1
cd /tmp
wget -q 
#submit the job
spark-submit --master yarn --deploy-mode client --conf "spark.dynamicAllocation.enabled=false" kafka-streaming.py node-1.cluster:2181 aod

