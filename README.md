# Data Warehouse and Analytics Project

A complete end-to-end SQL Data Warehouse project built using SQL Server, focused on designing a modern data warehouse using Medallion Architecture (Bronze, Silver, Gold), ETL pipelines, dimensional modeling, and business analytics reporting.

This project demonstrates how raw data from multiple source systems can be transformed into a clean, analytics-ready warehouse that supports reporting, decision-making, and business intelligence.

---

# Project Overview

This project covers the full lifecycle of building a modern data warehouse:

- Data Architecture Design
- ETL Development
- Data Cleansing and Transformation
- Dimensional Modeling
- SQL-Based Analytics and Reporting
- Data Quality Validation
- Documentation and Governance

The solution consolidates data from multiple source systems (ERP and CRM) into a centralized warehouse optimized for analytical queries and business reporting.

---

# Data Architecture

The project follows the **Medallion Architecture** approach:

## Bronze Layer — Raw Data

Stores source data exactly as received from source systems.

### Characteristics:
- Raw CSV imports
- No transformations
- Full historical snapshot
- Source system preservation

### Purpose:
Provides traceability and source-of-truth auditing.

---

## Silver Layer — Cleaned & Standardized Data

Transforms raw data into validated, structured datasets.

### Processes:
- Data cleansing
- Standardization
- Null handling
- Deduplication
- Type corrections
- Referential integrity validation

### Purpose:
Creates trusted, high-quality data for downstream use.

---

## Gold Layer — Business-Ready Analytics Model

Stores dimensional models optimized for reporting.

### Components:
- Fact Tables
- Dimension Tables
- Star Schema

### Purpose:
Supports BI reporting, dashboards, and advanced analytics.

---

# Tech Stack

## Database

- Microsoft SQL Server Express

## Development Tools

- SQL Server Management Studio (SSMS)
- Git & GitHub
- Draw.io

## Core Skills Demonstrated

- SQL Development
- Data Engineering
- ETL Design
- Data Modeling
- Data Warehousing
- Analytics Engineering
- Documentation Standards
- Data Quality Assurance

---

# Repository Structure

```text
data-warehouse-project/
│
├── datasets/
│   ├── source_crm/
│   ├── source_erp/
│
├── docs/
│   ├── data_flow.drawio
│   ├── high_level_architecture.drawio
│   ├── integration_model.drawio
│   ├── sales_data_mart.drawio
│   ├── data_catalog.md
│
├── scripts/
│   ├── bronze/
│   │   ├── ddl_bronze.sql
│   │   └── proc_load_bronze.sql
│   │
│   ├── gold/
│   │   ├── ddl_gold.sql
│   │
│   └── silver/
│       ├── ddl_silver.sql
│       ├── proc_load_silver.sql
│   ├── init_database.sql
│
├── tests/
│   ├── quality_checks_gold.sql
│   └── quality_checks_silver.sql
│
├── LICENSE
├── README.md
