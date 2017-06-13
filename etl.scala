import com.databricks.spark.avro._

val ratings = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("/input/ratings.csv")
val movies = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("/input/movies.csv")
val users = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("/input/users.csv")

ratings.saveAsParquetFile("/data/1m/ratings.parquet")
movies.saveAsParquetFile("/data/1m/movies.parquet")
users.saveAsParquetFile("/data/1m/users.parquet")

sqlContext.setConf("spark.sql.avro.compression.codec", "deflate")
sqlContext.setConf("spark.sql.avro.deflate.level", "5")

ratings.write.format("com.databricks.spark.avro").save("/data/1m/ratings.avro")
movies.write.format("com.databricks.spark.avro").save("/data/1m/movies.avro")
users.write.format("com.databricks.spark.avro").save("/data/1m/users.avro")

