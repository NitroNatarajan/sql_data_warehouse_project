# SQL_Data warehouse and SQL Data Analytics Project 

Welcome to the **Data Warehouse and Analytics Project** repository! 🚀💥
This project demonstartes a comprehensive data warehouse and analytics solution, from building a data warehouse to genarating actonable insights. And this is portfolio project highlights industry best practices in dataengineering and analytics.

---
### Project Requirements
Building the data warehouse (Data Engineering)
####  Objective:
Develop the modern data warehouse using the sql server to consolidate sales data, enabiling analytical reporting and informed decision-making. 

##### Specification: 
- **Data sources**: Import the data from the two source system (ERP, CRM) provided as csv.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **Integration**: Combine both sources into single, user-friendly data model designed for analytical purposes. 
- **Scope**: Focus on the latest dataset only, historization on data is not required. 
- **Documentation**: Provide the clear documentation of the data model to support both business stakeholders and analytics team. 

---
### BI: Analytics & Reporting (Data Analytics)

####  Objective:
Develop SQL-based analytics to deliver detailed insights into:
  - **Customer Bbehaviour**
  - **Product Pperformance**
	- **Sales Trends**

##### These insights empower stakeholders with key business metrics, enabiling strategic decision-making.

---
#### Data Architecture for the data warehouse building: 

![Data Architecture Diagram](https://github.com/NitroNatarajan/sql_data_warehouse_project/blob/main/docs/Architecture_datawarehouse.png)

--- 
#### Data Flow diagram: 

![Data Flow Diagram](https://github.com/NitroNatarajan/sql_data_warehouse_project/blob/main/docs/data_flow_diagram.png)
---
#### Gold Layer data model diagram: 

![Gold Layer Data Model](https://github.com/NitroNatarajan/sql_data_warehouse_project/blob/main/docs/Data_model_gold_layer.png)
---
#### Repository Structure:
```
└── 📁sql_data_warehouse_project
    └── 📁datasets
        └── 📁source_crm
            ├── cust_info.csv
            ├── prd_info.csv
            ├── sales_details.csv
        └── 📁source_erp
            ├── cust_az12.csv
            ├── loc_a101.csv
            ├── px_cat_g1v2.csv
    └── 📁docs
        ├── .$Data_model_gold_layer.drawio.bkp
        ├── Architecture_datawarehouse.drawio
        ├── Architecture_datawarehouse.png
        ├── Data modelling diagram.drawio
        ├── Data modelling diagram.png
        ├── data_flow_diagram.drawio
        ├── data_flow_diagram.png
        ├── Data_model_gold_layer.drawio
        ├── Data_model_gold_layer.png
    └── 📁scripts
        └── 📁bronze
            ├── ddl_bronze.sql
            ├── proc_load_bronze.sql
        └── 📁gold
            ├── ddl_gold.sql
        └── 📁silver
            ├── ddl_silver.sql
            ├── proc_load_silver.sql
        ├── init_database.sql
    └── 📁tests
        ├── data_validation_on_silver_layer.sql
        ├── quality_check_gold.sql
        ├── quality_checks_on_bronze_data.sql
    ├── LICENSE
    └── README.md
```
---
## 🪪 License
This project is licenced under the [MIT License](License). You are free to use, modify and share this project with proper attribution. 

## 📔 About me 💥
I'm **Natarajan Thanaraj**, aspiring data professional who is learning the data management and data analytics practices. 
