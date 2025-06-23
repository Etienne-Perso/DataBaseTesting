--TC001:
show tables; --success

--TC002:
show tables; --success

SELECT tablename            --posgres syntax
FROM pg_catalog.pg_tables
WHERE schemaname = 'public'; 

--TC003:
select count(*) as NumberOfColumns  --13, success
from information_schema.columns 
where table_name='customers';

--T004:
select column_name               --success
from information_schema.columns 
where table_name='customers';

--TC005:
select column_name, data_type     --success
from information_schema.columns 
where table_name='customers';

--T006:
select column_name , column_type  --success
from information_schema.columns 
where table_name='customers';

SELECT                             --postgres syntax
    column_name,
    data_type,
    character_maximum_length
FROM 
    information_schema.columns
WHERE 
    table_name = 'customers'
    AND table_schema = 'public';



--T007:
select column_name , is_nullable --success
from information_schema.columns 
where table_name='customers';

--T008:
select column_name ,column_key     --success
from information_schema.columns 
where table_name='customers';

select                             --postgres syntax
    kcu.column_name,
    tc.constraint_type
FROM 
    information_schema.table_constraints tc
JOIN 
    information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_name = kcu.table_name
WHERE 
    tc.table_name = 'customers'
    AND tc.constraint_type = 'PRIMARY KEY'
    AND tc.table_schema = 'public';