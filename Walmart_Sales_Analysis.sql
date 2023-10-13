#-----------------------------------------------------------WALMART SALES DATA ANALYSIS--------------------------------------------------------------------

CREATE TABLE sales(invoice_id varchar(30) not null primary key,
branch varchar(10) not null,city varchar(30) not null,
customer_type varchar(40) not null,gender varchar(10) not null,
product_line varchar(100) not null,unit_price decimal(10,2) not null,
quantity int not null,VAT float(6,4) not null,total decimal(12,4) not null,
date datetime not null,time time not null,payment_method varchar(15) not null,
cogs decimal(10,2) not null,gross_margin_pct float(11,9),gross_income decimal(12,4) not null,
rating float(2,1));

select * from sales;
select * from sales limit 5;

#---------------------------------------FIRST MOMENT BUSINESS DECISION----------------------------------------------------------------------------------------
#------------------------------------------------MEAN------------------------------------------------------------------------------------------
select avg(Total) as mean_total from sales;
#322.96674900000005

select avg(cogs) as mean_cogs from sales;
#307.58738000000034

select avg(`gross income`) as mean_gi from sales;
#15.379369000000002

#---------------------------------------------------------------MEDIAN------------------------------------------------------------------------
select Total as med_total
from (
select Total,row_number() over (order by Total) as row_num,
count(*) over () as tot_count from sales) as subquery
where row_num=(tot_count+1)/2 or row_num=(tot_count+2)/2 ;
#254.016

select cogs as med_cogs 
from (
select cogs,row_number() over (order by cogs) as row_num,
count(*) over () as tot_count from sales) as subquery
where row_num=(tot_count+1)/2 or row_num=(tot_count+2)/2;
#241.92


select `gross income` as med_gi
from(
select `gross income`,row_number() over (order by `gross income`) as row_num,
count(*) over () as tot_count from sales) as subquery
where row_num=(tot_count+1)/2 or row_num=(tot_count+2)/2;
#12.096

#----------------------------------------------------------------MODE--------------------------------------------------------------------------
select Total as mode_tot
from(
select Total,count(*) as freq from sales
group by Total order by freq desc limit 1) as subquery;
#829.08

select cogs as med_cogs
from(
select cogs, count(*) as freq from sales
group by cogs order by freq desc limit 1) as subquery;
#789.6

select `gross income` as mode_income
from(
select `gross income`,count(*) as freq from sales
group by `gross income` order by freq desc limit 1) as subquery; 
#39.48


#---------------------------------------------------------SECOND MOMENT BUSINESS DECISION------------------------------------------------------
#----------------------------------------------------------------VARIANCE----------------------------------------------------------------------
select 
round(variance(Total),2) as var_tot,
round(variance(cogs),2) as var_cogs,
round(variance(`gross income`),2) as var_gi
from sales;
#var_tot | var_cogs | var_gi
#60399.14 | 54783.8	|136.96

#--------------------------------------------------------------STANDARD DEVIATION-------------------------------------------------------------
select 
round(stddev(Total),2) as std_tot,
round(stddev(cogs),2) as std_cogs,
round(stddev(`gross income`),2) as std_gi
from sales;
#std_tot | std_cogs | std_gi
#245.76	 | 234.06   | 	11.7

#--------------------------------------------------------------------RANGE--------------------------------------------------------------------
select
round((max(Total) - min(Total)),2) as r_tot,
round((max(cogs) - min(cogs)),2) as r_cogs,
round((max(`gross income`) - min(`gross income`)),2) as r_gi
from sales;
#r_tot  | r_cogs | r_gi
#1031.97|982.83  |49.14


#--------------------------------------------------THIRD MOMENT BUSINESS DECISION-------------------------------------------------------------
#--------------------------------------------------------------SKEW---------------------------------------------------------------------------
select round(sum(power(Total - (select avg(Total) from sales),3))/
(count(*) * power((select stddev(Total) from sales),3)),2) 
as skew from sales;
#0.89

