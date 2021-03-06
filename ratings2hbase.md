
Create the table to read the data from the CSV file

```
CREATE TABLE ratings_all_hive (userid int, age int, gender string, occupation int, zip string, rating double, rating_time timestamp, movieid int, title string, year int, genres string) 
COMMENT 'data loaded with serde org.apache.hadoop.hive.serde2.OpenCSVSerde' 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde' 
WITH SERDEPROPERTIES ( "separatorChar" = "\,", "quoteChar" = "\"") 
STORED AS TEXTFILE tblproperties("skip.header.line.count"="1");
```

Load data from the CSV file (beware of the user that executes the query and the mode/rights on the file!, **THIS WILL MOVE THE ORIGINAL FILE!**)

```
LOAD DATA INPATH  '/tmp/ratings-all.csv' OVERWRITE into table ratings_all_hive;
```

Alternatively, to define the table from an existing csv file do ( **NOTE THIS will just link to the csv file ** )

```
CREATE EXTERNAL TABLE ratings_all_hive 
(userid INT, age INT, gender STRING, occupation INT,zip STRING,rating INT, rating_time INT,movieid INT, title STRING, year INT, genre STRING) 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde' WITH SERDEPROPERTIES ( "separatorChar" = "\,", "quoteChar" = "\"")
STORED AS TEXTFILE LOCATION "/input/ratings-all" tblproperties("skip.header.line.count"="1")
```
This way you won't need to run the ```LOAD DATA```


Now, because we're using OpenCSVSerde, all our datatypes are overwritten to string, we need to create a separate table (same structure, different name) in which to load the data with the right types. Doing this also allows us to query the data from Impala, since Hive and Impala share the same metastore (do not forget to do a `invalidate metadata` in Impala to reload the tables created in Hive)

```
CREATE TABLE ratings_all_impala (userid int, age int, gender string, occupation int, zip string, rating double, rating_time timestamp, movieid int, title string, year int, genres string) 
COMMENT 'data loaded from ratings_all_hive' 
```

Alternatively (if you chose the second option when defining the table) do this
```
create table ratings_all_impala as select cast (userid as int) As userid, cast (age as int) As age, gender, cast (occupation as int) As occupation, zip, cast (rating as double) As rating, rating_time, cast (movieid as int) As movieid, title, genre, cast (year as int) As year from ratings_all_hive 
```



followed by 

```
insert overwrite table ratings_all select * from ratings_all_csv
```

let's now create a view onto this data (this allows us not to duplicate - again - the data)

```
CREATE VIEW IF NOT EXISTS viewforhbase (rowkey, rating, datetime, user, movie) AS
   SELECT concat_ws('-',concat("",movieid),concat("",userid)),rating,rating_time,map("userid",userid,"age",age,"zip",zip,"occupation",occupation,"gender",gender),map("movieid",movieid,"title",title,"year",year,"genre",genre)
   FROM ratings_all_impala;
```

check how the data looks by issuing the following command
```
select * from viewforhbase limit 5
```

Note how we concatenated the movie id and user id to generate a string that will be used as HBase row key.

We create now a table with the HBase SerDe

```
CREATE TABLE IF NOT EXISTS ratings_hbase (rowkey STRING, rating double, datetime timestamp, user map<string,string>, movie map<string,string>)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ('hbase.columns.mapping' = ':key,rating:rating,rating:datetime,user:,movie:')
TBLPROPERTIES ('hbase.table.name' = 'ratings_all');
```

at last we populate the data from the view to HBase

```
insert into table ratings_hbase select * from viewforhbase
```

check the data
```
select * from ratings_hbase limit 5
```

You can now check that everything went fine by dropping to HBase shell ([see here how to do that](https://github.com/academyofdata/clusterdock/blob/master/cheatsheet.md#hbase)) and doing, for instance 

```
count 'ratings_all', INTERVAL=>1
```

or

```
get 'ratings_all','104-3850'
```

which should output something similar with

```
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
 ```
 
 (you can compare the performance of the query above with this Hive query ```select * from ratings_hbase where rowkey='104-3850'``` which semantically does the exact same thing )
 
 If we want to get all the ratings of a particular movie (of which we must know the id!) we could do
 
 ```
 scan 'ratings_all',{ROWPREFIXFILTER=>'104-'}
 ```
 
 (this gets the ratings for the movie with id 104)
 
 or, to get only the rating and the timestamp
 
 ```
 scan 'ratings_all',{ROWPREFIXFILTER=>'104-',COLUMNS=>['rating:rating','rating:datetime']}
 ```

If we want to get all the ratings of a specific user, things are a bit more complex, i.e. you need first to import some helper classes into hbase shell and then issue the 'scan' command

```
import org.apache.hadoop.hbase.filter.CompareFilter
import org.apache.hadoop.hbase.filter.SubstringComparator
scan 'ratings_all', {FILTER => org.apache.hadoop.hbase.filter.RowFilter.new(CompareFilter::CompareOp.valueOf('EQUAL'),SubstringComparator.new("-3850"))}
```
