CREATE DATABASE car_sales;
USE car_sales;

SELECT *
FROM car_data;

-- DATA CLEANING --

-- Looking for duplicates --
WITH duplicate_cte AS(SELECT *, ROW_NUMBER() OVER(PARTITION BY Car_id) AS row_num
FROM car_data)

SELECT row_num
FROM duplicate_cte
WHERE row_num > 1;
-- There are no duplicates in the table 

-- Filtering Columns --
SELECT DISTINCT `Date`
FROM car_data;

SELECT DISTINCT `Customer Name`
FROM car_data;

SELECT DISTINCT Gender
FROM car_data;

SELECT DISTINCT Dealer_Name
FROM car_data;

SELECT DISTINCT Company
FROM car_data;

SELECT DISTINCT Model
FROM car_data;

SELECT DISTINCT `Engine`
FROM car_data;

SELECT DISTINCT Transmission
FROM car_data;

SELECT DISTINCT Color
FROM car_data;

SELECT DISTINCT `Body Style`
FROM car_data;

SELECT DISTINCT Dealer_Region
FROM car_data;

-- Updating Columns --
SELECT *
FROM car_data
WHERE Model = 'Sebring Conv.';

UPDATE car_data
SET Model = 'Sebring Convertible'
WHERE Model = 'Sebring Conv.';

UPDATE car_data
SET `Engine` = 'Single_Overhead_Camshaft'
WHERE `Engine` = 'Overhead Camshaft';

UPDATE car_data
SET `Engine` = 'Dual_Overhead_Camshaft'
WHERE `Engine` = 'DoubleÃ‚Â Overhead Camshaft';

ALTER TABLE car_data
MODIFY COLUMN Phone VARCHAR(15);

UPDATE car_data
SET Phone = CONCAT(SUBSTRING(Phone, 1, 3), '-', SUBSTRING(Phone, 4, 7));

-- DATA TRANSFORMATION --

-- Adding new column --
ALTER TABLE car_data
ADD COLUMN `Month` VARCHAR(15);

SELECT MONTHNAME(STR_TO_DATE(`Date`, '%m/%d/%Y')) AS Month_name
FROM car_data;

UPDATE car_data
SET `Month` = MONTHNAME(STR_TO_DATE(`Date`, '%m/%d/%Y'));

-- DATA ANALYSIS --
SELECT COUNT(*) AS Num_of_Sales
FROM car_data;

-- 1
-- Counts the number of sales

SELECT Phone, Num_of_Sales
FROM (SELECT Phone, ROW_NUMBER() OVER(PARTITION BY Phone) AS Num_of_Sales FROM car_data) AS rn
WHERE Num_of_Sales > 1
ORDER BY Num_of_Sales DESC;

-- 2
-- Identify phone numbers that appear more than once by assigning a sequential row number to each phone number 
-- and filtering out those with more than one occurrence. The results are ordered by the number of occurrences in descending order.

SELECT `Customer Name`, Phone, Num_of_Sales
FROM (SELECT `Customer Name`, Phone, ROW_NUMBER() OVER(PARTITION BY `Customer Name`, Phone) AS Num_of_Sales FROM car_data) AS rn
WHERE Num_of_Sales > 1
ORDER BY Num_of_Sales DESC;

-- 3
-- Identify customers with duplicate phone numbers in the car_data table
-- The query assigns a sequential row number to each combination of customer name and phone number and filters out those with more than one occurrence.
-- The results are ordered by the number of occurrences in descending order.

SELECT Gender, COUNT(*) AS Num_of_Sales
FROM car_data
GROUP BY Gender;

-- 4
-- Count the number of sales for each gender in the car_data table
-- The query groups the data by gender and counts the total number of sales for each group

SELECT Gender, ROUND(AVG(`Price ($)`), 2) AS Avg_Price
FROM car_data
GROUP BY Gender;

-- 5
-- Calculate the average price of cars for each gender, rounded to two decimal places
-- The query groups the data by gender and computes the average price for each group

SELECT Gender, ROUND(AVG(`Annual Income`), 2) AS Avg_Annual_Income
FROM car_data
GROUP BY Gender;

-- 6
-- Calculate the average annual income for each gender, rounded to two decimal places
-- The query groups the data by gender and computes the average annual income for each group

SELECT Gender, Company, COUNT(*) AS Num_of_Sales
FROM car_data
WHERE Gender = 'Male'
GROUP BY Gender, Company
ORDER BY Num_of_Sales DESC;

