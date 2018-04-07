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
	[ClassDescription] nvarchar(50) 
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
   Laps int
    constraint ck_laps check(laps>0)
)
go

alter table Sessions 
 add 
  constraint pk_Sessions_RiderID_BikeID_SessionDate primary key (RiderID,BikeID,SessionDate)



