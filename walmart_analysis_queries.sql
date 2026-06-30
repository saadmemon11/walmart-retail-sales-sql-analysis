CREATE DATABASE walmart_sales_analysis;
USE walmart_sales_analysis;

CREATE TABLE stores (
store_id INT PRIMARY KEY,
store_type CHAR(1),
store_size INT,
region VARCHAR(20)
);
CREATE TABLE departments (
dept_id INT PRIMARY KEY,
dept_name VARCHAR(50)
);
CREATE TABLE sales (
row_id INT PRIMARY KEY,
store_id INT,
store_type CHAR(1),
store_size INT,
region VARCHAR(20),
dept_id INT,
dept_name VARCHAR(50),
week_date DATE,
weekly_sales DECIMAL(12,2),
is_holiday TINYINT,
temperature DECIMAL(5,1),
fuel_price DECIMAL(5,3),
cpi DECIMAL(7,3),
unemployment DECIMAL(5,3),
FOREIGN KEY (store_id) REFERENCES stores(store_id),
FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

SELECT COUNT(*) FROM sales;

SELECT * FROM sales LIMIT 10;


-- Query 1 — Total sales overview

SELECT 
    COUNT(*) AS total_records,
    COUNT(DISTINCT store_id) AS total_stores,
    COUNT(DISTINCT dept_id) AS total_departments,
    ROUND(SUM(weekly_sales), 2) AS total_sales,
    ROUND(AVG(weekly_sales), 2) AS avg_weekly_sales
FROM sales;


-- Query 2 — Top 5 stores by total sales

SELECT 
    s.store_id,
    s.store_type,
    s.region,
    ROUND(SUM(sa.weekly_sales), 2) AS total_sales
FROM sales sa
JOIN stores s ON sa.store_id = s.store_id
GROUP BY s.store_id, s.store_type, s.region
ORDER BY total_sales DESC
LIMIT 5;


-- Query 3 — Sales by region

SELECT 
    region,
    ROUND(SUM(weekly_sales), 2) AS total_sales,
    ROUND(AVG(weekly_sales), 2) AS avg_sales,
    COUNT(DISTINCT store_id) AS num_stores
FROM sales
GROUP BY region
ORDER BY total_sales DESC;


-- Query 4 — Top 10 departments by revenue

SELECT 
    dept_name,
    ROUND(SUM(weekly_sales), 2) AS total_sales,
    ROUND(AVG(weekly_sales), 2) AS avg_weekly_sales
FROM sales
GROUP BY dept_name
ORDER BY total_sales DESC
LIMIT 10;


-- Query 5 — Monthly sales trend

SELECT 
    DATE_FORMAT(week_date, '%Y-%m') AS sales_month,
    ROUND(SUM(weekly_sales), 2) AS monthly_sales
FROM sales
GROUP BY DATE_FORMAT(week_date, '%Y-%m')
ORDER BY sales_month;


-- Query 6 — Holiday vs Non-Holiday sales comparison

SELECT 
    CASE WHEN is_holiday = 1 THEN 'Holiday Week' ELSE 'Regular Week' END AS week_type,
    ROUND(AVG(weekly_sales), 2) AS avg_sales,
    COUNT(*) AS num_records
FROM sales
GROUP BY is_holiday;


-- Query 7 — Store type performance comparison

SELECT 
    store_type,
    COUNT(DISTINCT store_id) AS num_stores,
    ROUND(SUM(weekly_sales), 2) AS total_sales,
    ROUND(AVG(weekly_sales), 2) AS avg_sales_per_record
FROM sales
GROUP BY store_type
ORDER BY total_sales DESC;


-- Query 8 — Top performing department in each store (Window Function)

SELECT *
FROM (
    SELECT 
        store_id,
        dept_name,
        ROUND(SUM(weekly_sales), 2) AS dept_total_sales,
        RANK() OVER (PARTITION BY store_id ORDER BY SUM(weekly_sales) DESC) AS dept_rank
    FROM sales
    GROUP BY store_id, dept_name
) ranked
WHERE dept_rank = 1
ORDER BY store_id;


-- Query 9 — Month over month growth rate

SELECT 
    sales_month,
    monthly_sales,
    LAG(monthly_sales) OVER (ORDER BY sales_month) AS prev_month_sales,
    ROUND(
        (monthly_sales - LAG(monthly_sales) OVER (ORDER BY sales_month)) 
        / LAG(monthly_sales) OVER (ORDER BY sales_month) * 100, 2
    ) AS mom_growth_pct
FROM (
    SELECT 
        DATE_FORMAT(week_date, '%Y-%m') AS sales_month,
        ROUND(SUM(weekly_sales), 2) AS monthly_sales
    FROM sales
    GROUP BY DATE_FORMAT(week_date, '%Y-%m')
) monthly_data
ORDER BY sales_month;


-- Query 10 — Running cumulative total (YTD running sum)

SELECT 
    sales_month,
    monthly_sales,
    SUM(monthly_sales) OVER (ORDER BY sales_month) AS cumulative_ytd_sales
FROM (
    SELECT 
        DATE_FORMAT(week_date, '%Y-%m') AS sales_month,
        ROUND(SUM(weekly_sales), 2) AS monthly_sales
    FROM sales
    GROUP BY DATE_FORMAT(week_date, '%Y-%m')
) monthly_data
ORDER BY sales_month;


-- Query 11 — Store ranking with dense rank

SELECT 
    store_id,
    region,
    store_type,
    total_sales,
    DENSE_RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM (
    SELECT 
        s.store_id,
        s.region,
        s.store_type,
        ROUND(SUM(sa.weekly_sales), 2) AS total_sales
    FROM sales sa
    JOIN stores s ON sa.store_id = s.store_id
    GROUP BY s.store_id, s.region, s.store_type
) store_totals;


-- Query 12 — Sales correlation with fuel price (Economic Impact Analysis)

SELECT 
    CASE 
        WHEN fuel_price < 3.0 THEN 'Low Fuel Price (Under $3.0)'
        WHEN fuel_price BETWEEN 3.0 AND 3.5 THEN 'Medium Fuel Price ($3.0-$3.5)'
        ELSE 'High Fuel Price (Above $3.5)'
    END AS fuel_price_band,
    ROUND(AVG(weekly_sales), 2) AS avg_weekly_sales,
    COUNT(*) AS num_records
FROM sales
GROUP BY fuel_price_band
ORDER BY avg_weekly_sales DESC;


-- Query 13 — Unemployment rate impact on sales

SELECT 
    CASE 
        WHEN unemployment < 7.0 THEN 'Low Unemployment'
        WHEN unemployment BETWEEN 7.0 AND 8.5 THEN 'Medium Unemployment'
        ELSE 'High Unemployment'
    END AS unemployment_band,
    ROUND(AVG(weekly_sales), 2) AS avg_weekly_sales
FROM sales
GROUP BY unemployment_band
ORDER BY avg_weekly_sales DESC;


-- Query 14 — Top 3 departments per store using window function

SELECT store_id, dept_name, dept_total_sales, dept_rank
FROM (
    SELECT 
        store_id,
        dept_name,
        ROUND(SUM(weekly_sales), 2) AS dept_total_sales,
        ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY SUM(weekly_sales) DESC) AS dept_rank
    FROM sales
    GROUP BY store_id, dept_name
) ranked
WHERE dept_rank <= 3
ORDER BY store_id, dept_rank;


