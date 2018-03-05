--ica11 aggravate Xiao liu 

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
 max(o.OrderDate)                                                --max function as aggravate 
from 
 Employees as e inner join Orders as o 
 on e.EmployeeID=o.EmployeeID
group by 
 e.LastName +', '+e.FirstName 
order by 
  max(o.OrderDate)      
go