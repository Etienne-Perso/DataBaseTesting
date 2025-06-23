--SP1:
show procedure status where db='ClassicModels';
show procedure status where name='SelectAllCustomers';

--SP2:
call SelectAllCustomers(); 
select * from customers;

--SP3:
call SelectAllCustomersByCity('San Francisco'); 
select * from customers where city='San Francisco';

--SP4:
call SelectAllCustomersByCityAndPin('San Francisco', '94217');
select * from customers where city='San Francisco' and postalcode='94217';


--SP5:
call get-order_by_cust(129,@shipped,@canceled,@resolved,@disputed);
select @shipped,@canceled,@resolved,@disputed;

select
(select count(*) as 'shipped' from orders where customerNumber=129 and status='Shipped') as Shipped,          
(select count(*) as 'canceled' from orders where customerNumber=129 and status='Canceled') as Canceled,         
(select count(*) as 'resolved' from orders where customerNumber=129 and status='Resolved') as Resolved,           
(select count(*) as 'disputed' from orders where customerNumber=129 and status='Disputed') as Disputed;


--SP6:
call GetCustomerShipping(129, @shipping as ShippingTime;
call GetCustomerShipping(260, @shipping as ShippingTime;
call GetCustomerShipping(103, @shipping as ShippingTime;

select country, 
case
	when Country='USA' then '2-days shipping'
	when Country='Canada' then '3-days shipping'
	else '5-days shipping'
end as ShippingTime from customers where customerNumber=103;