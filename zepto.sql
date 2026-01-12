Create database zepto;
use zepto;
drop table if exists zepto;
create table zepto_1(
category varchar(120),
name varchar(120) NOT NULL,
mrp numeric(8,2),
discount_percent NUMERIC(5,2),
availablequantity integer,
discountedSellingPrice Numeric(8,2),
weightInGms integer,
OutOfStock text,
quantity Integer);
drop table zepto_1;
SET GLOBAL local_infile = 1;
SET SESSION local_infile = 1;
SHOW variables like 'local_infile';
LOAD DATA LOCAL INFILE 'C:/Users/USER/Documents/MySql/zepto_v21.csv' 
into table zepto_1
fields terminated by ','
enclosed by '"' 
lines terminated by '\n'
ignore 1 lines;

select count(*) from zepto_1;
select * from zepto_1 ;
alter table zepto_1 
add column sku_id int not null auto_increment primary key first;
update zepto_1 
set outofstock = 
Case 
when outofstock = 1 then True
else false
end;
alter table zepto_1 
modify outofstock boolean;

select * from zepto_1 where name = null or 
category = null or
mrp = null or
discount_percent = null or
discountedsellingprice = null or
weightingms = null or
availablequantity = null or
outofstock = null or
quantity = null;

select distinct category from zepto_1 order by category;
select outofstock, count(sku_id) from zepto_1 group by outofstock;
select name, count(sku_id) as "Num of Sku" from zepto_1 group by name having count(sku_id) > 1 order by count(sku_id) desc;
#data cleaning
#price might be zero 
select * from zepto_1 where mrp = 0 or discountedsellingprice = 0;
delete from zepto_1 where mrp = 0;

#convert paise to rupee
update zepto_1 set mrp = mrp/100.0,
discountedsellingprice = discountedsellingprice/100.0; 
select mrp, discountedsellingprice from zepto_1;

#Business Insight queries
# Q1. Find the top 10 best value products based on discount percentage
select name, mrp, discount_percent from zepto_1 order by discount_percent desc limit 10;

#Q2. What are products with high mrp but outofstock
select distinct name, mrp from zepto_1 where outofstock = 1 and mrp > 300 order by mrp desc;

#Q3. Calculate estimated revenue for each category
select category, sum(discountedsellingprice * availablequantity) as Total_revenue
from zepto_1 
group by category 
order by Total_revenue;

#Q4. find all products where mrp is greater than 500 and discount is less than 10%
select distinct name, mrp, discount_percent from zepto_1 where mrp > 500 and discount_percent < 10 order by mrp desc, discount_percent desc;

#Q5. Identify the top 5 category offering the highest average discount percentage
select category, avg(discount_percent) as 'avg_dis_per' from zepto_1 group by category order by avg_dis_per desc limit 5;

#Q6. Find the price per gram for products above 100 g and sort by best values
select name, weightingms, discountedsellingprice, round(discountedsellingprice/weightingms,2) as price_per_gram
from zepto_1 
where weightingms>100 
order by price_per_gram;

#Q7. Group the products into categories like low, medium, bulk
select distinct name, weightingms,
Case when  weightingms < 1000 then "Low"
when weightingms < 5000 then "Medium"
else "Bulk" 
end as weight_category 
from zepto_1;

#Q8. What is the total inventory weight per category
select category, sum(weightingms*availablequantity) as total_weight from zepto_1 group by category order by total_weight;