select 
round(sum(power(cogs - (select avg(cogs) from sales),3) / (count(*)*power((select stddev(cogs) from sales),3)) ),2) 
as skew from sales;
#0.89

select (sum(power(`gross income` - (select avg(`gross income`) from sales),3)) / (count(*) * power((select stddev(`gross income`) from sales),3))) as skew
from sales;
#0.8912303920037637

#---------------------------------------------FOURTH MOMENT BUSINESS DECISION-----------------------------------------------------------------
#--------------------------------------------------------KURTOSIS----------------------------------------------------------------------------------

select (sum(power(Total - (select avg(Total) from sales), 4)) / (count(*) * power((select stddev(Total) from sales), 4))) - 3 as kurt
from sales;
#-0.08746991289328587

select (sum(power(cogs-(select avg(cogs) from sales),4)) / (count(*) * power((select stddev(cogs) from sales),4)))-3 as kurt 
from sales;
#-0.08746991289330452

select (sum(power(`gross income` - (select avg(`gross income`) from sales) , 4)) / ( count(*) * power((select stddev(`gross income`) from sales),4)))-3 
as kurt from sales;
#-0.08746991289329076


#--------------------------------------------------------FEATURE ENGINEERING------------------------------------------------------------------------------
#ADDING A COL CALLED TIME_OF_DAY--------------------------------------------------------------------------------------------------------------

select 
time,( case 
when time between "00:00" and "12:00" then "Morning"
when time between "12:01" and "16:00" then "Afternoon"
when time between "16:01" and "19:00" then "Evening"
else "Night"
end) as time_of_day
from sales;

alter table sales add column time_of_day varchar(20);
update sales set  time_of_day = (case 
when time between "00:00" and "12:00" then "Morning"
when time between "12:01" and "16:00" then "Afternoon"
when time between "16:01" and "19:00" then "Evening"
else "Night"
end);

#ADDING A COL DAY_NAME -DAYS WHERE TRANSASCTION TOOK PLACE-----------------------------------------------------------------------------------
#select date,dayname(date) 
#from sales;#Here the date frmat is in D/M/Y,it has to be in D-M-Y,so converting to string
SELECT DATE_FORMAT(STR_TO_DATE(date, '%m/%d/%Y'), '%Y-%m-%d') AS formatted_date
FROM sales;
update sales set date=DATE_FORMAT(STR_TO_DATE(date, '%m/%d/%Y'), '%Y-%m-%d');
select date , dayname(date) as day_name from sales limit 5;
alter table sales add column day_name varchar(10);
update sales set day_name=dayname(date);


#ADDING A COL MONTH_NAME -MONTHS WHERE TRANSACTION DONE---------------------------------------------------------------------------------------
select date,monthname(date) from sales limit 5;
alter table sales add column month_name varchar(15);
update sales set month_name = monthname(date);

#---------------------------------------------------EDA---------------------------------------------------------------------------------------
#QUESTIONS TO ANSWER
#1)HOW MANY UNIQUE CITIES DOES THE DATA HAVE?
select distinct City from sales;

#2)IN WHICH CITY IS EACH BRACH?
select distinct Branch,  City from sales;

#3) HOW MANY UNIQUE PRODUCT LIMES DOES THE DATA HAVE?
select distinct `Product line` from sales;
select count(distinct `Product line`) from sales;

#4 ) WHAT IS THE MOST COMMON PAYMENT METHOD?
select Payment,count(Payment) as count_payment from sales group by Payment order by count_payment desc limit 1;

#5) WHAT IS THE MOST SELLING PRODUCT LINE?
select  `Product line`,count(`Product line`) as c_p from sales group by `Product line` order by c_p desc limit 1;

#6)WHAT IS THE TOTAL REVENUE BY MONTH?
select month_name,sum(`gross income`)   as tot_income from sales group by month_name;

