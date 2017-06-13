val ratings = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("/input/ml20m/ratings.csv")
