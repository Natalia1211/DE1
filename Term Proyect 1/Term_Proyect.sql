drop schema if exists term_proyect;

create schema term_proyect;

use term_proyect;

-- ------------------------------------------------- --
-- 					1. OPERATIONAL LAYER 			 --
-- ------------------------------------------------- --
-- ------------------------------------------------- --
-- 					1.1. CREATE TABLES 				 --
-- ------------------------------------------------- --
drop table if exists customers;
create table customers(
	ID int not null,
	Customer_ID varchar(50) not null,
	Customer_Name varchar(50) not null,
	Segment varchar(50) not null, 
    primary key (ID));

drop table if exists products;
create table products (
	ID int not null,
	Product_ID varchar(50) not null,
	Product_Name text not null,
	Category varchar(50) not null,
	Subcategory varchar(50) not null,
    primary key(ID)); 
  
drop table if exists orders1;
create table Orders (
	ID int not null,
    Order_ID varchar(50) not null,
	Orde_Date date not null,
	Ship_Date date not null,
    Customer_ID varchar(50) not null,
    Ship_Mode varchar(50) not null,
    Country varchar(50) not null,
    City varchar(50) not null,
    State varchar(50) not null,
    Postal_Code int not null,
    Region varchar(50) not null,
    Product_ID varchar(50) not null,
    Sales double not null,
    Quantity double not null,
    Discount double not null, 
    Profit double not null,
    Returns_ varchar(50) not null,
    primary key(ID)); 

-- ----------------------------------------------------- -- 
-- 					1.2. LOAD INFORMATION				 --
-- ----------------------------------------------------- --
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
into table orders
FIELDS TERMINATED BY ',' 
lines TERMINATED BY '\r\n' 
IGNORE 1 rows;

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customers.csv'
into table customers
FIELDS TERMINATED BY ',' 
lines TERMINATED BY '\r\n' 
IGNORE 1 rows;

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products1.csv'
into table products
character set latin1
FIELDS TERMINATED BY ',' 
lines TERMINATED BY '\r\n' 
IGNORE 1 rows;

		-- 1.3. ADD FOREIGN KEY--
alter table products 
add index idx_Products (Product_ID);

alter table customers
add index idx_Customers (Customer_ID);

alter table orders
add index idx_Products (Product_ID),
add index idx_Customer (Customer_ID);

-- --------------------------------------------------------- --
-- 		1.4. STABLISH RELATIONSHIPS BETWEEN TABLES			 --
-- --------------------------------------------------------- --
alter table orders
Add constraint FK_Customer
foreign key (Customer_ID)
references customers(Customer_ID)
on delete restrict
on update cascade;

drop table if exists Orders_products;

create table Orders_products (
  product_ID varchar(50) not null,
  primary key (product_ID),
  index idx_Products (product_ID),
  constraint fk_products1
    foreign key (Product_ID)
    references products(Product_ID)
    on update cascade
    on delete restrict,
  constraint fk_orders
    foreign key (Product_ID)
    references orders (Product_ID)
	on delete restrict
    on update cascade);

-- -------------------------------------------- --
-- 				2. ANALYTICAL LAYER             --
-- -------------------------------------------- --
-- -------------------------------------------- --
-- 			2.1. CREATION OF DATAWAREHOUSE      --
-- -------------------------------------------- --
drop procedure if exists Store_DWH;

delimiter $$

create procedure Store_DWH()
begin

	drop table if exists Data_Warehouse;
	Create table Data_Warehouse as
	select
		orders.Order_ID as Order_ID,
		round(orders.Sales, 2) as Sales,
        round(orders.Quantity, 2) as Quantity,
        round(orders.Profit, 2) as Profit,
		year(orders.Orde_Date) as Order_Year,
        month(orders.Orde_Date) as Order_Month,
        orders.Product_ID as Product_ID,
        products.Product_Name as Product_Name,
        products.Category as Category,
        products.Subcategory as Subcategory,
        customers.Customer_ID as Customer_ID,
        customers.Customer_Name as Customer_Name,
        customers.Segment as Segment,
        orders.Region as Region,
        orders.State as State
        from orders
        inner join products
        using (Product_ID)
        inner join customers
        using (Customer_ID);
          
        alter table data_warehouse 
		add column ID int not null auto_increment,
		Add primary key (ID);
        
end $$

delimiter ;

call Store_DWH();

-- ------------------------------------- --
-- 				3. DATA MARTS            --
-- ------------------------------------- --
-- ------------------------------------- --
-- 				3.1. CATEGORY			 --
-- ------------------------------------- --

drop procedure if exists category;

delimiter $$

create procedure category(
	in x int,
    in m int)

