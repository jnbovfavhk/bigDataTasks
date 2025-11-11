-- 01 Получите список районов Нью-Йорка, при поездке из которых суммарная оплата наличными за всё время наблюдения составила более $500000. При суммировании учитывайте только положительные суммы оплаты поездки.

-- Ваш код:
SELECT pickup_ntaname, SUM(total_amount)
FROM trips
WHERE payment_type = 'CSH'
AND total_amount > 0
GROUP BY pickup_ntaname
HAVING SUM(total_amount) > 500000;

-- 02 В какое время суток предпочитают расплачиваться картой и в какое время наличными? Постройте два запроса со средней суммой оплаты в зависимости от времени суток для оплат картой и наличными. При суммировании учитывайте только положительные суммы оплаты поездки.

-- Ваш код:
select payment_type, sum(total_amount) / count(total_amount) FROM trips
where total_amount > 0
and toHour(pickup_datetime) > 3
and toHour(pickup_datetime) < 16
group by payment_type; -- от 8 до 20:00

select payment_type, sum(total_amount) / count(total_amount) FROM trips
where total_amount > 0
and toHour(pickup_datetime) < 9
or toHour(pickup_datetime) > 15
group by payment_type; -- от 20 до 8:00

-- 03 Какие виды оплаты предпочитают компании из нескольких пассажиров? Получите списки вариантов оплаты, используемых пассажирами, в зависимости от их количества. Исключите случаи, когда число пассажиров меньше 2. Компании из скольки человек предпочитают оплату наличными?

-- Ваш код:
SELECT passenger_count, topK(1)(payment_type) -- топ самых частых с одним значением
from trips
where passenger_count >= 2
group by passenger_count;

-- 04 Постройте граф поездок - в первой колонке выведите район отправления, а во второй - список районов прибытия. Исключите из рассмотрения записи, в который районы отправления или прибытия не указаны. Таблицу отсортируй по убыванию длины списка прибытия.
select pickup_ntaname, groupArray(dropoff_ntaname)
from trips
where pickup_ntaname != ''
and dropoff_ntaname != ''
group by pickup_ntaname
order by length(groupArray(dropoff_ntaname)) DESC;
-- Ваш код:

-- 05 Для каждого района отправление найдите три наиболее частых района прибытия. Исключите из рассмотрения записи, в который районы отправления или прибытия не указаны. Используйте функцию topK.

-- Ваш код:
select pickup_ntaname, topK(3)(dropoff_ntaname), count() AS total_trips
from trips t
where pickup_ntaname != ''
and dropoff_ntaname != ''
group by pickup_ntaname;
-- 06 Вычислите квантили уровней 0.25, 0.5, 0.75 и 1  для полной суммы оплаты поездки используя приближенную функцию quantiles и точную quantilesExact. Используя только стандартный SQL (без расширенных возможностей ClickHouse), вычислите квантиль уровня 1. Сравните результаты трёх созданных запросов. Оцените насколько приближённые квантили отличаются от точных. Проанализируйте, почему это происходит. Возможно, в этом поможет изучение упорядоченных значений суммы оплаты поездки и точных квантилей вблизи единицы.


-- Ваш код:
-- приближенные
SELECT quantiles(0.25, 0.5, 0.75, 1)(total_amount)
FROM trips
WHERE total_amount > 0;

-- Точные 
SELECT quantilesExact(0.25, 0.5, 0.75, 1)(total_amount)
FROM trips
WHERE total_amount > 0;

SELECT MAX(total_amount)
FROM trips
WHERE total_amount > 0;

-- значения приближенных квантилей отличается от точных, потому что приближенные берут в расчет не все данные для лучшей 
-- скорочти выполнения. они выбирают определенное количество случаных по порядку значений из столбца. из-за этого квантиль 
-- уровня 1(максимум по столбцу) приближенно вычислять не стоит

-- 07 Создайте запрос, который вычисляет гистограмму из 10 ячеек для значений из столбца полной суммы оплаты поездки Исключите из рассмотрения отрицательные значения. Какие суммы оплаты встречаются чаще всего?

-- Ваш код:

SELECT 
    arrayJoin(histogram(10)(total_amount))
FROM trips
WHERE total_amount > 0;

-- на выходе получаем 3 столбца: начало ячейки, конец, примперное количество поездок сумма которых в диапазоне этой ячейки
-- 08 В поле полной суммы оплаты поездки есть отрицательные значения. Проанализируйте связь этих отрицательных значений с другими данным в таблице. Например, выясните как положительные и отрицательные оплаты связаны с временем суток поездок и районами начала и окончания. Ответьте на вопрос - можно ли считать это потерями таксистов, например, вследствие ограблений, или вероятнее всего это просто ошибочные данные.


-- Ваш код:
SELECT 
    count() AS negative_count,
    round(count() * 100.0 / (SELECT count() FROM trips), 4) AS negative_percent,
    avg(total_amount) AS avg_negative_amount,
    min(total_amount) AS min_negative_amount,
    max(total_amount) AS max_negative_amount
FROM trips 
WHERE total_amount < 0;

-- как положительные и отрицательные оплаты связаны с временем суток поездок 
SELECT 
    toHour(pickup_datetime) AS hour_of_day,
    count() AS total_count,
    countIf(total_amount < 0) AS negative_count,
    round(countIf(total_amount < 0) * 100.0 / count(), 2) AS negative_percent
FROM trips
GROUP BY hour_of_day;
-- как будто они не связаны со временем

-- связь с районами
SELECT 
    pickup_ntaname,
    count() AS total_trips,
    countIf(total_amount < 0) AS negative_trips,
    round(countIf(total_amount < 0) * 100.0 / count(), 4) AS negative_percent
FROM trips
WHERE pickup_ntaname != ''
GROUP BY pickup_ntaname
HAVING countIf(total_amount < 0) > 0
ORDER BY negative_percent DESC;
-- в некоторых районах процент негативных значений значительно больше, чем в других

-- судя по анализу, это точно не ограбления. это могут быть отмены поездок или ошибочные данные