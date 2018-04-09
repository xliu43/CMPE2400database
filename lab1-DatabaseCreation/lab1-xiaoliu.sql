--use master
--if exists
--(
--	select	[name]
--	from	sysdatabases
--	where	[name] = 'xliu43_lab01'
--)
--drop database xliu43_lab01
--go

--create database xliu43_lab01
--go 


use xliu43_lab01

if exists
(
	select [name]
	from   sysobjects
	where  [name] = 'Sessions'
)
drop table Sessions
go

if exists
(
	select [name]
	from   sysobjects
	where  [name] = 'Bikes'
)
drop table Bikes
go

if exists
(
	select [name]
	from   sysobjects
	where  [name] = 'Riders'
)
drop table Riders
go

if exists
(
	select [name]
	from   sysobjects
	where  [name] = 'Class'
)
drop table Class
go


create table Class
(
    ClassID varchar(6) not null
	  constraint pk_Class_ClassID primary key
	,
	[ClassDescription] varchar(100) 
)
go 




create table Riders 
( 
   RiderID int not null identity(10,1)
     constraint pk_Riders_RidersID Primary key
   ,
     
   [Name] varchar(64)
    constraint ck_Riders_Name check(len([Name])>4)
	,
	ClassID varchar(6)
	 constraint fk_Riders_ClassID foreign key 
	 references class(classID) on delete no action 

)
go



create table Bikes
(
   BikeID varchar(6) not null
     constraint ck_Bikes_BikeID check(BikeID like '[0-9][0-9][0-9][HYS][-][AP]')   
	 constraint pk_Bikes_BikeID primary key                            --remember the format specifier 
   ,
   StableDate date
)
go



create table [Sessions]
(
   RiderID int not null
     constraint fk_Riders_RiderID foreign key 
	 references Riders(RiderID)
   ,
   BikeID varchar(6) not null
    constraint fk_Sessions_BikeID foreign key 
	references Bikes(BikeID)
   ,
   SessionDate datetime not null
     constraint ck_Sessions_SessionDate check(datediff(day,'2017-09-01',(SessionDate))>0)
   ,
   Laps int default 0 
    constraint ck_laps check(laps>=0)
)
go

alter table Sessions 
 add 
  constraint pk_Sessions_RiderID_BikeID_SessionDate primary key (RiderID,BikeID,SessionDate)


------------------Stored Procedure--------------------------------

if exists
(
	select *
	from sysobjects
	where name = 'PopulateClass'
)
drop procedure PopulateClass
go
/*
('moto_3', 'Default Chassis, custom 125cc engine'),
('moto_2', 'Common 600cc engine and electronics, Custom Chassis'),
('motogp', '1000cc Full Factory Spec, common electronics')

*/


create procedure PopulateClass
as
 insert into Class(ClassID,ClassDescription)
 values 
  ('moto_3', 'Default Chassis, custom 125cc engine'),
  ('moto_2', 'Common 600cc engine and electronics, Custom Chassis'),
  ('motogp', '1000cc Full Factory Spec, common electronics')
go

exec PopulateClass 
go 
 
--------------------------------Popluate Bikes---------------------------
if exists
(
	select *
	from sysobjects
	where name = 'PopulateBikes'
)
drop procedure PopulateBikes
go



create procedure PopulateBikes
as
 select 
  BikeID as 'BikeID'
