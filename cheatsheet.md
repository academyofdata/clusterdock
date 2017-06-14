# Hadoop Cheatsheet
 
When using clusterdock containers, to log in to the container (assuming the container is called ‘small_morse’)

`docker exec -it small_morse bash`
 
Run one of the hadoop commands (‘put’ here) e.g.

`HADOOP_USER_NAME=hdfs hdfs dfs -put /tmp/movies.csv /user/spark/`

(hdfs is the new name of hadoop command, but hadoop can still be used, e.g.

`HADOOP_USER_NAME=hdfs hadoop fs -put /tmp/movies.csv /user/spark/)`
 
If it complains about safe mode

`HADOOP_USER_NAME=hdfs hadoop dfsadmin -safemode leave`

When executing various commands (from Hive console or Hue or otherwise) beware of the file mode and owner. For instance if you do a CREATE TABLE in Hive that requires moving the source file to Hive's data directory and the rights are not the correct ones, you'll get an error. In such cases you can work arround by changing the file access rights with the following command

`HADOOP_USER_NAME=hdfs hdfs dfs -chmod 777 /input/movies.csv`

(replace the filename to match your intention)

 
Start spark-shell

`HADOOP_USER_NAME=spark spark-shell`
 
Note: If all the HDFS commands are to be run as the same user then one can simply do

`export HADOOP_USER_NAME=<hdfsusername>`

once per session (or at login through .bash_profile or /etc/profile or similar)

## Spark
 
Start spark-shell with databricks spark-csv jars (csv support is built in only in spark 2.0+, clusterdock uses - as of jun 2017 - spark 1.6)
 
`HADOOP_USER_NAME=spark spark-shell --packages com.databricks:spark-csv_2.10:1.5.0`
 
Or, to start with avro and CSV support
 
`HADOOP_USER_NAME=spark spark-shell --packages com.databricks:spark-csv_2.10:1.5.0 com.databricks:spark-avro_2.10:3.2.0`
 
Commands in spark-shell

`val df = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("1m-zipuidmidtitlegenre.csv.gz")`
 
(we assume that the file https://github.com/academyofdata/data/blob/master/1m-zipuidmidtitlegenre.csv.gz has been loaded in HDFS in /user/spark using the put command above)
 
 
To save the dataframe in Parquet format

`df.saveAsParquetFile("/tmp/ratings.parquet")`
 
To save it in Avro format

`df.write.format("com.databricks.spark.avro").save("/tmp/ratings.avro")`
 
 
## Hive
 
One can load a csv file in HDFS and then create a hive table that maps onto that file using the following sequence
 
`HADOOP_USER_NAME=hive hdfs dfs -mkdir /tmp/movies`
 
`HADOOP_USER_NAME=hive hdfs dfs -put ./movies.csv /tmp/movies`
(we assume the movies.csv is already in the current directory)
 
We’ve now set-up the HDFS part, let’s move to Hive console
 
`HADOOP_USER_NAME=hive beeline -u jdbc:hive2://node-1.cluster:10000/default`
 
Once here we simply do
 
`CREATE EXTERNAL TABLE movies (mid INT, title String, genres STRING, year INT) COMMENT 'loaded from csv file' ROW FORMAT DELIMITED FIELDS TERMINATED BY '\054' STORED AS TEXTFILE LOCATION '/tmp/movies';`

We have, so far, loaded the CSV file into a Hive table (more accurately - we've linked the table to the CSV file). Let's now save the data from the CSV into another table in Parquet format
 
`INSERT OVERWRITE DIRECTORY '/data/movies'
STORED AS PARQUET 
select * from movies;`
 
Or 
 
`LOAD DATA INPATH '/input/movies.csv' into table movies_1;`

(this ends up moving the data file to the default hive directory, usually /user/hive/warehouse)
 
Loading the data using the method above works in most of the cases, except when the fields have commas and therefore have to use quotes - like here, where the genres field is stored as e.g. “{Animation, Comedy}”. For these cases we’ll need a different approach - using a SerDe from OpenCSV, thus the table creation becomes
 
`CREATE TABLE movies_ocsv (mid INT, title String, genres STRING, year INT)
COMMENT 'data loaded with serde org.apache.hadoop.hive.serde2.OpenCSVSerde'    
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES ( "separatorChar" = "\,", "quoteChar"     = "\"")
STORED AS TEXTFILE tblproperties("skip.header.line.count"="1");`

*Warning: when using OpenCSVSerde the data type output for all fields will be set to string. Use an intermediary table and the CAST function to load data in the right tables using the right data types*

To create tables based on Avro format use the following 

`create table if not exists users_avro 
ROW FORMAT
SERDE 'org.apache.hadoop.hive.serde2.avro.AvroSerDe'
STORED AS
INPUTFORMAT 'org.apache.hadoop.hive.ql.io.avro.AvroContainerInputFormat'
OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.avro.AvroContainerOutputFormat'
TBLPROPERTIES ('avro.schema.literal'='{
  "namespace": "testing",
  "name": "users",
  "type": "record",
  "fields": [
    {"name":"uid","type":"int","doc":"user id"},
    {"name":"gender","type":"string","doc":"user gender"},
    {"name":"age","type":"int","doc":"user age"},
    {"name":"ocupation","type":"int","doc:":"id of ocupation"},
    {"name":"zip","type":"string","doc:":"user address zip code"}
  ]
}')
`
to create the table followed by a `LOAD DATA INPATH` command, as shown above
