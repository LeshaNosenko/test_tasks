/*
������� 1. �������� ���������� �������� ������� �� ������� �������.
*/
select distinct c.city from city c order by c.city asc;
/*
������� 2. ����������� ������ �� ����������� �������, ����� ������ ������� ������ �� ������, �������� ������� ���������� �� �L� � ������������� �� �a�, � �������� �� �������� ��������.
*/
select distinct c.city from city c where c.city like 'L%' and c.city like '%a' and c.city not like '% %' order by c.city asc;
/*
������� 3. �������� �� ������� �������� �� ������ ������� ���������� �� ��������, ������� ����������� � ���������� � 17 ���� 2005 ���� �� 19 ���� 2005 ���� ������������ � ��������� ������� ��������� 1.00. ������� ����� ������������� �� ���� �������.
*/
select * from payment p where p.payment_date between '2005-06-17' and '2005-06-19' and p.amount >1.00 order by p.payment_date desc;
/*
������� 4. �������� ���������� � 10-�� ��������� �������� �� ������ �������.
*/
select * from payment p order by payment_date desc limit 10;
/*
������� 5. �������� ��������� ���������� �� �����������:
�	������� � ��� (� ����� ������� ����� ������)
�	����������� �����
�	����� �������� ���� email
�	���� ���������� ���������� ������ � ���������� (��� �������)

 ������ ������� ������� ������������ �� ������� �����.
*/
select c.last_name || ' ' || c.first_name as "���", c.email as "�-����", length(c.email) as "����� �-�����", c.last_update::date as "���� ���������� ��� �������"  from customer c;
/*
������� 6. �������� ����� �������� ������ �������� �����������, ����� ������� KELLY ��� WILLIE. ��� ����� � ������� � ����� �� �������� �������� ������ ���� ���������� � ������ �������.
*/
select lower(c.last_name || ' ' || c.first_name) from customer c where c.activebool is true and (c.first_name = 'KELLY' or  c.first_name = 'WILLIE');
/*
������� 7. �������� ����� �������� ���������� � �������, � ������� ������� �R� � ��������� ������ ������� �� 0.00 �� 3.00 ������������, � ����� ������ c ��������� �PG-13� � ���������� ������ ������ ��� ������ 4.00.
*/
select * from film f where ( f.rating = 'R' and f.rental_rate between 0.00 and 3.00) or (f.rating = 'PG-13' and f.rental_rate >= 4.00);
/*
������� 8. �������� ���������� � ��� ������� � ����� ������� ��������� ������.
*/
select * from film f order by length (f.description) desc limit 3;
/*
������� 9. �������� Email ������� ����������, �������� �������� Email �� 2 ��������� �������:
�	� ������ ������� ������ ���� ��������, ��������� �� @,
�	�� ������ ������� ������ ���� ��������, ��������� ����� @.
*/
select split_part(c.email,'@',1) as "�-���� �� ������� @",  split_part(c.email,'@',2) "�-���� ����� ������� @", c.email as "�-����" from customer c;
/*
������� 10. ����������� ������ �� ����������� �������, �������������� �������� � ����� ��������: ������ ����� ������ ���� ���������, ��������� ���������.
*/
select initcap(split_part(c.email,'@',1)) as "�-���� �� ������� @ � 1 ���������",  initcap(split_part(c.email,'@',2)) "�-���� ����� ������� @ � 1 ���������", c.email as "�-����" from customer c;
