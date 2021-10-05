 -- Exercise 3 --
use classicmodels;
select
t2.lastName, t2.firstName, t3.orderDate
from customers t1
inner join employees t2
on t1.salesRepEmployeeNumber = t2.employeeNumber
inner join orders t3
on t1.customerNumber = t3.customerNumber;

SELECT 
    CONCAT(m.lastName, ', ', m.firstName) AS Manager,
    CONCAT(e.lastName, ', ', e.firstName) AS 'Direct report'
FROM
    employees e
INNER JOIN employees m ON 
    m.employeeNumber = e.reportsTo
ORDER BY 
    Manager;
-- exercise 4 ----Because the president does not report to anyone on the table so the column reportsTo is empty--
select
c.customerNumber,
customerName,
orderNumber,
status
from
customers c
left join orders o
on c.customerNumber = o.customerNumber;	

select 
o.orderNumber,
customerNumber,
productCode
from orders o
left join orderdetails
	using(orderNumber)
where orderNumber =10123;

SELECT 
    o.orderNumber, 
    customerNumber, 
    productCode
FROM
    orders o
LEFT JOIN orderDetails d 
    ON o.orderNumber = d.orderNumber AND 
       o.orderNumber = 10123;
 --Homework--
 
select
o.orderNumber,
d.priceEach,
d.quantityOrdered,
p.productName,
p.productLine,
c.city,
c.country,
o.orderDate
from orders o
inner join orderdetails d
on o.orderNumber = d.orderNumber
inner join products p
on d.productCode = p.productCode
inner join customers c
on o.customerNumber = c.customerNumber;
