Create database Transactions_Project;
#Step-1 : Imported the Customer Purchase data into the database. Will use this data for normalization.
#Step-2 The date column is in text format, so altering the data format there.
SET SQL_SAFE_UPDATES=0;
Use Transactions_Project;
update customer_purchase_data  set PurchaseDate =  str_to_date(PurchaseDate, '%Y-%m-%d');
ALTER TABLE customer_purchase_data MODIFY COLUMN PurchaseDate DATE;

#Creating the customers table (Normalization Step-1)
#In each of the normalizations we have given a unique key to products, categories and customers by ourself as they were not unique in raw data.
# Assuming that same name customer can make multiple transactions. 
Create Table Customers as
with cte as (Select distinct(Customername) as Customer_Name from customer_purchase_data)
Select row_number() over (Order by Customer_Name) as Customer_ID,Customer_Name from cte;

Select * from Customers;
#Creating the Products table (Normalization step-2)
Create Table Products as
with cte as (Select distinct(Productname) as Product_Name from customer_purchase_data)
Select row_number() over (Order by Product_Name)+1000 as Product_ID,Product_Name from cte;

Select * from products;

#Creating the categories table (Normalization-Step3)
Create Table Categories as
with cte as (Select distinct(ProductCategory) as Category_Name from customer_purchase_data)
Select row_number() over (Order by Category_Name)+5000 as Category_ID,Category_Name from cte;

Select * from Categories;


# Creating the transactions table (Normalization step-4)
Create table transactions as 
Select c.TransactionID as Transaction_ID, d.Customer_ID as Customer_ID, e.Product_ID as Product_ID,
f.Category_ID as Category_ID,c.PurchaseQuantity as Purchase_Quantity,c.PurchasePrice as Purchase_Price,
c.PurchaseDate as Purchase_Date,c.Country as Country
From customer_purchase_data c join Customers d on c.CustomerName=d.Customer_Name Join Products e on c.ProductName=e.Product_Name Join Categories f on c.ProductCategory=f.Category_Name

Select * from transactions;
#Adding constraints-
alter table Customers
ADD Primary key (Customer_ID);

alter table Products
ADD Primary key (Product_ID);

alter table Categories
ADD Primary key (Category_ID);

Alter table transactions
add primary key (Transaction_ID);

Alter table transactions
add foreign key(Customer_ID) references customers(Customer_ID);

Alter table transactions
add foreign key(Product_ID) references Products(Product_ID);

Alter table transactions
add foreign key(Category_ID) references Categories(Category_ID);

# Checking null values
select * from transactions where Customer_ID is null;
select * from transactions where Product_ID is null;
select * from transactions where Category_ID is null;
select * from transactions where Transaction_ID is null;
select * from transactions where Country is null;
select * from transactions where Purchase_Quantity is null;
select * from transactions where Purchase_Price is null;
select * from transactions where Purchase_Date is null;
Select * from Customers where Customer_ID is null;
Select * from Customers where Customer_Name is null;

Select * from Products where Product_ID is null;
Select * from Products where Product_Name is null;

Select * from Categories where Category_ID is null;
Select * from Categories where Category_Name is null;

# Analysis using SQL-
# What is the total revenue?
Select sum(Purchase_Price) from transactions;

#What is the total quantity sold
Select sum(Purchase_Quantity) from transactions;

#Country wise quantity sold:
Select Country,sum(Purchase_Quantity) as Total_Quantity from transactions Group by 1 Order by 2 desc;

# Country wise revenue:
Select Country,round(sum(Purchase_Price),2) as Total_Revenue from transactions Group by 1 Order by 2 desc;

#Top 10 most sold products:
Select Products.Product_Name,sum(Transactions.Purchase_Quantity) as Total_Quantity 
from Transactions Join Products on Transactions.Product_ID=Products.Product_ID
Group by 1
Order by 2 desc
Limit 10;

# Top 10 products by revenue:
Select Products.Product_Name,round(sum(Transactions.Purchase_Price),2) as Total_Revenue 
from Transactions Join Products on Transactions.Product_ID=Products.Product_ID
Group by 1
Order by 2 desc
Limit 10;

#Category wise revenue:
Select Categories.Category_Name,round(sum(Transactions.Purchase_Price),2) as Total_Revenue 
from Transactions Join Categories on Transactions.Category_ID=Categories.Category_ID
Group by 1
Order by 2 desc

# Category wise quantity:
Select Categories.Category_Name,round(sum(Transactions.Purchase_Quantity),2) as Total_Quantity
from Transactions Join Categories on Transactions.Category_ID=Categories.Category_ID
Group by 1
Order by 2 desc

#Year wise revenue:
Select year(Purchase_Date) as Year_sale,Sum(Purchase_Price) as total_revenue
From transactions
Group by 1

#Year Wise, month wise sales
Select year(Purchase_Date) as Year_sale,Month(Purchase_Date) as mnth,round(Sum(Purchase_Price),2) as total_revenue
From transactions
Group by 1,2
Order by 3 desc;

# Year wise quarter wise sales:
#Year Wise, month wise sales
Select year(Purchase_Date) as Year_sale,Quarter(Purchase_Date) as mnth,round(Sum(Purchase_Price),2) as total_revenue
From transactions
Group by 1,2
Order by 3 desc;

#Top 10 customers in terms of purchase_price
Select Customers.Customer_Name,round(sum(Transactions.Purchase_Price),2) as Total_Revenue 
from Transactions Join Customers on Transactions.Customer_ID=Customers.Customer_ID
Group by 1
Order by 2 desc
Limit 10;

#Top 10 customers in terms of purchase_quantity
Select Customers.Customer_Name,round(sum(Transactions.Purchase_Quantity),2) as Total_Quantity
from Transactions Join Customers on Transactions.Customer_ID=Customers.Customer_ID
Group by 1
Order by 2 desc
Limit 10;

# Year wise percentage of transactions:
Select year(Purchase_Date) as Year_sale,(count(Customer_ID)/1000)*100 as percentage_of_customers
From transactions
Group by 1
Order by 2

#Average value of a transaction-
Select Avg(Purchase_Price) as average_transaction_amt From Transactions;

#Country wise average sales:
Select Country,round(avg(Purchase_Price),2) as Avg_Sales from transactions Group by 1 Order by 2 desc;

#Category wise average sales:
Select Categories.Category_Name,round(avg(Transactions.Purchase_Price),2) as average_sales
from Transactions Join Categories on Transactions.Category_ID=Categories.Category_ID
Group by 1
Order by 2 desc