-- 7
-- Count the number of sales for each company where the customer gender is male
-- The query filters the data to include only male customers, groups the results by gender and company,
-- and counts the total number of sales for each group. The results are ordered by the number of sales in descending order.

SELECT Gender, Company, COUNT(*) AS Num_of_Sales
FROM car_data
WHERE Gender = 'Female'
GROUP BY Gender, Company
ORDER BY Num_of_Sales DESC;

-- 8
-- Count the number of sales for each company where the customer gender is female
-- The query filters the data to include only female customers, groups the results by gender and company,
-- and counts the total number of sales for each group. The results are ordered by the number of sales in descending order.

WITH male_cte AS(SELECT Gender, Company, COUNT(*) AS Num_of_Sales
FROM car_data
WHERE Gender = 'Male'
GROUP BY Gender, Company
ORDER BY Num_of_Sales DESC),
female_cte AS(SELECT Gender, Company, COUNT(*) AS Num_of_Sales
FROM car_data
WHERE Gender = 'Female'
GROUP BY Gender, Company
ORDER BY Num_of_Sales DESC),
popularity_cte AS(SELECT m.Company AS Company_name,
NTILE(10) OVER(ORDER BY m.Num_of_Sales) AS Male_Popularity_Rank,
NTILE(10) OVER(ORDER BY f.Num_of_Sales) AS Female_Popularity_Rank
FROM male_cte m
JOIN female_cte f
ON m.Company = f.Company
ORDER BY Male_Popularity_Rank DESC)
 
SELECT Company_name, Male_Popularity_Rank,  Female_Popularity_Rank,  (Male_Popularity_Rank +  Female_Popularity_Rank) AS Popularity_Rank, CASE
WHEN (Male_Popularity_Rank +  Female_Popularity_Rank) >= 15 THEN 'Very Popular'
WHEN (Male_Popularity_Rank +  Female_Popularity_Rank) >= 10 THEN 'Popular'
WHEN (Male_Popularity_Rank +  Female_Popularity_Rank) >= 5 THEN 'Moderately Popular'
WHEN (Male_Popularity_Rank +  Female_Popularity_Rank) < 5 THEN 'Less Popular'
END AS Popularity
FROM popularity_cte
ORDER BY Popularity_Rank DESC;

-- 9
-- Analyzes the popularity ranks of car companies based on sales data categorized by gender.
-- Uses common table expressions (CTEs) to calculate sales counts for males and females separately,
-- assigns popularity ranks using NTILE, and categorizes companies by their combined popularity ranks.

SELECT Gender, Company, Model, Count(*) AS Number_of_Sales
FROM car_data
WHERE Company IN ('Dodge', 'Ford', 'Chevrolet') AND Gender = 'Male'
GROUP BY Gender, Company, Model
ORDER BY Gender, Company, Number_of_Sales DESC;

-- 10
-- Calculates the count of sales by gender, company, and car model for specified brands (Dodge, Ford, Chevrolet)
-- among males, ordered by gender, company, and number of sales in descending order.

SELECT Gender, Company, Model, Count(*) AS Number_of_Sales
FROM car_data
WHERE Company IN ('Dodge', 'Ford', 'Chevrolet') AND Gender = 'Female'
GROUP BY Gender, Company, Model
ORDER BY Gender, Company, Number_of_Sales DESC;

-- 11
-- Calculates the count of sales by gender, company, and car model for specified brands (Dodge, Ford, Chevrolet)
-- among females, ordered by gender, company, and number of sales in descending order.

SELECT Gender, Dealer_Name, COUNT(*) AS Number_of_Sales
FROM car_data
GROUP BY Gender, Dealer_Name
ORDER BY Gender, Number_of_Sales DESC;

-- 12
-- Counts the number of car sales grouped by gender and dealer name,
-- ordered by gender and number of sales in descending order.

SELECT Gender, Transmission, COUNT(*) AS Number_of_Sales
FROM car_data
GROUP BY Gender, Transmission
ORDER BY Gender, Number_of_Sales DESC;

-- 13
-- Counts the number of car sales grouped by gender and transmission type,
-- ordering the results by gender and number of sales in descending order.

SELECT Gender, Color, COUNT(*) AS Number_of_Sales
FROM car_data
GROUP BY Gender, Color
ORDER BY Gender, Number_of_Sales DESC;

-- 14
-- Counts the number of car sales grouped by gender and car color,
-- ordering the results by gender and number of sales in descending order.

SELECT Gender, `Body Style`, COUNT(*) AS Number_of_Sales
FROM car_data
GROUP BY Gender, `Body Style`
ORDER BY Gender, Number_of_Sales DESC;