into #BikesTemp
from Bikes 
    declare @initalCompany as char(1)
	declare @loopForHYS int = 0
	declare @loopForBike int = 0
	declare @bikeID varchar(6)

	while(@loopForHYS < 3)
		begin
			if(@loopForHYS = 0)
				begin
					set @initalCompany = 'H' 
				end
			if(@loopForHYS = 1)
				begin
					set @initalCompany = 'Y' 
				end
			if(@loopForHYS = 2)
				begin
					set @initalCompany = 'S' 
				end
	
					while(@loopForBike < 20)
						begin
			           
						set @bikeID = FORMAT(@loopForBike,'000') + @initalCompany + '-' + 'A'
						insert #BikesTemp(BikeID)
						values (@bikeID)
			
						set @bikeID = FORMAT(@loopForBike,'000') + @initalCompany + '-' + 'P'
						insert #BikesTemp(BikeID)
						values (@bikeID)

						set @loopForBike += 1
			
						end
						
		set @loopForHYS+=1
		set @loopForBike=0
		
		end      

	

		insert Bikes(BikeID)
		 (
		   	    select 
				*
				from 
				#BikesTemp
		 )

 
go 

execute PopulateBikes
go 


----------------------------------------AddRider-------------------------------------
if exists
(
	select *
	from sysobjects
	where name = 'AddRider'
)
drop procedure AddRider
go

create procedure AddRider
@riderName as nvarchar(50),
@classID as nvarchar(50),
@resultMsg as nvarchar(50) output,
@newRiderID as int output 
as
	if(@riderName is null)
	 begin 
	     set @resultMsg='riderName is null!'
		 return -1
	 end 
	
	if(LEN(@riderName) <=4)
		begin
			set @resultMsg = 'Rider must have a name more than 4 characters!'
			return -1
		end

	select *
	into #tempClasses
	from  
	Class 
	where Class.ClassID = @classID 
	
	if(@@ROWCOUNT = 0)
	begin
		set @resultMsg = 'Supplied class id does not exist '
		return -1
	end

	select *
	into #tempRiders
	from Riders
	where Riders.Name = @riderName and 
	Riders.ClassID=@classID
	
	if(@@ROWCOUNT = 0)
		begin
			insert Riders([Name],ClassID)
			values	(@riderName,@classID)
			set @newRiderID=@@IDENTITY
			set @resultMsg = 'A new Rider has been added with RiderID'+convert(varchar(100),@newRiderID)
			return 0
		end
	else
		begin
			set @resultMsg = 'Record exsits'
			return -1
		end
go

----------------AddRiderTest--------------------------------
----------class is !Exsits------
declare @resultMsg as varchar(50)
declare @newRiderID as int 
declare @name as varchar(50)='name is good'
declare @classID as varchar(10)='not exsit'
exec AddRider @name,@classID,@resultMsg output,@newRiderID output  

select 
@resultMsg as 'AddRiderDemo',
@newRiderID as 'NewRiderID'
go 

----------good one------
declare @resultMsg as varchar(50)
declare @newRiderID as int 
declare @name as varchar(50)='Xiao Liu'
declare @classID as varchar(10)='moto_2'
exec AddRider @name,@classID,@resultMsg output,@newRiderID output  

select 
@resultMsg as 'AddRiderDemo',
@newRiderID as 'NewRiderID'
go 

------dupliacated one----
declare @resultMsg as varchar(50)
declare @newRiderID as int 
declare @name as varchar(50)='Xiao Liu'
declare @classID as varchar(10)='moto_2'
exec AddRider @name,@classID,@resultMsg output,@newRiderID output  

select 
@resultMsg as 'AddRiderDemo',
@newRiderID as 'NewRiderID'
go 

----for future use------
declare @resultMsg as varchar(50)
declare @newRiderID as int 
declare @name as varchar(50)='Xiao Liu2'
declare @classID as varchar(10)='moto_2'
exec AddRider @name,@classID,@resultMsg output,@newRiderID output  

select 
@resultMsg as 'AddRiderDemo',
@newRiderID as 'NewRiderID'
go 

declare @resultMsg as varchar(50)
declare @newRiderID as int 
declare @name as varchar(50)='Xiao Liu3'
declare @classID as varchar(10)='moto_3'
exec AddRider @name,@classID,@resultMsg output,@newRiderID output  

select 
@resultMsg as 'AddRiderDemo',
@newRiderID as 'NewRiderID'
go 