-- Query 15 — Store size vs sales efficiency

SELECT 
    s.store_id,
    s.store_size,
    ROUND(SUM(sa.weekly_sales), 2) AS total_sales,
    ROUND(SUM(sa.weekly_sales) / s.store_size, 2) AS sales_per_sqft
FROM sales sa
JOIN stores s ON sa.store_id = s.store_id
GROUP BY s.store_id, s.store_size
ORDER BY sales_per_sqft DESC;


-- Query 16 — CTE example — Best and worst performing weeks

WITH weekly_totals AS (
    SELECT 
        week_date,
        ROUND(SUM(weekly_sales), 2) AS total_week_sales
    FROM sales
    GROUP BY week_date
)
SELECT * FROM weekly_totals
ORDER BY total_week_sales DESC
LIMIT 5;


-- views 1

CREATE VIEW store_performance_summary AS
SELECT 
    s.store_id,
    s.store_type,
    s.region,
    s.store_size,
    ROUND(SUM(sa.weekly_sales), 2) AS total_sales,
    ROUND(AVG(sa.weekly_sales), 2) AS avg_weekly_sales,
    ROUND(SUM(sa.weekly_sales) / s.store_size, 2) AS sales_per_sqft
FROM sales sa
JOIN stores s ON sa.store_id = s.store_id
GROUP BY s.store_id, s.store_type, s.region, s.store_size;

-- Views 2

CREATE VIEW monthly_sales_trend AS
SELECT 
    DATE_FORMAT(week_date, '%Y-%m') AS sales_month,
    ROUND(SUM(weekly_sales), 2) AS monthly_sales,
    SUM(CASE WHEN is_holiday = 1 THEN weekly_sales ELSE 0 END) AS holiday_sales
FROM sales
GROUP BY DATE_FORMAT(week_date, '%Y-%m');


SELECT * FROM store_performance_summary ORDER BY total_sales DESC;
SELECT * FROM monthly_sales_trend ORDER BY sales_month;


