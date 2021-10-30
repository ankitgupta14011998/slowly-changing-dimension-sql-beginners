create procedure Daily_sales_analysis.history_salesperson()
begin
	create table updatedrecord(
 SELECT   t.Salesperson_SK,
          t.Salesperson_ID,
          s.Salesperson_name,
          s.Supervisor_ID,
          s.Date_of_joining,
          CURDATE() as Validfrom,
          null as Validto,
          1 as Is_current
 FROM     DIM_Salesperson s
          INNER JOIN Salesperson_history t
              ON t.Salesperson_ID = s.Salesperson_ID_SK 
              AND t.Is_current = 1
 WHERE    s.Salesperson_name<>t.Salesperson_name
          OR s.Supervisor_ID <> t.Supervisor_ID
          or s.Salesperson_ID_SK <> t.Salesperson_ID );
         
       
create table modified_keys(select Salesperson_SK from updatedrecord);

update Salesperson_history 
	set Validto=DATE_SUB(CURDATE(),interval 1 day),Is_current =0
where Salesperson_history.Salesperson_SK in (select Salesperson_SK from modified_keys);


create table newrecordentry(
 SELECT   s.Salesperson_ID_SK as Salesperson_ID,
          s.Salesperson_name,
          s.Supervisor_ID ,
          s.Date_of_joining ,
          CURDATE() as Validfrom, 
          null AS Validto,
          1 as Is_current
 FROM     dim_Salesperson s
          LEFT OUTER JOIN Salesperson_history t
              ON t.Salesperson_ID = s.Salesperson_ID_SK 
 WHERE    t.Salesperson_ID IS null);

create table deletedrecord(
	select t.Salesperson_SK
from Salesperson_history t left outer join dim_Salesperson s 
		on t.Salesperson_ID =s.Salesperson_ID_SK 
where s.Salesperson_ID_SK =null
	);

update Salesperson_history set Validto=CURDATE(),Is_current =0 
where Salesperson_history.Salesperson_SK in (select Salesperson_SK from deletedrecord) and Salesperson_history.Is_current =1;

 insert into Salesperson_history (
    Salesperson_ID,
    Salesperson_name,
	Supervisor_ID,
    Date_of_joining,
    Validfrom,
    Validto,
    Is_current) select Salesperson_ID,
    Salesperson_name,
	Supervisor_ID,
    Date_of_joining,
    Validfrom,
    Validto,
    Is_current from updatedrecord;
   
    insert into Salesperson_history (
    Salesperson_ID,
    Salesperson_name,
	Supervisor_ID,
    Date_of_joining,
    Validfrom,
    Validto,
    Is_current) select Salesperson_ID,
    Salesperson_name,
	Supervisor_ID,
    Date_of_joining,
    Validfrom,
    Validto,
    Is_current from newrecordentry;
  
   drop table newrecordentry ;
  drop table updatedrecord ;
 drop table modified_keys;
drop table deletedrecord ;
 
end