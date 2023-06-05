-- what is total amount each customer spent on zomato ?
select userid,sum(price) from sales join product USING (product_id)
group by 1

-- How many days has each customer visited zomato?
select userid,count(distinct created_date)days from sales join users using (userid)
group by 1

--what was the first product purchased by each customer?
with sub1 as (select userid,product_name,created_date,
rank()over (partition by userid order by created_date)as ranking
from sales join product using (product_id))
select userid,product_name,ranking, created_date from sub1
where ranking = 1

--what is most purchased item on menu & 
--how many times was it purchased by all customers ?
select product_id,product_name,count(created_date) from sales join product
using (product_id)
group by 1,2
order by 3 desc
limit 1

--which item was most popular for each customer?
with sub1 as(select userid,product_name,count(created_date)as count_of_product from sales join product
using (product_id)
group by 1,2
order by 1),

sub2 as (select userid,product_name,rank()over(partition by userid order by count_of_product)ranking from sub1)
select userid,product_name,ranking from sub2 where not(ranking = 1) 

--which item was purchased first by customer after they become a member ?
with sub1 as (select *, 
rank()over(partition by userid order by created_date)as next 
from sales join goldusers_signup using (userid)
where created_date > gold_signup_date)
select * from sub1 
where next=1

--which item was purchased just before customer became a member?
with sub1 as (select *, 
rank()over(partition by userid order by created_date desc)as next 
from sales join goldusers_signup using (userid)
where created_date < gold_signup_date)
select * from sub1 
where next=1

--what is total orders and amount spent for each member before they become a member ?
select userid, count(created_date),sum(price)
from sales join goldusers_signup using (userid) join product using (product_id)
where created_date < gold_signup_date
group by 1

-- if buying each product generate points for eg 5rs=2 zomato point and 
--each product has different purchasing points— for eg for p1 5rs=1 zomato point,
--for p2 10rs=zomato point and p3 5rs=1 zomato point 2rs =1zomato point, — calculate
--points collected by each customers and for which product most points have
--been given till now.
select *,
CASE WHEN product_name='p1' THEN price/5 * 2
 WHEN product_name='p2' THEN price/10 * 2
 WHEN product_name='p1' THEN price/5 * 2 + price/2 *1
else 0 end as points
from sales join product using (product_id)

--rnk all transaction of the customers ?
select *,rank()over(partition by userid order by created_date) from sales 

--rank all transaction for each member whenever they are zomato gold member 
--for every non gold member transaction mark as na
with sub1 as (select *
from sales left join goldusers_signup using (userid))

select * ,
case when created_date >= gold_signup_date
THEN cast(rank()over(partition by userid order by created_date desc)as varchar)
else 'na' end as ranking	
from sub1


select * from