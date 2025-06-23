							--SF1: customerlevel():--
--TC001:

--Mysql syntax: 
show function status where name='customerlevel';

--Postgres syntax:
SELECT
    n.nspname AS schema_name,
    p.proname AS function_name,
    pg_get_function_arguments(p.oid) AS arguments,
    pg_get_function_result(p.oid) AS return_type,
    l.lanname AS language,
    p.prokind AS kind  -- 'f' = function, 'p' = procedure
FROM 
    pg_proc p
JOIN 
    pg_namespace n ON n.oid = p.pronamespace
JOIN
    pg_language l ON l.oid = p.prolang
WHERE 
    p.prokind = 'f'
    AND p.proname = 'customerlevel';
    
   
   
--TC002:
select customername, customerlevel(creditlimit)from customers;


select customername,                      
case                                                                                             
	when creditLimit>50000 then
'PlATINUM'
	when (creditLimit>=10000 and creditLimit<=50000)then
'GOLD'
	when creditLimit < 10000 then
'SILVER'                                                                                           
end as customerlevel from customers; 

--TC003:
call getcustomerlevel(103,@customerlevel);
select @customerlevel;

select customername,                                                          
case                                                                                         
	when creditLimit>50000 then
'PlATINUM'
	when (creditLimit>=10000 and creditLimit<=50000)then 
'GOLD'
	when creditLimit < 10000 then
'SILVER'                                                                                           
end as customerlevel from customers where customerNumber=103; 