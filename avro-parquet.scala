import com.databricks.spark.avro._

//valid values for compression codec: snappy, deflate, uncompressed
sqlContext.setConf("spark.sql.avro.compression.codec", "snappy")
sqlContext.setConf("spark.sql.avro.deflate.level", "5")
sqlContext.setConf("spark.sql.parquet.compression.codec", "snappy")

val ratings_all = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("/input/ratings-all/ratings-all.csv")

//if we want that parquet/avro files are saved in a single partition we do it like this
ratings_all.coalesce(1).saveAsParquetFile("/input/ratings_all_parquet")
ratings_all.coalesce(1).write.format("com.databricks.spark.avro").save("/input/ratings_all_avro")

