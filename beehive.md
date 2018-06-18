## Connecting to Hive from the command line

Once logged in on a system with hive installed type 
```
beeline
```
to start the Hive CLI. Beeline is a REPL interface for Hive. If everything is ok (paths etc) you'll get a prompt
```
beeline>
```
Now connect to the Hive server by issuing the following command
```
!connect  jdbc:hive2://localhost:10000
```
(replace with hostname or IP as required)

You'll be prompted for a username and a password, in a default instalation they will probably be hive/hive. If the connection is successful the output will show some info about the driver and the prompt will change
```
Connected to: Apache Hive (version 1.1.0-cdh5.12.1)
Driver: Hive JDBC (version 1.1.0-cdh5.12.1)
Transaction isolation: TRANSACTION_REPEATABLE_READ
0: jdbc:hive2://localhost:10000>
```
If at any point you are unsure what connection is acctive type 
```
!list
```
to get an output similar with this
```
1 active connection:
 #0  open     jdbc:hive2://localhost:10000
```
From this point on you can type any HiveQL statements , for instance
```
0: jdbc:hive2://localhost:10000> select * from intro_hadoop.table limit 3;
```
to get an output similar with this
```
INFO  : Compiling command(queryId=hive_20180618181111_689a949b-aedc-4375-8b26-071444a193f5): select * from intro_hadoop.movies_hive limit 3
INFO  : Semantic Analysis Completed
INFO  : Returning Hive schema: Schema(fieldSchemas:[FieldSchema(name:movies_hive.movieid, type:int, comment:null), FieldSchema(name:movies_hive.title, type:string, comment:null), FieldSchema(name:movies_hive.genre, type:string, comment:null), FieldSchema(name:movies_hive.year, type:int, comment:null)], properties:null)
INFO  : Completed compiling command(queryId=hive_20180618181111_689a949b-aedc-4375-8b26-071444a193f5); Time taken: 0.137 seconds
INFO  : Executing command(queryId=hive_20180618181111_689a949b-aedc-4375-8b26-071444a193f5): select * from intro_hadoop.movies_hive limit 3
INFO  : Completed executing command(queryId=hive_20180618181111_689a949b-aedc-4375-8b26-071444a193f5); Time taken: 0.001 seconds
INFO  : OK
.......................................
.....(actual query result is here).....
```

