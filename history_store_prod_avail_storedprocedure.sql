create procedure Daily_sales_analysis.history_store_prod_avail()
begin

create table updatedrecord(
 SELECT   t.Store_prod_avail_SK,
          t.Store_ID,
		  s.Product_ID ,
		  s.Stock_availability ,
          CURDATE() as Validfrom,
          null as Validto,
          1 as Is_current
 FROM     DIM_store_product s 
          INNER JOIN DIM_store_product_avail_history t
              ON t.Store_ID = s.Store_ID 
              and t.Product_ID=s.Product_ID
              AND t.Is_current = 1
 WHERE    s.Stock_availability <> t.Availability);
         
       
create table modified_keys(select Store_prod_avail_SK from updatedrecord);

update DIM_store_product_avail_history 
	set Validto=DATE_SUB(CURDATE(),interval 1 day),Is_current =0
where DIM_store_product_avail_history.Store_prod_avail_SK in (select Store_prod_avail_SK from modified_keys);


create table newrecordentry(
 SELECT   s.Store_ID,
          s.Product_ID ,
          s.Stock_availability ,
          CURDATE() as Validfrom, 
          null AS Validto,
          1 as Is_current
 FROM     DIM_store_product s  
          LEFT OUTER JOIN DIM_store_product_avail_history t
              ON t.Store_ID = s.Store_ID
              and t.Product_ID=s.Product_ID 
 WHERE    t.Store_ID IS null and t.Product_ID is null);

create table deletedrecord(
	select t.Store_prod_avail_SK
from DIM_store_product_avail_history t left outer join DIM_store_product s 
		on t.Store_ID =s.Store_ID and t.Product_ID=s.Product_ID 
where s.Store_ID is null and s.Product_ID is null
	);

update DIM_store_product_avail_history set Validto=CURDATE(),Is_current =0 
where DIM_store_product_avail_history.Store_prod_avail_SK in (select Store_prod_avail_SK from deletedrecord) and DIM_store_product_avail_history.Is_current =1;

 insert into DIM_store_product_avail_history (
    Store_ID,
    Product_ID,
    Availability,
    Validfrom,
    Validto,
    Is_current) select Store_ID,
    Product_ID,
    Stock_availability,
    Validfrom,
    Validto,
    Is_current from updatedrecord;
   
    insert into DIM_store_product_avail_history (
    Store_ID,
    Product_ID,
    Availability,
    Validfrom,
    Validto,
    Is_current) select Store_ID,
    Product_ID,
    Stock_availability,
    Validfrom,
    Validto,
    Is_current from newrecordentry;
  
   drop table newrecordentry ;
  drop table updatedrecord ;
 drop table modified_keys;
drop table deletedrecord ;

end