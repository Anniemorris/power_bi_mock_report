# Data Analytics Power BI Report 

This project aims to create a quarterly report for a medium-sized international retailer as a high-level business summary tailored for C-Suite executives, giving insight into high value customers.

### Phase 1 - Importing the Data 
All data had to be transformed with columns renamed to align with Power BI naming conventions. 

#### Orders Table 

Contains information about orders with one product code per order. This was imported via Azure SQL Database. 

* Order Date and Shipping Date columns were split to create Order Time and Shipping Time columns 
* Rows with missing order dates were removed 

#### Products Dimension (dim) Table

Contains information about the products sold by the company including price and weight. This was imported as a .csv file. 

* The Remove Duplicates function was used on the product_code column to ensure codes were unique 

#### Stores dim Table

Contains location information about each store. This was imported via Azure Blob Storage. 

* Column Profile was selected to see which regions were mispelled in the Region column
* The Replace Values function was used to replace mispelled versions of Europe and America

#### Customers Table 

Contains customer information including email address and address for each operating region. This was a zip folder containing 3 .csv files - it was imported as a folder and the data combined into one query. 

* A new column was created to combine first name and last name to make full name


### Phase 2 - Creating the Data Model 

A date table had to be created to allow time intelligence analysis with continuous date data covering the whole time period from the earliest Orders[Order Date] to the latest Orders[Shipping Date]. 

DESCRIPTION OF  HOW MADE DATE TABLE AND SCREENSHOT OF DAX FORMULA 

Some relationships had to be manually put together in a one-to-many relationship in single filter direction to form the star schema. 

* Products[product_code] to Orders[product_code]
* Stores[store code] to Orders[Store Code]
* Customers[User UUID] to Orders[User ID]
* Dates[date] to Orders[Order Date] - this had to be activated 
* Dates[date] to Orders[Shipping Date]

A new measures table was created to organise all of my measures and keep them under one table. I created an empty table using DAX formula to hold the measures under. 
DAX FORMULA FOR CREATING NEW MEASURES TABLE
