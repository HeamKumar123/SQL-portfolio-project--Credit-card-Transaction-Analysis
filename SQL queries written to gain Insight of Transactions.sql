
Select * from credit_card_transcations;

/*1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends */

with cte1 as (
select city,sum(amount) as total_exp, (select distinct SUM (amount) over () from credit_card_transcations) as Overall_exp
from credit_card_transcations
group by city)
select top 5 city, total_exp,Overall_exp ,Total_Exp*100/Overall_exp, round(Total_Exp*100/Overall_exp,2) as Percentage_cont
from cte1
order by Total_Exp desc

--2- write a query to print highest spend month and amount spent in that month for each card type

with cte as(
select card_type, DATEPART(year,transaction_date) YR, DATEPART(MONTH,transaction_date) as Mth, SUM(amount) as Total
from credit_card_transcations
group by card_type, DATEPART(year,transaction_date), DATEPART(MONTH,transaction_date))
select * from (
select *, DENSE_RANK() over (partition by card_type order by Total desc) as RNk
from cte) as A 
where RNk=1

/*3- write a query to print the transaction details(all columns from the table) for each card type when
it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)*/

with cte as(
select *, sum (amount) over (partition by card_type order by transaction_date, transaction_id) as Total
from credit_card_transcations)
,cte2 as (select *, Total-1000000 as Refer from cte )
select * from (
select *, DENSE_RANK() over (partition by card_type order by refer) as RNk
from cte2 
where refer>0)as new
where Rnk=1

--4- write a query to find city which had lowest percentage spend for gold card type
with cte as(
select city,sum(amount) as total_exp, (select SUM (amount) from credit_card_transcations where card_type='Gold') as Overall_exp
from credit_card_transcations
where card_type='Gold'
group by city),
cte2 as (
select *, total_exp*100/Overall_exp as Percen
from cte)
Select city from
(select *, DENSE_RANK() over (order by percen) as Rnk
from cte2) as a
where rnk=1


--5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
with cte as (
select *, DENSE_RANK() over (partition by city order by Total desc) as Rnk1, DENSE_RANK() over (partition by city order by Total) as Rnk2
from (
select city	,exp_type,sum (amount) As Total
from
credit_card_transcations
group by city	,exp_type) as a)
select city, max(case when rnk1=1 then exp_type end) as highest_expense_type , max(case when rnk2=1 then exp_type end) as lowest_expense_type
from cte
group by city


--6- write a query to find percentage contribution of spends by females for each expense type
Select * from credit_card_transcations;

with cte1 as
(
select exp_type , sum (amount) as Total
from credit_card_transcations
where gender='F'
group by exp_type)
,cte2 as(
select exp_type , sum (amount) as Total1
from credit_card_transcations
group by exp_type)
select cte1.exp_type, cte1.Total, cte2.Total1, cte1.Total*100/cte2.Total1
from cte1 join cte2 on cte1.exp_type=cte2.exp_type;

--7- which card and expense type combination saw highest month over month growth in Jan-2014

with cte1 as (
select card_type, exp_type,datepart(year,transaction_date) as Yr, datepart(Month,transaction_date) as Mth, SUM(amount) As Total
from credit_card_transcations
group by card_type, exp_type,datepart(year,transaction_date) , datepart(Month,transaction_date))
,cte2 as(select *, lag(Total,1,0) over (partition by card_type,exp_type order by yr,mth) as Prev
from cte1)
,cte3 as(
select *, Total-Prev as Diff
from cte2)
select top 1 
* from cte3 where Yr=2014 and mth=1
order by Diff desc;

with cte as (
select card_type,exp_type,datepart(year,transaction_date) yt
,datepart(month,transaction_date) mt,sum(amount) as total_spend
from credit_card_transcations
group by card_type,exp_type,datepart(year,transaction_date),datepart(month,transaction_date)
)
select  top 1 *, (total_spend-prev_mont_spend) as mom_growth
from (
select *
,lag(total_spend,1) over(partition by card_type,exp_type order by yt,mt) as prev_mont_spend
from cte) A
where prev_mont_spend is not null and yt=2014 and mt=1
order by mom_growth desc;


--8- during weekends which city has highest total spend to total no of transcations ratio 

select Top 1 city, sum(amount)/count(*) from
credit_card_transcations
where DATEPART(WEEKDAY,transaction_date) in (1,7)
group by city 
order by sum(amount)/count(*) desc


--9- which city took least number of days to reach its 500th transaction after the first transaction in that city

with cte1 as(
select city, min (transaction_date) as First_trans
from credit_card_transcations 
group by city)
,cte2 as (
select city,transaction_date , transaction_id
from credit_card_transcations )
,cte3 as
(select cte2.*, cte1.First_trans, count(*) over (partition by cte2.city order by transaction_date, transaction_id) as cnt
from cte2 join cte1 on cte1.city=cte2.city)
select * from(
select * , datediff(day,First_trans, transaction_date) as da
from cte3
where cnt=500) as a
order by da asc ;


select top 1 a.*,b.First_Trans, DATEDIFF(day,First_Trans,transaction_date) as Da from (
select *, count (*) over (partition by city order by transaction_date, transaction_id) as cnt from
credit_card_transcations) a join 
(select city , MIN(transaction_date) as First_Trans
from credit_card_transcations
group by city) b on a.city=b.city
where cnt=500
order by da;




