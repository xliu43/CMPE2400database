--ica12 xiao liu 
--q1
declare @id int=88
select 
at.ass_type_desc as 'Type',
Avg(r.score) as 'Raw Avg',
Avg(r.score*100/req.max_score) as 'Avg',
count(r.score)as 'Num'
from 
 Assignment_type as at left outer join Requirements as req 
 on at.ass_type_id=req.ass_type_id
 left outer join Results as r
 on req.req_id=r.req_id
where 
 r.class_id=@id
group by 
 at.ass_type_desc
 order by 
  at.ass_type_desc
go

--q2
declare @id2 int=88
select 
req.ass_desc+'('+at.ass_type_desc+')' as 'Desc(Type)',
Round(Avg(r.score*100/req.max_score),2) as 'Avg',
count(r.score) as 'Num Score'
from 
 Assignment_type as at left outer join Requirements as req 
 on at.ass_type_id=req.ass_type_id
 left outer join Results as r
 on req.req_id=r.req_id
where 
 r.class_id=@id2
group by 
 req.ass_desc, at.ass_type_desc
having 
 Avg(r.score*100/req.max_score) >57
order by 
 req.ass_desc+'('+at.ass_type_desc+')'
go

--	q3
declare @id3 int =123
select 
 s.last_name as 'Last',
 at.ass_type_desc as 'ass_type_desc',
 round(min(r.score*100/req.max_score),1) as 'Low',
 round(max(r.score*100/req.max_score),1) as 'High',
 round(avg(r.score*100/req.max_score),1) as 'Avg'
from 
 Students as s left outer join Results as r 
 on s.student_id=r.student_id
 left outer join  Requirements as req
 on r.req_id=req.req_id 
 left outer join Assignment_type as at 
 on req.ass_type_id=at.ass_type_id
where 
 r.class_id=@id3
group by 
 s.last_name, at.ass_type_desc
having 
 round(avg(r.score*100/req.max_score),1)>70
order by 
 at.ass_type_desc,'Avg'
 go

 --q4
 select 
 i.last_name as 'Instructor',
 Convert(varchar(15),c.start_date,106) as 'Start',
 --c.class_desc as 'class decription',
 count(cts.class_to_student_id) as 'Num registered',
 sum(Convert(int,cts.active)) as  'Num Active'

 from 
  Instructors as i left outer join Classes as c 
  on i.instructor_id=c.instructor_id
  left outer join class_to_student cts
  on cts.class_id=c.class_id

group by 
 i.last_name,c.start_date--,c.class_desc
having 
  sum(Convert(int,cts.active))< count(cts.class_to_student_id)-3
order by 
 i.last_name, c.start_date
 go

 --q5
 declare @year int =2011
 declare @score int=40
 select 
 Convert(varchar(24),s.last_name+', '+s.first_name) as 'Student',
 c.class_desc as 'Class',
 at.ass_type_desc as 'Type',
 count(r.score) as 'Submitted',
 round(Avg(r.score*100/req.max_score),1) as 'Avg'
 from 
  Students as s left outer join Results as r
  on s.student_id=r.student_id
  left outer join Classes as c
  on c.class_id=r.class_id
  left outer join Requirements as req
  on req.req_id=r.req_id
  left outer join Assignment_type as at
  on at.ass_type_id=req.ass_type_id
where 
 r.score is not null and 
 DATEPART(year,c.start_date)=@year
group by 
 s.last_name,s.first_name,c.class_desc,at.ass_type_desc
having 
 count(r.score) >10 and 
 round(Avg(r.score*100/req.max_score),1)<@score
order by 
 count(r.score),round(Avg(r.score*100/req.max_score),1)
 go 