
Create the table to read the data from the CSV file

`
CREATE TABLE ratings_all_csv (uid int, age int, gennder string, ocupation int, zip string, rating double, datetime bigint, mid int, title string, year int, genres string) 
COMMENT 'data loaded with serde org.apache.hadoop.hive.serde2.OpenCSVSerde' 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde' 
WITH SERDEPROPERTIES ( "separatorChar" = "\,", "quoteChar" = "\"") 
STORED AS TEXTFILE tblproperties("skip.header.line.count"="1");
`
