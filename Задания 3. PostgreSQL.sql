/*
������� 1. �������� ������ � ������� payment � � ������� ������� ������� �������� ����������� ������� �������� ��������:
�	������������ ��� ������� �� 1 �� N �� ����
�	������������ ������� ��� ������� ����������, ���������� �������� ������ ���� �� ����
�	���������� ����������� ������ ����� ���� �������� ��� ������� ����������, ���������� ������ ���� ������ �� ���� �������, � ����� �� ����� ������� �� ���������� � �������
�	������������ ������� ��� ������� ���������� �� ��������� ������� �� ���������� � ������� ���, ����� ������� � ���������� ��������� ����� ���������� �������� ������.
����� ��������� �� ������ ����� ��������� SQL-������, � ����� ���������� ��� ������� � ����� �������.
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
������� 2. � ������� ������� ������� �������� ��� ������� ���������� ��������� ������� � ��������� ������� �� ���������� ������ �� ��������� �� ��������� 0.0 � ����������� �� ����.
*/
 select p.customer_id,
        p.amount "��������� �������", 
        lag(p.amount, 1, 0.0)  over (partition by p.customer_id order by p.payment_date) "���������� ������ ��������� ������� � �������� 0.0"
    from payment p;
/*
������� 3. � ������� ������� ������� ����������, �� ������� ������ ��������� ������ ���������� ������ ��� ������ ��������.
*/
 select p.customer_id,
        p.amount "������� �����",
        lead(p.amount) over (partition by p.customer_id order by p.payment_date) "��������� ������",
        lead(p.amount) over (partition by p.customer_id order by p.payment_date) - p.amount "��������� ������ ��� ������ ��������� ������"
    from payment p;
/*
������� 4. � ������� ������� ������� ��� ������� ���������� �������� ������ � ��� ��������� ������ ������.
*/
select
	t.customer_id, t.rental_date  "���� ��������� ������ ������"
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
-- ���
select distinct r.customer_id, first_value (r.rental_date) over (partition by r.customer_id order by r.rental_date desc) "���� ��������� ������ ������"
  from rental r 
order by r.customer_id;
/*
������� 5. � ������� ������� ������� �������� ��� ������� ���������� ����� ������ �� ������ 2005 ���� � ����������� ������ �� ������� ���������� � �� ������ ���� ������� (��� ����� �������) � ����������� �� ����.
*/
select
    p.staff_id ,
   amount,
    sum(amount) over (partition by staff_id order by p.payment_date::date rows between unbounded preceding and current row) as "����������� ����"
from
    payment p
where
    p.payment_date::date >= '2005-08-01' and p.payment_date::date < '2005-09-01'
order by
  p.staff_id,p.payment_date;
/*
������� 6. 20 ������� 2005 ���� � ��������� ��������� �����: ���������� ������� ������ ������� ������� �������������� ������ �� ��������� ������. � ������� ������� ������� �������� ���� �����������, ������� � ���� ���������� ����� �������� ������.
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
������� 7. ��� ������ ������ ���������� � �������� ����� SQL-�������� �����������, ������� �������� ��� �������:
�	����������, ������������ ���������� ���������� �������;
�	����������, ������������ ������� �� ����� ������� �����;
�	����������, ������� ��������� ��������� �����.
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
    max(case when mf.rn_films = 1 then mf.customer_id end) as "����������, ������������ ���������� ���������� �������",
    max(case when sr.rn_amount = 1 then sr.customer_id end) as "����������, ������������ ������� �� ����� ������� �����",
    max(case when lr.rn_rental_date = 1 then lr.customer_id end) as "����������, ������� ��������� ��������� �����"
from
    max_films mf
    join sum_rentals sr on mf.country = sr.country and mf.customer_id = sr.customer_id
    join last_rental lr on mf.country = lr.country and mf.customer_id = lr.customer_id
group by
    mf.country
order by
    mf.country;