--1) Validating courses table:
create table courses
(courseid integer primary key,
coursename varchar(20) unique,
duration integer,
fee integer check(fee between 100 and 500)
);

select * from courses;

-- Validating courseid:
Insert into courses values(111,'Java',3,500);     --valid
Insert into courses values(111,'Python',2,300);   --not valid --> dupliquée rompt la contrainte unique « courses_pkey »
Insert into courses values(null,'Python',2,300);  --not valid --> viole la contrainte NOT NULL


-- Validating coursename:
insert into courses values(222,'Python',2,300); --valid
insert into courses values(333,'Python',2,300); --not valid --> dupliquée rompt la contrainte unique « courses_coursename_key »

--Validating FEE:
insert into courses values(333,'Javascript',1,100); --valid
insert into courses values(444,'TypeScript',1,500); --valid
insert into courses values(555,'VbScript',1,50);    --not valid --> viole la contrainte de vérification « courses_fee_check »
insert into courses values(555,'VbScript',1,600);   --not valid --> viole la contrainte de vérification « courses_fee_check »



--2) Validating students table:

create table students
(sid integer primary key,
sname varchar(20) not null,
age integer check(age between 15 and 30),
doj date default now(),
doc date,
courseid integer,
foreign key(courseid) references courses(courseid) on delete cascade
);

select * from students; 

--Validating sid & sname:
insert into students(sid, sname,age,doc,courseid)values(101,'John',20,null,111);  --valid
insert into students(sid, sname,age,doc,courseid)values(101,'X',20,null,111);     --not vaild -->la valeur d'une clé dupliquée rompt la contrainte unique « students_pkey »
insert into students(sid, sname,age,doc,courseid)values(102,null,20,null,111);    --not valid -->une valeur NULL viole la contrainte NOT NULL de la colonne « sname » dans la relation « students »


--Validating AGE:

insert into students(sid,sname,age,doc,courseid)values(102,'Smith',15,null,111); --valid
insert into students(sid,sname,age,doc,courseid)values(103,'Kim',30,null,111);   --valid
insert into students(sid,sname,age,doc,courseid)values(104,'Kate',10,null,111);  --not valid --> viole la contrainte de vérification « students_age_check »
insert into students(sid,sname,age,doc,courseid)values(105,'Bob',40,null,111);   --not valid --> viole la contrainte de vérification « students_age_check »

--Validating DOJ:

select * from students;


--Validating COURSEID Foreign key(References to courseid of courses table):

--insertion:
insert into students(sid,sname,age,doc,courseid)values(104,'Scott',30,null,222); --valid
insert into students(sid,sname,age,doc,courseid)values(105,'Scott',30,null,555); --not valid -->une instruction insert ou update sur la table « students » viole la contrainte de clé
                                                                                              --étrangère « students_courseid_fkey »

--Deletion:
delete from courses where courseid=222; --successfull 
select * from students;