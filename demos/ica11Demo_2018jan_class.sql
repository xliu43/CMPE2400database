-- Single summary value, sum of value of all sales 
select
	sum(t.price) * sum(s.qty) as 'sum()',
	sum( t.price * s.qty ) as 'real sum ()' -- 
from 
	titles as t inner join sales as s
	on t.title_id = s.title_id
go

-- select title and all related sales,
select
	t.title as 'Title',
	sum(t.price * s.qty) as 'Sum of Sales',
	count(s.qty) as 'Count of Sales' -- any sales field would do...
from 
	titles as t left outer join sales as s
	on t.title_id = s.title_id
group by t.title
go

-- All publisher, any titles and ANY sales of those
-- where qty > 8 and the sum of sales > 100
select
	p.pub_name as 'Publisher',
	t.title as 'Title',
	sum( COALESCE(t.price,0) * COALESCE(s.qty,0)) as 'Sum of Sales',
	avg( COALESCE(t.price * s.qty, 0) ) as 'Average of Sales'
	--count( s.qty ) as 'NumSales'
from
	publishers as p left outer join titles as t -- ALL publishers, join titles
	on p.pub_id = t.pub_id
		left outer join sales as s -- ALL publishers+titles, join sales
		on s.title_id = t.title_id
--where 
--	s.qty > 8
group by pub_name, title
having
	count( * ) > 1 -- aggregate constraint w/o select list item
order by p.pub_name, t.title
go

-- Publishers, titles and 0 based sales stats, no exclusions in rollup
select
	p.pub_name as 'Publisher',
	COALESCE(sum( t.price * s.qty ), 0) as 'Sales Value',
	COALESCE(AVG( t.price * s.qty ), 0) as 'AVG Sales',
	-- CAREFUL : substitute 0 in COALESCE ONLY when it makes sense/required.
	--  In this case, valid Price exists, qty = null and subs a 0, making
	--    the record contribute ( erroneously ) to the average..
	avg( COALESCE( t.price, 0 ) * COALESCE( s.qty, 0 )) as 'COAL Avg'
from
	publishers as p left outer join titles as t -- ALL publishers, join titles
	on p.pub_id = t.pub_id
		left outer join sales as s -- ALL publishers+titles, join sales
		on s.title_id = t.title_id
group by pub_name
having avg( t.price * s.qty ) > 300
order by p.pub_name
go