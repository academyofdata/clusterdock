
Create the table to read the data from the CSV file

`
CREATE TABLE ratings_all_csv (uid int, age int, gennder string, ocupation int, zip string, rating double, datetime timestamp, mid int, title string, year int, genres string) 
COMMENT 'data loaded with serde org.apache.hadoop.hive.serde2.OpenCSVSerde' 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde' 
WITH SERDEPROPERTIES ( "separatorChar" = "\,", "quoteChar" = "\"") 
STORED AS TEXTFILE tblproperties("skip.header.line.count"="1");
`

Load data from the CSV file (beware of the user that executes the query and the mode/rights on the file!)

`
LOAD DATA INPATH  '/tmp/ratings-all.csv' OVERWRITE into table ratings_all_csv;
`

Now, because we're using OpenCSVSerde all our datatypes are overwritten to string, we need to create a separate table (same structure, different name) in which to load the data with the right types. Doing this also allows us to query the data from Impala, since Hive and Impala share the same metastore (do not forget to do a `invalidate metadata` in Impala to reload the tables created in Hive)

`
CREATE TABLE ratings_all (uid int, age int, gennder string, ocupation int, zip string, rating double, datetime timestamp, mid int, title string, year int, genres string) 
COMMENT 'data loaded from ratings_all_csv' 
`

followed by 

`
insert overwrite table ratings_all select * from ratings_all_csv
`

