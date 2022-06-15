-- Databricks notebook source
-- DBTITLE 1,Take a look at our sale table
select *
from cogsley_sales
limit 100;

-- COMMAND ----------

-- DBTITLE 1,Calculate Sales Totals
select CompanyName, round(sum(SaleAmount)) as Sales
from cogsley_sales
group by CompanyName
order by 2 desc

-- COMMAND ----------

-- DBTITLE 1,Join to get Client Info
select CompanyName, IPOYear, Symbol, round(sum(SaleAmount)) as Sales
from cogsley_sales
left join cogsley_clients on CompanyName = Name
group by CompanyName, IPOYear, Symbol
order by 1

-- COMMAND ----------

-- DBTITLE 1,Join to get State Info
select i.StateCode, round(sum(s.SaleAmount)) as Sales
from cogsley_sales s
join state_info i on s.State = i.State
group by i.StateCode

-- COMMAND ----------