---------------------------------------Remove Rider-----------------------------------------------
if exists
(
	select *
	from sysobjects
	where name = 'RemoveRider'
)
drop procedure RemoveRider
go

create procedure RemoveRider
@riderID as int ,
@boolForce as bit =0,
@resultMsg as varchar(50) output
as
if(@riderID is null)
	 begin 
	     set @resultMsg='riderID is null!'
		 return -1
	 end 
select 
RiderID as 'RidersID'
into #RidersTemp
from 
Riders
where
RiderID=@riderID

if(@@ROWCOUNT=0)
 begin
    set @resultMsg='RidersID not exsits'
	return -1
 end
 ----check the rider has sessions 
 	If exists 
	(select * from Sessions where Sessions.RiderID = @riderID)
		begin
			if(@boolForce = 1)
			begin
				
				delete Sessions
				where Sessions.RiderID = @riderID

				delete Riders
				where Riders.RiderID = @riderID

				set @resultMsg = 'Rider with'+convert(varchar,@riderID)+'has been removed along with registed sessions'

				return 0
			end

			if(@boolForce = 0)
			begin
				set @resultMsg = 'Rider : ' + CONVERT(varchar(max),@riderID)+ ' currently in session'
				return -1
			end	
		end
	 else -- rider does not registed in any sessions
	  begin 
	    	delete Riders
			where Riders.RiderID = @riderID
			set @resultMsg ='Rider with'+convert(varchar,@riderID)+'has been removed Not registed in any sessions'
	  end 
	  
go

---------------------testing remove riders---------

declare @resultMsg as varchar(50)
declare @riderID as int =11
declare @force as bit=0
exec RemoveRider @riderID,@force,@resultMsg output

select 
@resultMsg as 'RemoveRidersDemo'
go 


---------------------------------Add Sessions--------------------------------------
if exists
(
	select *
	from sysobjects
	where name = 'AddSession'
)
drop procedure AddSession
go

create procedure AddSession
@riderId as int,
@bikeId as varchar(6),
@sessionDate as datetime,
@resultMsg as nvarchar(50) output
as

if(@riderID is null)
	 begin 
	     set @resultMsg='riderID is null!'
		 return -1
	 end
if(@bikeId is null)
	 begin 
	     set @resultMsg='bikeId is null!'
		 return -1
	 end 
if(@sessionDate is null)
	 begin 
	     set @resultMsg='sessionDate is null!'
		 return -1
	 end 
 
	
	if(datediff(day,'2017-09-01',@sessionDate)<0)
		begin
			set @resultMsg = 'Session date Must after Sep 1st 2017)'
			return -1
		end
	if not exists (select * from Riders where Riders.RiderID = @riderId)
		begin
			set @resultMsg = 'RiderId :  does not exist'
			return -1
		end
	if not exists (select * from Bikes where Bikes.BikeID = @bikeId)
		begin
			set @resultMsg = 'Bike Id : ' + @bikeId + ' does not exist'
			return -1
		end
	if exists (select * from Sessions where Sessions.BikeID = @bikeId)
		begin
			set @resultMsg = 'Bike Id : ' + @bikeId + ' already assigned.'
			return -1			
		end
	
			insert into Sessions (RiderID,BikeID,SessionDate)
			values (@riderId, @bikeId,@sessionDate)
			set @resultMsg = 'One Session Created successfully'
			return 0
		

go


-------------------Test ADD Session---------------------
-------add good one ---
declare @resultMsg as varchar(50)
declare @riderID as int =10
declare @sessionDate datetime ='2018-04-07'
declare @bikeId varchar(10)='018H-A'

execute AddSession @riderID,@bikeId,@sessionDate,@resultMsg output 

select 
@resultMsg as 'AddSessionDemo-sucess'
select 
*
from 
Sessions

go 

