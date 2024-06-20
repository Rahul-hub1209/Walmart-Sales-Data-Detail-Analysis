use walmart;
SELECT * FROM walmart_sales;
-- ----------------------------------  Feature Engineering  ----------------------------------------------------------
-- 1. Time of Day

SELECT Time,
(CASE WHEN Time BETWEEN "00:00:00" AND "12;00:00" THEN "Morning"
 WHEN Time BETWEEN "12:01:00" AND "04:00:00" THEN "Afternoon" ELSE
 "Evening" END) as Time_of_Day
 FROM walmart_sales;
 
 ALTER TABLE walmart_sales ADD column time_of_day VARCHAR(25);
 
 SET SQL_SAFE_UPDATES = 0;
 UPDATE walmart_sales
 SET time_of_day = ( CASE WHEN Time BETWEEN "00:00:00" AND "12:00:00" THEN  "Morning"
                     WHEN Time BETWEEN "12:01:00" AND "04:00:00" THEN "Afternoon"
                     ELSE "Evening"
                     END );
SET SQL_SAFE_UPDATES = 1;

-- 2. DayName

SELECT Date, dayname(Date) as Day_name
FROM walmart_sales;

ALTER TABLE walmart_sales ADD column Day_Name VARCHAR(10);

SET SQL_SAFE_UPDATES=0;
UPDATE walmart_sales
SET Day_Name=dayname(Date);
SET SQL_SAFE_UPDATES=1;

-- 3. MonthName

SELECT Date, monthname(Date) as Month_Name
FROM walmart_sales;

ALTER TABLE walmart_sales ADD COLUMN Month_Name VARCHAR(10);

SET SQL_SAFE_UPDATES=0;
UPDATE walmart_sales
SET Month_Name= monthname(Date);
SET SQL_SAFE_UPDATES=1;

SELECT * FROM walmart_sales;

-- --------------------------------- Explorartory Data Analysis(EDA) ------------------------------------------------
-- -------------------------------------(A) Generic Questions --------------------------------------------------------
-- 1. How many distinct cities are present in the dataset?
SELECT DISTINCT City FROM walmart_sales;

-- 2. In which city is each branch situated?
SELECT DISTINCT Branch, City FROM walmart_sales;

-- ------------------------------------(B) Product Analysis ----------------------------------------------------------
-- 1. How many distinct product lines are there in the dataset?
SELECT COUNT(DISTINCT Product_Line) FROM walmart_sales;

-- 2. What is the most common payment method?

SELECT Payment, COUNT(Payment) as most_common_payment
FROM walmart_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 3.What is the most selling product line?
SELECT Product_Line, COUNT(Product_Line) as most_purchased_product_line
FROM walmart_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 4.What is the total revenue by month?
SELECT Month_Name, ROUND(SUM(Total),2) as Total_Revenue
FROM walmart_sales
GROUP BY 1
ORDER BY 2 DESC;

-- 5.Which month recorded the highest Cost of Goods Sold (COGS)?
SELECT Month_Name, ROUND(SUM(cogs),2) as total_cogs
FROM walmart_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 6. Which product line generated the highest revenue?
SELECT Product_line, ROUND(SUM(Total),2) as Highest_Revenue
FROM walmart_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 7. Which city has the highest revenue?
SELECT City, ROUND(SUM(Total),2) as Highest_Revenue
FROM walmart_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 8.Which product line incurred the highest VAT?

SELECT Product_Line, ROUND(SUM(Tax),2) as Highest_Tax
FROM walmart_sales
GROUP BY 1
ORDER BY 2
LIMIT 1;

-- 9. Retrieve each product line and add a column product_category, indicating 'Good' or 'Bad,'based on whether its sales are above the average.
SELECT * FROM walmart_sales; 
ALTER TABLE walmart_sales ADD COLUMN product_category VARCHAR(10);
SET SQL_SAFE_UPDATES=0;

SET @avg_total = (SELECT AVG(Total) FROM walmart_sales);
UPDATE walmart_sales
SET product_category = CASE 
    WHEN Total >= @avg_total THEN 'Good'
    ELSE 'Bad'
END;

