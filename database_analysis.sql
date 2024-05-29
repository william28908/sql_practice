-- Where are our customers located? How many customers do we have in each country/state/city?
SELECT country, COUNT(country) FROM customers GROUP BY country ORDER BY COUNT(country) DESC;
SELECT country, state, COUNT(state) FROM customers GROUP BY country, state ORDER BY COUNT(state) DESC;
SELECT country, state, city, COUNT(city) FROM customers GROUP BY country, state, city ORDER BY COUNT(city) DESC;
-- What is the credit limit based on country/state/city?
SELECT country, SUM(creditLimit) FROM customers GROUP BY country ORDER BY SUM(creditLimit) DESC;
SELECT country, state, SUM(creditLimit) FROM customers GROUP BY country, state ORDER BY SUM(creditLimit) DESC;
SELECT country, state, city, SUM(creditLimit) FROM customers GROUP BY country, state, city ORDER BY SUM(creditLimit) DESC;
-- How much of each product was ordered (by product code)?
SELECT productCode, SUM(quantityOrdered) FROM orderdetails GROUP BY productCode ORDER BY SUM(quantityordered) DESC;
-- What is the gross profit of each product (by product code)?
SELECT productCode, (quantityOrdered*priceEach) AS gross_profit FROM orderdetails;
-- What is the status of current orders?
SELECT status, COUNT(status) FROM orders GROUP BY status ORDER BY COUNT(status) DESC;
-- How many orders were placed by each customer?
SELECT customerNumber, COUNT(customerNumber) FROM orders GROUP BY customerNumber ORDER BY COUNT(customerNumber) DESC;
-- How many orders were placed in each date?
SELECT orderDate, COUNT(orderDate) FROM orders GROUP BY orderDate ORDER BY COUNT(orderDate) DESC;
-- How many orders were placed in each date for each customer?
SELECT orderDate, customerNumber, COUNT(customerNumber) FROM orders GROUP BY orderDate, customerNumber ORDER BY COUNT(customerNumber) DESC;
-- What is the status of our orders based on the date?
SELECT shippedDate, status, COUNT(status) FROM orders GROUP BY shippedDate, status ORDER BY COUNT(status) DESC;
-- How much did each customer spend?
SELECT customerNumber, SUM(amount) FROM payments GROUP BY customerNumber ORDER BY SUM(amount) DESC;
-- How much was paid by customers for each day? Create a running total.
SELECT paymentDate, amount, SUM(amount) OVER(ORDER BY paymentDate) FROM payments;
-- What is the expected profit for each item?
SELECT productCode, productName, productLine, (MSRP-buyPrice) AS exp_profit FROM products ORDER BY exp_profit;
-- Where are our employees located based on country/state/city?
SELECT emp.employeeNumber, emp.firstName, emp.lastName, office.country, office.state, office.city FROM employees emp 
INNER JOIN offices office ON emp.officeCode = office.officeCode ORDER BY emp.employeeNumber;
-- How many employees do we have in the U.S.?
SELECT emp.employeeNumber, emp.firstName, emp.lastName, office.country, office.state, office.city FROM employees emp 
INNER JOIN offices office ON emp.officeCode = office.officeCode WHERE office.country = 'USA' ORDER BY emp.employeeNumber;
-- How much did each customer spend in total?
SELECT ord.customerNumber, cust.customerName, SUM(ord_details.quantityOrdered * ord_details.priceEach) 
AS gross_profit FROM orders ord INNER JOIN orderdetails ord_details ON ord.orderNumber
= ord_details.orderNumber INNER JOIN customers cust ON cust.customerNumber = ord.customerNumber 
GROUP BY ord.customerNumber, cust.customerName ORDER BY gross_profit DESC;
-- How many motorcycles/cars/etc. were sold?
SELECT prod.productLine, SUM(ord_details.quantityOrdered * ord_details.priceEach) 
AS gross_profit FROM products prod INNER JOIN orderdetails ord_details ON ord_details.productCode =
prod.productCode GROUP BY prod.productLine ORDER BY gross_profit DESC;
/*
Apply a label to our customers depending on their credit limit. Anything below 25,000
should be labeled as 'low priority,' anything between 25,000 and 100,000 should be
'medium priority,' and anything above 100,000 is 'high priority.'
*/
SELECT customerNumber, customerName, creditLimit,
CASE
	WHEN creditLimit < 25000 THEN 'Low Priority'
    WHEN creditLimit BETWEEN 25000 AND 100000 THEN 'Medium Priority'
    WHEN creditLimit > 100000 THEN 'High Priority'
END AS importance
FROM customers ORDER BY customerNumber; 
/* 
Find how many customers each employee has helped. If the employee has helped
6 or less, they will receieve a 5% bonus. If they helped between 7 and 8 customers, they 
will receieve a 7% bonus. Anything above 8 customers and they will receive a 9% bonus
*/
SELECT *,
CASE
	WHEN numb_of_cust_helped < 7 THEN "5% Bonus"
    WHEN numb_of_cust_helped BETWEEN 7 AND 8 THEN "7% Bonus"
    ELSE "9% Bonus"
END AS bonus
FROM (SELECT emp.employeeNumber, CONCAT(emp.firstName, " ", emp.lastName) AS full_name, 
COUNT(salesRepEmployeeNumber) AS numb_of_cust_helped FROM customers cust INNER JOIN employees emp 
ON cust.salesRepEmployeeNumber = emp.employeeNumber GROUP BY emp.employeeNumber, full_name 
ORDER BY emp.employeeNumber) AS temp;
-- How much did each customer/area pay? 
SELECT cust.customerName, cust.country, payments.amount, SUM(payments.amount) 
OVER (PARTITION BY cust.country ORDER BY payments.customerNumber) FROM customers cust
INNER JOIN payments ON cust.customerNumber = payments.customerNumber