-- Databricks notebook source
-- MAGIC %md
-- MAGIC ## Project CORD-19 - HiveQL - Big Data Tools & Techniques 

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 
-- MAGIC ### 1. Setting the stage

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 
-- MAGIC #### 1.1 Input Variable Declaration : CORD19 - YYYY_MM_DD & ScimagoJr - YYYY

-- COMMAND ----------

-- Enter CORD19 dataset date - YYYY_MM_DD format only
SET cord19_date = ${Enter_CORD19_Dataset_Date} ;

-- Enter SJR dataset Year - YYYY format only
SET sjr_year = ${Enter_ScimagoJr_Dataset_Year} ;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 
-- MAGIC #### 1.2 Use the Hive Variables created to pass in Database name and Table name variables

-- COMMAND ----------

-- Set the Database name
SET db_name = cprd ;

-- Set the CORD19 table name
SET metadata_table = metadata_${hivevar:cord19_date} ;

-- Set the Scimago Journal Rankings table name
SET scimagojr_table = scimagojr_${hivevar:sjr_year} ;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### ASSUMPTION - Hive Metastore has our .csv files manually imported and stored

-- COMMAND ----------

SET cord19_hivepath = "dbfs:/user/hive/warehouse/${hivevar:metadata_table}.csv"

-- COMMAND ----------

SET sjr_hivepath = "dbfs:/user/hive/warehouse/${hivevar:scimagojr_table}.csv"

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 
-- MAGIC ### 2. Data Preparation & Scrubbing

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### 2.1 Create Database from the Hive variable : db_name

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ##### 2.1.1 Drop, Create & Show Database

-- COMMAND ----------

DROP DATABASE IF EXISTS ${hivevar:db_name} CASCADE;
CREATE DATABASE ${hivevar:db_name} WITH DBPROPERTIES (
  ID = 001,
  Name = 'Ambareesh Jonnavittula',
  Type = 'admin',
  DBType = 'Production'
);
SHOW DATABASES;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ##### 2.1.2 Describe the Database Properties

-- COMMAND ----------

DESCRIBE DATABASE EXTENDED ${hivevar:db_name}

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 
-- MAGIC #### 2.2 Create permanent tables in the Database

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ##### 2.2.1 Create a table for cord19 dataset and rename it in the format - 'metadata_YYYY_MM_DD' within the database

-- COMMAND ----------

DROP TABLE IF EXISTS ${hivevar:db_name}.${hivevar:metadata_table};
CREATE TABLE ${hivevar:db_name}.${hivevar:metadata_table} USING CSV OPTIONS (
  path ${hivevar:cord19_hivepath},
  header "true",
  inferSchema "true",
  delimiter ",",
  quote "\"",
  escape "\""
);

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ###### 2.2.1.1 Quality Check for 'metadata_table'

-- COMMAND ----------

SELECT COUNT(*) as `Num_of_Records` FROM ${hivevar:db_name}.${hivevar:metadata_table}

-- COMMAND ----------

SELECT
  *
FROM
  ${hivevar:db_name}.${hivevar:metadata_table}
LIMIT
  2;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ##### 2.2.2 Create a table for scimagojr dataset and rename it in the format 'scimagojr_YYYY' within the database

-- COMMAND ----------

DROP TABLE IF EXISTS ${hivevar:db_name}.${hivevar:scimagojr_table};
CREATE TABLE ${hivevar:db_name}.${hivevar:scimagojr_table} USING CSV OPTIONS (
  path ${hivevar:sjr_hivepath},
  header "true",
  inferSchema "true",
  delimiter ";"
);

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ###### 2.2.2.1 Quality Check for {scimagojr_table}

-- COMMAND ----------

SELECT
  *
FROM
  ${hivevar:db_name}.${hivevar:scimagojr_table}
LIMIT
  2;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 
-- MAGIC #### 2.3 Create Temporary view for cord19 dataset

-- COMMAND ----------

