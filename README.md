# slowly-changing-dimension-sql-beginners
This project is to implement slowly changing dimension of type 1 and 2 in database using only MySQL.
In this project we use concept of "Enterprise data warehouse for Daily Sales Analysis".
We use following 5 modules to acknowlwdge sales performance, forecasting the future sales.
Store module: This module stores the details on store ID, name, branch, available stock and productID
Salesperson module: This module stores the details on sales person, name supervisor ID, date of joining and goal ID
Product module: This module maintains the details on product ID, Product name, price, manufacturing date and expiry date.
Sales module: This module stores the detail on sales ID, product ID, store ID, salesperson ID, sold quantity, Amount and date of sales.
Goal module: This module stores the details on goal ID, goal name, goal expiry date, goal amount and goal quantity per year.
Star Schema and SCD type 2 will be used for DW.
Dbeaver, oracle, used for implementation.
