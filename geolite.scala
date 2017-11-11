/*
steps to enhance a geolite csv from CIDR format to include also start IP and end IP as longs
*/

import org.apache.spark.sql.functions._
import org.apache.spark.sql.types.IntegerType

def ipToLong:( String => Long) = { _.split("\\.").reverse.zipWithIndex.map(a=>a._1.toInt*math.pow(256,a._2).toLong).sum }
def endInt(x:Long,y:Int):Long = {x + scala.math.pow(2,32-y).toLong - 1}
val getEndInt = udf((x:Long,y:Int) => endInt(x,y))
val ipv4 = sqlContext.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("/data/ipv4/IPv4.csv")

ipv4
.withColumn("tmp",split($"network","/"))
.select($"network",$"geoname_id",$"registered_country_geoname_id",$"represented_country_geoname_id",$"is_anonymous_proxy",$"is_satellite_provider",$"tmp".getItem(0).as("net"),$"tmp".getItem(1).as("maskbits").cast(IntegerType))
.withColumn("startint",udf(ipToLong).apply($"net"))
.withColumn("endint",getEndInt($"startint",$"maskbits"))
.coalesce(1)
.write
.format("com.databricks.spark.csv")
.option("header", "true")
.save("/tmp/sparkdata.csv")
