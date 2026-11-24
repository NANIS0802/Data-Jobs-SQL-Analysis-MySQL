# 🗄️ Data Jobs Market, Salary & Skill Demand Analysis (MySQL)

## 📌 Project Overview
This project explores **12,589 data-related job postings** stored in a relational MySQL database (`job_market_db.job_postings`) to uncover insights into salary benchmarks, remote work distribution, hiring platforms, posting schedules, and core technical skill requirements (SQL & Python).

Designed as part of my **Data Analyst Portfolio**, this repository demonstrates end-to-end SQL data cleaning, type conversion, modular querying with CTEs, and analytical ranking using Window Functions.

---

## 🛠️ Tools & SQL Techniques Used
* **Database & Environment:** MySQL 8.0, DBeaver, Visual Studio Code
* **Data Cleaning & Transformation:** `TRIM()`, `LOWER()`, `REPLACE()`, `CAST(... AS DECIMAL)`, `COALESCE()`, `STR_TO_DATE()`, `DATE_FORMAT()`
* **Aggregation & Conditional Logic:** `GROUP BY`, `HAVING`, `COUNT()`, `AVG()`, `MIN()`, `MAX()`, `ROUND()`, `CASE WHEN`
* **Advanced Querying:** Common Table Expressions (`WITH` / CTEs) and Window Functions (`SUM() OVER ()`, `DENSE_RANK() OVER (PARTITION BY ... ORDER BY ...)`)

---

## 📂 Repository Structure
```text
Data-Jobs-SQL-Analysis-MySQL/
├── sql/
│   └── job_market_analysis.sql      # Complete MySQL script with 7 analytical queries
├── data/
│   └── job_postings.csv             # Raw dataset (12,589 records) - optional if <25MB
├── assets/
│   └── skill_demand_results.png     # Query output screenshots from VS Code / DBeaver
└── README.md