begin
declare y int;
set y = x-1;
	with table1 as(
		select
		Category, 
		sum(case when order_year = (x) and order_month = (m) then sales else 0 end) as sales,
		sum(case when order_year = (y) and order_month = (m) then sales else 0 end) as ly_sales,
		sum(case when order_year = (x) and order_month = (m) then quantity else 0 end) as quantity,
		sum(case when order_year = (y) and order_month = (m) then quantity else 0 end) as ly_quantity,
		sum(case when order_year = (x) and order_month = (m) then profit else 0 end) as profit,
		sum(case when order_year = (y) and order_month = (m) then profit else 0 end) as ly_profit
		FROM data_warehouse group by category			
	)

select
	category,
	round(sales, 2) as sales,
	round(((sales/ly_sales)-1), 2) as Var_Sales,
	round(quantity, 2) as quantity,
	round(((quantity/ly_quantity)-1), 2) as Var_quantity,
	round(profit, 2) as profit,
	round(((profit/ly_profit)-1), 2) as Var_profit
	from table1
    group by category
    order by sales desc;
end $$

delimiter ;

call category(2017, 1);

-- ------------------------------------ --
-- 			3.2. SUBCATEGORY 			--
-- ------------------------------------ --
drop procedure if exists subcategory;
delimiter $$
create procedure subcategory(
	in x int,
    in m int,
    in c varchar(50))
begin
	declare y int;
    set y = x-1;
    
	with table2 as(
		select
		subcategory, 
		sum(case when order_year = (x) and order_month = (m) then sales else 0 end) as sales,
		sum(case when order_year = (y) and order_month = (m) then sales else 0 end) as ly_sales,
		sum(case when order_year = (x) and order_month = (m) then quantity else 0 end) as quantity,
		sum(case when order_year = (y) and order_month = (m) then quantity else 0 end) as ly_quantity,
		sum(case when order_year = (x) and order_month = (m) then profit else 0 end) as profit,
		sum(case when order_year = (y) and order_month = (m) then profit else 0 end) as ly_profit
		FROM data_warehouse 
			where category = c
			group by subcategory
	)
    
	select
	subcategory,
	round(sales, 2) as sales,
	round(((sales/ly_sales)-1), 2) as Var_Sales,
	round(quantity, 2) as quantity,
	round(((quantity/ly_quantity)-1), 2) as Var_quantity,
	round(profit, 2) as profit,
	round(((profit/ly_profit)-1), 2) as Var_profit
	from table2
		group by subcategory
        order by sales desc; 
 
end$$

delimiter ;

call subcategory(2017, 1, 'furniture');

-- ------------------------------------ --
-- 			3.3. TOP PRODUCTS 			--
-- ------------------------------------ --
drop procedure if exists Top_Products;
delimiter $$
create procedure Top_Products(
	in x int,
    in m int,
    in s varchar(50),
    in l int)
begin
	declare y int;
    declare n int;
    set y = x-1;
	with table3 as(
		select
		Product_Name, 
		sum(case when order_year = (x) and order_month = (m) then sales else 0 end) as sales,
		sum(case when order_year = (y) and order_month = (m) then sales else 0 end) as ly_sales,
		sum(case when order_year = (x) and order_month = (m) then quantity else 0 end) as quantity,
		sum(case when order_year = (y) and order_month = (m) then quantity else 0 end) as ly_quantity,
		sum(case when order_year = (x) and order_month = (m) then profit else 0 end) as profit,
		sum(case when order_year = (y) and order_month = (m) then profit else 0 end) as ly_profit
		FROM data_warehouse 
			where subcategory = s
			group by Product_Name
	)
    
	select
	Product_Name,
	round(sales, 2) as sales,
	round(((sales/ly_sales)-1), 2) as Var_Sales,
	round(quantity, 2) as quantity,
	round(((quantity/ly_quantity)-1), 2) as Var_quantity,
	round(profit, 2) as profit,
	round(((profit/ly_profit)-1), 2) as Var_profit
	from table3 where sales > 0
		group by Product_Name
        order by sales desc
        limit l; 
 
end$$

delimiter ;
		
call  Top_Products(2017, 1, 'bookcases', 5);

-- -------------------------------- --
-- 			3.4. REGIONS 			--
-- -------------------------------- --        
drop procedure if exists Regions;

delimiter $$

create procedure Regions (
		in x int,
        in m int)

