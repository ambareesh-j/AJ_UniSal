# Databricks notebook source
# MAGIC %md
# MAGIC ### Processing IoT data using Spark DataFrames

# COMMAND ----------

# Read IoT JSON data into a dataframe
df = spark.read.json("/databricks-datasets/iot/iot_devices.json")

# COMMAND ----------

# Count records
df.count()

# COMMAND ----------

# Show some of the entries
df.show(10)

# COMMAND ----------

# Filtering data
dfTempDF = df.filter((df.temp > 30) & (df.humidity > 70))
dfTempDF.show(10)

# COMMAND ----------

# Select particular columns you're interested in after filtering
dfTemp = df.where(df.temp > 25).select(["temp", "device_name", "device_id", "cca3"])
dfTemp.show(10)

# COMMAND ----------

# Can also sort
df.select(["battery_level", "c02_level", "device_name"]).where(df.battery_level > 6).sort("c02_level").show(10)

# COMMAND ----------

# Apply group by etc
df.select(["temp", "humidity", "cca3"]).groupBy("cca3").avg().show(10)

# COMMAND ----------

# MAGIC %md
# MAGIC ### Use the SQL visualizations

# COMMAND ----------

dfTempDF.createOrReplaceTempView("iot_device_data")

# COMMAND ----------

# MAGIC %sql 
# MAGIC select * from iot_device_data

# COMMAND ----------

# MAGIC %md
# MAGIC Count all devices for a particular country and map them. (Select the map visualization!)

# COMMAND ----------

# MAGIC %sql select cca3, count(device_id) as number, avg(humidity), avg(temp) from iot_device_data group by cca3 order by number desc limit 20

# COMMAND ----------

# MAGIC %md
# MAGIC Find the distribution for devices in the country where C02 is high and visualize the results as a pie chart. (Select the pie chart visualization)

# COMMAND ----------

# MAGIC %sql select cca3, c02_level from iot_device_data where c02_level > 1400 order by c02_level desc
