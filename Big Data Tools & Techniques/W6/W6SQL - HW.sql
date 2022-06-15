-- Databricks notebook source
-- MAGIC %md
-- MAGIC In this notebook you will query the table you have created.
-- MAGIC 
-- MAGIC --> 6. Use SELECT with a COUNT to find out the number of rows in the zip level risk table.

-- COMMAND ----------

SELECT COUNT(*) 
  FROM zip_level_risk;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 
-- MAGIC --> 7. You can use ORDER BY to order results of a query by the values in a specific column.
-- MAGIC 
-- MAGIC Select the values of count_property from the zip level risk table and order the output in a descending manner.

-- COMMAND ----------

SELECT count_property 
  FROM zip_level_risk 
  ORDER BY count_property DESC;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC --> 8. Find an SQL clause which selects a limited number of records. Restrict the number of records returned in the query
-- MAGIC in Point 7 to 10.

-- COMMAND ----------

SELECT count_property 
  FROM zip_level_risk 
  ORDER BY count_property DESC
  LIMIT 10;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC --> 9. The options under your Databricks results look like this:
-- MAGIC The left, as selected, gives you the numerical results. Explore the second option, to obtain a histogram plot of the
-- MAGIC results.

-- COMMAND ----------

SELECT count_property 
  FROM zip_level_risk 
  ORDER BY count_property DESC
  LIMIT 10;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC --> 10. If you look at the values of two of the columns in your table (i.e. you SELECT those), you can use the plots (such
-- MAGIC as a scatter plot) to explore the relationship between the two features. Select the values of count property and
-- MAGIC count fs risk 2020 100 from your table. Look at the scatter plot this yields.

-- COMMAND ----------

SELECT count_property, count_fs_risk_2020_100 
  FROM zip_level_risk 
  ORDER BY count_property DESC;

-- COMMAND ----------