-- 15
-- Counts the number of car sales grouped by gender and body style,
-- ordering the results by gender and number of sales in descending order.

SELECT Gender, Dealer_Region, COUNT(*) AS Number_of_Sales
FROM car_data
GROUP BY Gender, Dealer_Region
ORDER BY Gender, Number_of_Sales DESC;

-- 16
-- Counts the number of car sales grouped by gender and dealer region,
-- ordering the results by gender and number of sales in descending order.

SELECT Gender, `Month`, COUNT(*) AS Number_of_Sales
FROM car_data
GROUP BY Gender, `Month`
ORDER BY Gender, Number_of_Sales DESC;

-- 17
-- Counts the number of car sales grouped by gender and month,
-- ordering the results by gender and number of sales in descending order.

SELECT ROUND(AVG(`Annual Income`), 2) AS avg_annual_income
FROM car_data;

-- 18
-- Calculates the rounded average annual income

SELECT annual_income_rank, Dealer_name, Count(*) AS Number_of_Sales
FROM (SELECT *, NTILE(10) OVER(ORDER BY `Annual Income`) AS annual_income_rank FROM car_data) AS ranking
-- WHERE annual_income_rank = 10
GROUP BY annual_income_rank, Dealer_name
ORDER BY annual_income_rank DESC, Number_of_Sales DESC;

-- 19
-- Calculates the number of sales per dealer grouped by the rank of annual income.
-- Uses a subquery to assign annual income ranks using NTILE, then groups by income rank and dealer name,
-- ordering the results by income rank and number of sales in descending order.

SELECT annual_income_rank, Company, Count(*) AS Number_of_Sales
FROM (SELECT *, NTILE(10) OVER(ORDER BY `Annual Income`) AS annual_income_rank FROM car_data) AS ranking
-- WHERE annual_income_rank = 1
GROUP BY annual_income_rank, Company
ORDER BY annual_income_rank DESC, Number_of_Sales DESC;

-- 20
-- Calculates the number of sales per company grouped by the rank of annual income.
-- Uses a subquery to assign annual income ranks using NTILE, then groups by income rank and company,
-- ordering the results by income rank and number of sales in descending order.

SELECT annual_income_rank, Company, Model, Count(*) AS Number_of_Sales
FROM (SELECT *, NTILE(10) OVER(ORDER BY `Annual Income`) AS annual_income_rank FROM car_data) AS ranking
-- WHERE annual_income_rank = 5 AND Company = 'Chevrolet'
GROUP BY annual_income_rank, Company, Model
ORDER BY annual_income_rank DESC, Number_of_Sales DESC;

-- 21
-- Calculates the number of sales per company and car model, grouped by the rank of annual income.
-- Uses a subquery to assign annual income ranks using NTILE, then groups by income rank, company, and model,
-- ordering the results by income rank and number of sales in descending order.

SELECT 
	ROUND((SUM((`Annual Income` - avg_annual_income) * (`Price ($)` - avg_price)) / COUNT(*)) /
    (SQRT(SUM(POW(`Annual Income` - avg_annual_income, 2)) / COUNT(*)) * SQRT(SUM(POW(`Price ($)` - avg_price, 2)) / COUNT(*))), 5) AS correlation_coefficient
FROM (SELECT `Annual Income`, `Price ($)`, (SELECT AVG(`Annual Income`) FROM car_data) AS avg_annual_income, (SELECT AVG(`Price ($)`) FROM car_data) AS avg_price FROM car_data) AS subquerry;

-- 22
-- Calculates the correlation coefficient between annual income and car price using Pearson correlation coefficient

SELECT COUNT(DISTINCT(Dealer_Name)) AS Number_of_Dealers
FROM car_data;

-- 23
-- Counts the number of distinct dealer names

SELECT Dealer_Name, COUNT(*) AS Number_of_Sales
FROM car_data
GROUP BY Dealer_Name
ORDER BY Number_of_Sales DESC;

-- 24
-- Counts the number of sales per dealer name in the car_data table,
-- ordering the results by the number of sales in descending order.

SELECT Dealer_Name, COUNT(*) / (SELECT COUNT(*) FROM car_data) * 100 AS pct_of_sales
FROM car_data
GROUP BY Dealer_Name
ORDER BY pct_of_sales DESC;

-- 25
-- Calculates the percentage of total sales attributed to each dealer name in the car_data table,
-- grouping the results by dealer name and ordering them by percentage of sales in descending order.

SELECT Dealer_Name, Company, Count(*) AS Number_of_Sales
FROM car_data
-- WHERE Dealer_name = 'Chrysler Plymouth'
GROUP BY Dealer_Name, Company
ORDER BY Dealer_Name, Number_of_Sales DESC;

