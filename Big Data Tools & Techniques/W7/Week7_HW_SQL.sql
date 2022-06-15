-- Databricks notebook source
-- MAGIC %md 
-- MAGIC 
-- MAGIC ## HW7: Homework: partition data in Hive
-- MAGIC 
-- MAGIC Ambareesh Jonnavittula
-- MAGIC 
-- MAGIC This homework must be completed on your own. By the act of following these instructions and handing your work in, it is
-- MAGIC deemed that you have read and understand the rules on plagiarism as written in the academic handbook.
-- MAGIC In week 3, you downloaded accounts.zip from Blackboard and uploaded it to your Databricks account, unzipped these
-- MAGIC and placed them in /FileStore/accounts/. If you do not have these les in this location any more, you should repeat the
-- MAGIC steps you did in that week to ensure you place them there again.

-- COMMAND ----------

show databases;

-- COMMAND ----------

-- MAGIC %python
-- MAGIC dbutils.fs.ls("user/hive/warehouse")

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 
-- MAGIC --> 1. Create a Hive table in an SQL notebook cell (i.e. not in the UI) which corresponds to the accounts data. To ensure
-- MAGIC the table is populated, LOCATION should be specied to be /FileStore/accounts/
-- MAGIC The data types are as follows:

-- COMMAND ----------

CREATE EXTERNAL TABLE IF NOT EXISTS accounts
(
acct_num INT ,
acct_created TIMESTAMP ,
last_order TIMESTAMP ,
first_name STRING ,
last_name STRING ,
address STRING ,
city STRING ,
state STRING ,
zipcode STRING ,
phone_number STRING ,
last_click TIMESTAMP ,
last_logout TIMESTAMP
)
ROW FORMAT DELIMITED
FIELDS TERMINATED by ','
STORED AS TEXTFILE
LOCATION '/FileStore/tables/accounts'

-- COMMAND ----------

-- Validation check

select * from accounts;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC --> 2. The area code corresponds to the rst three digits of the phone number. Create a new (empty) table called
-- MAGIC accounts with areacode which extracts the columns acct num, first name, last name and phone number. It also
-- MAGIC adds a new feature corresponding to the areacode (with data type STRING). You should specify that the les will be
-- MAGIC stored in /FileStore/accounts with areacode.

-- COMMAND ----------

create external table if not exists accounts_with_areacode
(
acct_num INT,
first_name STRING,
last_name STRING,
phone_number STRING,
areacode STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED by ','
LOCATION '/FileStore/tables/accounts_with_areacode/'

-- COMMAND ----------

-- MAGIC %md
-- MAGIC --> 3. Populate the accounts with areacode table using INSERT OVERWRITE TABLE. You should consider using Google to
-- MAGIC work out how to use LEFT to extract the relevant part of the phone number and you may want to use AS to assign a
-- MAGIC name to a column (such as areacode).

-- COMMAND ----------

INSERT OVERWRITE TABLE accounts_with_areacode
SELECT acct_num,
       first_name,
       last_name,
       phone_number,
       LEFT(phone_number, 3) as areacode 
FROM accounts;


-- COMMAND ----------

select * from accounts_with_areacode;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC --> 4. Create a new, empty table in Hive:

-- COMMAND ----------

CREATE EXTERNAL TABLE IF NOT EXISTS accounts_by_areacode 
(
acct_num INT ,
first_name STRING ,
last_name STRING ,
phone_number STRING 
)
PARTITIONED BY (areacode STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LOCATION '/FileStore/tables/accounts_by_areacode';

-- COMMAND ----------

-- MAGIC %md
-- MAGIC --> 5. Switch strict mode o dynamic partitioning using the following commands:
-- MAGIC %

-- COMMAND ----------

-- MAGIC %python
-- MAGIC from pyspark import HiveContext
-- MAGIC sc = spark.sparkContext
-- MAGIC hiveContext = HiveContext(spark.sparkContext)
-- MAGIC hiveContext.setConf("hive.exec.dynamic.partition.mode", "nonstrict")

-- COMMAND ----------

-- MAGIC %md
-- MAGIC --> 6. Populate the new table using your accounts with areacode table using INSERT OVERWRITE TABLE command to copy
-- MAGIC the specied columns to the new table, dynamically partitioning by area code.

-- COMMAND ----------

INSERT OVERWRITE TABLE accounts_by_areacode
PARTITION(areacode)
SELECT acct_num,first_name,last_name,phone_number,areacode 
FROM accounts_with_areacode;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC --> 7. Execute a simple query to conrm that the table was populated correctly, such as

-- COMMAND ----------

SELECT * FROM accounts_by_areacode LIMIT 10;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC --> 8. Write a Python cell in your SQL notebook (this will start with %python) which uses the dbutils.fs.ls command to
-- MAGIC conrm that the accounts by areacode directory contains the partition directories.

-- COMMAND ----------

-- MAGIC %python
-- MAGIC dbutils.fs.ls("/FileStore/accounts_by_areacode")

-- COMMAND ----------

-- MAGIC %md
-- MAGIC --> 9. Extra credit: write another Python cell which extends Point 8 and prints the number of files in the accounts by areacode
-- MAGIC directory.

-- COMMAND ----------

-- MAGIC %python
-- MAGIC len(dbutils.fs.ls("/FileStore/accounts_by_areacode"))
