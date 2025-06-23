                                                --Triggers--
--1) Trigger#1 Before insert:                                                
create table WorkCenters(
	id serial primary key,
	name varchar(100) not null,
	capacity int not null	
);
	
create table WorkCenterStats(
	totalCapacity int not null
); 

select * from workcenters;
select * from workcenterstats;


/*delimiter//
create trigger before_workcenters_insert before insert on workcenters for each row 
begin 
	declare rowcount int;
	select count(*) into rowcount from workcenterstats;
	if rowcount >0 then
		update workcenterstats set totalcapacity=totalcapacity+new.capacity;
	else
		insert into workcenterstats(totalcapacity)values(new.capacity);
	end if;
end //
delimiter;
*/
-- 1. Créer la fonction déclencheur
CREATE OR REPLACE FUNCTION before_workcenters_insert_fn()
RETURNS TRIGGER
AS $$
DECLARE
    rowcount INT;
BEGIN
    SELECT COUNT(*) INTO rowcount FROM workcenterstats;

    IF rowcount > 0 THEN
        UPDATE workcenterstats
        SET totalcapacity = totalcapacity + NEW.capacity;
    ELSE
        INSERT INTO workcenterstats(totalcapacity)
        VALUES (NEW.capacity);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Créer le trigger qui appelle la fonction
CREATE TRIGGER before_workcenters_insert
BEFORE INSERT ON workcenters
FOR EACH ROW
EXECUTE FUNCTION before_workcenters_insert_fn();


show triggers;

SELECT
    event_object_table AS table_name,
    trigger_name,
    action_timing AS trigger_time,
    event_manipulation AS event,
    action_statement AS trigger_body
FROM
    information_schema.triggers
WHERE
    trigger_schema = 'public';  -- adapte si ton schéma est différent
    
    
--Testing the before insert trigger
    
--Step1:
insert into workcenters (name, capacity) values('Mold Machine',100);

--Step2:
select * from workcenterstats;

--Step3:
insert into workcenters (name, capacity) values('Packing',200);

--Step4:
select * from workcenterstats;


--2)Trigger#2 After insert: 

create table members(
	id serial primary key,
	name varchar(100) not null,
	email varchar(225),
	birthDate date
);

drop table reminder ;
create table reminders(
	id serial,
	memberId int,
	message varchar(225) not null,
	primary key(id, memberId)
);

select * from members;
select * from reminder;

delimiter//

create trigger after_members_insert after insert on members for each row
begin 
	if new.birthDate is null then insert into reminders(memeberId, message)
		values(new.id, concat('Hi ', new.name, ', please update your date of birth.'))
	end if;
end//
delimiter;


-- 1. Créer la fonction déclencheur
CREATE OR REPLACE FUNCTION after_members_insert_fn()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.birthDate IS NULL THEN
        INSERT INTO reminders(memberId, message)
        VALUES (
            NEW.id,
            'Hi ' || NEW.name || ', please update your date of birth.'
        );
    END IF;
    RETURN NULL;  -- AFTER triggers peuvent retourner NULL
END;
$$ LANGUAGE plpgsql;

-- 2. Créer le trigger
CREATE TRIGGER after_members_insert
AFTER INSERT ON members
FOR EACH ROW
EXECUTE FUNCTION after_members_insert_fn();


--Testing the after insert trigger
--Step1:
insert into members(name, email, birthDate) values('John', 'john123@gmail.com',null);
insert into members(name, email, birthDate) values('Kate', 'kate987@gmail.com','07-03-2012');

--Step2:
select * from members; 

--Step3:
select * from reminders; 


--3)Trigger#3 Before update:

create table sales(
	id serial,
	product varchar(100) not null,
	quantity int not null default 0,
	fiscalYear smallint not null,
	fiscalMonth smallint not null,
	check (fiscalMonth>=1 and fiscalMonth<=12),
	check (fiscalYear between 2000 and 2050),
	unique(product, fiscalYear, fiscalMonth),
	primary key(id)
);

select * from sales;

insert into sales (product, quantity, fiscalYear, fiscalMonth) values
	('2003 Harley-Davidson Eagle Drag Bike', 120, 2020,1),
	('1969 Corvair Monza',150,2020,1),
	('1970 Plymouth Hemi Cuda', 200,2020,1);

/*
delimiter //
create trigger before_sales_update before update on sales for each row 
begin 
	decalre errorMessage varchar(225);
	set errorMessage = concat('The new quantity', new.quantity, ' cannot be 3 times greater than the current quantity ', old.quantity);
	if new.quantity > old.quantity * 3 then
		signal sqlstate '45000' set Message_text =  errorMessage;
	end if;
end//
delimiter ;
*/	

CREATE OR REPLACE FUNCTION before_sales_update_fn()
RETURNS TRIGGER AS $$
DECLARE
    errorMessage TEXT;
BEGIN
    IF NEW.quantity > OLD.quantity * 3 THEN
        errorMessage := 'The new quantity ' || NEW.quantity ||
                        ' cannot be 3 times greater than the current quantity ' || OLD.quantity;
        RAISE EXCEPTION '%', errorMessage;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_sales_update