CREATE OR REPLACE TEMP VIEW temp_${hivevar:metadata_table}
  USING CSV OPTIONS (
  path ${hivevar:cord19_hivepath},
  header "true",
  inferSchema "true",
  delimiter ",",
  quote "\"",
  escape "\""
);

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ##### 2.3.1 Quality Check for temp view 'metadata_table'

-- COMMAND ----------

SELECT COUNT(*) as `Num_of_Records` FROM temp_${hivevar:metadata_table}

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 
-- MAGIC #### 2.4 Parquet file to Table

-- COMMAND ----------

DROP TABLE IF EXISTS ${hivevar:db_name}.parq_${hivevar:metadata_table};

CREATE TABLE ${hivevar:db_name}.parq_${hivevar:metadata_table}
   ( cord_uid STRING,
     sha STRING, 
     source_x STRING,
     title STRING,
     doi STRING,
     pmcid STRING,
     pubmed_id STRING,
     license STRING,
     abstract STRING,
     publish_time STRING,
     authors STRING,
     journal STRING,
     url STRING
   )
--   LIKE ${hivevar:db_name}.${hivevar:metadata_table}
  STORED AS PARQUET 
  LOCATION "dbfs:/user/hive/warehouse/cord19" ;

-- COMMAND ----------

INSERT OVERWRITE TABLE ${hivevar:db_name}.parq_${hivevar:metadata_table}
  SELECT cord_uid,
         sha, 
         source_x,
         title,
         doi,
         pmcid,
         pubmed_id,
         license,
         abstract,
         publish_time,
         authors,
         journal,
         url
  FROM ${hivevar:db_name}.${hivevar:metadata_table};

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ##### 2.4.1 Quality Check for parquet table created

-- COMMAND ----------

SELECT COUNT(*) as `Num_of_Records` FROM ${hivevar:db_name}.parq_${hivevar:metadata_table}

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### 2.5 Validate the Tables within the database, Views and describe them

-- COMMAND ----------

SHOW TABLES
FROM
  ${hivevar:db_name};

-- COMMAND ----------

SHOW VIEWS LIKE 'temp_metadata*'

-- COMMAND ----------

DESCRIBE EXTENDED ${hivevar:db_name}.${hivevar:metadata_table} ; 

-- COMMAND ----------

DESCRIBE EXTENDED ${hivevar:db_name}.parq_${hivevar:metadata_table} ; 

-- COMMAND ----------

DESCRIBE EXTENDED temp_${hivevar:metadata_table};

-- COMMAND ----------

DESCRIBE EXTENDED ${hivevar:db_name}.${hivevar:scimagojr_table} ; 

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### 3. Task 1. Find the 5 most common journals, list them along with their frequencies.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### 3.1 Using Permanent Tables

-- COMMAND ----------

SELECT
  journal AS `Name of the Journal`,
  count(journal) AS Frequency
FROM
  ${hivevar:db_name}.${hivevar:metadata_table}
GROUP BY
  journal
ORDER BY
  Frequency DESC
LIMIT
  5

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### 3.2 Using Temp View

-- COMMAND ----------

SELECT
  journal AS `Name of the Journal`,
  count(journal) AS Frequency
FROM
  temp_${hivevar:metadata_table}
GROUP BY
  journal
ORDER BY
  Frequency DESC
LIMIT
  5

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### 3.3 Using Table from Parquet File

-- COMMAND ----------

SELECT
  journal AS `Name of the Journal`,
  count(journal) AS Frequency
FROM
  ${hivevar:db_name}.parq_${hivevar:metadata_table}
GROUP BY
  journal
ORDER BY
  Frequency DESC
LIMIT
  5

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### 4. Task 2. The top 5 average abstract lengths (number of words) per journal.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### 4.1 Using Permanent Tables

-- COMMAND ----------

SELECT
  journal AS `Name of the Journal`,
  ROUND(
    AVG(
      LENGTH(abstract) - LENGTH(REPLACE(abstract, ' ', '')) + 1
        ),1) AS `Average Abstract lengths`
FROM
  ${hivevar:db_name}.${hivevar:metadata_table}
