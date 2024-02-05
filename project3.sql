-- 1.	Create DataBase BANK and Write SQL query to create above schema with constraints

create database BANK1 ;
use bank1;

-- 2.	Inserting Records into created tables
/*Branch
Branch_no	Name
1		Delhi
2		Mumbai
Customer
custid	fname	mname	lname	occupation	dob
1	Ramesh	Chandra	Sharma	Service		1976-12-06
2	Avinash	Sunder	Minha	Business		1974-10-16
Account
acnumber	custid	bid	curbal	opnDT	atype	astatus
1	1	1	10000	2012-12-15	Saving	Active
2	2	2	5000	2012-06-12	Saving	Active
Employee
Emp_no	Branch_no	Fname	Mname	Lname	Dept	Desig		Mngr_no
1	1		Mark	steve	Lara	Account	Accountant	2
2	2		Bella	James	Ronald	Loan	Manager		1
*/

create table Branch(
Branch_no int ,
Name varchar(20));

insert into Branch values(1,'Delhi'),(2,'Mumbai');

create table Customer(
custid int,
fname varchar(20),
mname varchar(20),
lname varchar(20),
occupation varchar(20),
dob date);

insert into Customer values (1,'Ramesh','Chandra','Sharma','Service','1976-12-06'),
(2,'Avinash','Sunder','Minha','Business','1974-10-16');

create table Account(
acnumber int,
custid int,
bid int,
curbal int,
opnDT date,
atype varchar(20),
astatus varchar(20));
insert into Account values(1,1,1,10000,'2012-12-15','Saving','Active'),(2,2,2,5000,'2012-06-12','Saving','Active');

create table Employee(
Emp_no int,
Branch_no int,
Fname varchar(20),
Mname varchar(20),
Lname varchar(20),
Dept varchar(20),
Desig varchar(20),
Mngr_no int);
insert into Employee values(1,1,'Mark','steve','Lara','Account','Accountant',2),(2,2,'Bella','James','Ronald','Loan','Manager',1);

-- 3.	Select unique occupation from customer table

select distinct occupation from customer;

-- 4.	Sort accounts according to current balance 

select *
from account
order by curbal;

-- 5.	Find the Date of Birth of customer name ‘Ramesh’

select dob from customer where fname='Ramesh';

-- 6.	Add column city to branch table 

alter table branch add city varchar(20); 

-- 7.	Update the mname and lname of employee ‘Bella’ and set to ‘Karan’, ‘Singh’ 

update employee set Mname='Karan',Lname='Singh' where Fname='Bella';

-- 8.	Select accounts opened between '2012-07-01' AND '2013-01-01'

select * from account where opnDT between '2012-07-01' AND '2013-01-01';

-- 9.	List the names of customers having ‘a’ as the second letter in their names 

select concat(fname,' ',mname,' ',lname) name from customer where fname like '_a%';

-- 10.	Find the lowest balance from customer and account table

select * from customer where custid = (
select  custid from account
where curbal in (select min(curbal)
from account) );

-- 11.	Give the count of customer for each occupation

select occupation,count(custid)
from customer
group by 1;

-- 12.	Write a query to find the name (first_name, last_name) of the employees who are managers.

select concat(m.fname,' ',m.lname) name 
from employee e join employee m
on e.Mngr_no=m.Emp_no;

-- 13.	List name of all employees whose name ends with a

select * from employee where Fname like '%a';

-- 14.	Select the details of the employee who work either for department ‘loan’ or ‘credit’

select * from employee where Dept in ('loan','credit');

-- 15.	Write a query to display the customer number, customer firstname, account number for the 

select custid,(select fname from customer where custid = a.custid)  as cust_name ,acnumber from account a;

-- 16.	Write a query to display the customer’s number, customer’s firstname, branch id and balance amount for people using JOIN.

select acnumber,fname,bid,curbal from account a join customer c on a.custid=c.custid;

-- 17.	Create a virtual table to store the customers who are having the accounts in the same city as they live

select * from customer;

