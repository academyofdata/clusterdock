#this script transforms the HDFS stored CSV files to AVRO and Parquet formats using spark-shell and a small scala script
cd /tmp
#gets the ETL script into /tmp, the saved file will be called avro-parquet.scala
wget -q https://raw.githubusercontent.com/academyofdata/clusterdock/master/avro-parquet.scala
#runs spark-shell providing the script as input
HADOOP_USER_NAME=spark spark-shell --packages com.databricks:spark-csv_2.10:1.5.0 com.databricks:spark-avro_2.10:3.2.0 -i avro-parquet.scala 
