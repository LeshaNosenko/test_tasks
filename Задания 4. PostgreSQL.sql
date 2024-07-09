/*
Задание 1. Напишите SQL-запрос, который выводит всю информацию о фильмах со специальным атрибутом (поле special_features) равным “Behind the Scenes”.
*/
select * from film f where f.special_features = '{Behind the Scenes}';
/*
Задание 2. Напишите ещё 2 варианта поиска фильмов с атрибутом “Behind the Scenes”, используя другие функции или операторы языка SQL для поиска значения в массиве.
*/
select * from film f where 'Behind the Scenes' = all(special_features);

select * from film f where 'Behind the Scenes' = any(special_features);

select * from film f where '{Behind the Scenes}' <@ (special_features);

select * from film f where  (special_features) @> '{Behind the Scenes}';
/*
Задание 3. Для каждого покупателя посчитайте, сколько он брал в аренду фильмов со специальным атрибутом “Behind the Scenes”.
Обязательное условие для выполнения задания: используйте запрос из задания 1, помещённый в CTE.
*/
with films as (select f.film_id 
			     from film f 
				where  (f.special_features) @> '{Behind the Scenes}'			   
select r.customer_id, count(ff.film_id) "Число фильмов"
from films ff 
join inventory i on i.film_id = ff.film_id  
join rental r on r.inventory_id = i.inventory_id 
where r.rental_date notnull
group by r.customer_id
order by r.customer_id;
/*
Задание 4. Для каждого покупателя посчитайте, сколько он брал в аренду фильмов со специальным атрибутом “Behind the Scenes”.
Обязательное условие для выполнения задания: используйте запрос из задания 1, помещённый в подзапрос, который необходимо использовать для решения задания.
*/
select r.customer_id, count(ff.film_id) "Число фильмов"
from (select f.film_id 
		from film f 
	    where (f.special_features) @> '{Behind the Scenes}') ff
join inventory i on i.film_id = ff.film_id  
join rental r on r.inventory_id = i.inventory_id 
where r.rental_date notnull
group by r.customer_id
order by r.customer_id;
/*
Задание 5. Создайте материализованное представление с запросом из предыдущего задания и напишите запрос для обновления материализованного представления.
*/
create materialized view films_summary as 
select r.customer_id, count(ff.film_id) "Число фильмов"
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
Задание 6. С помощью explain analyze проведите анализ скорости выполнения запросов из предыдущих заданий и ответьте на вопросы:
с каким оператором или функцией языка SQL, используемыми при выполнении домашнего задания, поиск значения в массиве происходит быстрее;
какой вариант вычислений работает быстрее: с использованием CTE или с использованием подзапроса.
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


-- Наиболее быстрый - с оператором all

explain analyze 
with films as (select f.film_id 
				 from film f 
				 where  (f.special_features) @> '{Behind the Scenes}'
			  )
select r.customer_id, count(ff.film_id) "Число фильмов"
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
select r.customer_id, count(ff.film_id) "Число фильмов"
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

-- Судя по планам - разницы нет между Cte или через подзапрос, все зависит от нагруженности, поведение статистики может меняться.
/*
Задание 7. Используя оконную функцию, выведите для каждого сотрудника сведения о первой его продаже.
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
Задание 8. Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
•	день, в который арендовали больше всего фильмов (в формате год-месяц-день);
•	количество фильмов, взятых в аренду в этот день;
•	день, в который продали фильмов на наименьшую сумму (в формате год-месяц-день);
•	сумму продажи в этот день.
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
    r.rental_day as "день в который арендовали больше всего фильмов",
    r.num_rentals as "число фильмов взятых в аренду в этот день",
    s.payment_day as "день, в который продали фильм на наименьшую сумму",
    s.total_sales as "сумма продаж в этот день"
from
    rental_stats r
    join sales_stats s on r.store_id = s.store_id
where
    r.rn_rentals = 1
    and s.rn_sales = 1;