#7 ) WHAT MONTH HAD THE LARGEST COGS?
select month_name,sum(cogs) as s_cogs from sales group by month_name order by s_cogs desc limit 1; 

#8) WHAT PRODUCT LINE HAS THE LARGEST REVENUE?
select `Product line`,sum(Total) as tot_rev from sales group by `Product line` order by tot_rev desc limit 1;

#9) WHAT IS THE CITY WITH THE LARGEST REVENUE?
select City ,sum(Total) as tot_rev from sales group by City order by tot_rev desc limit 1;

#10 )WHAT PRODUCT LINE HAD THE LARGEST TAX?
select `Product line`,avg(`Tax 5%`) as tax_avg from sales group by `Product line`  order by tax_avg desc limit 1;

#11)WHICH BRANCH SOLD MORE THAN THE AVERAGE PRODUCTS SOLD?
select  Branch,sum(Quantity) as pro from sales group by Branch having pro> (select avg(Quantity) from sales);

#12 ) WHAT IS THE MOST COMMON PRODUCT LINE BY GENDER?
select `Product line`,count(`Product line`)as cnt,Gender from sales group by Gender,`Product line` order by cnt desc limit 1;

#13)WHAT IS THE AVERAGE RATING FOR EACH PRODUCT LINE?
select `Product line`,avg(Rating) as avg from sales group by `Product line` order by avg;

#14) NUMBER OF SALES MADE IN EACH TIME OF THE DAY PER WEEKDAY.
select time_of_day,count(*) as tot_sales from sales where day_name='Monday' group by time_of_day order by tot_sales desc;
#EACH DAY CAN BE GIVEN HERE ACC TO OUR WISH

#15) WHICH CUSTOMER TYPE BRINGS IN THE MOST REVENUE?
select `Customer type`,sum(Total) as tot_rev from sales group by `Customer Type` order by tot_rev desc limit 1;

#16)WHICH CITY HAS THE LARGEST TAX?
select City,avg(`Tax 5%`) as avg_tax from sales group by City order by avg_tax desc limit 1;

#17) WHICH CUSTOMER TYPE PAYS THE MOST TAX?
select `Customer Type`,avg(`Tax 5%`) as avg_tax from sales group by `Customer Type`  order by avg_tax desc limit 1;

#18) HOW MANY UNIQUE CUSTOMERS DOES THE DATA HAVE?
select distinct `Customer Type`, count(`Customer Type`) from sales group by `Customer Type`;

#19)HOW MANY UNIQUE PAYMENT METHOD DOES THE DATA HAVE?
select distinct Payment, count(Payment) from sales group by `Payment`;

#20) WHICH CUSTOMER TYPE BUYS THE MOST?
select  `Customer Type`,count(*) as cnt from sales group by `Customer Type` order by cnt desc limit 1;

#21) WHAT'S THE MOST COMMON GENDER?
select Gender ,count(Gender) as cnt_gender from sales group by Gender order by cnt_gender desc;

#22) WHAT IS THE GENDER DISTRIBUTION PER BRANCH?
select Gender ,count(Gender) as cnt_gender from sales where Branch='B' group by Gender order by cnt_gender desc;
#CHANGE THE BRANCH TO YOUR LIKING

#23) WHAT TIME OF THE DAY DOES CUSTOMERS GIVE MORE RATINGS?
select time_of_day,avg(Rating) as rating from sales group by time_of_day order by rating desc;

#24)WHAT TIME OF THE DAY DOES CUSTOMERS GIVE MORE RATINGS PER BRANCH?
select time_of_day,avg(Rating) as rating from sales where Branch='A' group by time_of_day order by rating desc;

#25) WHICH DAY OF THE WEEK HAS THE BEST AVG RATING?
select day_name,avg(Rating) as avg from sales group by day_name order by avg desc limit 1;
#TO FIND FOR EACH BRANCH,ADD A WHERE CLAUSE WITH THE BRANCH NAME SPECIFIED

