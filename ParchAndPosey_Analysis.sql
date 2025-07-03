-- Duplicates

SELECT id , account_id , COUNT(*) Duplicates FROM orders GROUP BY id , account_id HAVING COUNT(*) > 1;

-- nulls

SELECT * FROM orders WHERE total is null;
SELECT * FROM orders WHERE total= '';

-- removing '0'

DELETE FROM orders
WHERE total = 0;

-- Number of orders ?

SELECT FORMAT( COUNT( distinct id), '#,#') as Total_Orders
FROM orders;

-- Number of accounts ?

SELECT COUNT( distinct id ) as Total_Accounts
FROM accounts;

-- Accounts in each region

SELECT r.name , COUNT(a.id) Total_Accounts
FROM region r
JOIN sales_reps s
	ON r.id = s.region_id
JOIN accounts a
	ON s.id = a.sales_rep_id
GROUP BY r.name;

-- Total quantity sold ?

SELECT FORMAT(SUM( total ),'#,#') as Total_Quantity
FROM orders;

-- Total Revenue ?

SELECT FORMAT(SUM(total_amt_usd),'#,#') as Total_Revenue
FROM orders;

-- Total Revenue per Year

SELECT DATETRUNC(YEAR,occurred_at) Year , FORMAT( SUM(total_amt_usd),'c') Total_Revenue
FROM orders
GROUP BY DATETRUNC(YEAR,occurred_at)
ORDER BY DATETRUNC(YEAR,occurred_at);

-- Total revenue per month

SELECT FORMAT(occurred_at,'yyyy-MM') Month , FORMAT( SUM(total_amt_usd),'c') Total_Revenue
FROM orders
GROUP BY FORMAT(occurred_at,'yyyy-MM')
ORDER BY FORMAT(occurred_at,'yyyy-MM');

-- Total revenue for each paper type

SELECT 'Standard' as Products , FORMAT( SUM(standard_amt_usd),'c') Total_Revenue
FROM orders
UNION ALL
SELECT 'GLoss' as Products , FORMAT( SUM(gloss_amt_usd),'c') Total_Revenue
FROM orders
UNION ALL
SELECT 'Poster' as Products , FORMAT( SUM(poster_amt_usd),'c') Total_Revenue
FROM orders
ORDER BY Total_Revenue DESC;

-- Unit price for each paper type ?

SELECT  FORMAT( SUM(standard_amt_usd) / SUM(standard_qty),'N2') as Standard_UnitPrice,
		FORMAT( SUM(gloss_amt_usd)/SUM(gloss_qty),'N2') as Gloss_UnitPrice,
		FORMAT( SUM(poster_amt_usd)/SUM(poster_qty),'N2') as Poster_UnitPrice
FROM orders;

-- Total sales rep?

SELECT COUNT(id) Total_SalesRep
FROM sales_reps;

-- Find the number of sales reps in each region

SELECT r.name , COUNT(s.id) NumOFSalesRep
FROM region r
JOIN sales_reps s
	ON r.id = s.region_id
GROUP BY r.name;

-- Number of accounts each sales rep manage

SELECT 
		s.id , COUNT(a.id) Total_Accounts
FROM sales_reps s
JOIN accounts a
	ON s.id = a.sales_rep_id
GROUP BY s.id
ORDER BY Total_Accounts DESC;

-- The region for each sales rep and the account he manage

SELECT 
		s.id , s.name , r.name , a.id , a.name
FROM sales_reps s
JOIN region r
	ON s.region_id = r.id
JOIN accounts a
	ON s.id = a.sales_rep_id
ORDER BY s.id;

-- First account Started ?

SELECT TOP 1 
		w.id WebEvent_ID , w.occurred_at , w.account_id , 
		a.name Account_Name , w.channel
FROM web_events w
JOIN accounts a
	ON w.account_id = a.id
ORDER BY occurred_at;

-- First account purchased ?

SELECT TOP 1 
o.id Order_ID , a.id Account_ID , a.name Account_Name , o.occurred_at , o.total , o.total_amt_usd 
FROM orders o
JOIN accounts a
	ON o.account_id = a.id
ORDER BY o.occurred_at ASC;

-- More details about the account whose id is 2861 

SELECT TOP 1
		a.id Account_ID, a.name Account_Name , a.primary_poc , 
		w.id WebEvent_ID , w.occurred_at , w.channel , 
		a.sales_rep_id , s.name Sales_Name , r.name Region_Name
FROM accounts a
JOIN web_events w 
	ON a.id = w.account_id
JOIN sales_reps s 
	ON a.sales_rep_id = s.id
JOIN region r 
	ON s.region_id = r.id
WHERE a.id = 2861;

-- Highest order ?

SELECT TOP 1
		id , account_id , occurred_at , FORMAT( total_amt_usd,'N2') Highest_Order