-- 26
-- Calculates the count of sales per dealer name and company in the car_data table,
-- grouping the results by dealer name and company, and ordering them by dealer name and number of sales in descending order.

SELECT Dealer_Name, Company, (Number_of_Sales / SUM(Number_of_Sales) OVER(PARTITION BY Dealer_Name) * 100) AS pct_of_sales
FROM (SELECT Dealer_Name, Company, Count(*) AS Number_of_Sales
FROM car_data
GROUP BY Dealer_Name, Company) AS subquery
ORDER BY Dealer_Name, pct_of_sales DESC;

-- 27
-- Calculates the percentage of total sales for each company within each dealer,
-- using window functions to partition by dealer name and ordering the results by dealer name and percentage of sales in descending order.

SELECT Dealer_Name, Company, Model, Count(*) AS Number_of_Sales
FROM car_data
-- WHERE Dealer_name = 'Chrysler Plymouth' AND Company = 'Mitsubishi'
GROUP BY Dealer_Name, Company, Model
ORDER BY Dealer_Name, Number_of_Sales DESC;

-- 28
-- Calculates the count of sales per dealer name, company, and car model in the car_data table,
-- grouping the results by dealer name, company, and model, and ordering them by dealer name and number of sales in descending order.

SELECT Dealer_Name, `Engine`, Count(*) AS Number_of_Sales
FROM car_data
-- WHERE Dealer_name = 'Chrysler Plymouth'
GROUP BY Dealer_Name, `Engine`
ORDER BY Dealer_Name, Number_of_Sales DESC;

-- 29
-- Calculates the count of sales per dealer name and engine type in the car_data table,
-- grouping the results by dealer name and engine type, and ordering them by dealer name and number of sales in descending order.

SELECT Dealer_Name, Transmission, Count(*) AS Number_of_Sales
FROM car_data
-- WHERE Dealer_name = 'Chrysler Plymouth'
GROUP BY Dealer_Name, Transmission
ORDER BY Dealer_Name, Number_of_Sales DESC;

-- 30
-- Calculates the count of sales per dealer name and transmission type in the car_data table,
-- grouping the results by dealer name and transmission type, and ordering them by dealer name and number of sales in descending order.

SELECT Dealer_Name, Color, Count(*) AS Number_of_Sales
FROM car_data
-- WHERE Dealer_name = 'Chrysler Plymouth'
GROUP BY Dealer_Name, Color
ORDER BY Dealer_Name, Number_of_Sales DESC;

-- 31
-- Calculates the count of sales per dealer name and car color in the car_data table,
-- grouping the results by dealer name and color, and ordering them by dealer name and number of sales in descending order.

SELECT Dealer_Name, SUM(`Price ($)`) AS Amount_of_Income
FROM car_data
GROUP BY Dealer_Name
ORDER BY Amount_of_Income DESC;

-- 32
-- Calculates the total income generated per dealer name from car sales in the car_data table,
-- grouping the results by dealer name and ordering them by total income in descending order.

SELECT Dealer_Name, Company, SUM(`Price ($)`) AS Amount_of_Income
FROM car_data
-- WHERE Dealer_Name = 'Rabun Used Car Sales'
GROUP BY Dealer_Name, Company
ORDER BY Dealer_Name, Amount_of_Income DESC;

-- 33
-- Calculates the total income generated per dealer name and company from car sales in the car_data table,
-- grouping the results by dealer name and company, and ordering them by dealer name and total income in descending order.

SELECT Dealer_Name, Company, Model, SUM(`Price ($)`) AS Amount_of_Income
FROM car_data
-- WHERE Dealer_Name = 'Rabun Used Car Sales' AND Company = 'Volkswagen'
GROUP BY Dealer_Name, Company, Model
ORDER BY Dealer_Name, Amount_of_Income DESC;

-- 34
-- Calculates the total income generated per dealer name, company, and car model from car sales in the car_data table,
-- grouping the results by dealer name, company, and model, and ordering them by dealer name and total income in descending order.

SELECT Dealer_Name, `Month`, SUM(`Price ($)`) AS Amount_of_Income
FROM car_data
-- WHERE Dealer_Name = 'Rabun Used Car Sales' 
GROUP BY Dealer_Name, `Month`
ORDER BY Dealer_Name, Amount_of_Income DESC;

-- 35
-- Calculates the total income generated per dealer name and month from car sales in the car_data table,
-- grouping the results by dealer name and month, and ordering them by dealer name and total income in descending order.

