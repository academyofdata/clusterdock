val ratings = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("/input/ratings.csv")
val movies = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("/input/movies.csv")
val users = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("/input/users.csv")
