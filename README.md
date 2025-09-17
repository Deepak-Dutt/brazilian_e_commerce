Brazilian E-Commerce Dataset


Cleaned and validated e-commerce dataset ready for analysis and KPI calculation.

This repository contains a dataset from a Brazilian online shopping platform. It includes information about customers, orders, products, payments, and sellers. The dataset is used to study shopping patterns, clean and prepare data, and make simple business predictions.


Dataset Overview:
1. The dataset has information about:
2. Customers: IDs and locations
3. Orders & Items: Orders, products, prices, and delivery dates
4. Products & Categories: Product IDs, names, and categories
5. Payments: Payment methods and amounts
6. Sellers: IDs, locations, and products


Tools Used:
1. Python (Pandas)
2. SQL (MySQL Workbench)
3. Jupyter Notebook


Data Cleaning & Validation Process:

This project cleans and validates the e-commerce dataset to make it ready for analysis.

1. Check missing data: Find columns with empty values.
2. Remove duplicates: Keep only one copy of repeated rows.
3. Standardize text: Trim spaces and fix capitalization in city names, state codes, etc.
4. Validate numbers: Check prices, weights, scores, and other numeric fields for correctness.
5. Validate dates: Convert date strings to proper format and ensure logical order.
6. Create clean tables: Prepare final tables ready for KPI calculations and analysis.


SQL Scripts:

This repository contains 5 SQL scripts:
1. Data Loading Script: Load CSV data into MySQL tables
2. Data Cleaning & Validation Script: Clean data, remove duplicates, validate fields, and prepare clean tables
3. KPI Scripts (3 files): Calculate KPIs based on the cleaned data