GROUP BY
  journal
ORDER BY
  `Average Abstract lengths` DESC
LIMIT
  5

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### 4.2 Using Temp View

-- COMMAND ----------

SELECT
  journal AS `Name of the Journal`,
  ROUND(
    AVG(
      LENGTH(abstract) - LENGTH(REPLACE(abstract, ' ', '')) + 1
        ),1) AS `Average Abstract lengths`
FROM
  temp_${hivevar:metadata_table}
GROUP BY
  journal
ORDER BY
  `Average Abstract lengths` DESC
LIMIT
  5

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### 4.3 Using Table from Parquet File

-- COMMAND ----------

SELECT
  journal AS `Name of the Journal`,
  ROUND(
    AVG(
      LENGTH(abstract) - LENGTH(REPLACE(abstract, ' ', '')) + 1
        ),1) AS `Average Abstract lengths`
FROM
  ${hivevar:db_name}.parq_${hivevar:metadata_table}
GROUP BY
  journal
ORDER BY
  `Average Abstract lengths` DESC
LIMIT
  5

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### 5. Task 3. Titles of the 5 papers with the highest numbers of authors. 
-- MAGIC Both the numbers of authors and the corresponding titles need to be output.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### 5.1 Using Permanent Tables

-- COMMAND ----------

SELECT
  title as Title,
  COUNT(author) AS `Number of Authors`
FROM
  (
    SELECT
      title,
      explode(split(authors, ";")) as author
    FROM
      ${hivevar:db_name}.${hivevar:metadata_table}
  )
GROUP BY
  title
ORDER BY
  `Number of Authors` DESC
LIMIT
  5 
  
  -- Error in SQL statement: AnalysisException: Generators are not supported when it's nested in expressions, so we are doing a subquery

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### 5.2 Using Temp View

-- COMMAND ----------

SELECT
  title as Title,
  COUNT(author) AS `Number of Authors`
FROM
  (
    SELECT
      title,
      explode(split(authors, ";")) as author
    FROM
      temp_${hivevar:metadata_table}
  )
GROUP BY
  title
ORDER BY
  `Number of Authors` DESC
LIMIT
  5 

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### 5.3 Using Table from Parquet File

-- COMMAND ----------

SELECT
  title as Title,
  COUNT(author) AS `Number of Authors`
FROM
  (
    SELECT
      title,
      explode(split(authors, ";")) as author
    FROM
      ${hivevar:db_name}.parq_${hivevar:metadata_table}
  )
GROUP BY
  title
ORDER BY
  `Number of Authors` DESC
LIMIT
  5 

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### 6. Task 4. The top 5 most prolific authors along with the number of papers they have contributed to.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### 6.1 Using Permanent Tables

-- COMMAND ----------

SELECT
  TRIM(full_list) AS `Name of the Author`,
  COUNT(*) AS `Number of Papers`
FROM
  ${hivevar:db_name}.${hivevar:metadata_table} LATERAL VIEW EXPLODE(SPLIT(authors, ';')) AS full_list
WHERE
 TRIM(full_list) NOT RLIKE '[0-9]'
GROUP BY
  `Name of the Author`
ORDER BY
  `Number of Papers` desc
LIMIT
  5

-- COMMAND ----------

-- MAGIC 
-- MAGIC %md
-- MAGIC #### 6.2 Using Temp View

-- COMMAND ----------

SELECT
  TRIM(full_list) AS `Name of the Author`,
  COUNT(*) AS `Number of Papers`
FROM
  temp_${hivevar:metadata_table} LATERAL VIEW EXPLODE(SPLIT(authors, ';')) AS full_list
WHERE
 TRIM(full_list) NOT RLIKE '[0-9]'
GROUP BY
  `Name of the Author`
ORDER BY
  `Number of Papers` desc
LIMIT
  5

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### 6.3 Using Table from Parquet File

-- COMMAND ----------

SELECT
  TRIM(full_list) AS `Name of the Author`,
  COUNT(*) AS `Number of Papers`
