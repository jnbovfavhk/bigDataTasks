-- 01 Получите список актёров, чьи фамилии - 'WILLIAMS' или 'DAVIS', а затем найдите в нём имя, начинающиеся на 'J'. Запишите имя и фамилию этого актёра.

-- Ваш код:
SELECT first_name, last_name FROM actor 
WHERE last_name IN ('WILLIAMS', 'DAVIS') and first_name LIKE 'J%';

-- Ваш ответ:
JENNIFER	DAVIS

-- 02 Получите список выдачи дисков в прокат (таблица rental) от 5 июля 2005 года. Чтобы игнорировать время выдачи, можно использовать функцию date(). Определите, какой заказ из этого списка был возвращён самым последним. Запишите дату.

-- Ваш код:
SELECT * FROM rental where date(rental_date) = "2005-07-05"
ORDER BY return_date DESC
LIMIT 1;

-- Ваш ответ:
2005-07-15 02:31:19

-- 03 Создайте запрос, который находит всех клиентов, начальные буквы фамилий которых находятся между 'AN' и AT'. Отсортируйте вывод по именам.

-- Ваш код:
SELECT * FROM customer c 
WHERE last_name BETWEEN 'AN%' AND 'AT%'
ORDER BY first_name;
-- Ваш ответ:
BEATRICE
CARL
DARRYL
HARRY
IDA
JORDAN
JOSE
KENT
LISA
MELANIE
OSCAR
TYRONE

-- 04 Создайте запрос, который находит всех клиентов, в фамилиях которых содержатся буква А во второй позиции и буква W — в любом месте после А. Отсортируйте результат по фамилиям. Если не знаете как это сделать, ищите информацию об использовании в запросах подстановочных знаков.

-- Ваш код:
SELECT * FROM customer 
WHERE last_name like '_A%W%'
ORDER BY last_name;

-- Ваш ответ:CALDWELL
FARNSWORTH
HAWKINS
HAWKS
LAWRENCE
LAWSON
LAWTON
MARLOW
MATTHEWS


-- 05 Используя таблицы rental и customer среди клиентов, вернувших заказ 7 июля 2005 года найдите электронную почту того, кто продержал заказ дольше всех.

-- Ваш код:

SELECT MAX(return_date - rental_date) as max_durance, email
from rental r 
JOIN customer c on r.customer_id = c.customer_id
where date(return_date) = '2005-07-07'
GROUP BY email
order by max_durance desc
limit 1;

-- Ваш ответ:
HAZEL.WARREN@sakilacustomer.org

-- 06 Среди клиентов, разовый платёж которых за заказ был более 11 долларов и менее 12 найдите имя того, чья фамилия 'GILBERT'

-- Ваш код:
SELECT * FROM customer c 
join payment p on c.customer_id = p.customer_id 
where p.amount > 11 and p.amount < 12
AND	 c.last_name = 'GILBERT';
-- Ваш ответ:
237	1	TANYA	GILBERT	TANYA.GILBERT@sakilacustomer.org

-- 07 Постройте объединение таблиц customer, address и city и найдите имя, адрес и город клиента с фамилией 'JOHNSTON' из Калифорнии.

-- Ваш код:
SELECT c.first_name, a.address, c2.city FROM customer c 
join address a on c.address_id = a.address_id 
join city c2 on a.city_id = c2.city_id 
WHERE c.last_name = 'JOHNSTON'
AND a.district = 'California';
-- Ваш ответ:
KRISTINKRISTIN	226 Brest Manor	Sunnyvale

-- 08 Напишите запрос, который выводил бы названия всех фильмов, начинающиеся с буквы 'B', в которых играл актер с именем KARL.

-- Ваш код:
select f.title from film f 
join film_actor fa on f.film_id = fa.film_id 
join actor a on a.actor_id = fa.actor_id 
WHERE f.title like 'B%'
AND a.first_name = 'KARL';
-- Ваш ответ:
BOUND CHEAPER
BOWFINGER GABLES
BUNCH MINDS

-- 09 Используя таблицы rental и customer и функцию extract() найдите фамилию клиентки по имени JANET, которая в брала диски в августе и вернула в сентябре. Возможно для проверки и сравнения месяцев потребуется задействовать секцию having.

-- Ваш код:
SELECT c.last_name FROM customer c 
JOIN rental r on c.customer_id = r.customer_id 
WHERE c.first_name = 'JANET'
AND r.rental_date LIKE '_____08%'
AND r.return_date LIKE '_____09%';
-- Ваш ответ:
PHILLIPS

-- 10 Используя таблицу payment, подсчитайте количество платежей, которые сделал каждый клиент и общую уплаченную каждым клиентом сумму. Выполните упорядочивание результатов запроса по убыванию уплаченной суммы и ограничьте вывод тремя первыми записями.

-- Ваш код:
SELECT customer_id, SUM(amount) as amount_sum, COUNT(amount) as amount_count
FROM payment
group by customer_id
ORDER BY amount_sum DESC
limit 3;

-- Ваш ответ:
526	221.55	45
148	216.54	46
144	195.58	42

-- 11 Модифицируйте предыдущий запрос так, чтобы он дополнительно выдавал имена и фамилии трёх клиентов с наибольшими суммарными платежами.

-- Ваш код:
SELECT p.customer_id, SUM(p.amount) as amount_sum, COUNT(amount) as amount_count, c.first_name, c.last_name 
FROM payment p
JOIN customer c on c.customer_id = p.customer_id 
group by p.customer_id
ORDER BY amount_sum DESC
limit 3;
-- Ваш ответ:
KARL	SEAL
ELEANOR	HUNT
CLARA	SHAW