FROM orders
ORDER BY total_amt_usd DESC;

-- Top 10 orders 

SELECT  TOP 10 
		*
FROM orders
ORDER BY total_amt_usd DESC;

-- Name of region for every order with account name

SELECT
		o.id , a.name acc_name, r.name reg_name
FROM orders o
JOIN accounts a
	ON o.account_id = a.id
JOIN sales_reps s
	ON a.sales_rep_id = s.id
JOIN region r
	ON s.region_id = r.id;

-- Most recent order

SELECT TOP 1 *
FROM orders
ORDER BY occurred_at DESC;

-- Via what channel did the most recent web_event occur, which account was associated with this web_event? 

SELECT	TOP 1
		w.id , w.occurred_at , w.account_id , a.name , w.channel 
FROM web_events w
JOIN accounts a
	ON w.account_id = a.id
ORDER BY occurred_at DESC;

-- Average quantity and revenue for each paper type

SELECT 
		AVG(standard_qty) Standard_AvgQty , FORMAT( AVG(standard_amt_usd), 'N2') Standard_AvgRev,
		AVG(gloss_qty) Gloss_AvgQty , FORMAT( AVG(gloss_amt_usd), 'N2') Gloss_AvgRev,
		AVG(poster_qty) Poster_AvgQty , FORMAT( AVG(poster_amt_usd), 'N2') Poster_AvgRev
FROM orders;

-- Total sales for each account (order by total sales desc to show the top customers)

SELECT a.id , a.name , FORMAT( SUM(o.total_amt_usd), 'N2') Total_Sales
FROM accounts a
JOIN orders o
	ON a.id = o.account_id
GROUP BY a.id , a.name
ORDER BY SUM(o.total_amt_usd) DESC;

-- Total number of times each type of channel was used

SELECT channel , COUNT(channel) NumOfTimes 
FROM web_events
GROUP BY channel;

-- For each account, determine the average amount of each type of paper they purchased across their orders

SELECT o.account_id, a.name , AVG(standard_qty) Standard_AvgQty, AVG(gloss_qty) Gloss_AvgQty , AVG(poster_qty) Poster_AvgQty
FROM orders o
JOIN accounts a
	ON o.account_id = a.id
GROUP BY o.account_id , a.name;

-- Determine the number of times a particular channel was used in the web_events table for each sales rep

SELECT s.name , w.channel , COUNT(w.channel) NumOfTimes
FROM sales_reps s
JOIN accounts a
	ON s.id = a.sales_rep_id
JOIN web_events w
	ON a.id = w.account_id
GROUP BY s.name , w.channel;

-- Determine the number of times a particular channel was used for each region

SELECT r.name , channel , COUNT(channel) NumOfTimes
FROM region r 
JOIN sales_reps s
	ON r.id = s.region_id
JOIN accounts a
	ON s.id = a.sales_rep_id
JOIN web_events w
	ON a.id = w.account_id
GROUP BY r.name , channel;

-- Have any sales reps worked on more than one account

WITH AccPerSR AS ( SELECT s.id , COUNT(a.id) Total_accounts
					FROM sales_reps s
					JOIN accounts a
						ON s.id = a.sales_rep_id
					GROUP BY s.id
					HAVING COUNT(a.id) > 1 )

SELECT COUNT(id) NumberOfSalesRep FROM AccPerSR;

-- Find the sales in terms of total dollars for all orders in each year

SELECT YEAR(occurred_at) Sales_Year , FORMAT( SUM(total_amt_usd),'N2') Total_Sales
FROM orders
GROUP BY YEAR(occurred_at);

-- Which month did Parch & Posey have the greatest sales in terms of total dollars?

SELECT TOP 1 MONTH(occurred_at) Sales_Month , FORMAT(SUM(total_amt_usd),'c') Total_Sales 
FROM orders
GROUP BY MONTH(occurred_at)
ORDER BY SUM(total_amt_usd) DESC;

-- Which year did Parch & Posey have the greatest sales in terms of total number of orders?

SELECT TOP 1 YEAR(occurred_at) Sales_Year , COUNT(id) Total_Orders
FROM orders
GROUP BY YEAR(occurred_at)
ORDER BY Total_Orders DESC;

-- Which month did Parch & Posey have the greatest sales in terms of total number of orders

SELECT TOP 1 MONTH(occurred_at) Sales_Year , COUNT(id) Total_Orders
FROM orders
GROUP BY MONTH(occurred_at)
ORDER BY Total_Orders DESC;

-- Arranged orders

SELECT
		*,
		ROW_NUMBER() OVER(ORDER BY occurred_at) AS Arranged_Orders
FROM orders;

-- Sales per region

SELECT r.name Region, FORMAT( SUM(total_amt_usd),'N2') Total_Sales 
FROM region r
JOIN sales_reps s
	ON r.id = s.region_id