begin
declare y int;
set y = x-1;

	with table4 as( select
		region,
		sum(case when order_year = (x) and order_month = (m) then sales else 0 end) as sales,
		sum(case when order_year = (y) and order_month = (m) then sales else 0 end) as ly_sales,
		sum(case when order_year = (x) and order_month = (m) then quantity else 0 end) as quantity,
		sum(case when order_year = (y) and order_month = (m) then quantity else 0 end) as ly_quantity,
		sum(case when order_year = (x) and order_month = (m) then profit else 0 end) as profit,
		sum(case when order_year = (y) and order_month = (m) then profit else 0 end) as ly_profit
		FROM data_warehouse 
        group by region)
	
    select
    region,
    round(sales, 2) as sales,
	round(((sales/ly_sales)-1), 2) as Var_Sales,
	round(quantity, 2) as quantity,
	round(((quantity/ly_quantity)-1), 2) as Var_quantity,
	round(profit, 2) as profit,
	round(((profit/ly_profit)-1), 2) as Var_profit
    from table4
    group by region
    order by sales desc;

end $$

Call Regions(2017,2);

-- -------------------------------- --
-- 			3.5. STATES 			--
--									--
drop procedure if exists states;
delimiter $$

create procedure states(
	in x int,
    in m int,
    in r varchar(50))
begin
	declare y int;
    set y = x-1;
    
	with table5 as(
		select
		state, 
		sum(case when order_year = (x) and order_month = (m) then sales else 0 end) as sales,
		sum(case when order_year = (y) and order_month = (m) then sales else 0 end) as ly_sales,
		sum(case when order_year = (x) and order_month = (m) then quantity else 0 end) as quantity,
		sum(case when order_year = (y) and order_month = (m) then quantity else 0 end) as ly_quantity,
		sum(case when order_year = (x) and order_month = (m) then profit else 0 end) as profit,
		sum(case when order_year = (y) and order_month = (m) then profit else 0 end) as ly_profit
		FROM data_warehouse 
			where region = r
			group by state
	)
    
	select
	state,
	round(sales, 2) as sales,
	round(((sales/ly_sales)-1), 2) as Var_Sales,
	round(quantity, 2) as quantity,
	round(((quantity/ly_quantity)-1), 2) as Var_quantity,
	round(profit, 2) as profit,
	round(((profit/ly_profit)-1), 2) as Var_profit
	from table5
		group by state
        order by sales desc; 
 
end$$

delimiter ;

call states(2017, 1, 'west');

-- -------------------------------- --
-- 			3.6. SEGMENTS 			--
-- -------------------------------- --
drop procedure if exists segment;

delimiter $$

create procedure segment (
		in x int,
        in m int)

begin
declare y int;
set y = x-1;

	with table6 as( select
		segment,
		sum(case when order_year = (x) and order_month = (m) then sales else 0 end) as sales,
		sum(case when order_year = (y) and order_month = (m) then sales else 0 end) as ly_sales,
		sum(case when order_year = (x) and order_month = (m) then quantity else 0 end) as quantity,
		sum(case when order_year = (y) and order_month = (m) then quantity else 0 end) as ly_quantity,
		sum(case when order_year = (x) and order_month = (m) then profit else 0 end) as profit,
		sum(case when order_year = (y) and order_month = (m) then profit else 0 end) as ly_profit
		FROM data_warehouse 
        group by segment)
	
    select
    segment,
    round(sales, 2) as sales,
	round(((sales/ly_sales)-1), 2) as Var_Sales,
	round(quantity, 2) as quantity,
	round(((quantity/ly_quantity)-1), 2) as Var_quantity,
	round(profit, 2) as profit,
	round(((profit/ly_profit)-1), 2) as Var_profit
    from table6
    group by segment
    order by sales desc;

end $$

Call segment(2017,1);
-- ----------------------------- --
-- 			3.7. CUSTOMERS		 --
-- ----------------------------- --
drop procedure if exists Customers;
delimiter $$
create procedure Customers(
	in x int,
    in m int,
    in r varchar(50)
    )
begin
	declare y int;
    declare n int;
    set y = x-1;
	with table7 as(
		select
		Customer_Name, 
		sum(case when order_year = (x) and order_month = (m) then sales else 0 end) as sales,
		sum(case when order_year = (y) and order_month = (m) then sales else 0 end) as ly_sales,
		sum(case when order_year = (x) and order_month = (m) then quantity else 0 end) as quantity,
		sum(case when order_year = (y) and order_month = (m) then quantity else 0 end) as ly_quantity,
		sum(case when order_year = (x) and order_month = (m) then profit else 0 end) as profit,
		sum(case when order_year = (y) and order_month = (m) then profit else 0 end) as ly_profit
		FROM data_warehouse 
			where region = r
			group by Customer_Name
	)
    
	select
	Customer_Name,
	round(sales, 2) as sales,
	round(((sales/ly_sales)-1), 2) as Var_Sales,
	round(quantity, 2) as quantity,
	round(((quantity/ly_quantity)-1), 2) as Var_quantity,
	round(profit, 2) as profit,
	round(((profit/ly_profit)-1), 2) as Var_profit
	from table7 where sales > 0
		group by Customer_Name
        order by sales desc; 
 
end$$

delimiter ;

Call customers(2017, 1, 'west');





