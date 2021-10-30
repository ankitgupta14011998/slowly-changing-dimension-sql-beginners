create procedure Daily_sales_analysis.history_product()
begin
	create table Daily_Sales_analysis.updatedrecord(
 SELECT   t.Product_SK,
          t.Product_ID,
          s.Product_name,
          s.Product_price,
          s.Manufacturing_date,
          s.Expiry_date,
          CURDATE() as Validfrom,
          null as Validto,
          1 as Is_current
 FROM     Daily_Sales_analysis.DIM_Product s
          INNER JOIN Daily_Sales_analysis.history_product t
              ON t.Product_ID = s.Product_ID_SK 
              AND t.Is_current = 1
 WHERE    s.Product_name<>t.Product_name
          OR s.Product_price <> t.Product_price);
         
 select * from Daily_Sales_analysis.updatedrecord u ;
         
       
create table modified_keys(select Product_SK from updatedrecord);

update history_product 
	set Validto=DATE_SUB(CURDATE(),interval 1 day),Is_current =0
where history_product.Product_SK in (select Product_SK from modified_keys);


create table newrecordentry(
 SELECT   s.Product_ID_SK as Product_ID,
          s.Product_name,
          s.Product_price ,
          s.Manufacturing_date ,
          s.Expiry_date ,
          CURDATE() as Validfrom, 
          null AS Validto,
          1 as Is_current
 FROM     dim_product s
          LEFT OUTER JOIN history_product t
              ON t.Product_ID = s.Product_ID_SK 
 WHERE    t.Product_ID IS null);


create table deletedrecord(
	select t.Product_SK
from history_product t left outer join dim_product s 
		on t.Product_ID =s.Product_ID_SK 
where s.Product_ID_SK is null
	);




update history_product set Validto=CURDATE(),Is_current =0 
where history_product.Product_SK in (select Product_SK from deletedrecord) and history_product.Is_current =1;

 insert into history_product (
    Product_ID,
    Product_name,
	Product_price,
    Manufacturing_date,
    Expiry_date,
    Validfrom,
    Validto,
    Is_current) select Product_ID,
    Product_name,
	Product_price,
    Manufacturing_date,
    Expiry_date,
    Validfrom,
    Validto,
    Is_current from updatedrecord;
   
    insert into history_product (
    Product_ID,
    Product_name,
	Product_price,
    Manufacturing_date,
    Expiry_date,
    Validfrom,
    Validto,
    Is_current) select Product_ID,
    Product_name,
	Product_price,
    Manufacturing_date,
    Expiry_date,
    Validfrom,
    Validto,
    Is_current from newrecordentry;
  
   drop table newrecordentry ;
  drop table updatedrecord ;
 drop table modified_keys;
drop table deletedrecord ;
 
end