SELECT Dealer_Name, `Body Style`, SUM(`Price ($)`) AS Amount_of_Income
FROM car_data
-- WHERE Dealer_Name = 'Rabun Used Car Sales' 
GROUP BY Dealer_Name, `Body Style`
ORDER BY Dealer_Name, Amount_of_Income DESC;

-- 36
-- Calculates the total income generated per dealer name and car body style from car sales in the car_data table,
-- grouping the results by dealer name and body style, and ordering them by dealer name and total income in descending order.

SELECT Dealer_Name, `Body Style`, COUNT(*) AS Number_of_Sales
FROM car_data
GROUP BY Dealer_Name, `Body Style`
ORDER BY Dealer_Name, Number_of_Sales DESC;

-- 37
-- Calculates the count of sales per dealer name and car body style in the car_data table,
-- grouping the results by dealer name and body style, and ordering them by dealer name and number of sales in descending order.

SELECT Dealer_Name, Dealer_Region
FROM car_data
GROUP BY Dealer_Name, Dealer_Region
ORDER BY Dealer_Region;

-- 38
-- Retrieves unique combinations of dealer name and dealer region from the car_data table,
-- grouping the results by dealer name and dealer region, and ordering them by dealer region.

SELECT Dealer_Name, `Month`, COUNT(*) AS Number_of_Sales
FROM car_data
GROUP BY Dealer_Name, `Month`
ORDER BY Dealer_Name, Number_of_Sales DESC;

-- 39
-- Calculates the count of sales per dealer name and month in the car_data table,
-- grouping the results by dealer name and month, and ordering them by dealer name and number of sales in descending order.

SELECT COUNT(DISTINCT(Company)) AS num_of_company
FROM car_data;

-- 40
-- Counts the number of distinct companies

SELECT Company, Count(*) AS Number_of_Sales
FROM car_data
GROUP BY Company
ORDER BY Number_of_Sales DESC;

-- 41
-- Calculates the count of sales per company in the car_data table,
-- grouping the results by company and ordering them by number of sales in descending order.

SELECT Company, SUM(`Price ($)`) Total_sales
FROM car_data
GROUP BY Company
ORDER BY Total_sales DESC;

-- 42
-- Calculates the total sales per company from the car_data table,
-- grouping the results by company and ordering them by total sales in descending order.

SELECT Company, Model, COUNT(*) AS Number_of_Sales
FROM car_data
GROUP BY Company, Model
ORDER BY Number_of_Sales DESC;

-- 43
-- Calculates the count of sales per company and car model in the car_data table,
-- grouping the results by company and model, and ordering them by number of sales in descending order.

SELECT Company, Model, AVG(`Price ($)`) AS avg_price
FROM car_data
-- WHERE Company = 'Ford' AND Model = 'Expedition'
GROUP BY Company, Model
ORDER BY avg_price DESC;

-- 44
-- Calculates the average price per company and car model in the car_data table,
-- grouping the results by company and model, and ordering them by average price in descending order.

SELECT Company, Model, MAX(`Price ($)`) AS max_price
FROM car_data
-- WHERE Company = 'Ford' AND Model = 'Expedition'
GROUP BY Company, Model
ORDER BY max_price DESC;

-- 45
-- Retrieves the maximum price per company and car model in the car_data table,
-- grouping the results by company and model, and ordering them by maximum price in descending order.

SELECT Company, Model, MIN(`Price ($)`) AS min_price
FROM car_data
-- WHERE Company = 'Ford' AND Model = 'Expedition'
GROUP BY Company, Model
ORDER BY min_price;

-- 46
-- Retrieves the minimum price per company and car model in the car_data table,
-- grouping the results by company and model, and ordering them by minimum price in ascending order.

SELECT Company, Model, SUM(`Price ($)`) AS Amount_of_Income
FROM car_data
-- WHERE Company = 'Ford' AND Model = 'Expedition'
GROUP BY Company, Model
ORDER BY Amount_of_Income DESC;

-- 47
-- Calculates the total income generated per company and car model in the car_data table,
-- grouping the results by company and model, and ordering them by total income in descending order.

SELECT Company, Model, `Body Style`
FROM car_data
GROUP BY Company, Model, `Body Style`
ORDER BY Company;

-- 48
-- Retrieves unique combinations of company, car model, and body style from the car_data table,
-- grouping the results by company, model, and body style, and ordering them by company.