BEFORE UPDATE ON sales
FOR EACH ROW
EXECUTE FUNCTION before_sales_update_fn();

--Testing the before update trigger

--Step1: it should update sales table because the new quantity does not violate the rule.

--update the quantity of the row with id 1 to 150.
update sales set quantity =150 where id =1;

--Query date from the sales table to verify update
select * from sales; 


--Step2: error code: 1644. Then new quantity 500 cannot be 3 times greater than the current quantity 150. In this case, the trigger should found the new quantity caused a violation and raised an error.

--update the quantity of the row id 1 to 500.  
update sales set quantity =500 where id=1; 

--Query date from the sales table to verify update
select * from sales; 



--4)Trigger#4 After update:
create table SalesChanges(
	id serial primary key,
	salesId int,
	beforeQuantity int,
	afterQuantity int,
	changedAt time not null default current_timestamp
);

select * from saleschanges; 
/*
dilimiter//
create trigger after_sales_update after update on sales for each row 
begin 
	
	if old.quantity <> new.quantity then
		insert into saleschanges (salesId, beforeQuantity, afterQuantity)
		values(old.id, old.quantity, new.quantity);
	end if;
end//
delimiter ;
*/

CREATE OR REPLACE FUNCTION after_sales_update_fn()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.quantity <> NEW.quantity THEN
        INSERT INTO saleschanges (salesId, beforeQuantity, afterQuantity)
        VALUES (OLD.id, OLD.quantity, NEW.quantity);
    END IF;

    RETURN NULL; -- AFTER triggers return NULL
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_sales_update
AFTER UPDATE ON sales
FOR EACH ROW
EXECUTE FUNCTION after_sales_update_fn();


--Testing the after update trigger

--step1: the trigger should triggered automatically.

--update the quantity of the row with id 1 to 350.
update sales set quantity = 350 where id = 1;

--query data from the sales changes table to verify update
select * from saleschanges;
select * from sales;


--step2: update the quantity of all 3 rows by increasing 10%.
UPDATE sales SET quantity = CAST(quantity * 1.1 AS INTEGER);


--step3: the trigger should fire three times because of the updates of the three rows.
--query data from saleschanges table 
select * from saleschanges; 


--5)Trigger#5 Before delete:
create table salaries(
	employeeNumber int primary key,
	validFrom date not null,
	salary decimal(12,2) not null default 0
);

insert into salaries(employeeNumber,validFrom, salary)
values
	(1002,'2000-01-01',50000),
	(1056,'2000-01-01',60000),
	(1076,'2000-01-01',70000);

create table salaryarchives(
	id serial primary key,
	employeeNumber int,
	validFrom date not null,
	salary dec(12,2) not null default 0,
	deleteAt timestamp default now()
);

select * from salaries;
select * from salaryarchives;

/*
delimiter //

create trigger before_salaries_delete before delete on salaries for each row 

begin
	
	insert into salaryarchives (employeeNumber, validFrom, salary )
	values(old.employeeNumber, old.validFrom, old.salary);
	
end//

delimiter;
*/

CREATE OR REPLACE FUNCTION before_salaries_delete_fn()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO salaryarchives (employeeNumber, validFrom, salary)
    VALUES (OLD.employeeNumber, OLD.validFrom, OLD.salary);

    RETURN OLD;  -- obligatoire dans un trigger BEFORE DELETE
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_salaries_delete
BEFORE DELETE ON salaries
FOR EACH ROW
EXECUTE FUNCTION before_salaries_delete_fn();


--Testing the before delete trigger

--step1: the trigger should invoke and insert a new row into the SalaryArchives table.

--delete the row from salaries table
delete from salaries where employeeNumber = 1002;
--query the data from salaryarchives table
select * from salaryarchives; 


--step2: the trigger should trigger 2 times because the delete statement deleted two rows from the salaries table.

--delete all the rows from salries table.
delete from salaries ;
--finally, query the data from salariesarchives table.
select * from salaryarchives;



--6)Trigger#6 After delete:

create table salarybudgets(
	total decimal(15,2) not null
);
insert into salarybudgets(total) select sum(salary) from salaries; 
select * from salarybudgets;

/*
create trigger after_salaries_delete after delete on salaries for each row 
update salarybudgets set total = total - old.salary; 
*/

CREATE OR REPLACE FUNCTION after_salaries_delete_fn()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE salarybudgets
    SET total = total - OLD.salary;

    RETURN NULL; -- AFTER triggers return NULL
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_salaries_delete
AFTER DELETE ON salaries
FOR EACH ROW
EXECUTE FUNCTION after_salaries_delete_fn();

--Testing the before delete trigger

--step1: in the output, the total should be reduced by the deleted salary.

--delete the row from salaries table.
delete from salaries where employeenumber=1002;

--query salary from salarybudgets table.
select * from salarybudgets; 


--step2: the trigger updated the total to zero.

--delete all the rows from salaries table.
delete from salaries ;

--finally, query the total from salarybudgets table.
select * from salarybudgets; 





































