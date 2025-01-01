-----------------------------------------Miscellaneous
SELECT * FROM sales;

BULK INSERT dbo.sales
FROM '/WalmartSalesData.csv'
WITH 
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

SELECT 
    name AS logical_name,
    physical_name AS file_location,
    type_desc AS file_type
FROM sys.master_files
WHERE database_id = DB_ID('SalesdataWalmart');

EXEC sp_helpfile;

SELECT time FROM WalmartSalesData;
 ------------------------------------------------------------------------------------------------------------------------------------------------------------- Feature Engineering------------------------------------------------------------------------
SELECT time,
      AS time_of_day
FROM WalmartSalesData;

ALTER TABLE WalmartSalesData
ADD time_of_day VARCHAR(20);


UPDATE WalmartSalesData
set time_of_day = (
      CASE
           WHEN time BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
           WHEN time BETWEEN '12:00:00' AND '15:59:59' THEN 'Afternoon'
           ELSE 'Evening'
       END
);

-------------------------------------------------FInding Day Name----------------------------------------------------------
ALTER TABLE WalmartSalesData
ADD day_name VARCHAR(10);

UPDATE WalmartSalesData
SET day_name = DATENAME(WEEKDAY, Date);



-------------------------------------------------Finding Date--------------------------------------------------------------
SELECT Date ,
    case
    when date between '2019-01-01' and '2019-01-31' then 'January'
    when date between '2019-02-01' and '2019-02-28' then 'February'
    when date between '2019-03-01' and '2019-03-31' then 'March'
    when date between '2019-04-01' and '2019-04-30' then 'April'
    when date between '2019-05-01' and '2019-05-31' then 'May'
    when date between '2019-06-01' and '2019-06-30' then 'June'
    when date between '2019-07-01' and '2019-07-31' then 'July'
    when date between '2019-08-01' and '2019-08-31' then 'August'
    when date between '2019-09-01' and '2019-09-30' then 'September'
    when date between '2019-10-01' and '2019-10-31' then 'OCtober'
    when date between '2019-11-01' and '2019-11-30' then 'November'
    else 'Decemmber'
    end as Month
      from WalmartSalesData;



SELECT Date,
       DATENAME(DAY, Date) AS Month
FROM WalmartSalesData;

ALTER TABLE WalmartSalesData
ADD Month_Name VARCHAR(20);

UPDATE WalmartSalesData
SET Month_Name = DATENAME(MONTH, Date);

SELECT * FROM WalmartSalesData;

-----------------------------------------------Generic-----------------------------------
-----------------------------------------------------------------------------------

--How many unique cities does the data have?
SELECT City
from WalmartSalesData 
GROUP by City;

--In which city is each branch?
SELECT Branch
from WalmartSalesData 
GROUP by Branch;

--------------------------------------------------Prodcuts-------------------------------------

----How many unique product lines does the data have?
SELECT Product_line
from WalmartSalesData 
GROUP by Product_line;

--What is the most common payment method?
SELECT TOP 1 Payment, COUNT(Payment) AS ct_pay
FROM WalmartSalesData
GROUP BY Payment
ORDER BY ct_pay DESC;
----What is the most selling product line?
SELECT top 1 Product_line, sum(Total) as most_selling_product
from WalmartSalesData
GROUP by  Product_line
ORDER by most_selling_product DESC;
----What is the total revenue by month?
SELECT Month_Name, sum(gross_income) as total_revenue
from WalmartSalesData
GROUP by  Month_Name
ORDER by total_revenue DESC;

-----What month had the largest COGS?
SELECT top 1 Month_Name, sum(cogs) as largest_cogs
from WalmartSalesData
GROUP by  Month_Name
ORDER by largest_cogs DESC;
 ----What product line had the largest revenue?
SELECT top 1 Product_line, sum(Total) as largest_revenue
from WalmartSalesData
GROUP by  Product_line
ORDER by largest_revenue DESC;

