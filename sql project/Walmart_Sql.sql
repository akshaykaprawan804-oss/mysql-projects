create database if not exists walmart;
use walmart;
create table sales(
invoice_id varchar(30) not null primary key,
branch varchar(5) not null ,
city varchar(30) not null,
customer_type varchar(30) not null,
gender varchar(10) not null,
product_line varchar(100) not null,
unit_price decimal(10,2) not null,
quantity int(30) not null,
var float(6,4) not null,
total decimal(12,4),
date datetime not null,
time time not null,
payment varchar(15) not null,
cogs decimal(10,2) not null,
gross_margin_pct float(11,9),
gross_income decimal(12,4),
rating float(6,1)
);
show global variables like 'local_infile';

set global local_infile=0;
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Walmart Sales Data.csv.csv"
into table sales
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;
show variables like 'secure_file_priv';
alter table sales
modify column rating  float(6,2);
select * from sales;
 ------------------------- fearture Engineering --------------------------------------
-- 1. Time_of_day
select time,
(case 
	when `time`  between "00:00:00" and "12:00:00" then "Morning"
    when `time`between "12:01:00" and "16:00:00" then "Afternoon"
    else "Evening"
    end)as time_of_day
    from sales;
    
    Alter table sales
    add column time_of_day varchar(30);
    
update sales
set time_of_day=(
case
when `time` between "00:00:00" and "12:00:00" then "Morning"
when `time` between "12:01:00" and "16:00:00" then "afternoon"
else "Evening"
end
);
set sql_safe_updates=0;
select * from sales;

-- 2.Day_name
select date,dayname(date) as day_name
from sales;

Alter table sales 
add column day_name varchar(30);


update sales
set day_name=dayname(date);

select * from sales;
 -- 3.month_name

select date,monthname(date)as month_name from sales;

alter table sales
add column month_name varchar(10);



update sales
set month_name=monthname(date);

--------------------- Exploratory Data Analysis(EDA) ----------------------------------------

-- Generic Questions
-- 1.How many distinct cities are present in the dataset?
select distinct(city) as unique_city from sales;



-- 2. In which city is each branch situated?
select distinct (branch),city from sales;

-- Product Analysis
 -- 1. how many distinct product_lines are there in the dataset?
select count(distinct product_line) as Total_product_lines from sales;
 
-- 2.what is the most common payment method?
select payment,count(payment) as common_payment_method 
from sales
group by payment order by common_payment_method desc;


-- 3. what is the most selling product_line?
select product_line ,count(product_line)as most_selling_product
from sales
group by product_line
order by most_selling_product desc;

-- 4.What is the total revenue by month?
select month_name,sum(total) as total_revenue_by_month 
from sales
group by month_name
order by total_revenue_by_month desc;


-- 5.which month recorded the highest  cost of goods sold(cogs)?
select month_name,sum(cogs) as total_cogs
from sales
group by month_name
order by total_cogs desc;



-- 6.Which product line generated the highest revenue?
select product_line ,sum(total) as total_revenue
from sales
group by product_line 
order by total_revenue;


-- 7.Which city has the highest revenue?
select city ,sum(total) as total_revenue
from sales
group by city 
order by total_revenue desc limit 1;


-- 8.Which product line incurred the highest Var?
select product_line ,sum(var) as total_var 
from sales 
group by product_line
order by total_var
limit 1;




-- 9.Retrieve each product line and add a column product_category, indicating 'Good' or 'Bad,'based on whether its sales are above the average.
select * from sales;
select product_line, (case 
when total>=(select avg(total) from sales)
then "good"
else "bad"
end)as product_category
from sales;

alter table sales
add column product_category varchar(30) ;


UPDATE sales
SET product_category = CASE
    WHEN product_line IN (
        SELECT product_line
        FROM (
            SELECT 
                product_line,
                SUM(total) AS total_sales
            FROM sales
            GROUP BY product_line
            HAVING SUM(total) > (
                SELECT AVG(product_sales)
                FROM (
                    SELECT SUM(total) AS product_sales
                    FROM sales
                    GROUP BY product_line
                ) t
            )
        ) x
    )
    THEN 'Good'
    ELSE 'Bad'
END;






-- 10.Which branch sold more products than average product sold?

select branch,sum(quantity) from sales
group by branch 
having sum(quantity)>avg(quantity) 
order by  sum(quantity) desc limit 1;








-- 11.What is the most common product line by gender?
select gender,product_line,count(gender)as total_count from sales
group by gender ,product_line 
order by gender desc;




-- 12.What is the average rating of each product line?

select product_line,round(avg(rating),2) as avg_rating
from sales
group by product_line
order by avg_rating desc;
---------------------------------------- sales Analysis-------------------------------------------------

-- 1.Number of sales made in each time of the day per weekday

select day_name,time_of_day,count(invoice_id) total_sales
from sales
where day_name not in("saturday","sunday")
group by day_name,time_of_day;
						-- or
select day_name,time_of_day,count(invoice_id) total_sales
from sales
group by day_name,time_of_day
having day_name not in ('saturday','sunday');


-- 2.Identify the customer type that generates the highest revenue.
select customer_type,sum(total) total_revenue
from sales
group by customer_type
order by total_revenue desc limit 1;




-- 3.Which city has the largest tax percent/ VAT (Value Added Tax)?
select city,sum(var) as total_vat
from sales 
group by city
order by total_vat desc limit 1;

-- 4.Which customer type pays the most in VAT?
select customer_type,sum(var) as total_Vat
from sales
group by customer_type
order by total_Vat desc limit 1;


-------------------------------------- customer Analysis------------------------------------------------------------------

-- 1.How many unique customer types does the data have?

select count(distinct(customer_type) ) as unique_customer_type from sales;





-- 2.How many unique payment methods does the data have?
select count(distinct(payment)) as unique_payment_method 
from sales;


-- 3.Which is the most common customer type?
select customer_type,count(customer_type) as total_customer_type
from sales
group by customer_type
order by total_customer_type desc limit 1;

-- 4.Which customer type buys the most?
select customer_type ,sum(total) as total_revenue 
from sales
group by customer_type 
order by total_revenue limit 1;



-- 5.What is the gender of most of the customers?


select gender ,count(*) as total_customer
from sales
group by gender
order by total_customer desc limit 1;



-- 6.What is the gender distribution per branch?
select branch,gender,count(gender) as gender_distribution
from sales
group by branch,gender 
order by gender_distribution desc ;

select * from sales;

-- 7.Which time of the day do customers give most ratings?
select time_of_day ,avg(rating) as avg_ratings
from sales
group by time_of_day 
order by avg_ratings desc limit 1;





-- 8.Which time of the day do customers give most ratings per branch?
select branch,time_of_day ,avg(rating) as avg_ratings
from sales
group by branch,time_of_day 
order by avg_ratings desc ;


SELECT branch, time_of_day,
AVG(rating) OVER(PARTITION BY branch) AS ratings
FROM sales 
order by ratings desc;


-- 9.Which day of the week has the best avg ratings?
select day_name,avg(rating) as avg_ratings
from sales
group by day_name 
order by avg_ratings desc limit 1;








-- 10.Which day of the week has the best average ratings per branch?
select branch,day_name,avg(rating) as avg_ratings
from sales
group by branch,day_name 
order by avg_ratings desc limit 1;





























