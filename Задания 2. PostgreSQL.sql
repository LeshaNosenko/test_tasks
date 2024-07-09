/*
������� 1. �������� ��� ������� ���������� ��� �����, ����� � ������ ����������.
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
������� 2. � ������� SQL-������� ���������� ��� ������� �������� ���������� ��� �����������.
�	����������� ������ � �������� ������ �� ��������, � ������� ���������� ����������� ������ 300. ��� ������� ����������� ���������� �� ��������������� ������� � �������� ���������. 
�	����������� ������, ������� � ���� ���������� � ������ ��������, ������� � ����� ��������, ������� �������� � ��. 
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

	select  s.store_id,  count(c.customer_id), ci.city, st.last_name || ' ' || st.first_name as "���"
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
������� 3. �������� ���-5 �����������, ������� ����� � ������ �� �� ����� ���������� ���������� �������.
*/
	   select c.customer_id, count(i.film_id) "����� �������"
	     from customer c
	       join rental r on r.customer_id = c.customer_id 
	       join inventory i on i.inventory_id = r.inventory_id 
	       group by c.customer_id
	       order by count(i.film_id) desc 
	       limit 5;
/*
������� 4. ���������� ��� ������� ���������� 4 ������������� ����������:
�	���������� ������ � ������ �������;
�	����� ��������� �������� �� ������ ���� ������� (�������� ��������� �� ������ �����);
�	����������� �������� ������� �� ������ ������;
�	������������ �������� ������� �� ������ ������.
*/
SELECT distinct
    c.customer_id,
    COUNT(r.rental_id) OVER (PARTITION BY c.customer_id) AS "���������� ������ � ������",
    ROUND(SUM(p.amount) OVER (PARTITION BY c.customer_id)) AS "����� ����� �����������",
    MIN(p.amount) OVER (PARTITION BY p.customer_id) AS "����������� ����. �������",
    MAX(p.amount) OVER (PARTITION BY p.customer_id) AS "������������ ����. �������"
FROM customer c
JOIN rental r ON r.customer_id = c.customer_id
JOIN payment p ON p.rental_id = r.rental_id
ORDER BY c.customer_id;
/*
������� 5. ��������� ������ �� ������� �������, ��������� ����� �������� ������������ ���� ������� ���, ����� � ���������� �� ���� ��� � ����������� ���������� �������. ��� ������� ���������� ������������ ��������� ������������.
*/
select c.city, c2.city from city c cross join city c2 where c.city <> c2.city;
/*
������� 6. ��������� ������ �� ������� rental � ���� ������ ������ � ������ (���� rental_date) � ���� �������� (���� return_date), ��������� ��� ������� ���������� ������� ���������� ����, �� ������� �� ���������� ������.
*/
select r.customer_id, avg(r.return_date - r.rental_date)::interval 
  from rental r 
where r.rental_date is not null 
group by r.customer_id 
order by r.customer_id;
/*
������� 7. ���������� ��� ������� ������, ������� ��� ��� ����� � ������, � ����� ����� ��������� ������ ������ �� �� �����.
*/
select
    i.film_id,
    count(r.rental_id) as "����� ������ ������",
    sum(p.amount) as "����� �����"
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
������� 8. ����������� ������ �� ����������� ������� � �������� � ������� ���� ������, ������� �� ���� �� ����� � ������.
*/
select
    f.film_id,
    count(r.rental_id) as "����� ������ ������",
    sum(p.amount) as "����� �����"
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
������� 9. ���������� ���������� ������, ����������� ������ ���������. �������� ����������� ������� ��������. ���� ���������� ������ ��������� 7 300, �� �������� � ������� ����� ���, ����� ������ ���� �������� ����.
*/
select
	s.staff_id,
	count(p.amount) as cnt,
	case when count(p.amount) > 7300 then '��' else '���' end "������"
from
	staff s
join payment p on
	s.staff_id = p.staff_id
	group by s.staff_id;