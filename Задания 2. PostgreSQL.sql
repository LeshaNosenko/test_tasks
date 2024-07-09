/*
Задание 1. Выведите для каждого покупателя его адрес, город и страну проживания.
*/
select c.customer_id,
    c.first_name,
    c.last_name,
    a.address,
    c2.city,
    c3.country
    from customer c
       join address a on a.address_id = c.address_id 
       join city c2 on c2.city_id = a.city_id
       join country c3 on c3.country_id = c2.country_id;
/*
Задание 2. С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
•	Доработайте запрос и выведите только те магазины, у которых количество покупателей больше 300. Для решения используйте фильтрацию по сгруппированным строкам с функцией агрегации. 
•	Доработайте запрос, добавив в него информацию о городе магазина, фамилии и имени продавца, который работает в нём. 
*/
select s.store_id, count(c.customer_id) 
  from store s 
  join customer c on s.store_id = c.store_id
 group by s.store_id;
 
select s.store_id, count(c.customer_id) 
  from store s 
  join customer c on s.store_id = c.store_id
 group by s.store_id
having count(c.customer_id) > 300;

	select  s.store_id,  count(c.customer_id), ci.city, st.last_name || ' ' || st.first_name as "фио"
	from
	    public.store s
		join
		    public.customer c on s.store_id = c.store_id
		join
		    public.staff st on s.store_id = st.store_id
		join
		    public.address a on st.address_id = a.address_id
		join
		    public.city ci on a.city_id = ci.city_id
		group by
		    s.store_id, ci.city, st.first_name, st.last_name
		having
		    count(c.customer_id) > 300; 
/*
Задание 3. Выведите топ-5 покупателей, которые взяли в аренду за всё время наибольшее количество фильмов.
*/
	   select c.customer_id, count(i.film_id) "Число фильмов"
	     from customer c
	       join rental r on r.customer_id = c.customer_id 
	       join inventory i on i.inventory_id = r.inventory_id 
	       group by c.customer_id
	       order by count(i.film_id) desc 
	       limit 5;
/*
Задание 4. Посчитайте для каждого покупателя 4 аналитических показателя:
•	количество взятых в аренду фильмов;
•	общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа);
•	минимальное значение платежа за аренду фильма;
•	максимальное значение платежа за аренду фильма.
*/
SELECT distinct
    c.customer_id,
    COUNT(r.rental_id) OVER (PARTITION BY c.customer_id) AS "количество взятых в аренду",
    ROUND(SUM(p.amount) OVER (PARTITION BY c.customer_id)) AS "общая сумма округленная",
    MIN(p.amount) OVER (PARTITION BY p.customer_id) AS "минимальное знач. платежа",
    MAX(p.amount) OVER (PARTITION BY p.customer_id) AS "максимальное знач. платежа"
FROM customer c
JOIN rental r ON r.customer_id = c.customer_id
JOIN payment p ON p.rental_id = r.rental_id
ORDER BY c.customer_id;
/*
Задание 5. Используя данные из таблицы городов, составьте одним запросом всевозможные пары городов так, чтобы в результате не было пар с одинаковыми названиями городов. Для решения необходимо использовать декартово произведение.
*/
select c.city, c2.city from city c cross join city c2 where c.city <> c2.city;
/*
Задание 6. Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date) и дате возврата (поле return_date), вычислите для каждого покупателя среднее количество дней, за которые он возвращает фильмы.
*/
select r.customer_id, avg(r.return_date - r.rental_date)::interval 
  from rental r 
where r.rental_date is not null 
group by r.customer_id 
order by r.customer_id;
/*
Задание 7. Посчитайте для каждого фильма, сколько раз его брали в аренду, а также общую стоимость аренды фильма за всё время.
*/
select
    i.film_id,
    count(r.rental_id) as "число аренды фильма",
    sum(p.amount) as "общая сумма"
FROM
    film f
join  inventory i on i.film_id = f.film_id 
join rental r on r.inventory_id  = i.inventory_id 
join  payment p on p.rental_id = r.rental_id
group by
    i.film_id
order by
    i.film_id;
/*
Задание 8. Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые ни разу не брали в аренду.
*/
select
    f.film_id,
    count(r.rental_id) as "число аренды фильма",
    sum(p.amount) as "общая сумма"
from
    film f
left join inventory i on f.film_id = i.film_id
left join rental r on i.inventory_id = r.inventory_id
left join payment p on r.rental_id = p.rental_id
    where i.inventory_id is null
group by
    f.film_id
order by
    f.film_id;
/*
Задание 9. Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку «Премия». Если количество продаж превышает 7 300, то значение в колонке будет «Да», иначе должно быть значение «Нет».
*/
select
	s.staff_id,
	count(p.amount) as cnt,
	case when count(p.amount) > 7300 then 'Да' else 'нет' end "Премия"
from
	staff s
join payment p on
	s.staff_id = p.staff_id
	group by s.staff_id;