SELECT cd.Company, cd.Model, cd.`Body Style`, COUNT(*) AS Number_of_Sales
FROM car_data cd
JOIN (
    SELECT Company, Model
    FROM car_data
    GROUP BY Company, Model
    HAVING COUNT(DISTINCT `Body Style`) > 1
) subquery ON cd.Company = subquery.Company AND cd.Model = subquery.Model
GROUP BY cd.Company, cd.Model, cd.`Body Style`
ORDER BY cd.Company, cd.Model, Number_of_Sales DESC;

-- 49
-- Retrieves the count of sales per company, car model, and body style from the car_data table,
-- filtering only those combinations where a car model has more than one distinct body style.
-- Groups the results by company, model, and body style, and orders them by company, model, body style, and number of sales in descending order.

SELECT cd.Company, cd.Model, cd.`Body Style`, SUM(`Price ($)`) AS Amount_of_Income
FROM car_data cd
JOIN (
    SELECT Company, Model
    FROM car_data
    GROUP BY Company, Model
    HAVING COUNT(DISTINCT `Body Style`) > 1
) subquery ON cd.Company = subquery.Company AND cd.Model = subquery.Model
GROUP BY cd.Company, cd.Model, cd.`Body Style`
ORDER BY cd.Company, cd.Model, cd.`Body Style`, Amount_of_Income DESC;

-- 50
-- Calculates the total income generated per company, car model, and body style from the car_data table,
-- filtering only those combinations where a car model has more than one distinct body style.
-- Groups the results by company, model, and body style, and orders them by company, model, body style, and total income in descending order.

SELECT Transmission, COUNT(*) AS Number_of_Sales
FROM car_data
GROUP BY Transmission;

-- 51
-- Calculates the count of sales per transmission type in the car_data table,
-- grouping the results by transmission type.

SELECT Transmission, AVG(`Price ($)`) AS avg_price
FROM car_data
GROUP BY Transmission;

-- 52
-- Calculates the average price per transmission type in the car_data table,
-- grouping the results by transmission type.

SELECT Transmission, SUM(`Price ($)`) AS Total_sales
FROM car_data
GROUP BY Transmission;

-- 53
-- Calculates the total sales amount per transmission type in the car_data table,
-- grouping the results by transmission type.

SELECT Color, COUNT(*) AS Number_of_Sales
FROM car_data
GROUP BY Color
ORDER BY Number_of_Sales DESC;

-- 54
-- Calculates the count of sales per car color in the car_data table,
-- grouping the results by color and ordering them by number of sales in descending order.

SELECT SUM(`Price ($)`) AS Total_Value
FROM car_data;

-- 55
-- Calculates the total value of all car sales

SELECT AVG(`Price ($)`) AS avg_price
FROM car_data;

-- 56
-- Calculates the average price of car sales.

SELECT CASE 
WHEN `Price ($)` > (SELECT AVG(`Price ($)`) AS avg_price FROM car_data) THEN 'Above_Avarage'
WHEN `Price ($)` <= (SELECT AVG(`Price ($)`) AS avg_price FROM car_data) THEN 'Below_Avarage' END AS Price,
COUNT(*) AS Number_of_Sales
FROM car_data
GROUP BY Price
ORDER BY Number_of_Sales DESC;

-- 57
-- Classifies car sales into 'Above_Average' and 'Below_Average' categories
-- based on whether the price is above or below the average price of all car sales in the car_data table.
-- Counts the number of sales in each category and orders the results by number of sales in descending order.

SELECT CASE 
WHEN `Price ($)` > (SELECT AVG(`Price ($)`) AS avg_price FROM car_data) THEN 'Above_Avarage'
WHEN `Price ($)` <= (SELECT AVG(`Price ($)`) AS avg_price FROM car_data) THEN 'Below_Avarage' END AS Price,
SUM(`Price ($)`) AS Total_Value
FROM car_data
GROUP BY Price
ORDER BY Total_Value DESC;

-- 58
-- Classifies car sales into 'Above_Average' and 'Below_Average' categories
-- based on whether the price is above or below the average price of all car sales in the car_data table.
-- Calculates the total sales value in each category and orders the results by total value in descending order.

SELECT `Body Style`, SUM(`Price ($)`) AS Amount_of_Income
FROM car_data
GROUP BY `Body Style`
ORDER BY Amount_of_Income DESC;

-- 59
-- Calculates the total income generated per car body style in the car_data table,
-- grouping the results by body style and ordering them by total income in descending order.

SELECT `Body Style`, ROUND(AVG(`Price ($)`), 2) AS avg_price
FROM car_data
GROUP BY `Body Style`
ORDER BY avg_price DESC;