-- 10.Which branch sold more products than average product sold?
SELECT Branch, SUM(Quantity) as Greater_than_avg
FROM walmart_sales
GROUP BY 1
HAVING SUM(Quantity)> AVG(Quantity)
ORDER BY 2 DESC
LIMIT 1;

-- 11. What is the most common product line by gender?
SELECT gender, product_line, tot_count
FROM (
    SELECT gender, product_line, COUNT(gender) as tot_count
    FROM walmart_sales
    WHERE gender="Female"
    GROUP BY gender, product_line
    ORDER BY tot_count DESC
    LIMIT 1
) AS female_max
UNION 
SELECT gender, product_line, tot_count
FROM (
    SELECT gender, product_line, COUNT(gender) as tot_count
    FROM walmart_sales
    WHERE gender="Male"
    GROUP BY gender, product_line
    ORDER BY tot_count DESC
    LIMIT 1
) AS male_max;

-- 12. What is the average rating of each product line?
SELECT * FROM walmart_sales;
SELECT Product_Line, ROUND(AVG(Rating),2) as AVG_RATING
FROM walmart_sales
GROUP BY 1
ORDER BY 2 DESC;

-- 13. Calculate total sales monthly?
SELECT year(Date)as year, monthname(Date)as month,ROUND(SUM(Total),2)as Total
FROM walmart_sales
GROUP BY 1,2
ORDER BY 3 DESC;


-- ----------------------------------- (C) Sales Analysis ------------------------------------------------------------
-- 1. Number of sales made in each time of the day per weekday.
SELECT Day_Name,time_of_day, COUNT(Invoice_ID) as total_sales_in_weekday
FROM walmart_sales
WHERE Day_Name !="Saturday" AND Day_Name !="Sunday"
GROUP BY 1,2
ORDER BY 1,2 DESC;

-- 2. Identify the customer type that generates the highest revenue.
SELECT Customer_type, ROUND(SUM(Total),2) as highest_revenue
FROM walmart_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 3. Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT City, ROUND(SUM(Tax),2) as highest_tax
FROM walmart_sales
GROUP BY 1
ORDER BY 2 DESC;

-- 4. Which customer type pays the most in VAT?
SELECT Customer_Type, ROUND(SUM(Tax),2) as highest_tax
FROM walmart_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- ---------------------------------------- (D) Customer Analysis ----------------------------------------------------
-- 1. How many unique customer types does the data have?
SELECT DISTINCT Customer_type
FROM walmart_sales;

-- 2. How many unique payment methods does the data have?
SELECT DISTINCT Payment
FROM walmart_sales;

-- 3. Which is the most common customer type?
SELECT Customer_type, COUNT(Customer_type)as common_customer
FROM walmart_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 4. Which customer type buys the most?
SELECT Customer_type, ROUND(SUM(Total),2)as most_buys
FROM walmart_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 5. What is the gender of most of the customers?
SELECT gender, COUNT(*)as most_gender
FROM walmart_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 6. What is the gender distribution per branch?
SELECT * from walmart_sales;
SELECT Branch,gender,COUNT(gender)as gender_distribution
FROM walmart_sales
GROUP BY 1,2
ORDER BY 1;

-- 7. Which time of the day do customers give most ratings?
SELECT time_of_day, AVG(Rating) as avg_rating
FROM walmart_sales
GROUP BY 1
ORDER BY 2 DESC;

-- 8. Which time of the day do customers give most ratings per branch?
SELECT Branch, time_of_day, AVG(Rating) as avg_rating
FROM walmart_sales
GROUP BY 1,2
ORDER BY 3 DESC;

SELECT * FROM walmart_sales;

-- 9. Which day of the week has the best avg ratings?
SELECT Day_Name, ROUND(AVG(Rating),2) as highest_avg_rating
FROM walmart_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIt 1;

-- 10. Which day of the week has the best average ratings per branch?
WITH CTE as (SELECT Day_Name,Branch, ROUND(AVG(Rating),2)as highest_avg_rating,
DENSE_RANK() OVER(partition by Branch order by ROUND(AVG(Rating),2))as "rnk"
FROM walmart_sales
GROUP BY 1,2
ORDER BY 3 DESC)

SELECT Day_Name, Branch,highest_avg_rating
FROM CTE
where rnk=1;


