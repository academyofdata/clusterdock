#script to execute inside one of the containers
kafka-topics --create --zookeeper node-1.cluster:2181 --topic aod --partitions 1 --replication-factor 1