/* 18.	A. Create a transaction table with following details 
TID – transaction ID – Primary key with autoincrement 
Custid – customer id (reference from customer table
account no – acoount number (references account table)
bid – Branch id – references branch table
amount – amount in numbers
type – type of transaction (Withdraw or deposit)
DOT -  date of transaction

a. Write trigger to update balance in account table on Deposit or Withdraw in transaction table
b. Insert values in transaction table to show trigger success*/

create table transt (
TID int AUTO_INCREMENT primary key,
custid int,
acc_no int,
bid INT,
amount int,
type varchar(20),
DOT date,
foreign key(custid) REFERENCES customers(cust_no),
foreign key (acc_no) references accounts(acc_no),
foreign key (bid) REFERENCES branch(branch_no));

create trigger blc_update 
after insert on transt for each row
update accounts set curbal = curbal + new.amount 
where acc_no = new.acc_no ;

insert into transt(custid, acc_no, bid, amount, type, DOT) values
(1,1,2,500,'savings',current_date());

-- 19.	Write a query to display the details of customer with second highest balance 

select * from (
select *,dense_rank() over(order by curbal desc ) rk from accounts) t
where rk =  2;

-- 20.	Take backup of the databse created in this case study

use casestudy;

/*

1. Display the product details as per the following criteria and sort them in descending order of category:
   #a.  If the category is 2050, increase the price by 2000
   #b.  If the category is 2051, increase the price by 500
   #c.  If the category is 2052, increase the price by 600

*/

select 
product_id ,product_desc,product_class_code,product_price,
case when product_class_code =2050 then product_price + 2000
when product_class_code =2051 then product_price + 500
when product_class_code =2052 then product_price + 600
else product_price
end as new_price
from product
order  by product_class_code desc;

-- 2. List the product description, class description and price of all products which are shipped. 

select product_desc,product_class_desc,product_price
from product p
join product_class pc
on p.product_class_code= pc.product_class_code where product_id in (
select distinct product_id from order_items where order_id in ( 
select order_id from order_header where order_status = 'Shipped'));


/*
. Show inventory status of products as below as per their available quantity:
#a. For Electronics and Computer categories, if available quantity is < 10, show 'Low stock', 11 < qty < 30, show 'In stock', > 31, show 'Enough stock'
#b. For Stationery and Clothes categories, if qty < 20, show 'Low stock', 21 < qty < 80, show 'In stock', > 81, show 'Enough stock'
#c. Rest of the categories, if qty < 15 – 'Low Stock', 16 < qty < 50 – 'In Stock', > 51 – 'Enough stock'
#For all categories, if available quantity is 0, show 'Out of stock'.

*/
select 
	product_desc,
    product_quantity_avail,
    product_class_desc,
    case 
		when product_class_desc in ('Electronics','Computer') then (case  when product_quantity_avail <= 10 then 'low stock'
															        when product_quantity_avail  between 11 and 30 then 'in stock'
                                                                     when product_quantity_avail > 30 then 'enough stock' end)
		when product_class_desc in ('Stationery','Clothing') then  (case  when product_quantity_avail <= 20 then 'low stock'
															        when product_quantity_avail  between 21 and 80 then 'in stock'
                                                                     when product_quantity_avail > 80 then 'enough stock' end )
	else 															(case  when product_quantity_avail <= 15 then 'low stock'
															        when product_quantity_avail  between 16 and 50 then 'in stock'
                                                                     when product_quantity_avail > 50 then 'enough stock' end)
 
		end as Inventory_status
 from product p
 join product_class pc
 on p.product_class_code = pc.product_class_code;





-- 4. List customers from outside Karnataka who haven’t bought any toys or books

select distinct oc.* from address a join online_customer oc
on a.address_id=oc.address_id
join order_header oh
on oh.customer_id=oc.customer_id
join order_items oi
on oi.order_id=oh.order_id
join product p
on p.product_id=oi.product_id
join product_class pc
on pc.product_class_code=p.product_class_code
where a.state not like 'karnataka'
and product_class_desc not in ('toys','books');