
--ica14_store procedureII Xiao liu 

--q1
if exists ( select * from sysobjects where name = 'ica14_01' )          -- put on the cheat sheet just in case 
drop procedure ica14_01
go

create procedure ica14_01 
@category varchar(20),
@productName varchar(20) out,
@quantity int out
as 

select top(1)
 @productName=p.ProductName ,
 @quantity=od.Quantity 
from
  NorthwindTraders.dbo.Products as p
 left outer join   NorthwindTraders.dbo.[Order Details] as od
 on p.ProductID=od.ProductID
 inner join   NorthwindTraders.dbo.Categories as c
 on c.CategoryID=p.CategoryID
where
 c.CategoryName=@category
order by
 od.Quantity desc 
 go 

 declare @category_local varchar(20)='Beverages'
 declare @productName_local varchar(20)
 declare @quanity_local int

 exec ica14_01 @category_local, @productName_local out, @quanity_local out  
 select @category_local as 'Category', @productName_local as 'ProductName',@quanity_local as 'Highest Qty'

 set @category_local='Confections'
 exec ica14_01 @category=@category_local, @productName=@productName_local out, @quantity=@quanity_local out 
 select @category_local as 'Category', @productName_local as 'ProductName',@quanity_local as 'Highest Qty'
 go 

 go 

 --q2 
 if exists ( select * from sysobjects where name = 'ica14_02' )          -- put on the cheat sheet just in case 
drop procedure ica14_02
go

create procedure ica14_02
@year int,
@name varchar(64) output,
@money money output
as 
select top 1
 @name=LastName +', '+e.FirstName,
 @money=Avg(o.Freight)                                                 
                                             
from 
 NorthwindTraders.dbo.Employees as e inner join NorthwindTraders.dbo.Orders as o 
 on e.EmployeeID=o.EmployeeID
where
 year(o.OrderDate)=@year
group by 
 e.LastName +', '+e.FirstName 
order by 
  Avg(o.Freight) desc       
go 



declare @year_local int=1996
declare @name_local varchar(64) 
declare @money_local money 

--exec ica14_02 @year=@year_local,@name=@name_local output,@money=@money_local output  
exec ica14_02 @year_local,@name_local output,@money_local output  
select @year_local as 'Year', @name_local as 'Name',@money_local as 'Biggest Avg Freight'
set @year_local=1997
exec ica14_02 @year=@year_local,@name=@name_local output,@money=@money_local output  
select @year_local as 'Year', @name_local as 'Name',@money_local as 'Biggest Avg Freight'
go 

go 

--q3
if exists ( select * from sysobjects where name = 'ica14_03' )          -- put on the cheat sheet just in case 
drop procedure ica14_03
go

create procedure ica14_03
@classID int,
@assignmentType varchar(20)='all'
as
select 	
	s.last_name as 'Last',
	at.ass_type_desc,
	Round(Min(r.score*100/req.max_score),1) as 'Low',
	Round(max(r.score*100/req.max_score),1) as 'High',
	Round(Avg(r.score*100/req.max_score),1) as 'Avg'
into #tempTable
from 
	ClassTrak.dbo.Assignment_type as at inner join ClassTrak.dbo.Requirements as req
	on at.ass_type_id=req.ass_type_id inner join ClassTrak.dbo.Results as r 
	on req.req_id=r.req_id inner join ClassTrak.dbo.Students as s 
	on s.student_id=r.student_id
where 
  r.class_id=@classID 
group by 
at.ass_type_desc, s.last_name


if(@assignmentType='ica')
begin
     select* from #tempTable as t
	 where  t.ass_type_desc='Assignment'
	 order by t.Avg desc 
end 

if(@assignmentType='lab')
begin
     select* from #tempTable as t
	 where  t.ass_type_desc='Lab'
	 order by t.Avg desc 
end 

if(@assignmentType='le')
begin
     select* from #tempTable as t
	 where  t.ass_type_desc='Lab Exam'
	 order by t.Avg desc 
end 

if(@assignmentType='fe')
begin
     select* from #tempTable as t
	 where  t.ass_type_desc='Final'
	 order by t.Avg desc 
end 
go 

declare @cid as int 
set @cid=123
exec ica14_03 @cid,'ica'
set @cid=123
exec ica14_03 @cid,'le'
go 

go 

--q4
if exists ( select * from sysobjects where name = 'ica14_04' )          -- put on the cheat sheet just in case 
drop procedure ica14_04
go

