create procedure Daily_sales_analysis.history_goal()
begin
create table updatedrecord(
 SELECT   t.Goal_history_SK,
          t.Goal_ID,
          s.Goal_name,
          s.Goal_expirydate,
          s.Goal_amount,
          s.Goal_quantity_per_year,
          CURDATE() as Validfrom,
          null as Validto,
          1 as Is_current
 FROM     goals s 
          INNER JOIN Goal_history t
              ON t.Goal_ID = s.Goal_ID_SK
              AND t.Is_current = 1
 WHERE    s.Goal_name<>t.Goal_name
          or s.Goal_expirydate <> t.Goal_expirydate
          or s.Goal_amount <> t.Goal_amount
          or s.Goal_quantity_per_year <> t.Goal_quantity_per_year);
         
       
create table modified_keys(select Goal_history_SK from updatedrecord);

update Goal_history 
	set Validto=DATE_SUB(CURDATE(),interval 1 day),Is_current =0
where Goal_history.Goal_history_SK in (select Goal_history_SK from modified_keys);


create table newrecordentry(
 SELECT   s.Goal_ID_SK as Goal_ID,
          s.Goal_name,
          s.Goal_expirydate ,
          s.Goal_amount ,
          s.Goal_quantity_per_year ,
          CURDATE() as Validfrom, 
          null AS Validto,
          1 as Is_current
 FROM     Goals s  
          LEFT OUTER JOIN Goal_history t
              ON t.Goal_ID = s.Goal_ID_SK 
 WHERE    t.Goal_ID IS null);

create table deletedrecord(
	select t.Goal_history_SK
from Goal_history t left outer join Goals s 
		on t.Goal_ID =s.Goal_ID_SK 
where s.Goal_ID_SK =null
	);

update Goal_history set Validto=CURDATE(),Is_current =0 
where Goal_history.Goal_history_SK in (select Goal_history_SK from deletedrecord) and Goal_history.Is_current =1;

 insert into Goal_history (
    Goal_ID,
    Goal_name,
    Goal_expirydate ,
    Goal_amount,
    Goal_quantity_per_year,
    Validfrom,
    Validto,
    Is_current) select Goal_ID,
    Goal_name,
    Goal_expirydate ,
    Goal_amount,
    Goal_quantity_per_year,
    Validfrom,
    Validto,
    Is_current from updatedrecord;
   
    insert into Goal_history (
    Goal_ID,
    Goal_name,
    Goal_expirydate ,
    Goal_amount,
    Goal_quantity_per_year,
    Validfrom,
    Validto,
    Is_current) select Goal_ID,
    Goal_name,
    Goal_expirydate,
    Goal_amount,
    Goal_quantity_per_year,
    Validfrom,
    Validto,
    Is_current from newrecordentry;
  
   drop table newrecordentry ;
  drop table updatedrecord ;
 drop table modified_keys;
drop table deletedrecord ;

end