------Bike already Assigned---- 
declare @resultMsg as varchar(50)
declare @riderID as int =12
declare @sessionDate datetime ='2018-04-08'
declare @bikeId varchar(10)='018H-A'

execute AddSession @riderID,@bikeId,@sessionDate,@resultMsg output 

select 
@resultMsg as 'AddSessionDemo-Bike Assigned'
select 
*
from 
Sessions

go 


------------------------Update Session------------------------------
if exists
(
	select *
	from sysobjects
	where name = 'UpdateSession'
)
drop procedure UpdateSession
go

create procedure UpdateSession
@riderId as int,
@bikeId as varchar(6),
@sessionDate as datetime,
@laps as int,
@resultMsg as nvarchar(50) output
as 

if(@riderID is null)
	 begin 
	     set @resultMsg='riderID is null!'
		 return -1
	 end
if(@bikeId is null)
	 begin 
	     set @resultMsg='bikeId is null!'
		 return -1
	 end 
if(@sessionDate is null)
	 begin 
	     set @resultMsg='sessionDate is null!'
		 return -1
	 end 

    if( datediff(day,'2017-09-01',@sessionDate)<0)
		begin
			set @resultMsg = 'Session date is Invalid(Must after Sep 1st 2017)'
			return -1
		end
	if not exists (select * from Riders where Riders.RiderID = @riderId)
		begin
			set @resultMsg = 'RiderId :  does not exist'
			return -1
		end
	if not exists (select * from Bikes where Bikes.BikeID = @bikeId)
		begin
			set @resultMsg = 'Bike Id : ' + @bikeId + ' does not exist'
			return -1
		end
    declare @originalLaps int
	if not exists 
	(select Sessions.Laps from Sessions where RiderID=@riderId and BikeID=@bikeId and SessionDate=@sessionDate )
	    begin
		   set @resultMsg='Session not found'
		   return -1
		end 
    
	select @originalLaps=Sessions.Laps from Sessions where RiderID=@riderId and BikeID=@bikeId and SessionDate=@sessionDate 
	if(@laps<@originalLaps)
	  begin
	    set @resultMsg = 'laps provided need to be greater than the exsiting laps'
		return -1
	  end
	else 
	  begin
		  update Sessions
		  set Laps=@laps
		  where 
		   RiderID=@riderId and BikeID=@bikeId and SessionDate=@sessionDate 
		  set @resultMsg='Session Updated Successfully'
	  end
go 


----------------------------test UpdateSession--------------------------
---------good one 
declare @resultMsg as varchar(50)
declare @riderID as int =10
declare @sessionDate datetime ='2018-04-07'
declare @bikeId varchar(10)='018H-A'
declare @laps int=10

execute UpdateSession @riderID,@bikeId,@sessionDate,@laps,@resultMsg output 

select 
@resultMsg as 'UpdateSession Success'
select 
*
from 
Sessions

go 

------laps invalid---
declare @resultMsg as varchar(50)
declare @riderID as int =10
declare @sessionDate datetime ='2018-04-07'
declare @bikeId varchar(10)='018H-A'
declare @laps int=8

execute UpdateSession @riderID,@bikeId,@sessionDate,@laps,@resultMsg output 

select 
@resultMsg as 'UpdateSession LapsInvalid'
select 
*
from 
Sessions

go 


--------------------------------Remove Class--------------------------------
if exists
(
	select *
	from sysobjects
	where name = 'RemoveClass'
)
drop procedure RemoveClass
go

create procedure RemoveClass
@classID as varchar(10),
@resultMsg as varchar(50) output 
as 

if(@classID is null)
	 begin 
	     set @resultMsg='classID is null!'
		 return -1
	 end
  if not exists (select * from Class where ClassID = @classID)
		begin
			set @resultMsg = 'classID not exsits'
			return -1
		end

