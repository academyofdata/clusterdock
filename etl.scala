import com.databricks.spark.avro._

//valid values for compression codec: snappy, deflate, uncompressed
sqlContext.setConf("spark.sql.avro.compression.codec", "snappy")
sqlContext.setConf("spark.sql.avro.deflate.level", "5")
sqlContext.setConf("spark.sql.parquet.compression.codec", "snappy")

val ratings = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("/input/ratings/ratings.csv")
val ratings_all = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("/input/ratings-all/ratings-all.csv")
val movies = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("/input/movies/movies.csv")
val users = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("/input/users/users.csv")


//if we want that parquet/avro files are saved in a single partition we do it like this
ratings.coalesce(1).saveAsParquetFile("/data/1m/ratings.parquet")
ratings.coalesce(1).write.format("com.databricks.spark.avro").save("/data/1m/ratings.avro")
ratings.coalesce(1).saveAsParquetFile("/data/1m/ratings-all.parquet")
ratings.coalesce(1).write.format("com.databricks.spark.avro").save("/data/1m/ratings-all.avro")
//otherwise we just do
//ratings.write.format("com.databricks.spark.avro").save("/data/1m/ratings.avro")
//ratings.saveAsParquetFile("/data/1m/ratings.parquet")

//movies and users are small files, they will anyway tend to generate a single partition, coalesce is not really required
movies.coalesce(1).saveAsParquetFile("/data/1m/movies.parquet")
users.coalesce(1).saveAsParquetFile("/data/1m/users.parquet")
movies.coalesce(1).write.format("com.databricks.spark.avro").save("/data/1m/movies.avro")
users.coalesce(1).write.format("com.databricks.spark.avro").save("/data/1m/users.avro")