----What is the city with the largest revenue?
SELECT top 1 City, sum(Total) as largest_revenue
from WalmartSalesData
GROUP by  City
ORDER by largest_revenue DESC;
-----What product line had the largest VAT?
SELECT top 1 Product_line, sum(Tax_5) as largest_tax
from WalmartSalesData
GROUP by  Product_line
ORDER by largest_tax DESC;


----Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT 
    Product_line, 
    (SELECT AVG(Total) FROM WalmartSalesData) AS average, 
    AVG(Total) AS avg_sales, 
    CASE 
        WHEN AVG(Total) > (SELECT AVG(Total) FROM WalmartSalesData) THEN 'Good'
        ELSE 'Bad' 
    END AS Product_Review
FROM WalmartSalesData
GROUP BY Product_line;

----Which branch sold more products than average product sold?
SELECT Branch, sum(Quantity) AS avg_quantity
FROM WalmartSalesData
GROUP BY Branch
HAVING sum(Quantity) > (SELECT AVG(Quantity) FROM WalmartSalesData);

-----What is the most common product line by gender?
SELECT Top 1 Gender, Product_line, COUNT(Gender) as cnt_gender
from WalmartSalesData
GROUP by Gender, Product_line
order by cnt_gender DESC;

----What is the average rating of each product line?
SELECT Product_line, AVG(Rating) as avg_rating from WalmartSalesData
 GROUP by Product_line;
---------------------------------------------------------------------------Sales-----------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT * FROM WalmartSalesData;

---Number of sales made in each time of the day per weekday
SELECT time_of_day, COUNT(Quantity) as Sales_count 
from WalmartSalesData
group by time_of_day;

----Which of the customer types brings the most revenue?
SELECT Customer_type,ROUND(SUM(Total), 2)as RevenuePerCusterType
FROM WalmartSalesData
GROUP by Customer_type;
---Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT TOP 1 City, ROUND(AVG(Tax_5), 2) as LargestTax
 from WalmartSalesData
 GROUP by City
 ORDER BY LargestTax DESC;

 ----Which customer type pays the most in VAT?
SELECT TOP 1 Customer_type, ROUND(AVG(Tax_5), 2) as LargestTaxPayesBYCustomer
 from WalmartSalesData
 GROUP by Customer_type
 ORDER BY LargestTaxPayesBYCustomer DESC;

 -----------------------------------------------------------------------Customer--------------------------------------------------------------
 ---------------------------------------------------------------------------------------------------------------------------------------------

SELECT * FROM WalmartSalesData;


 ---How many unique customer types does the data have
SELECT distinct Customer_type from WalmartSalesData;
----How many unique payment methods does the data have?
SELECT distinct Payment from WalmartSalesData;
-----What is the most common customer type?
SELECT distinct Customer_type from WalmartSalesData;
----Which customer type buys the most?
SELECT Customer_type, SUM(Total) as Most_Buy from WalmartSalesData 
group by Customer_type
order by Most_Buy;

---What is the gender of most of the customers?
SELECT top 1 Gender, COUNT(*) as cnt_gen FROM WalmartSalesData 
group by Gender
order by cnt_gen DESC;

---What is the gender distribution per branch?
SELECT Branch, COUNT(*) as GenderPerBranch FROM WalmartSalesData
group by Branch;
---Which time of the day do customers give most ratings?
SELECT time_of_day, AVG(Rating) as CGivesMostRating 
FROM WalmartSalesData
group by time_of_day
order by CGivesMostRating DESC;
-----Which time of the day do customers give most ratings per branch?
SELECT Branch,time_of_day, ROUND(AVG(Rating), 2) as CGivesMostRating
FROM WalmartSalesData
group by time_of_day, Branch
order by CGivesMostRating DESC;

----Which day of the week has the best avg ratings?
SELECT day_name, ROUND(AVG(Rating), 2) as BestAvgRating
 from WalmartSalesData
 group by day_name
 order by BestAvgRating DESC;
----Which day of the week has the best average ratings per branch?
SELECT day_name, Branch, ROUND(AVG(Rating), 2) as BestAvgRating
 from WalmartSalesData
 group by day_name, Branch
 order by BestAvgRating DESC;