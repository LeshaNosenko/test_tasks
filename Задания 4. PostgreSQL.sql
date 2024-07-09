/*
������� 1. �������� SQL-������, ������� ������� ��� ���������� � ������� �� ����������� ��������� (���� special_features) ������ �Behind the Scenes�.
*/
select * from film f where f.special_features = '{Behind the Scenes}';
/*
������� 2. �������� ��� 2 �������� ������ ������� � ��������� �Behind the Scenes�, ��������� ������ ������� ��� ��������� ����� SQL ��� ������ �������� � �������.
*/
select * from film f where 'Behind the Scenes' = all(special_features);

select * from film f where 'Behind the Scenes' = any(special_features);

select * from film f where '{Behind the Scenes}' <@ (special_features);

select * from film f where  (special_features) @> '{Behind the Scenes}';
/*
������� 3. ��� ������� ���������� ����������, ������� �� ���� � ������ ������� �� ����������� ��������� �Behind the Scenes�.
������������ ������� ��� ���������� �������: ����������� ������ �� ������� 1, ���������� � CTE.
*/
with films as (select f.film_id 
			     from film f 
				where  (f.special_features) @> '{Behind the Scenes}'			   
select r.customer_id, count(ff.film_id) "����� �������"
from films ff 
join inventory i on i.film_id = ff.film_id  
join rental r on r.inventory_id = i.inventory_id 
where r.rental_date notnull
group by r.customer_id
order by r.customer_id;
/*
������� 4. ��� ������� ���������� ����������, ������� �� ���� � ������ ������� �� ����������� ��������� �Behind the Scenes�.
������������ ������� ��� ���������� �������: ����������� ������ �� ������� 1, ���������� � ���������, ������� ���������� ������������ ��� ������� �������.
*/
select r.customer_id, count(ff.film_id) "����� �������"
from (select f.film_id 
		from film f 
	    where (f.special_features) @> '{Behind the Scenes}') ff
join inventory i on i.film_id = ff.film_id  
join rental r on r.inventory_id = i.inventory_id 
where r.rental_date notnull
group by r.customer_id
order by r.customer_id;
/*
������� 5. �������� ����������������� ������������� � �������� �� ����������� ������� � �������� ������ ��� ���������� ������������������ �������������.
*/
create materialized view films_summary as 
select r.customer_id, count(ff.film_id) "����� �������"
from (select f.film_id 
		from film f 
	    where (f.special_features) @> '{Behind the Scenes}') ff
join inventory i on i.film_id = ff.film_id  
join rental r on r.inventory_id = i.inventory_id 
where r.rental_date notnull
group by r.customer_id
order by r.customer_id;

refresh materialized view films_summary;
/*
������� 6. � ������� explain analyze ��������� ������ �������� ���������� �������� �� ���������� ������� � �������� �� �������:
� ����� ���������� ��� �������� ����� SQL, ������������� ��� ���������� ��������� �������, ����� �������� � ������� ���������� �������;
����� ������� ���������� �������� �������: � �������������� CTE ��� � �������������� ����������.
*/

explain analyze 
 select * from film f where f.special_features = '{Behind the Scenes}';

Seq Scan on film f  (cost=0.00..67.50 rows=70 width=386) (actual time=0.957..1.631 rows=70 loops=1)
  Filter: (special_features = '{"Behind the Scenes"}'::text[])
  Rows Removed by Filter: 930
Planning Time: 2.815 ms
Execution Time: 1.653 ms

explain analyze 
select * from film f where 'Behind the Scenes' = all(special_features);

Seq Scan on film f  (cost=0.00..77.50 rows=69 width=386) (actual time=0.020..0.222 rows=70 loops=1)
  Filter: ('Behind the Scenes'::text = ALL (special_features))
  Rows Removed by Filter: 930
Planning Time: 0.073 ms
Execution Time: 0.233 ms

explain analyze 
select * from film f where 'Behind the Scenes' = any(special_features);

Seq Scan on film f  (cost=0.00..77.50 rows=538 width=386) (actual time=0.011..0.255 rows=538 loops=1)
  Filter: ('Behind the Scenes'::text = ANY (special_features))
  Rows Removed by Filter: 462
Planning Time: 0.067 ms
Execution Time: 0.278 ms

explain analyze 
select * from film f where '{Behind the Scenes}' <@ (special_features);

Seq Scan on film f  (cost=0.00..67.50 rows=538 width=386) (actual time=0.010..0.274 rows=538 loops=1)
  Filter: ('{"Behind the Scenes"}'::text[] <@ special_features)
  Rows Removed by Filter: 462
Planning Time: 0.069 ms
Execution Time: 0.294 ms

explain analyze 
select * from film f where  (special_features) @> '{Behind the Scenes}';

Seq Scan on film f  (cost=0.00..67.50 rows=538 width=386) (actual time=0.007..0.271 rows=538 loops=1)
  Filter: (special_features @> '{"Behind the Scenes"}'::text[])
  Rows Removed by Filter: 462
Planning Time: 0.066 ms
Execution Time: 0.292 ms


-- �������� ������� - � ���������� all

explain analyze 
with films as (select f.film_id 
				 from film f 
				 where  (f.special_features) @> '{Behind the Scenes}'
			  )
select r.customer_id, count(ff.film_id) "����� �������"
from films ff 
join inventory i on i.film_id = ff.film_id  
join rental r on r.inventory_id = i.inventory_id 
where r.rental_date notnull
group by r.customer_id
order by r.customer_id;

Sort  (cost=673.98..675.48 rows=599 width=10) (actual time=6.178..6.194 rows=599 loops=1)
  Sort Key: r.customer_id
  Sort Method: quicksort  Memory: 48kB
  ->  HashAggregate  (cost=640.36..646.35 rows=599 width=10) (actual time=6.075..6.120 rows=599 loops=1)
        Group Key: r.customer_id
        Batches: 1  Memory Usage: 105kB
        ->  Hash Join  (cost=202.30..597.19 rows=8633 width=6) (actual time=0.915..5.227 rows=8608 loops=1)
              Hash Cond: (i.film_id = f.film_id)
              ->  Hash Join  (cost=128.07..480.67 rows=16044 width=4) (actual time=0.582..3.596 rows=16044 loops=1)
                    Hash Cond: (r.inventory_id = i.inventory_id)
                    ->  Seq Scan on rental r  (cost=0.00..310.44 rows=16044 width=6) (actual time=0.007..0.940 rows=16044 loops=1)
                          Filter: (rental_date IS NOT NULL)
                    ->  Hash  (cost=70.81..70.81 rows=4581 width=6) (actual time=0.556..0.556 rows=4581 loops=1)
                          Buckets: 8192  Batches: 1  Memory Usage: 243kB
                          ->  Seq Scan on inventory i  (cost=0.00..70.81 rows=4581 width=6) (actual time=0.004..0.247 rows=4581 loops=1)
              ->  Hash  (cost=67.50..67.50 rows=538 width=4) (actual time=0.329..0.329 rows=538 loops=1)
                    Buckets: 1024  Batches: 1  Memory Usage: 27kB
                    ->  Seq Scan on film f  (cost=0.00..67.50 rows=538 width=4) (actual time=0.010..0.295 rows=538 loops=1)
                          Filter: (special_features @> '{"Behind the Scenes"}'::text[])
                          Rows Removed by Filter: 462
Planning Time: 0.286 ms
Execution Time: 6.236 ms

explain analyze 
select r.customer_id, count(ff.film_id) "����� �������"
from (select f.film_id 
		from film f 
		where  (f.special_features) @> '{Behind the Scenes}') ff
join inventory i on i.film_id = ff.film_id  
join rental r on r.inventory_id = i.inventory_id 
where r.rental_date notnull
group by r.customer_id
order by r.customer_id;

Sort  (cost=673.98..675.48 rows=599 width=10) (actual time=6.198..6.216 rows=599 loops=1)
  Sort Key: r.customer_id
  Sort Method: quicksort  Memory: 48kB
  ->  HashAggregate  (cost=640.36..646.35 rows=599 width=10) (actual time=6.095..6.136 rows=599 loops=1)
        Group Key: r.customer_id
        Batches: 1  Memory Usage: 105kB
        ->  Hash Join  (cost=202.30..597.19 rows=8633 width=6) (actual time=0.928..5.252 rows=8608 loops=1)
              Hash Cond: (i.film_id = f.film_id)
              ->  Hash Join  (cost=128.07..480.67 rows=16044 width=4) (actual time=0.578..3.576 rows=16044 loops=1)
                    Hash Cond: (r.inventory_id = i.inventory_id)
                    ->  Seq Scan on rental r  (cost=0.00..310.44 rows=16044 width=6) (actual time=0.005..0.945 rows=16044 loops=1)
                          Filter: (rental_date IS NOT NULL)
                    ->  Hash  (cost=70.81..70.81 rows=4581 width=6) (actual time=0.556..0.556 rows=4581 loops=1)
                          Buckets: 8192  Batches: 1  Memory Usage: 243kB
                          ->  Seq Scan on inventory i  (cost=0.00..70.81 rows=4581 width=6) (actual time=0.004..0.269 rows=4581 loops=1)
              ->  Hash  (cost=67.50..67.50 rows=538 width=4) (actual time=0.347..0.347 rows=538 loops=1)
                    Buckets: 1024  Batches: 1  Memory Usage: 27kB
                    ->  Seq Scan on film f  (cost=0.00..67.50 rows=538 width=4) (actual time=0.010..0.307 rows=538 loops=1)
                          Filter: (special_features @> '{"Behind the Scenes"}'::text[])
                          Rows Removed by Filter: 462
Planning Time: 0.279 ms
Execution Time: 6.260 ms

-- ���� �� ������ - ������� ��� ����� Cte ��� ����� ���������, ��� ������� �� �������������, ��������� ���������� ����� ��������.
/*
������� 7. ��������� ������� �������, �������� ��� ������� ���������� �������� � ������ ��� �������.
*/
select
	t.staff_id, t.first_name, t.last_name, t.payment_date
from
	(
	select
		s.staff_id,
		s.first_name,
		s.last_name,
		row_number() over(partition by p.staff_id order by p.payment_date asc) as rn,
		payment_date
	from
		staff s
	join payment p on p.staff_id = s.staff_id
   ) t
where
	t.rn = 1
order by t.staff_id;
/*
������� 8. ��� ������� �������� ���������� � �������� ����� SQL-�������� ��������� ������������� ����������:
�	����, � ������� ���������� ������ ����� ������� (� ������� ���-�����-����);
�	���������� �������, ������ � ������ � ���� ����;
�	����, � ������� ������� ������� �� ���������� ����� (� ������� ���-�����-����);
�	����� ������� � ���� ����.
*/
with 
stores as (
select store_id from store s
),
rental_stats as (
    select
        s.store_id,
        rental_date::date as rental_day,
        count(*) as num_rentals,
        row_number() over (partition by s.store_id order by count(*) desc) as rn_rentals
    from
        rental r
        join inventory i on r.inventory_id = i.inventory_id
        join stores s on i.store_id = s.store_id
    group by
        s.store_id, rental_date::date
),
sales_stats as (
    select
        s.store_id,
        payment_date::date as payment_day,
        sum(amount) as total_sales,
        row_number() over (partition by s.store_id order by sum(amount) asc) as rn_sales
    from
        payment p
        join rental r on p.rental_id = r.rental_id
        join inventory i on r.inventory_id = i.inventory_id
        join stores s on i.store_id = s.store_id
    group by
        s.store_id, payment_date::date
)
select
    r.store_id,
    r.rental_day as "���� � ������� ���������� ������ ����� �������",
    r.num_rentals as "����� ������� ������ � ������ � ���� ����",
    s.payment_day as "����, � ������� ������� ����� �� ���������� �����",
    s.total_sales as "����� ������ � ���� ����"
from
    rental_stats r
    join sales_stats s on r.store_id = s.store_id
where
    r.rn_rentals = 1
    and s.rn_sales = 1;