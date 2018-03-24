--ica13_store procedure Xiao liu 

--q1
if exists ( select * from sysobjects where name = 'ica13_01' )          -- put on the cheat sheet just in case 
drop procedure ica13_01
go

create procedure ica13_01 
as 
   select
    e.LastName+', '+e.FirstName as 'Name',
	count(o.OrderID) as 'Num Orders'
	from NorthwindTraders.dbo.Employees as e 
	 inner join NorthwindTraders.dbo.Orders as o
	 on e.EmployeeID=o.EmployeeID
	group by 
	 e.LastName,
	 e.FirstName
	order by 
	 count(o.OrderID) desc
go 

exec ica13_01 
go 
go


--q2
if exists ( select * from sysobjects where name = 'ica13_02' )          -- put on the cheat sheet just in case 
drop procedure ica13_02
go

create procedure ica13_02
as 
  select 
   e.LastName+','+e.FirstName as 'Name',
   Convert(money,sum(od.UnitPrice*od.Quantity)) as 'Sales Total',
   Count(od.OrderID) as 'Detail Items'
  from 
    NorthwindTraders.dbo.[Order Details] as od
	inner join NorthwindTraders.dbo.Orders as o 
	on od.OrderID=o.OrderID
	right outer join NorthwindTraders.dbo.Employees as e
	on e.EmployeeID= o.EmployeeID
  group by 
    e.LastName,e.FirstName
  order by 
    sum(od.UnitPrice*od.Quantity) desc  
  
go

exec ica13_02
go 
go


--q3
if exists ( select * from sysobjects where name = 'ica13_03' )          -- put on the cheat sheet just in case 
drop procedure ica13_03
go

create procedure ica13_03
@maxPrice money =null                           --remember how parameter is decalred
as 


select 
    CompanyName as 'Company name',
	Country as 'Country'
from 
   NorthwindTraders.dbo.Customers
where CustomerID in(
			select 
			CustomerID
			from 
		    NorthwindTraders.dbo.Orders	
			where 
			OrderID in (
				select
				OrderID
				from
				NorthwindTraders.dbo.[Order Details]
				where
				UnitPrice*Quantity<@maxPrice
)
)
order by 
Country
go 

--exec ica13_03 default
--exec ica13_03 15
--exec ica13_03 @maxPrice=15
declare @myParam money=15
exec ica13_03 @maxPrice=@myParam              --notice the operator order, interpred as associate @maxPrice with @myParam
 go 
 go 


 --q4
 if exists ( select * from sysobjects where name = 'ica13_04' )          -- put on the cheat sheet just in case 
drop procedure ica13_04
go
create procedure ica13_04
@minPrice money=null,
@categoryName nvarchar(max)=''                           --be careful when decalre variables have to decaclre max or # of chars 

as 
 
	select 
	ProductName as 'ProductName'
	from 
    NorthwindTraders.dbo.Products as outty
	where 
	UnitPrice>@minPrice and 
	exists(
		select 
		*
		from 
	    NorthwindTraders.dbo.Categories as inny
		where 
		CategoryName in (@categoryName) and 
		(outty.CategoryID=inny.CategoryID)
		)
	order by CategoryID, ProductName
go
exec ica13_04 @minPrice=20,@categoryName=N'confections'
go 
 go 


 --q5
 if exists ( select * from sysobjects where name = 'ica13_05' )          -- put on the cheat sheet just in case 
drop procedure ica13_05
go

create procedure ica13_05
@minPrice money=null,
@country nvarchar(10)=N'USA'
as 
  select 
  s.CompanyName as 'Supplier',
  s.Country as 'Country',
  COALESCE( min(p.UnitPrice),0) as 'Min Price',
  COALESCE( max(p.UnitPrice),0) as 'Max Price'
  from 
   NorthwindTraders.dbo.Suppliers as s
   left outer join NorthwindTraders.dbo.Products as p 
   on s.SupplierID=p.SupplierID
   where                                                                    --where needs to before group by 
   s.Country =(@country)
   group by 
    s.CompanyName,s.Country
   having 
   min(p.UnitPrice)>@minPrice
   order by 
    min(p.UnitPrice)
 go 

 exec ica13_05 15
 go
 exec ica13_05 @minPrice=15
 go
 exec ica13_05 @minPrice=5,@country='UK'
 go

 go 

 --q6
 if exists ( select * from sysobjects where name = 'ica13_06' )          -- put on the cheat sheet just in case 
drop procedure ica13_06
go

create procedure ica13_06
@class_id int =0
as 
 select 
   at.ass_type_desc as 'Type',
   Convert(decimal(10,2),AVG(r.score)) as 'Raw Avg',                            --convert() decimal(10,2)
   Convert(decimal(10,2),AVG(r.score*100/req.max_score) )as 'Avg',
   Count(r.score) as 'Num'
  from
   ClassTrak.dbo.Assignment_type as at
   inner join ClassTrak.dbo.Requirements as req
   on at.ass_type_id=req.ass_type_id
   inner join ClassTrak.dbo.Results as r
   on r.req_id=req.req_id
   where 
   req.class_id=@class_id
   group by 
   at.ass_type_desc
   order by 
   at.ass_type_desc
 go 

 exec ica13_06 88
 go 

 exec ica13_06 @class_id=89
 go 

 go 


 --q7
 if exists ( select * from sysobjects where name = 'ica13_07' )          -- put on the cheat sheet just in case 
drop procedure ica13_07
go

create procedure ica13_07 
@year int,
@minAvg int=50,
@minSize int=10
as 
 select 
  s.last_name+','+s.first_name as 'Student',
  c.class_desc as 'Class',
  at.ass_type_desc as 'Type',
  Count(r.score) as 'Submitted',
  Round(Avg(r.score*100/req.max_score),1) as 'Avg'
  from 
   ClassTrak.dbo.Students as s 
   inner join ClassTrak.dbo.Results as r
   on s.student_id=r.student_id
   inner join ClassTrak.dbo.Classes as c 
   on c.class_id=r.class_id
   inner join ClassTrak.dbo.Requirements as req
   on req.req_id=r.req_id
   inner join ClassTrak.dbo.Assignment_type as at
   on at.ass_type_id=req.ass_type_id
 
 where
   DATEPART(year,c.start_date)=@year and 
   r.score is not null
 group by 
   s.last_name,s.first_name,at.ass_type_desc,c.class_desc
 having 
   Count(r.score) >@minSize and 
   Avg(r.score*100/req.max_score)<@minAvg
 order by 
    Count(r.score),Avg(r.score*100/req.max_score)
go 

exec ica13_07 @year=2011
go

exec ica13_07 @year=2011,@minAvg=40, @minSize=15
go
go
 
  
 go 


