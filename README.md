# 🛒 Walmart Retail Sales Analysis
### MySQL | Retail Analytics | Store Performance | Economic Indicators | FY 2023

---

## 📌 Project Overview

This project simulates a **retail point-of-sale (POS) analysis** of the type that retail analytics firms perform for large-format retailers like Walmart — covering store performance, department-level revenue, seasonal trends, and the relationship between macroeconomic indicators (fuel price, unemployment) and consumer spending.

The database is designed with a proper relational schema — a central sales fact table connected to store and department dimension tables — and analyzed using 16 SQL queries ranging from basic aggregation to advanced window functions and CTEs.

---

## 🎯 Business Context

> A retail analyst studying Walmart's performance would ask:
> - Which stores and regions generate the most revenue?
> - Which departments are top performers in each store?
> - How does revenue change month over month, and what's the cumulative YTD trend?
> - Do holiday weeks meaningfully outperform regular weeks?
> - Does fuel price or unemployment correlate with consumer spending?
> - Which stores use their floor space most efficiently (sales per square foot)?

This is the type of analysis that retail data teams run regularly to support merchandising, inventory, and regional strategy decisions.

---

## 🗄️ Database Schema

Three related tables forming a simple star schema:

```
stores (dimension)          departments (dimension)
├── store_id (PK)            ├── dept_id (PK)
├── store_type                └── dept_name
├── store_size
└── region

sales (fact table)
├── row_id (PK)
├── store_id (FK → stores)
├── dept_id (FK → departments)
├── week_date
├── weekly_sales
├── is_holiday
├── temperature
├── fuel_price
├── cpi
└── unemployment
```

**Total records:** 12,480 rows across 10 stores, 24 departments, 52 weeks (FY 2023)

> Note: Dataset is synthetically generated to mirror the structure of Walmart's publicly known retail sales data (store type/size, weekly sales, holiday indicators, and macroeconomic indicators like fuel price, CPI, and unemployment).

---

## 🔢 SQL Skills Demonstrated

| Category | Techniques Used |
|---|---|
| Schema Design | Primary keys, foreign keys, relational integrity across 3 tables |
| Joins | INNER JOIN across fact and dimension tables |
| Aggregation | SUM, AVG, COUNT, GROUP BY, HAVING |
| Window Functions | RANK(), DENSE_RANK(), ROW_NUMBER(), LAG(), running SUM() OVER() |
| CTEs | WITH clause for readable multi-step queries |
| Conditional Logic | CASE WHEN for banding and categorization |
| Date Functions | DATE_FORMAT() for monthly trend analysis |
| Views | Reusable saved queries for store performance and monthly trends |
| Business Metrics | Sales per square foot, MoM growth %, YTD cumulative sales |

---

## 📊 Key Queries

```sql
-- Month-over-month growth using window function LAG
SELECT 
    sales_month,
    monthly_sales,
    ROUND(
        (monthly_sales - LAG(monthly_sales) OVER (ORDER BY sales_month)) 
        / LAG(monthly_sales) OVER (ORDER BY sales_month) * 100, 2
    ) AS mom_growth_pct
FROM monthly_data;

-- Top performing department per store using RANK
SELECT store_id, dept_name, dept_total_sales, dept_rank
FROM (
    SELECT store_id, dept_name,
        SUM(weekly_sales) AS dept_total_sales,
        RANK() OVER (PARTITION BY store_id ORDER BY SUM(weekly_sales) DESC) AS dept_rank
    FROM sales
    GROUP BY store_id, dept_name
) ranked
WHERE dept_rank = 1;

-- Sales efficiency per square foot
SELECT 
    s.store_id, s.store_size,
    ROUND(SUM(sa.weekly_sales) / s.store_size, 2) AS sales_per_sqft
FROM sales sa
JOIN stores s ON sa.store_id = s.store_id
GROUP BY s.store_id, s.store_size
ORDER BY sales_per_sqft DESC;
```

Full set of 16 queries with comments available in `walmart_analysis_queries.sql`

---

## 📈 Key Findings

- **Store Type A locations generate the highest average weekly sales**, despite Type B and C stores being more numerous — confirming format size drives revenue efficiency
- **Holiday weeks show a meaningful sales lift** compared to regular weeks, with November and December producing the two highest monthly totals of the year
- **Grocery, Electronics, and Dairy are consistently the top 3 departments** across most stores, indicating stable category leadership regardless of region
- **Sales per square foot varies significantly between same-sized stores**, revealing that floor space efficiency is not purely a function of store size
- **Fuel price band analysis shows a mild inverse relationship** with average weekly sales, consistent with discretionary spending pressure during high fuel cost periods
- **December posted the highest cumulative YTD sales jump** of any month, driven by holiday season demand

---

## 🛠️ Tools & Technologies

- **MySQL 8.0 / MySQL Workbench** — Database design, query development, EER diagramming
- **SQL** — DDL (table creation), DML (queries), Views, Window Functions, CTEs
- **Python** — Synthetic dataset generation (NumPy, CSV)

---

## 📁 Files in This Repository

```
├── walmart_analysis_queries.sql      # All table creation + 16 queries + views
├── walmart_sales_data.csv            # Main fact table (12,480 rows)
├── walmart_stores.csv                # Store dimension table
├── walmart_departments.csv           # Department dimension table
├── Screenshots/
│   ├── ER_Diagram.png
│   └── Views_Output.png
└── README.md
```

---

## 🚀 How to Use

1. Open MySQL Workbench and connect to your local server
2. Run the `CREATE DATABASE` and `CREATE TABLE` statements from `walmart_analysis_queries.sql`
3. Import the 3 CSV files into their matching tables using Table Data Import Wizard
4. Run any of the 16 queries or the 2 views to reproduce the analysis

---

## 👤 About

Built by **Saad** — CS Engineering Student at Parul University transitioning into Data Analytics.

This project is part of a **targeted FMCG and retail analytics portfolio** covering Power BI, Excel, MySQL, and Python — simulating real-world data work in the consumer goods and retail analytics space.

🔗 [LinkedIn](https://linkedin.com/in/saad-memon-49aa75350) | 📧 saadmemon1104@gmail.com | 🐙 [GitHub](https://github.com/saadmemon11)
