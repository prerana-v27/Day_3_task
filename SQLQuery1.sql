-- SQL QUERIES
SELECT Customer_Name, City, Sales, Profit
FROM [Sample - Superstore]
WHERE Region = 'West'
ORDER BY Profit DESC;

-- group by
SELECT Category, SUM(Sales) AS Total_Sales, AVG(Profit) AS Average_Profit
FROM [Sample - Superstore]
GROUP BY Category;

--join
CREATE TABLE Region_Info (
    Region VARCHAR(50),
    Manager VARCHAR(50)
);

INSERT INTO Region_Info VALUES
('West', 'Alice'),
('East', 'Bob'),
('South', 'Carol'),
('Central', 'Dave');

-- JOIN
SELECT S.Region, R.Manager, SUM(S.Sales) AS Region_Sales
FROM [Sample - Superstore] S
JOIN Region_Info R ON S.Region = R.Region
GROUP BY S.Region, R.Manager;

-- Avg
SELECT * FROM [Sample - Superstore]
WHERE Sales > (SELECT AVG(Sales) FROM [Sample - Superstore]);

--Count
SELECT COUNT(*) AS Count_Above_Avg
FROM [Sample - Superstore]
WHERE Sales > (SELECT AVG(Sales) FROM [Sample - Superstore]);

--indexing
CREATE INDEX idx_orderid 
ON [Sample - Superstore](Order_ID);

SELECT *
FROM [Sample - Superstore]
ORDER BY Order_ID;

CREATE INDEX idx_orderdate
ON [Sample - Superstore](Order_Date);

SELECT 
    Order_Date,
    COUNT(Order_ID) AS Number_of_Orders
FROM [Sample - Superstore]
GROUP BY Order_Date
ORDER BY Order_Date DESC;

SELECT *
FROM [Sample - Superstore]
WHERE Order_Date >= '2014-01-01' AND Order_Date <= '2017-01-31';

-- View the structure
SELECT TOP 10 * FROM [Sample - Superstore];

-- Check NULLs in each column
SELECT 
    SUM(CASE WHEN Row_ID IS NULL THEN 1 ELSE 0 END) AS Row_ID_Nulls,
    SUM(CASE WHEN Order_ID IS NULL THEN 1 ELSE 0 END) AS Order_ID_Nulls,
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS Order_Date_Nulls,
    SUM(CASE WHEN Ship_Date IS NULL THEN 1 ELSE 0 END) AS Ship_Date_Nulls,
    SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS Sales_Nulls,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS Quantity_Nulls,
    SUM(CASE WHEN Profit IS NULL THEN 1 ELSE 0 END) AS Profit_Nulls
FROM [Sample - Superstore];

-- Remove rows with NULLs in critical columns
DELETE FROM [Sample - Superstore]
WHERE Order_ID IS NULL 
   OR Order_Date IS NULL 
   OR Sales IS NULL;

-- Check for duplicate Order_ID + Product_ID combinations
SELECT 
    Order_ID, Product_ID, COUNT(*) AS Count
FROM [Sample - Superstore]
GROUP BY Order_ID, Product_ID
HAVING COUNT(*) > 1;

-- Remove duplicate rows while keeping the one with the lowest Row_ID
WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Order_ID, Product_ID ORDER BY Row_ID) AS rn
    FROM [Sample - Superstore]
)
DELETE FROM CTE WHERE rn > 1;

--check datatypes
EXEC sp_help '[Sample - Superstore]';

--date format
SELECT TOP 10 Order_Date
FROM [Sample - Superstore];

SELECT 
    FORMAT(Order_Date, 'dd-MM-yyyy') AS Formatted_Order_Date,
    FORMAT(Ship_Date, 'dd-MM-yyyy') AS Formatted_Ship_Date
FROM [Sample - Superstore]
ORDER BY Order_Date;

DELETE FROM [Sample - Superstore]
WHERE Ship_Date < Order_Date;

UPDATE [Sample - Superstore]
SET Customer_Name = LTRIM(RTRIM(Customer_Name)),
    City = LTRIM(RTRIM(City)),
    State = LTRIM(RTRIM(State)),
    Product_Name = LTRIM(RTRIM(Product_Name));

-- top 5 highest sales
SELECT TOP 5 * FROM [Sample - Superstore]
ORDER BY Sales DESC;

-- Negative profit entries
SELECT TOP 5 * FROM [Sample - Superstore]
WHERE Profit < 0;

SELECT COUNT(*) AS NegativeProfitCount
FROM [Sample - Superstore]
WHERE Profit < 0;

-- create cleaned datset
SELECT * INTO Superstore_Clean FROM [Sample - Superstore];

SELECT 
    FORMAT(Order_Date, 'yyyy-MM') AS Order_Month,
    COUNT(Order_ID) AS Number_of_Orders,
    SUM(Sales) AS Total_Sales
FROM [Sample - Superstore]
GROUP BY FORMAT(Order_Date, 'yyyy-MM')
ORDER BY Order_Month DESC;

-- top 3 year
SELECT 
    YEAR(Order_Date) AS Order_Year,
    SUM(Sales) AS Total_Sales
FROM [Sample - Superstore]
GROUP BY YEAR(Order_Date)
ORDER BY Total_Sales DESC
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;

-- top 3 month
SELECT 
    FORMAT(Order_Date, 'yyyy-MM') AS Order_Month,
    SUM(Sales) AS Total_Sales