JOIN accounts a
	ON s.id = a.sales_rep_id
JOIN orders o 
	ON a.id = o.account_id
GROUP BY r.name;

-- For the region with the largest sales , how many total orders were placed

SELECT TOP 1 r.name Region, FORMAT( SUM(total_amt_usd),'N2') Total_Sales , COUNT(o.id) NumOfOrders
FROM region r
JOIN sales_reps s
	ON r.id = s.region_id
JOIN accounts a
	ON s.id = a.sales_rep_id
JOIN orders o 
	ON a.id = o.account_id
GROUP BY r.name
ORDER BY Total_Sales DESC;

-- Top 5 Performing sales rep  

SELECT TOP 5
		s.id,
		s.name,
		FORMAT( SUM(total_amt_usd) , 'c') Total_Sales
FROM sales_reps s
JOIN accounts a
	ON s.id = a.sales_rep_id
JOIN orders o 
	ON a.id = o.account_id
GROUP BY s.name , s.id
ORDER BY SUM(total_amt_usd) DESC;

-- top performing sales rep in each region

WITH Ranked_Rep AS	(SELECT s.name ,r.name region , FORMAT( SUM(o.total_amt_usd),'C') Total_Sales,
					RANK() OVER ( PARTITION BY r.name ORDER BY SUM(o.total_amt_usd) DESC) AS Rank_num
	FROM sales_reps s 
	JOIN accounts a
		ON s.id = a.sales_rep_id
	JOIN orders o 
		ON a.id = o.account_id
	JOIN region r
		ON s.region_id = r.id
	GROUP BY s.name , r.name)

SELECT name , region , Total_Sales
FROM Ranked_Rep
WHERE Rank_num = 1;

-- For the customer that spent the most total_amt_usd, how many web_events did they have for each channel

WITH Ranked_customer AS(
SELECT TOP 1 a.id , a.name , FORMAT(SUM(o.total_amt_usd),'c') as Total_Sales
FROM accounts a
JOIN orders o 
	ON a.id = o.account_id
GROUP BY a.id,a.name
ORDER BY SUM(o.total_amt_usd) DESC)

SELECT a.name , w.channel , COUNT(w.id) NumOfTimes
FROM accounts a
JOIN web_events w
	ON a.id = w.account_id AND a.id = (SELECT id FROM Ranked_customer)
GROUP BY a.name , w.channel
ORDER BY NumOfTimes DESC;

-- Orders without account associated

select o.* , a.*
from orders o 
left JOIN accounts a
	ON o.account_id = a.id
WHERE a.id is null;

-- Total spending and total orders per account

WITH Ranked_Accounts AS(
SELECT
	a.name Account_Name,
	FORMAT( SUM(total_amt_usd),'c') Total_Spending,
	COUNT(o.id) Total_Orders,
	RANK() OVER(ORDER BY SUM(total_amt_usd) DESC) as Acc_Rank
FROM orders o
JOIN accounts a
	ON o.account_id = a.id
GROUP BY a.name )
-- Top 5 Accounts
SELECT *
FROM Ranked_Accounts
WHERE Acc_Rank in (1,2,3,4,5);

-- Monthly Sales Growth rate

WITH Monthly_Sales AS(
	SELECT FORMAT(occurred_at,'yyyy-MM') Sales_Month,
			SUM(total_amt_usd) CurrentMonth_Sales
	FROM orders
	GROUP BY FORMAT(occurred_at,'yyyy-MM')
	),
	Lagged_Sales AS(
	SELECT  Sales_Month,
			CurrentMonth_Sales,
			LAG(CurrentMonth_Sales,1) OVER(ORDER BY Sales_Month) AS PrevMonth_Sales
	FROM Monthly_Sales)

SELECT
		Sales_Month,
		CurrentMonth_Sales,
		PrevMonth_Sales,
		CASE WHEN PrevMonth_Sales is null OR PrevMonth_Sales = 0 THEN NULL
		ELSE ROUND(((CurrentMonth_Sales-PrevMonth_Sales)*100)/PrevMonth_Sales,2) END AS Growth_Rate
FROM Lagged_Sales
ORDER BY Sales_Month;

-- Sales rep running total

DROP PROCEDURE SalesRep_RunningTotal;

CREATE PROCEDURE SalesRep_RunningTotal @id int = NULL AS
BEGIN
SELECT
	s.id,s.name,o.occurred_at,
	SUM(o.total_amt_usd) OVER(PARTITION BY s.id ORDER BY o.occurred_at) AS Running_Sales
FROM orders o
JOIN accounts a
	ON o.account_id = a.id
JOIN sales_reps s
	ON a.sales_rep_id = s.id
WHERE s.id = @id or s.id is NULL
END;

EXEC SalesRep_RunningTotal @id = 321800;


