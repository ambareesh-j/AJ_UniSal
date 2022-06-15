-- Databricks notebook source
SHOW Databases;

-- COMMAND ----------

-- MAGIC %python 
-- MAGIC dbutils.fs.ls("user/hive/warehouse/")

-- COMMAND ----------

CREATE DATABASE bdtt;

-- COMMAND ----------

SHOW Databases;

-- COMMAND ----------

-- MAGIC %python 
-- MAGIC dbutils.fs.ls("user/hive/warehouse/")

-- COMMAND ----------

DROP DATABASE IF EXISTS bdtt;

-- COMMAND ----------

--  Be careful when we use CASCADE

DROP DATABASE IF EXISTS bdtt CASCADE;

-- COMMAND ----------

-- Let's create  a table  --> Format

CREATE TABLE tablename (colname DATATYPE, ...)
ROW FORMAT DELIMITED      -- Default is Pipe
FIELDS TERMINATED BY char     -- alternatively ',', '\t'
STORED AS {TEXTFILE|SEQUENCEFILE|.. }

-- COMMAND ----------

CREATE TABLE IF NOT EXISTS jobs (
  id INT,
  title STRING,
  salary INT,
  posted TIMESTAMP
    )
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ',';

-- COMMAND ----------

INSERT INTO jobs VALUES (1, "Data Analyst", 100000, current_timestamp());

-- COMMAND ----------

SELECT * FROM jobs;

-- COMMAND ----------

-- MAGIC %python 
-- MAGIC dbutils.fs.ls("/user/hive/warehouse")

-- COMMAND ----------

-- Another way of table creation

CREATE TABLE jobs_archived LIKE jobs;

-- COMMAND ----------

-- Only metadata is created, not data

SELECT * FROM jobs_archived;

-- COMMAND ----------

-- CTAS method - Create Table as Select 
/*
CREATE TABLE ny_Customers AS
  SELECT cust_id, fname, lname
  FROM customers
  WHERE state = 'NY'; */

-- COMMAND ----------

INSERT INTO jobs VALUES (2, "Data Engineer", 200000, current_timestamp());
INSERT INTO jobs VALUES (3, "Data Scientist", 300000, current_timestamp());

-- COMMAND ----------

SELECT * FROM jobs;

-- COMMAND ----------

-- CTAS method

CREATE TABLE current_jobs_over_150000 AS 
  SELECT title, salary
  FROM jobs
  WHERE salary > 150000;

-- COMMAND ----------

 SELECT * from current_jobs_over_150000;

-- COMMAND ----------

-- MAGIC %python 
-- MAGIC dbutils.fs.ls("/user/hive/warehouse")

-- COMMAND ----------

DROP TABLE IF EXISTS current_jobs_over_150000;

-- COMMAND ----------

-- MAGIC %python 
-- MAGIC dbutils.fs.ls("/user/hive/warehouse")

-- COMMAND ----------

-- MAGIC %python 
-- MAGIC dbutils.fs.ls("/FileStore/tables/accounts/")

-- COMMAND ----------

-- MAGIC %python
-- MAGIC print(dbutils.fs.head('dbfs:/FileStore/tables/accounts/part-m-00000'))

-- COMMAND ----------

-- Controlling table data location 

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
LOCATION '/FileStore/tables/accounts'

-- COMMAND ----------

select * FROM accounts;

-- COMMAND ----------

-- CAUTION - Dropping a table can remove its data from your file system
-- Using EXTERNAL keyword when creating the table avoids this behavior 

-- Dropping an external table removes only its metadata

-- COMMAND ----------

DROP TABLE IF EXISTS accounts;

-- COMMAND ----------

-- MAGIC %python
-- MAGIC dbutils.fs.ls('dbfs:/FileStore/tables/accounts/')

-- COMMAND ----------

-- Files are still present as shown above, but the metadata table is gone
SHOW TABLES;

-- COMMAND ----------

-- DESCRIBE command lists the fields in a table;

DESCRIBE jobs;

-- COMMAND ----------

DESCRIBE FORMATTED jobs;

-- COMMAND ----------

SHOW CREATE TABLE jobs;    -- Gives the command that created that table

-- COMMAND ----------

-- Data validation
-- Loading data from files usually --> 

-- dbutils.fs.mv("file:/tmp/sales.txt", "/user/hive/warehouse/sales/")

-- Alternatively, use LOAD DATA INPATH command
-- Done from within Hive -- just like the above command, source can be either a file or a directory

-- COMMAND ----------

LOAD DATA INPATH 'file:/tmp/sales.txt'
INTO TABLE sales;

-- COMMAND ----------

-- Overwrite - deletes all records before import 

-- LOAD DATA INPATH 'file:/tmp/sales.txt'
-- OVERWRITE INTO TABLE sales;

-- COMMAND ----------

-- Appending / Inserting records into a table 

INSERT INTO TABLE jobs_archived
SELECT * FROM jobs;

-- COMMAND ----------

SELECT * FROM jobs_archived;

-- COMMAND ----------


