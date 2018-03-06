--ica11 aggravate Xiao liu 

/*
technique for aggravate functions 
select all reletive fields and join tables first 
and then using aggravate fucntions to specifc selected field
group by the rest field 

be carefull when using avg and coalesce together as if the null value 
is consider as 0 the number of rows to divide will increase one. 
so better to Coalesce(Avg())  
*/

--q1
select 
e.LastName+' , '+ e.FirstName as 'Name',
count(o.OrderID) as 'Num Orders'                                       --count the rows specified by the field name 
from 
 Employees as e inner join Orders as o
 on e.EmployeeID=o.EmployeeID
group by 
 e.LastName+' , '+ e.FirstName                                         -- can not use alias for group by 
order by 
 'Num Orders' desc
go 

--q2
select 
 e.LastName +', '+e.FirstName as 'Name',
 Avg(o.Freight) as 'Average Freight',                                                 
 Convert(varchar(20),max(o.OrderDate),106) as 'Newest Order Date'                                              --max function as aggravate 
from 
 Employees as e inner join Orders as o 
 on e.EmployeeID=o.EmployeeID
group by 
 e.LastName +', '+e.FirstName 
order by 
  max(o.OrderDate)      
go

--q3
select 
s.CompanyName as 'Supplier',
s.Country as'Country',
Count(p.ProductID) as 'Num Products', 
Avg(p.UnitPrice) as 'Avg Price'
from 
 Suppliers as s left outer join Products as p
 on s.SupplierID=p.SupplierID
where 
 s.CompanyName like '[H,U,R,T]%'
group by s.CompanyName,s.Country                                   --group by the fields not having aggravate functions 
order by Count(p.ProductID) 
go

--q4
declare @country varchar(3)='USA'
select 
 s.CompanyName as 'Supplier',
 s.Country as 'Country',
 coalesce( min(p.UnitPrice),0)as' Min Price',
 coalesce(max(p.UnitPrice),0) as 'Max Price'
from 
 Suppliers as s left outer join Products as p 
 on s.SupplierID=p.SupplierID
where s.Country=@country
group by s.CompanyName,s.Country
order by coalesce( min(p.UnitPrice),0)
go


--q5
select                                                              --notice how to inner join and then right outer join (A+B)+*C to get all null values  
 c.CompanyName as'Customer',
 c.City as 'City',
 Convert(varchar(20),o.OrderDate,106) as 'Order Date',
 Count(od.ProductID) as 'Products in Order'
from 
 orders as o inner join [Order Details] as od
 on o.OrderID=od.OrderID
 right outer join Customers as c 
 on c.CustomerID=o.CustomerID
where 
 c.City='Walla Walla' or 
 c.Country ='Poland'
 group by c.CompanyName, c.City,o.OrderDate
 order by  count(od.ProductID)
go

/*
--demo                                                                                   --notice if lefter outer join first the null nvalue is excluded because when passing null value to inner join the whole row is excluded
select 
 c.CompanyName as'Customer',
 c.City as 'City',
 Convert(varchar(20),o.OrderDate,106) as 'Order Date',
 Count(od.ProductID) as 'Products in Order'
from 
  Customers as c left outer join Orders as o 
  on c.CustomerID=o.CustomerID
  inner join [Order Details] as od
  on od.OrderID=o.OrderID
where 
 c.City='Walla Walla' or 
 c.Country ='Poland'
 group by c.CompanyName, c.City,o.OrderDate
 order by  count(od.ProductID)
go 
*/

--q6
select 
 e.LastName+', '+e.FirstName as 'Name',
 Convert(money,sum(od.UnitPrice*od.Quantity)) as'Sales Total',
 Count(od.OrderID) as 'Detail Items'
from 
 [Order Details] as od inner join Orders as o
 on od.OrderID=o.OrderID
 right outer join Employees as e 
 on e.EmployeeID=o.EmployeeID
group by  e.LastName+', '+e.FirstName
order by sum(od.UnitPrice*od.Quantity) desc
go 