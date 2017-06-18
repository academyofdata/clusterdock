# Hadoop Cheatsheet
 
When using clusterdock containers, to log in to the container (assuming the container is called ‘small_morse’)

```
docker exec -it small_morse bash
```
 
Run one of the hadoop commands (‘put’ here) e.g.

```
HADOOP_USER_NAME=hdfs hdfs dfs -put /tmp/movies.csv /user/spark/
```

(hdfs is the new name of hadoop command, but hadoop can still be used, e.g.

```
HADOOP_USER_NAME=hdfs hadoop fs -put /tmp/movies.csv /user/spark/)
```
 
If it complains about safe mode

```
HADOOP_USER_NAME=hdfs hadoop dfsadmin -safemode leave
```

When executing various commands (from Hive console or Hue or otherwise) beware of the file mode and owner. For instance if you do a CREATE TABLE in Hive that requires moving the source file to Hive's data directory and the rights are not the correct ones, you'll get an error. In such cases you can work arround by changing the file access rights with the following command

`HADOOP_USER_NAME=hdfs hdfs dfs -chmod 777 /input/movies.csv`

(replace the filename to match your intention)

 
Note: If all the HDFS commands are to be run as the same user then one can simply do

```
export HADOOP_USER_NAME=<hdfsusername>
```

once per session (or at login through .bash_profile or /etc/profile or similar)

## Spark

Start 'plain' spark-shell

```
HADOOP_USER_NAME=spark spark-shell
```
 
 
Start spark-shell with databricks spark-csv jars (csv support is built in only in spark 2.0+, clusterdock uses - as of jun 2017 - spark 1.6)
 
```
HADOOP_USER_NAME=spark spark-shell --packages com.databricks:spark-csv_2.10:1.5.0
```
 
Or, to start with avro and CSV support
 
```
HADOOP_USER_NAME=spark spark-shell --packages com.databricks:spark-csv_2.10:1.5.0 com.databricks:spark-avro_2.10:3.2.0
```
 
Commands in spark-shell

```
val df = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("1m-zipuidmidtitlegenre.csv.gz")
```
 
(we assume that the file https://github.com/academyofdata/data/blob/master/1m-zipuidmidtitlegenre.csv.gz has been loaded in HDFS in /user/spark using the put command above)
 
 
To save the dataframe in Parquet format

```
df.saveAsParquetFile("/tmp/ratings.parquet")
```
 
To save it in Avro format

```
df.write.format("com.databricks.spark.avro").save("/tmp/ratings.avro")
```
 
 
## Hive
 
One can load a csv file in HDFS and then create a hive table that maps onto that file using the following sequence
 
```
HADOOP_USER_NAME=hive hdfs dfs -mkdir /tmp/movies
```
 
```
HADOOP_USER_NAME=hive hdfs dfs -put ./movies.csv /tmp/movies
```
(we assume the movies.csv is already in the current directory)
 
We’ve now set-up the HDFS part, let’s move to Hive console
 
```
HADOOP_USER_NAME=hive beeline -u jdbc:hive2://node-1.cluster:10000/default
```
 
Once here we simply do
 
```
CREATE EXTERNAL TABLE movies (mid INT, title String, genres STRING, year INT) COMMENT 'loaded from csv file' ROW FORMAT DELIMITED FIELDS TERMINATED BY '\054' STORED AS TEXTFILE LOCATION '/tmp/movies';
```

We have, so far, loaded the CSV file into a Hive table (more accurately - we've linked the table to the CSV file). Let's now save the data from the CSV into another table in Parquet format
 
```
INSERT OVERWRITE DIRECTORY '/data/movies'
STORED AS PARQUET 
select * from movies;
```
 
Or 
 
```
LOAD DATA INPATH '/input/movies.csv' into table movies_1;
```

(this ends up moving the data file to the default hive directory, usually /user/hive/warehouse)
 
Loading the data using the method above works in most of the cases, except when the fields have commas and therefore have to use quotes - like here, where the genres field is stored as e.g. “{Animation, Comedy}”. For these cases we’ll need a different approach - using a SerDe from OpenCSV, thus the table creation becomes
 
```
CREATE TABLE movies_ocsv (mid INT, title String, genres STRING, year INT)
COMMENT 'data loaded with serde org.apache.hadoop.hive.serde2.OpenCSVSerde'    
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES ( "separatorChar" = "\,", "quoteChar"     = "\"")
STORED AS TEXTFILE tblproperties("skip.header.line.count"="1");
```

*Warning: when using OpenCSVSerde the data type output for all fields will be set to string. Use an intermediary table and the CAST function to load data in the right tables using the right data types*

To create tables based on Avro format use the following 

```
create table if not exists users_avro 
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
```

to create the table followed by a `LOAD DATA INPATH` command, as shown above

## HBase

In this repository you'll find a script called 'curl-hbase.sh' that uses curl and HBase's REST server (not enabled by default in the clusterdock setup) to generate and load some data in a table called 'ztable', into two column families 'data' and 'text'. Once the script is run, one can start an HBase shell to query the result. The shell is started with the following command

```
HADOOP_USER_NAME=hbase hbase shell
```

If the shell starts correctly the prompt should say something like `hbase(main):001:0>`, this means that we can see what tables are there and query the data in them. Start with 

```
desc 'default:ztable'
```

This will get the table definition, that also shows the defined column families and their properties. Further on you can type

```
get 'ztable','row111'
```

to get the data stored at the key called 'row111', or

```
get 'ztable','row111','text:subcol2'
```

to get the cell 'text:subcol2' of the said row

## HBase to Hive

What if we want to make available the data from this HBase table, that we just set-up and provisioned with data, in Hive? We could do it using a particular SerDe - org.apache.hadoop.hive.hbase.HBaseStorageHandler. And using it is rather simple we just do

```
CREATE EXTERNAL TABLE ztable (key string, data map<string,string>, text map<string,string>) 
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ("hbase.columns.mapping" = ":key,data:,text:")
TBLPROPERTIES("hbase.table.name" = "ztable", "hbase.mapred.output.outputtable" = "ztable");
```

i.e. we tell Hive to create metadata for an external (stored in HBase's territory) table, with the key being the hbase key (mapping first field to :key), with the second field being a map of string->string where we load the 'data' column family and the last field a map where we load the 'text' column family

## Hive to HBase

We could also do the reverse: define a table in Hive and have the data available in/through HBase and it would go something like this

```
CREATE TABLE definhive(value map<string,int>, row_key int) 
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES (
"hbase.columns.mapping" = "colfam:,:key"
)
```

we could then do 

```
insert into definhive select map("aa",100),1;
insert into definhive select map("aa",200),2;
insert into definhive select map("bb",100),3;
```

and if we go to hive and do a 

`list`

we should see the table called 'definhive', and could afterwards do

```
scan 'definhive'
```

to check that the inserted data is there
## Avro

One of the nuissances when working with Avro files is providing the right schema (when creating a table in Hive, for instance) that's why there's a little helper script to help with the schema generation. 
If you generated an Avro file with Spark (as shown above) and want to get the schema from it, simply run

```
wget -O- https://raw.githubusercontent.com/academyofdata/clusterdock/master/get-avro-schema.sh | bash -s "/data/1m/ratings.avro"
```

(we assumed that the generated Avro file is /data/1m/ratings.avro).

At the end of the execution you'll have in /tmp a file called schema.avsc with the desired schema. These files should be uploaded to HDFS (e.g. `hdfs dfs -put /tmp/schema.avsc /metadata/ratings.avsc`) for easy access from Spark, Hive aso

