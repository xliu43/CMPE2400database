-- ica16
-- You will need to install a personal version of the ClassTrak database
-- The Full and Refresh scripts are on the Moodle site.
-- Once installed, you can run the refresh script to restore data that may be modified or 
--  deleted in the process of completing this ica.

use  xliu43_ClassTrak
go

-- q1
-- Complete an update to change all classes to have their descriptions be lower case
-- select all classes to verify your update
update Classes
set class_desc=LOWER(class_desc)
select 
*
from 
Classes

go

-- q2
-- Complete an update to change all classes have 'Web' in their 
-- respective course description to be upper case
-- select all classes to verify your selective update
update Classes
set class_desc=Upper(class_desc)
from 
 Classes as cl inner join Courses as co
 on co.course_id=cl.course_id

where 
 co.course_desc like '%Web%'
select 
 *
from 
 Classes
go

-- q3
-- For class_id = 123
-- Update the score of all results which have a real percentage of less than 50
-- The score should be increased by 10% of the max score value, maybe more pass ?
-- Use ica13_06 select statement to verify pre and post update values,
--  put one select before and after your update call.
select 
   at.ass_type_desc as 'Type',
   Convert(decimal(10,2),AVG(r.score)) as 'Raw Avg',                            --convert() decimal(10,2)
   Convert(decimal(10,2),AVG(r.score*100/req.max_score) )as 'Avg',
   Count(r.score) as 'Num'
  from
   Assignment_type as at
   inner join Requirements as req
   on at.ass_type_id=req.ass_type_id
   inner join Results as r
   on r.req_id=req.req_id
   where 
   req.class_id=123
   group by 
   at.ass_type_desc
   order by 
   at.ass_type_desc

update Results
set score=score+req.max_score*0.1
from 
 Results as r inner join Requirements as req
 on req.req_id=r.req_id
where 
 r.class_id=123 and 
 (r.score*100/req.max_score)<50

 
 select 
   at.ass_type_desc as 'Type',
   Convert(decimal(10,2),AVG(r.score)) as 'Raw Avg',                            --convert() decimal(10,2)
   Convert(decimal(10,2),AVG(r.score*100/req.max_score) )as 'Avg',
   Count(r.score) as 'Num'
  from
   Assignment_type as at
   inner join Requirements as req
   on at.ass_type_id=req.ass_type_id
   inner join Results as r
   on r.req_id=req.req_id
   where 
   req.class_id=123
   group by 
   at.ass_type_desc
   order by 
   at.ass_type_desc



go