FROM [Sample - Superstore]
GROUP BY FORMAT(Order_Date, 'yyyy-MM')
ORDER BY Total_Sales DESC
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;

-- WEEKEND/WEEKDAY
SELECT TOP 10
    Order_Date,
    DATENAME(WEEKDAY, Order_Date) AS Day_Name,
    CASE 
        WHEN DATENAME(WEEKDAY, Order_Date) IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type,
    SUM(Sales) AS Total_Sales
FROM [Sample - Superstore]
GROUP BY Order_Date
ORDER BY Total_Sales DESC;

SELECT TOP 1
    Order_Date,
    DATENAME(WEEKDAY, Order_Date) AS Day_Name,
    SUM(Sales) AS Total_Sales
FROM [Sample - Superstore]
GROUP BY Order_Date
ORDER BY Total_Sales DESC;

SELECT TOP 1
    Order_Date,
    DATENAME(WEEKDAY, Order_Date) AS Day_Name,
    SUM(Sales) AS Total_Sales
FROM [Sample - Superstore]
GROUP BY Order_Date
ORDER BY Total_Sales ASC;


-- KPI's
--sales profit by category
SELECT 
    Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM [Sample - Superstore]
GROUP BY Category
ORDER BY Total_Sales DESC;

--sale, profit,quantity,discount
SELECT 
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity,
    ROUND(AVG(Discount), 2) AS Avg_Discount
FROM [Sample - Superstore];

--sales profit by sub-category
SELECT 
    Sub_Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM [Sample - Superstore]
GROUP BY Sub_Category
ORDER BY Total_Sales DESC;

--  Monthly Sales Trend
SELECT 
    FORMAT(Order_Date, 'yyyy-MM') AS Month,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM [Sample - Superstore]
GROUP BY FORMAT(Order_Date, 'yyyy-MM')
ORDER BY Month;

--Sales by Region and State
SELECT 
    Region,
    State,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM [Sample - Superstore]
GROUP BY Region, State
ORDER BY Region, Total_Sales DESC;

-- Top 10 Customers by Sales
SELECT TOP 10 
    Customer_Name,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM [Sample - Superstore]
GROUP BY Customer_Name
ORDER BY Total_Sales DESC;

--Most Sold Products
SELECT TOP 10 
    Product_Name,
    SUM(Quantity) AS Total_Quantity,
    SUM(Sales) AS Total_Sales
FROM [Sample - Superstore]
GROUP BY Product_Name
ORDER BY Total_Quantity DESC;

-- Profitability by Segment
SELECT 
    Segment,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND(SUM(Profit)/SUM(Sales)*100, 2) AS Profit_Margin_Percentage
FROM [Sample - Superstore]
GROUP BY Segment;

-- Loss-making Orders (Negative Profit)
SELECT 
    Order_ID,
    Customer_Name,
    Sales,
    Profit
FROM [Sample - Superstore]
WHERE Profit < 0
ORDER BY Profit ASC;

--Create View for High-Profit Orders
CREATE VIEW High_Profit_Orders AS
SELECT 
    Order_ID,
    Customer_Name,
    Sales,
    Profit
FROM [Sample - Superstore]
WHERE Profit > 100;

--Performance by Ship Mode
SELECT 
    Ship_Mode,
    COUNT(*) AS Num_Orders,
    SUM(Sales) AS Total_Sales,
    ROUND(AVG(Profit), 2) AS Avg_Profit
FROM [Sample - Superstore]
GROUP BY Ship_Mode
ORDER BY Total_Sales DESC;

--Top Performing Cities (Sales > 50K)
SELECT 
    City,
    State,
    SUM(Sales) AS Total_Sales
FROM [Sample - Superstore]
GROUP BY City, State
HAVING SUM(Sales) > 50000
ORDER BY Total_Sales DESC;

--Count of Orders by Weekday vs Weekend
SELECT 
    CASE 
        WHEN DATENAME(WEEKDAY, Order_Date) IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type,
    COUNT(Order_ID) AS Number_of_Orders
FROM [Sample - Superstore]
GROUP BY 
    CASE 
        WHEN DATENAME(WEEKDAY, Order_Date) IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END
ORDER BY Number_of_Orders DESC;

-- Graphs
--Sales & Profit by Category
SELECT Category, SUM(Sales) AS Total_Sales, SUM(Profit) AS Total_Profit
FROM [Sample - Superstore]
GROUP BY Category;

-- Sales Trend Over Time
SELECT 
    FORMAT(Order_Date, 'yyyy-MM') AS Order_Month, 
    SUM(Sales) AS Monthly_Sales
FROM [Sample - Superstore]
GROUP BY FORMAT(Order_Date, 'yyyy-MM')
ORDER BY Order_Month;

--Profit by Region or State
SELECT Region, SUM(Profit) AS Total_Profit
FROM [Sample - Superstore]
GROUP BY Region;

--Discount vs Profit
SELECT Discount, Profit
FROM [Sample - Superstore];

--Top 10 Products by Sales
SELECT TOP 10 Product_Name, SUM(Sales) AS Total_Sales
FROM [Sample - Superstore]
GROUP BY Product_Name
ORDER BY Total_Sales DESC;

--Order Count by Ship Mode
SELECT Ship_Mode, COUNT(*) AS Order_Count
FROM [Sample - Superstore]
GROUP BY Ship_Mode;

--Segment-wise Sales Contribution
SELECT Segment, SUM(Sales) AS Segment_Sales
FROM [Sample - Superstore]
GROUP BY Segment;

































