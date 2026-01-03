--SQL Advance Case Study
CREATE DATABASE gaurav_case_study2 




SELECT * FROM (
SELECT 'DIM_MANUFACTURER' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM DIM_MANUFACTURER UNION ALL
SELECT 'DIM_MODEL' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM DIM_MODEL UNION ALL
SELECT 'DIM_CUSTOMER' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM DIM_CUSTOMER UNION ALL
SELECT 'DIM_LOCATION' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM DIM_LOCATION UNION ALL
SELECT 'DIM_DATE' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM DIM_DATE UNION ALL
SELECT 'FACT_TRANSACTIONS' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM FACT_TRANSACTIONS
) TBL


--Q1--BEGIN 
--STATE NAME--DIM LOCATION
--CATEGORY--MODEL NAME-- CELLPHONE
--CRITERIA-- BOUGHT-- SINCE 2005

select State,Country,DATE,DATEPART(year,DATE) Years  from FACT_TRANSACTIONS as f
left join DIM_LOCATION as dl on f.IDLocation = dl.IDLocation 
where DATEPART(Year,Date)>2004
order by DATE asc

--Q1--END

--Q2--BEGIN
--joins--fact_transactions to dim_location (left),
--fact_transactions to dim_model (right),dim_model to dim_manufacturer (left)
--TOP1--STATE
-- WHERE--US
--CATEGORY--SAMSUNG
select top 1 COUNT(ft.Quantity) TOTAL_QUANTITY ,dl.State,dl.Country,dr.Manufacturer_Name from FACT_TRANSACTIONS as ft
left join DIM_LOCATION as dl on ft.IDLocation=dl.IDLocation
right join DIM_MODEL as dm on ft.IDModel=dm.IDModel
left join DIM_MANUFACTURER as dr on dm.IDManufacturer=dr.IDManufacturer
where dl.Country = 'US' and dr.Manufacturer_Name = 'Samsung'
group by dl.State,dl.Country,dr.Manufacturer_Name


--Q2--END

--Q3--BEGIN      
--count of transactions--fact_transactions
--basis of zipcode and state--dim_location
select COUNT(ft.IDLocation) Count_of_transactions,dm.ZipCode, dm.State, dl.Model_Name from FACT_TRANSACTIONS as ft
left join DIM_LOCATION as dm on ft.IDLocation=dm.IDLocation
right join DIM_MODEL as dl on ft.IDModel=dl.IDModel
group by dm.ZipCode, dm.State,dl.Model_Name


--Q3--END

--Q4--BEGIN
--cheapest cellphone-- lower function--set on price 
--order by price
select top 1*from DIM_MODEL
order by unit_price asc


--Q4--END

--Q5--BEGIN  
--top5 manufacturers--dim_manufacturer
--group by sales quantity-- fact_transactions
--avg price--dim_model
--order by avg price
--joins--dim_manufacturer to dim_model (inward),fact_transactions to dim_model(right)

select top 5 MD.Manufacturer_Name, DM.Model_Name ,sum(FT.Quantity) Sales_Quantity,avg(FT.TotalPrice) average_price from DIM_MODEL DM
INNER JOIN DIM_MANUFACTURER MD ON MD.IDManufacturer=DM.IDManufacturer
RIGHT JOIN FACT_TRANSACTIONS FT ON DM.IDModel=FT.IDModel
group by MD.Manufacturer_Name,DM.Model_Name
order by avg(FT.TotalPrice) desc


--Q5--END

--Q6--BEGIN   
--customer name-- dim_customer
--left join fact transactions to dim customer 
--avg amount spent-- in 2009 and higher than 500--fact_transactions

select DL.Customer_name,Date,TotalPrice as Total_Spent,Avg(TotalPrice) Average_Spent from DIM_CUSTOMER DL
LEFT JOIN FACT_TRANSACTIONS FT ON FT.IDCustomer=DL.IDCustomer
where datepart(year,Date)=2009
group by date,DL.Customer_name,TotalPrice
having Avg(TotalPrice)>500
order by date asc


--Q6--END
	
--Q7--BEGIN  
--total quantity--fact_transactions
--year--2008,2009,2010
--top5
select top 5  dm.model_name, SUM(ft.Quantity) TOTAL_QUANTITY from FACT_TRANSACTIONS ft
left join DIM_MODEL dm on ft.IDModel=dm.IDModel
	where datepart(year,date) in(2008,2009,2010)
	group by dm.model_name
	order by SUM(ft.Quantity) desc

--Q7--END	
--Q8--BEGIN   
--manufacturer with sales i.e 
--manufacturer name from dim_manufacturer
--totalprice as sales from facts_transactions
--joining dim_manufacturer to facts_transaction (rightjoin)
-- need top second --offset top1--then top1
--where year=2009 and 2010

select  dm.model_name, SUM(ft.Quantity) TOTAL_QUANTITY from FACT_TRANSACTIONS ft
left join DIM_MODEL dm on ft.IDModel=dm.IDModel
	where datepart(year,date) in(2009,2010)
	group by dm.model_name
	order by SUM(ft.Quantity) desc
	offset 1 ROW
	fetch next 1 ROW only

--Q8--END
--Q9--BEGIN    
--manufactures--from dim_Mnaufacturer
-- total_quantity--from facts_transactions
-- sold in 2010 and not in 2009
select datepart(year,date) Years ,dt.Manufacturer_Name ,dm.model_name, SUM(ft.Quantity) TOTAL_QUANTITY from FACT_TRANSACTIONS ft
left join DIM_MODEL dm on ft.IDModel=dm.IDModel
inner join DIM_MANUFACTURER dt on dm.IDManufacturer=dt.IDManufacturer
	where datepart(year,date) =2010 and datepart(year,date) <>2009
	group by dm.model_name,dt.Manufacturer_Name,datepart(year,date)
	order by SUM(ft.Quantity) desc 

--Q9--END

--Q10--BEGIN
--top 100 customers-- top function-- dim_customers
--avg spend--total price--fact_transactions
--avg quantity--fact_transactions
--group by year

with YEAR_Top10
as
( select top 10 b.Customer_Name,AVG(a.Quantity) AVG_QUANTITY,a.TotalPrice as CURRENT_SPEND ,AVG(a.TotalPrice) AVG_SPEND,YEAR(a.Date) Years from FACT_TRANSACTIONS as a
right join DIM_CUSTOMER as b on a.IDCustomer=b.IDCustomer
group by b.Customer_Name,a.TotalPrice,YEAR(a.Date)
order by AVG_QUANTITY desc, AVG_SPEND desc),PERCENTAGE_CHANGE
as (
select Customer_Name,Years,CURRENT_SPEND ,LAG(CURRENT_SPEND,1) over ( Order by Years) Prev_SPEND, 
CURRENT_SPEND- LAG(CURRENT_SPEND,1) over ( Order by Years)/LAG(CURRENT_SPEND,1) over ( Order by Years)*100 PERCENTAGE_SPEND
from YEAR_Top10

group by Customer_Name,Years,CURRENT_SPEND

)

select*from PERCENTAGE_CHANGE
--Q10--END
	