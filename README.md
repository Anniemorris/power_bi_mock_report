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

        Dates = CALENDAR(MIN(Orders[Order Date]), MAX(Orders[Shipping Date]))
        
        Day of Week = FORMAT(Dates[Date], "dddd")
        
        Month Name = FORMAT(Dates[Date], "MMMM")
        
        Month Number = MONTH(Dates[Date])
        
        Quarter = QUARTER(Dates[Date])
        
        Year = YEAR(Dates[Date])
        
        Start of Week = Dates[Date] - WEEKDAY(Dates[Date],2) + 1 # the 2 signals 2 as the start of the week (Monday) subtracting the weekday number from the date, it becomes the start of the week at the +1 (Sunday is the default start of the week)
        
        Start of Month = STARTOFMONTH(Dates[Date])
        
        Start of Quarter = STARTOFQUARTER(Dates[Date])
        
        Start of Year = STARTOFYEAR(Dates[Date])

The table was maked as date table under table tools tab. 

Some relationships had to be manually put together in a one-to-many relationship in single filter direction to form the star schema. 

* Products[product_code] to Orders[product_code]
* Stores[store code] to Orders[Store Code]
* Customers[User UUID] to Orders[User ID]
* Dates[date] to Orders[Order Date] - this had to be activated 
* Dates[date] to Orders[Shipping Date]

![image](https://github.com/user-attachments/assets/d6d88dc4-921d-4b83-ba8a-a46ccc7b6b05)

A new measures table was created to organise all of my measures and keep them under one table. I created an empty table using DAX formula to hold the measures under. 

= #table({"Measure_1"}, {{1}}) 

This created a one column, one row table. 

The following key measures were created: 
* 'Total Orders' -> counts the number of orders in the Orders table
  
        Total Orders = COUNTROWS(Orders)
  
* 'Total Revenue' -> multiplies the Orders[Product Quantity] column by the Products[Sale_Price] column for each row, and then sums the result - uses RELATED function to allow selection of multiple related tables
  
        Total Revenue = SUMX(Orders, (Orders[Product Quantity] * RELATED(Products[Sale Price]))
  
* 'Total Profit' -> For each row, subtract the Products[Cost_Price] from the Products[Sale_Price], and then multiply the result by the Orders[Product Quantity], Sums the result for all rows
  
        Total Profit = SUMX(Orders, (RELATED(Products[Sale Price]) - RELATED(Products[Cost Price])) * Orders[Product Quantity])
  
* 'Total Customers' -> counts the number of unique customers in the Orders table. To account for filtering I utilised the CALCULATE function to override existing filters.

        Total Customers = CALCULATE(DISTINCTCOUNT(Orders[User ID]))
  
* 'Total Quantity' -> counts the number of items sold in the Orders table

        Total Quantity = SUM(Orders[Product Quantity])

* 'Profit YTD' -> calculates the total profit for the current year

        Profit YTD = TOTALYTD([Total Profit], Dates[Date])

* 'Revenue YTD' -> calculates the total revenue for the current year
  
        Revenue YTD = TOTALYTD([Total Revenue], Dates[Date])

Hierarchies aid visualisations so I created a date hierarchy to drill-down in my line charts from start of year, to the day. A geography-based hierachy was also created to allow filtering by region, country and province. 

New calculated columns were created in the stores column to add to the geography hierarchy. Country codes were translated to Country name using x2 IF statements: 

        Country = IF(Stores[Country Code] = "GB", "United Kingdom", IF(Stores[Country Code] = "US", "United States", "Germany"))

In addition to the country column, a full geography column was created to make mapping more accurate. The formula for this column was: 

        Geography = Stores[Country Region] & ", " & Stores[Country]
        
### Phase 3 - Setting Up the Report 

Four essential report pages were set up - Executive Summary, Customer Detail, Product Detail, Stores Map. I chose a colour-blind friendly theme to ensure accessibility. 

#### Customer Detail Page: 

This page consists of many visuals aiding in customer-level analysis including cards, line chart, table, donut chart, slicers. 

Headline cards: 

These include key metrics including total unique customers and revenue per customer. This meant creating new measures: 

* Total Customers = CALCULATE(DISTINCTCOUNT(Orders[User UD]))
* Revenue per Customer = [Total Revenue] / [Total Customers]

x2 donut charts were created to show total customers by country and category(product) using [Total Customers] as the value and country/category as the legend. 

The line chart showed total customers over time, allowing drilldown to month level using the date hierarchy created earlier. Trendlines and forecasts for next 10 periods were creating in the further analysis tab. 

The top 20 customers, filtered by revenue, were shown in a table along with their number of orders. In the 'filters on this visual' section, I had to create a TOPN filter type by value of total revenue to display these top customers. When right clicking over total revenue in the values category, I was able to select conditional formatting of data bars for that column. 

3 Cards were created to show the top customers' (by revenue) name, revenue and number or orders. This was done by creating separate measures for each card: 

Top Customer Name = CALCULATE(SELECTEDVALUE(Customers[Full Name]), TOPN(1, Customers, [Total Revenue], DESC))

Top Customer Revenue = CALCULATE(MAXX(TOPN(1, Customers, [Total Revenue], DESC), [Total Revenue]))

Top Customer Orders = 
VAR TopUUID = 
        CALCULATE(SELECTEDVALUE(Customers[User UUID]), TOPN(1, Customers, [Total Revenue], DESC)) 
RETURN 
        CALCULATE(COUNTROWS(orders), Orders[User ID] = TopUUID)

This is the final page:
![image](https://github.com/user-attachments/assets/61081e0d-e704-461a-8860-b70cbb413113)

#### Executive Summary Page: 

The purpose of this page in the report was for a high-level executive summary detailing the companys performance as a whole showing revenue through time and by country, orders by category and a number of KPIs. 

x3 key measures were added to card visuals - total revenue, total orders and total profit. 

The formatted line chart from the customer detail page was copied over for ease with date hierarchy on the x axis and total revenue on the y axis. 

x2 donut charts were created using total revenue by country and by store type. I had some issues with these needing troubleshooting as all categories were just split equally i.e. revenue by country was 33.33% each. To fix this I had to ensure the required relationships were active. 

A bar chart for total orders by product category was created with data labels added on with homewares being most popular. 

Finally x3 KPI's had to be created to show performance based on targets - previous quarter profit, previous quarter revenue, previous quarter orders - along with targets equal to 5% growth compared to previous quarter. 

        Previous Quarter Revenue = CALCULATE([Total Revenue], PREVIOUSQUARTER(Dates[Date]))
        
        Previous Quarter Profit = CALCULATE([Total Profit], PREVIOUSQUARTER(Dates[Date]))
        
        Previous Quarter Orders = CALCULATE([Total Orders], PREVIOUSQUARTER(Dates[Date]))

For each of these measures, the target measures were also created:

        Target Revenue = CALCULATE([Previous Quarter Revenue] * 1.05)

        Target Profit = CALCULATE([Previous Quarter Profit] * 1.05)

        Target Orders = CALCULATE([Previous Quarter Orders] * 1.05)

The value field was total revenue/profit/orders, the trend axis was start of quarter and the target was target revenue/profit/orders. 

The final page is below: 
![image](https://github.com/user-attachments/assets/2f6fea0d-2307-4712-a699-e0d16180ae00)
