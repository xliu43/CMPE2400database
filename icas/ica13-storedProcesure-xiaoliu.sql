 

--q1
if exists ( select * from sysobjects where name = 'ica13_01' )
drop procedure ica13_01
go
create procedure ica13_01
as 
		select 
		e.LastName+' , '+ e.FirstName as 'Name',
		count(o.OrderID) as 'Num Orders'                                       --count the rows specified by the field name 
		from 
		 NorthwindTraders.dbo.Employees as e inner join NorthwindTraders.dbo.Orders as o
		 on e.EmployeeID=o.EmployeeID
		group by 
		 e.LastName+' , '+ e.FirstName                                         -- can not use alias for group by 
		order by 
		 'Num Orders' desc

		go
exec ica13_01 
go
go


--q2

if exists ( select * from sysobjects where name = 'ica13_02' )
drop procedure ica13_02
go
create procedure ica13_02
as
		select 
		 e.LastName+', '+e.FirstName as 'Name',
		 Convert(money,sum(od.UnitPrice*od.Quantity)) as'Sales Total',
		 Count(od.OrderID) as 'Detail Items'
		from 
		 NorthwindTraders.dbo.[Order Details] as od inner join NorthwindTraders.dbo.Orders as o
		 on od.OrderID=o.OrderID
		 right outer join NorthwindTraders.dbo.Employees as e 
		 on e.EmployeeID=o.EmployeeID
		group by  e.LastName+', '+e.FirstName
		order by sum(od.UnitPrice*od.Quantity) desc
		go 
exec ica13_02 
go

go

--q3
if exists ( select * from sysobjects where name = 'ica13_03' )
drop procedure ica13_03
go



go



