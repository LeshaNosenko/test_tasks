/*
Задание 1. Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
•	Пронумеруйте все платежи от 1 до N по дате
•	Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
•	Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
•	Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.
*/
select p.payment_id,
	   p.payment_date,
       p.customer_id,
       row_number() over(order by p.payment_date asc) rn_order_date,
       row_number() over(partition by p.customer_id order by p.payment_date asc) rn_customer_order_date,
       sum(p.amount) over(partition by p.customer_id order by p.payment_date asc, p.amount asc) sum_ord_date_amount,
       dense_rank() over(partition by p.customer_id order by p.amount desc) rnk
    from payment p 
   order by p.payment_id asc;
/*
Задание 2. С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.
*/
 select p.customer_id,
        p.amount "стоимость платежа", 
        lag(p.amount, 1, 0.0)  over (partition by p.customer_id order by p.payment_date) "Предыдущая строка стоимость платежа с дефолтом 0.0"
    from payment p;
/*
Задание 3. С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.
*/
 select p.customer_id,
        p.amount "Текущая сумма",
        lead(p.amount) over (partition by p.customer_id order by p.payment_date) "Следующий платеж",
        lead(p.amount) over (partition by p.customer_id order by p.payment_date) - p.amount "Насколько больше или меньше следующий платеж"
    from payment p;
/*
Задание 4. С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.
*/
select
	t.customer_id, t.rental_date  "Дата последней оплаты аренды"
from
	(
    select
	r.customer_id,
	r.rental_date,
	row_number () over (partition by r.customer_id order by	r.rental_date desc) rn
from
	rental r ) t
where
	t.rn = 1
order by
	t.customer_id;
-- или
select distinct r.customer_id, first_value (r.rental_date) over (partition by r.customer_id order by r.rental_date desc) "Дата последней оплаты аренды"
  from rental r 
order by r.customer_id;
/*
Задание 5. С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) с сортировкой по дате.
*/
select
    p.staff_id ,
   amount,
    sum(amount) over (partition by staff_id order by p.payment_date::date rows between unbounded preceding and current row) as "Нарастающий итог"
from
    payment p
where
    p.payment_date::date >= '2005-08-01' and p.payment_date::date < '2005-09-01'
order by
  p.staff_id,p.payment_date;
/*
Задание 6. 20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей, которые в день проведения акции получили скидку.
*/
select
	t.customer_id
from
	(
	select
		customer_id,
		row_number() over (order by p.payment_date) rn
	from
		payment p
	where
		p.payment_date::date = '2005-08-20'
	) t
where
	mod(t.rn,100) = 0
	order by t.customer_id;
/*
Задание 7. Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
•	покупатель, арендовавший наибольшее количество фильмов;
•	покупатель, арендовавший фильмов на самую большую сумму;
•	покупатель, который последним арендовал фильм.
*/
with countrys_customers as (
    select
        co.country,
        c.customer_id,
        count(r.rental_id) as cnt_films,
        sum(p.amount) as sum_amount,
        max(r.rental_date) as last_rental_date
    from
        public.country co
        join public.city ci on co.country_id = ci.country_id
        join public.address a on ci.city_id = a.city_id
        join public.customer c on a.address_id = c.address_id
        join public.rental r on c.customer_id = r.customer_id
        join public.payment p on r.rental_id = p.rental_id
    group by
        co.country, c.customer_id
),
max_films as (
    select
        country,
        customer_id,
        row_number() over (partition by country order by cnt_films desc) as rn_films
    from
        countrys_customers
),
sum_rentals as (
    select
        country,
        customer_id,
        row_number() over (partition by country order by sum_amount desc) as rn_amount
    from
        countrys_customers
),
last_rental as (
    select
        country,
        customer_id,
        row_number() over (partition by country order by last_rental_date desc) as rn_rental_date
    from
        countrys_customers
)
select
    mf.country,
    max(case when mf.rn_films = 1 then mf.customer_id end) as "покупатель, арендовавший наибольшее количество фильмов",
    max(case when sr.rn_amount = 1 then sr.customer_id end) as "покупатель, арендовавший фильмов на самую большую сумму",
    max(case when lr.rn_rental_date = 1 then lr.customer_id end) as "покупатель, который последним арендовал фильм"
from
    max_films mf
    join sum_rentals sr on mf.country = sr.country and mf.customer_id = sr.customer_id
    join last_rental lr on mf.country = lr.country and mf.customer_id = lr.customer_id
group by
    mf.country
order by
    mf.country;