-----cascading to sessions------
  if exists 
  (
    select *
	from 
	 Class inner join Riders 
	 on class.ClassID=Riders.ClassID
	 inner join Sessions
	 on Riders.RiderID=Sessions.RiderID
	 where class.ClassID=@classID
  )
	  begin 
--delte sessions
	      delete Sessions
		  from
		     Class inner join Riders 
			 on class.ClassID=Riders.ClassID
			 inner join Sessions
			 on Riders.RiderID=Sessions.RiderID
		  where class.ClassID=@classID
--delete Riders
		  delete Riders
		  from
		     Class inner join Riders 
			 on class.ClassID=Riders.ClassID
		   where class.ClassID=@classID
	
	   end 
------------cascading to Riders-----
  if exists 
  (
     select *
	 from 
	 Class inner join Riders 
	 on class.ClassID=Riders.ClassID
	 where class.ClassID=@classID
  )
	  begin 
	      delete Riders
		  from
		     Class inner join Riders 
			 on class.ClassID=Riders.ClassID
		  where class.ClassID=@classID
				
	  end 
----------finally delete Class---------
delete Class
 where Class.ClassID=@classID
 set @resultMsg='All class entries are succesfully deleted'
 return 0
go 


-------------------------Testing Remove Class-------------
-----create rider and session for testing 

declare @resultMsg as varchar(50)
declare @newRiderID as int 
declare @name as varchar(50)='Name1'
declare @classID as varchar(10)='moto_2'
exec AddRider @name,@classID,@resultMsg output,@newRiderID output  
go
declare @resultMsg as varchar(50)
declare @newRiderID as int 
declare @name as varchar(50)='Name2'
declare @classID as varchar(10)='moto_2'
exec AddRider @name,@classID,@resultMsg output,@newRiderID output  
go

---add seesions
declare @resultMsg as varchar(50)
declare @riderID as int =13
declare @sessionDate datetime ='2018-04-07'
declare @bikeId varchar(10)='001H-A'

execute AddSession @riderID,@bikeId,@sessionDate,@resultMsg output 


select *
	 from 
	 Class as c left outer join Riders as r 
	 on c.ClassID=r.ClassID
	 left outer join Sessions as s 
	 on r.RiderID=s.RiderID
go
declare @resultMsg as varchar(50)
execute RemoveClass 'moto_2',@resultMsg output 

select 
@resultMsg as 'TestRemoveClass'

select *
	 from 
	 Class as c left outer join Riders as r 
	 on c.ClassID=r.ClassID
	 left outer join Sessions as s 
	 on r.RiderID=s.RiderID

go 

----------------------------------------ClassInfo-----------------------------------
if exists
(
	select *
	from sysobjects
	where name = 'ClassInfo'
)
drop procedure ClassInfo
go

create procedure ClassInfo
@classID as varchar(10),
@riderID as int,
@resultMsg as varchar(50) output 
as
    if(@classID is null)
	 begin 
	     set @resultMsg='classID is null!'
		 return -1
	 end

	 if not exists (select * from Class where ClassID = @classID)
		begin
			set @resultMsg = 'classID not exsits'
			return -1
		end 

	if(@riderID is null)
	  begin 
	    select 
		 c.ClassID,
		 c.ClassDescription,
		 r.RiderID,
		 r.Name,
		 s.BikeID,
		 s.SessionDate,
		 s.Laps
		 from 
		 Class as c left outer join Riders as r 
		 on c.ClassID=r.ClassID
		 left outer join Sessions as s 
		 on r.RiderID=s.RiderID
	  end 
	  else 
	       select 
		 c.ClassID,
		 c.ClassDescription,
		 r.RiderID,
		 r.Name,
		 s.BikeID,
		 s.SessionDate,
		 s.Laps
		 from 
		 Class as c left outer join Riders as r 
		 on c.ClassID=r.ClassID
		 left outer join Sessions as s 
		 on r.RiderID=s.RiderID
		 where r.RiderID=@riderID	 
go 


-------Test ClassInfo---------------------
  