FROM
  ${hivevar:db_name}.parq_${hivevar:metadata_table} LATERAL VIEW EXPLODE(SPLIT(authors, ';')) AS full_list
WHERE
 TRIM(full_list) NOT RLIKE '[0-9]'
GROUP BY
  `Name of the Author`
ORDER BY
  `Number of Papers` desc
LIMIT
  5

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### 7. Task 5. List the 5 people with the top author H-index values
-- MAGIC 
-- MAGIC An author's H index is computed by summing all the H indexes of the journals they've published in (as included in the scimagojr dataset), .

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### 7.1 Using Permanent Tables

-- COMMAND ----------

SELECT
  TRIM(author_list) AS `Name of the Author`,
  SUM(`H index`) AS `Total H-index`
FROM
  ${hivevar:db_name}.${hivevar:metadata_table} AS A
  INNER JOIN 
  ${hivevar:db_name}.${hivevar:scimagojr_table} AS J 
  ON A.journal = J.title 
  LATERAL VIEW EXPLODE(SPLIT(authors, ';')) AS author_list
GROUP BY
  `Name of the Author`
ORDER BY
  `Total H-index` DESC
LIMIT
  5

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### 7.2 Using Temp View

-- COMMAND ----------

SELECT
  TRIM(author_list) AS `Name of the Author`,
  SUM(`H index`) AS `Total H-index`
FROM
  temp_${hivevar:metadata_table} AS A
  INNER JOIN 
  ${hivevar:db_name}.${hivevar:scimagojr_table} AS J 
  ON A.journal = J.title 
  LATERAL VIEW EXPLODE(SPLIT(authors, ';')) AS author_list
GROUP BY
  `Name of the Author`
ORDER BY
  `Total H-index` DESC
LIMIT
  5

-- COMMAND ----------

-- MAGIC 
-- MAGIC %md
-- MAGIC #### 7.3 Using Table from Parquet File

-- COMMAND ----------

SELECT
  TRIM(author_list) AS `Name of the Author`,
  SUM(`H index`) AS `Total H-index`
FROM
  ${hivevar:db_name}.parq_${hivevar:metadata_table} AS A
  INNER JOIN 
  ${hivevar:db_name}.${hivevar:scimagojr_table} AS J 
  ON A.journal = J.title 
  LATERAL VIEW EXPLODE(SPLIT(authors, ';')) AS author_list
GROUP BY
  `Name of the Author`
ORDER BY
  `Total H-index` DESC
LIMIT
  5

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### 8. Task 6. Plot the number of papers per month since 2020-01. 
-- MAGIC You need to include your visualization as well as a table of the values you have plotted for each month. 

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### 8.1 Using Permanent Tables

-- COMMAND ----------

SELECT
  SUBSTR(publish_time, 1, 7) as `Year Month`,
  COUNT(*) as `Number of papers published`
FROM
  ${hivevar:db_name}.${hivevar:metadata_table}
WHERE
  publish_time > '2020'
GROUP BY
  `Year Month`
ORDER BY
  `Year Month` ASC

-- COMMAND ----------

-- MAGIC 
-- MAGIC %md
-- MAGIC #### 8.2 Using Temp View

-- COMMAND ----------

SELECT
  SUBSTR(publish_time, 1, 7) as `Year Month`,
  COUNT(*) as `Number of papers published`
FROM
  temp_${hivevar:metadata_table}
WHERE
  publish_time > '2020'
GROUP BY
  `Year Month`
ORDER BY
  `Year Month` ASC

-- COMMAND ----------

-- MAGIC 
-- MAGIC %md
-- MAGIC #### 8.3 Using Table from Parquet File

-- COMMAND ----------

SELECT
  SUBSTR(publish_time, 1, 7) as `Year Month`,
  COUNT(*) as `Number of papers published`
FROM
  ${hivevar:db_name}.parq_${hivevar:metadata_table}
WHERE
  publish_time > '2020'
GROUP BY
  `Year Month`
ORDER BY
  `Year Month` ASC
