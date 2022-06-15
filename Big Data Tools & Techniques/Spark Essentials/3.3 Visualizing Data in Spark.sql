-- Databricks notebook source
-- DBTITLE 1,Basic Bar Chart
select *
from cogsley_sales
limit 100;

-- COMMAND ----------

-- DBTITLE 1,Basic Line Chart
select *
from cogsley_sales
limit 100;

-- COMMAND ----------

-- DBTITLE 1,Build a Map
/* requires 2char state code */
select i.StateCode, round(sum(s.SaleAmount)) as Sales
from cogsley_sales s
join state_info i on s.State = i.State
group by i.StateCode

-- COMMAND ----------

-- DBTITLE 1,Box Plot (bonus!)
select *
from cogsley_sales
limit 100;
