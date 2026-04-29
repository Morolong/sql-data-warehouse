#Data Dictionary for the Gold Layer 
##Overview 
The gold Layer is the business-level data representation structured to support analytical and reporting use cases. It consts of dimension tables and fact tables for specific business metrics. 

#1. gold.dim_customers
PurposeL stores customer details enriched with demographic and geographic data. 
Columns: 


| Column Name  | Data Type  | Description |
| :---         |     :---:  | :---        |
| customer_key |   INT     |Surrogate key uniquely identifying each customer record in the dimension table |
| customer_id |   INT      |Surrogate key uniquely identifying each customer record in the dimension table |
| customer_number |   NVARCHAR(50)  |Surrogate key uniquely identifying each customer record in the dimension table |
| first_name |   NVARCHAR(50) |Surrogate key uniquely identifying each customer record in the dimension table |
| last_name |   NVARCHAR(50)      |Surrogate key uniquely identifying each customer record in the dimension table |
| country |   NVARCHAR(50)      |Surrogate key uniquely identifying each customer record in the dimension table |
| marital_status |   NVARCHAR(50)      |Surrogate key uniquely identifying each customer record in the dimension table |
| gender |   NVARCHAR(50)      |Surrogate key uniquely identifying each customer record in the dimension table |
| birthdate |   DATE      |Surrogate key uniquely identifying each customer record in the dimension table |
| create_date |   DATE      |Surrogate key uniquely identifying each customer record in the dimension table |
