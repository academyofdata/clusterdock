
Create the table to read the data from the CSV file

`
CREATE TABLE ratings_all_csv (uid int, age int, gender string, occupation int, zip string, rating double, datetime timestamp, mid int, title string, year int, genres string) 
COMMENT 'data loaded with serde org.apache.hadoop.hive.serde2.OpenCSVSerde' 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde' 
WITH SERDEPROPERTIES ( "separatorChar" = "\,", "quoteChar" = "\"") 
STORED AS TEXTFILE tblproperties("skip.header.line.count"="1");
`

Load data from the CSV file (beware of the user that executes the query and the mode/rights on the file!)

`
LOAD DATA INPATH  '/tmp/ratings-all.csv' OVERWRITE into table ratings_all_csv;
`

Now, because we're using OpenCSVSerde, all our datatypes are overwritten to string, we need to create a separate table (same structure, different name) in which to load the data with the right types. Doing this also allows us to query the data from Impala, since Hive and Impala share the same metastore (do not forget to do a `invalidate metadata` in Impala to reload the tables created in Hive)

`
CREATE TABLE ratings_all (uid int, age int, gender string, occupation int, zip string, rating double, datetime timestamp, mid int, title string, year int, genres string) 
COMMENT 'data loaded from ratings_all_csv' 
`

followed by 

`
insert overwrite table ratings_all select * from ratings_all_csv
`

let's now create a view onto this data (this allows us not to duplicate - again - the data)

`CREATE VIEW IF NOT EXISTS viewforhbase (rowkey, rating, datetime, user, movie) AS
SELECT concat_ws('-',concat("",mid),concat("",uid)),rating,datetime,map("uid",uid,"age",age,"zip",zip,"occupation",occupation,"gender",gender),map("mid",mid,"title",title,"year",year,"genres",genres)
FROM ratings_all;
`

Note how we concatenated the movie id and user id to generate a string that will be used as HBase row key.

We create now a table with the HBase SerDe

`
CREATE TABLE IF NOT EXISTS ratings_hbase (rowkey STRING, rating double, datetime timestamp, user map<string,string>, movie map<string,string>)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ('hbase.columns.mapping' = ':key,rating:rating,rating:datetime,user:,movie:')
TBLPROPERTIES ('hbase.table.name' = 'ratings_all');
`

at last we populate the data from the view to HBase

`
insert into table ratings_hbase select * from viewforhbase
`

You can now check that everything went fine by dropping to HBase shell and doing, for instance 

`
get 'ratings_all','104-3850'
`
which should output something similar with

`
COLUMN  CELL
 movie:genres timestamp=1497781581729, value={Comedy}
 movie:mid timestamp=1497781581729, value=104
 movie:title timestamp=1497781581729, value=Happy Gilmore (1996)
 movie:year timestamp=1497781581729, value=1996
 rating:datetime timestamp=1497781581729, value=2000-08-10 04:10:29
 rating:rating timestamp=1497781581729, value=4.0
 user:age timestamp=1497781581729, value=18
 user:gender timestamp=1497781581729, value=M
 user:occupation timestamp=1497781581729, value=3
 user:uid timestamp=1497781581729, value=3850
 user:zip timestamp=1497781581729, value=92278
 `
 
 If we want to get all the ratings of a particular movie (of which we must know the id!) we could do
 
 `
 scan 'ratings_all',{ROWPREFIXFILTER=>'104-'}
 `
 
 (this gets the ratings for the movie with id 104)
 
 or, to get only the rating and the timestamp
 
 `
 scan 'ratings_all',{ROWPREFIXFILTER=>'104-',COLUMNS=>['rating:rating','rating:datetime']}
 `