-- 60
-- Calculates the average price per car body style in the car_data table,
-- rounding the results to two decimal places, grouping by body style, and ordering them by average price in descending order.

SELECT Dealer_Region, SUM(`Price ($)`) AS Amount_of_Income
FROM car_data
GROUP BY Dealer_Region
ORDER BY Amount_of_Income DESC;

-- 61
-- Calculates the total income generated per dealer region in the car_data table,
-- grouping the results by dealer region and ordering them by total income in descending order.

SELECT Dealer_Region, ROUND(AVG(`Price ($)`), 2) AS avg_price
FROM car_data
GROUP BY Dealer_Region
ORDER BY avg_price DESC;

-- 62
-- Calculates the average price per dealer region in the car_data table,
-- rounding the results to two decimal places, grouping by dealer region, and ordering them by average price in descending order.

SELECT Dealer_Region, Dealer_Name, SUM(`Price ($)`) AS Amount_of_Income
FROM car_data
GROUP BY Dealer_Region, Dealer_Name
ORDER BY Dealer_Region, Amount_of_Income DESC;

-- 63
-- Calculates the total income generated per dealer region and dealer name in the car_data table,
-- grouping the results by dealer region and dealer name, and ordering them by dealer region and total income in descending order.

SELECT Dealer_Region, Dealer_Name, ROUND((Amount_of_Income / SUM(Amount_of_Income) OVER(PARTITION BY Dealer_Region) * 100), 2) AS pct_of_sales
FROM (SELECT Dealer_Region, Dealer_Name, SUM(`Price ($)`) AS Amount_of_Income
FROM car_data
GROUP BY Dealer_Region, Dealer_Name) AS subquery
ORDER BY Dealer_Region, pct_of_sales DESC;

-- 64
-- Calculates the percentage of total sales income (%) per dealer name within each dealer region in the car_data table,
-- rounding the results to two decimal places, based on the total income partitioned by dealer region.
-- Orders the results by dealer region and percentage of sales in descending order.

SELECT `Month`, AVG(`Price ($)`) AS avg_price
FROM car_data
GROUP BY `Month`
ORDER BY avg_price;

-- 65
-- Calculates the average price of car sales per month in the car_data table,
-- grouping the results by month and ordering them by average price in ascending order.

SELECT `Month`, SUM(`Price ($)`) AS Amount_of_Income
FROM car_data
GROUP BY `Month`
ORDER BY Amount_of_Income DESC;

-- 66
-- Calculates the total income generated per month from car sales in the car_data table,
-- grouping the results by month and ordering them by total income in descending order.

SELECT `Month`, COUNT(*) AS Number_of_Sales
FROM car_data
GROUP BY `Month`
ORDER BY Number_of_Sales DESC;

-- 67
-- Calculates the count of car sales per month in the car_data table,
-- grouping the results by month and ordering them by number of sales in descending order.

-- RESULT --