create procedure ica14_04 
@student varchar(10),
@summary int =0
as 
declare @studentID int
declare @studnetName varchar(20)
declare @rowcount int

 select 
   @studentID=s.student_id,
   @studnetName=s.first_name+' '+s.last_name 
 from ClassTrak.dbo.Students as s
 where s.first_name=@student 
 set @rowcount=@@ROWCOUNT
 if @rowcount=0
  return -1
 if @rowcount=1
   select 
    @studnetName as 'Name',
    c.class_desc,
   at.ass_type_id,
   req.ass_desc,
   r.score,
   req.max_score,
   r.class_id
   
   into #tempTable
   from 
   ClassTrak.dbo.Students as s inner join ClassTrak.dbo.Results as r 
   on s.student_id=r.student_id inner join ClassTrak.dbo.Requirements as req
   on  req.req_id=r.req_id 
   inner join ClassTrak.dbo.Assignment_type as at 
   on at.ass_type_id=req.ass_type_id inner join ClassTrak.dbo.Classes as c 
   on c.class_id=r.class_id
   where 
   s.student_id=@studentID
   
   if(@summary=0)
     begin
	   select 
	   t.Name,
	   t.class_desc,
	   t.ass_type_id,
	   Round(Avg(t.score*100/t.max_score),1) as 'Avg'
	   from
	   #tempTable as t
	   group by 
	   t.Name,t.class_desc,t.ass_type_id
	   order by 
	   t.class_desc,t.ass_type_id
	 end
	 if(@summary=1)
     begin
	   select 
	   t.Name,
	   t.class_desc,
	   Round(Avg(t.score*100/t.max_score),1) as 'Avg'
	   from
	   #tempTable as t
	   group by 
	   t.Name,t.class_desc
	   order by 
	   t.class_desc
	 end
	 return 1
 go 


 declare @retVal as int
 exec @retVal=ica14_04 @student='Ro'
  select @retVal 
  exec @retVal=ica14_04 @student='Ron'
select @retVal
  exec @retVal=ica14_04 @student='Ron',@summary=1
  select @retVal
 go 

 go 

 --q5
 if exists ( select * from sysobjects where name = 'ica14_05' )          -- put on the cheat sheet just in case 
drop procedure ica14_05
go

create procedure ica14_05 
@lastNameSearch varchar(20)='',
@instructor varchar(20) output ,
@classCount int output,
@studentCount int output,
@totalScore int output,
@avgScore float output 

as 
 declare @rowCount int
 declare @instructorID int
 select 
 @instructorID=i.instructor_id,
 @instructor=i.first_name+' '+i.last_name
 from
 ClassTrak.dbo.Instructors as i 
 where
 i.last_name like @lastNameSearch+'%'
 set @rowCount=@@ROWCOUNT
 if(@rowCount<>1)
  return -1
 else 
  begin 
   select 
	@classCount=Count( distinct c.class_id),
	@studentCount=count(cs.class_to_student_id)
   from 
    ClassTrak.dbo.Instructors as i 
	inner join ClassTrak.dbo.Classes as c 
	on i.instructor_id=c.instructor_id 
	left outer  join  ClassTrak.dbo.class_to_student as cs 
	on c.class_id=cs.class_id
   where
    i.instructor_id=@instructorID
   group by 
    i.instructor_id
--------------------------------------------------
    select 
	
	@totalScore=count(r.score),
	@avgScore=AVG(r.score*100/req.max_score)
   from 
    ClassTrak.dbo.Instructors as i 
	inner join ClassTrak.dbo.Classes as c 
	on i.instructor_id=c.instructor_id 
	inner join  ClassTrak.dbo.Results as r
	on c.class_id=r.class_id 
	inner join  ClassTrak.dbo.Requirements as req
	on req.req_id=r.req_id
   where
    i.instructor_id=@instructorID
   group by 
    i.instructor_id

  return 1
  end 
  go 
  
  declare @retVal int 
  declare @instructor_local varchar(20)
  declare @classCount_local int 
  declare @studentCount_local int 
  declare @totalScore_local int 
  declare @avgScore_local float
  exec @retVal=ica14_05  'Cas',@instructor_local output,@classCount_local output,@studentCount_local output,@totalScore_local output,@avgScore_local output               --do not forget output 
  select 
  @instructor_local as 'Instructor',
  @retVal as 'Returned',
  @classCount_local as 'Num Classes',
  @studentCount_local as 'Total Students',
  @totalScore_local as 'Total Graded',
  @avgScore_local as 'Avg Awarded'
  go 