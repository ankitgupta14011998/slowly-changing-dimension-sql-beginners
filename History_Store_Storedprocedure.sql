create procedure Daily_sales_analysis.history_store()
begin
create table updatedrecord(
 SELECT   t.Store_SK,
          t.Store_ID,
          s.Store_name,
          s.Store_branch,
          CURDATE() as Validfrom,
          null as Validto,
          1 as Is_current
 FROM     dim_store s 
          INNER JOIN Store_history t
              ON t.Store_ID = s.Store_ID_SK 
              AND t.Is_current = 1
 WHERE    s.Store_name<>t.Store_name
          or s.Store_branch <> t.Store_branch);
         
       
create table modified_keys(select Store_SK from updatedrecord);

update Store_history 
	set Validto=DATE_SUB(CURDATE(),interval 1 day),Is_current =0
where Store_history.Store_SK in (select Store_SK from modified_keys);


create table newrecordentry(
 SELECT   s.Store_ID_SK as Store_ID,
          s.Store_name,
          s.Store_branch ,
          CURDATE() as Validfrom, 
          null AS Validto,
          1 as Is_current
 FROM     dim_store s  
          LEFT OUTER JOIN Store_history t
              ON t.Store_ID = s.Store_ID_SK 
 WHERE    t.Store_ID IS null);

create table deletedrecord(
	select t.Store_SK
from Store_history t left outer join dim_store s 
		on t.Store_ID =s.Store_ID_SK 
where s.Store_ID_SK =null
	);

update Store_history set Validto=CURDATE(),Is_current =0 
where Store_history.Store_SK in (select Store_SK from deletedrecord) and Store_history.Is_current =1;

 insert into Store_history (
    Store_ID,
    Store_name,
    Store_branch ,
    Validfrom,
    Validto,
    Is_current) select Store_ID,
    Store_name,
    Store_branch ,
    Validfrom,
    Validto,
    Is_current from updatedrecord;
   
    insert into Store_history (
    Store_ID,
    Store_name,
    Store_branch ,
    Validfrom,
    Validto,
    Is_current) select Store_ID,
    Store_name,
    Store_branch,
    Validfrom,
    Validto,
    Is_current from newrecordentry;
  
   drop table newrecordentry ;
  drop table updatedrecord ;
 drop table modified_keys;
drop table deletedrecord ;

end