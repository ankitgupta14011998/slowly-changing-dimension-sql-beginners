create table Goals(
    Goal_ID_SK numeric(3) primary key,
    Goal_name varchar(20),
    Goal_expirydate datetime,
    Goal_amount decimal(6,2),
    Goal_quantity_per_year numeric(5));

create table DIM_Salesperson(
    Salesperson_ID_SK numeric(5) primary key,
    Salesperson_name varchar(20),
    Supervisor_ID varchar(20),
    Date_of_joining Datetime,
    
create table salesperson_goal(
    Salesperson_ID numeric(6),
    Goal_ID numeric(3),
    foreign key (Salesperson_ID) references DIM_Salesperson(Salesperson_ID_SK),
    foreign key (Goal_ID) references Goals(Goal_ID_SK),
    primary key(Salesperson_ID,Goal_ID));

create table DIM_Product(
    Product_ID_SK numeric(3) primary key,
    Product_name varchar(20),
    Product_price numeric(5),
    Manufacturing_date datetime,
    Expiry_date datetime);
   
create table DIM_Store(
    Store_ID_SK numeric(3) primary key,
    Store_name varchar(20),
    Store_branch varchar(20));
    
create table Store_Product(
    Store_Id numeric(3),
    Product_ID numeric(3),
    Stock_availability numeric(3),
    foreign key (Store_ID) references DIM_Store(Store_ID_SK),
    foreign key (Product_ID) references DIM_Product(Product_ID_SK),
    primary key(Store_ID,Product_ID));

create table FCT_Sales(
    Sales_ID_SK int primary key auto_increment not null,
    Product_ID_FK numeric(3),
    Store_ID_FK numeric(3),
    Salesperson_ID_FK numeric(6),
    Sold_quantity numeric(5),
    Amount decimal(10,2),
    Date_of_sales datetime,
    foreign key (Product_ID_FK) references DIM_Product(Product_ID_SK),
   foreign key (Store_ID_FK) references DIM_Store(Store_ID_SK),
   foreign key(Salesperson_ID_FK) references DIM_Salesperson(Salesperson_ID_SK));



#Use this query to automatically fill Amount column in FCT_Sales(Other columns must be prefilled in FCT_Sales)
update FCT_Sales SET Amount=(select FCT_Sales.Sold_quantity*d.Product_price from DIM_Product d where FCT_Sales.Product_ID_FK=d.Product_ID_SK);



