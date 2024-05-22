--1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 

Select * from credit_card_transcations;

with cte1 as (
select city,sum(amount) as total_exp, (select distinct SUM (amount) over () from credit_card_transcations) as Overall_exp
from credit_card_transcations
group by city)
select top 5 city, total_exp,Overall_exp ,Total_Exp*100/Overall_exp, round(Total_Exp*100/Overall_exp,2) as Percentage_cont
from cte1
order by Total_Exp desc