-- 9: 'Dodge', 'Ford' and 'Chevrolet' brand cars are the most popular types of cars among men and women.
-- 'Saab', 'Infiniti' and 'Jaguar' brand cars are the least popular types of cars among men and women.
-- 10, 11: 'Ram pickup', 'Durango' and 'Viper' models of 'Dodge' brand cars are the most sold models among men and women.
-- 'Explorer', 'Expedition' and 'Mustang' models of 'Ford' brand cars are the most sold models among men.
-- 'Prizm', 'Metro' and 'Corvette' models of 'Chevrolet' brand cars are the most sold models among men.
-- 'Taurus', 'Expedition' and 'Crown Victoria' models of 'Ford' brand cars are the most sold models among women.
-- 'Prizm', 'Metro' and 'Malibu' models of 'Chevrolet' brand cars are the most sold models among women.
-- 12: Women mostly buy cars from 'Rabun Used Car Sales', 'Ryder Truck Rental and Leasing' and 'Progressive Shippers Cooperative Association No' dealers.
-- Men mostly buy cars from 'Rabun Used Car Sales', 'Star Enterprises Inc' and 'Progressive Shippers Cooperative Association No' dealers.
-- 14: Pale white cars are popular among both men and women.
-- 15: Both women and men prefer cars with 'SUV' and 'Hatchback' bodies.
-- 16: Customers prefer buy cars from 'Austin', 'Janesville', 'Scottsdale' regions.
-- 17: Customers mostly buy cars in December, November and September.
-- 19: Customers with the highest annual income rating (10) prefer to buy a car from the 'Race Car Help' dealer, and the lowest (1) from the 'Tri-State Mack Inc' seller.
-- 20: 'Dodge' brand cars are among the top 3 choices of customers at all levels of annual income.
-- 21: Customers with the highest annual income rating (10) mostly buy 'Volkswagen Passat', 'Mitsubishi Diamante' and 'Oldsmobile Silhouette' model cars.
-- 22: There is not much correlation between annual income and car's price.
-- 24, 25: 'Progressive Shippers Cooperative Association No', 'Rabun Used Car Sales' and 'Race Car Help' are the dealers who make the most sales.
-- These 3 dealers make 16.25 percent of sales.
-- 26, 27: 'Chevrolet', 'Ford' and 'Dodge' brand cars make up 21.45 percent of the sales volume of 'Progressive Shippers Cooperative Association No' dealer.
-- 28: 'Progressive Shippers Cooperative Association No' sold mostly 'Volkswagen Passat', 'Chevrolet Prizm' and 'Oldsmobile Silhouette' model cars.
-- 29: Most of the cars sold by 'Rabun Used Car Sales' have 'dual overhead camshaft' engines
-- 30: Most of the cars sold by 'Race Car Help' have auto transmissions.
-- 31: All dealers sold the most white cars then black cars and the least red cars.
-- 32: 'Rabun Used Car Sales', 'Progressive Shippers Cooperative Association No' and 'U-Haul CO' are the dealers who earn the most revenue.
-- "Buddy Storbeck's Diesel Service Inc", 'Pitre Buick-Pontiac-Gmc of Scottsdale' and 'Chrysler Plymouth' are the dealers who earn the least revenue.
-- 33: 'U-Haul CO' earns least from 'Jaguar', 'Hyundai', 'Saab' brand cars.
-- 34: 'Chrysler Plymouth' earns mostly from 'Lexus LS400', 'Volkswagen Jetta' and 'Chevrolet Prizm' model cars.
-- 35: 'Pitre Buick-Pontiac-Gmc of Scottsdale' had the lowest sales in February, January and March.
-- 36: "Buddy Storbeck's Diesel Service Inc" received the most revenue from the sale of SUV cars, and the least revenue from the sale of Hardtop cars.
-- 42: In general, $139011844 was obtained from the sale of 'Chevrolet', 'Ford' and 'Dodge' brand cars.
-- 43: 'Mitsubishi Diamante', 'Chevrolet Prizm' and 'Oldsmobile Silhouette' model cars are the most sold cars.
-- 'Chrysler Sebring Convertible', 'Toyota Avalon' and 'Lexus RX300' model cars are the least sold cars.
-- 44: 'Cadillac Catera', 'Cadillac DeVille' and 'Ford Contour' had the highest average price.
-- 'Ford Escort', 'Chrysler Cirrus' and 'Mitsubishi Mirage' had the lowest average price.
-- 45: The most expensive cars sold were 'Cadillac Eldorado', 'Toyota RAV4' and 'Audi A6'.
-- 46: The cheapest cars sold were 'Ford Taurus', 'Mercedes-B S-Class' and 'Lincoln Town car'.
-- 47: The most revenue comes from 'Lexus LS400', 'Volkswagen Jetta' and 'Chevrolet Prizm' model cars.
-- The least revenue comes from 'Chrysler Sebring Convertible', 'Mitsubishi Mirage' and 'Toyota Avalon' model cars.
-- 49, 50: Hardtop version of 'Audi A4' has sold more and generated revenue than other versions of 'Audi A4'.
-- 52: In average, cars with automatic transmission are more expensive than manual ones.
-- 53: And automatic cars brought more income than manual.
-- 55: Total value of all car sales are $671525465.
-- 56, 57: The average price of the cars was $28000, 8125 cars were sold above this price, and 15781 cars were sold below it.
-- 59: 'SUV' and 'Hatchback' cars generated the most revenue.
-- 60: Also SUV and Hatchback cars were the cheapest cars according to the average price. 'Sedan' and 'Hardtop' were the most expensive cars
-- 61: The regions with the highest income were 'Austin', 'Janesville' and 'Scottsdale'
-- The regions with the lowest income were 'Middletown', 'Pasco' and 'Greenville'
-- 62: The regions with the highest average price were 'Austin', 'Aurora' and 'Greenville'
-- The regions with the lowest average price were 'Janesville', 'Middletown' and 'Scottsdale'
-- 63, 64: The top earners in the Aurora region were 'Saab-Belle Dodge', 'Enterprise Rent A Car' and 'New Castle Ford Lincoln Mercury'
-- These dealers make up 64.36 percent of the region's sales
-- 65: March, January, July had the lowest average price
-- 66, 67: December, November, September had the highest sale numbers and revenue