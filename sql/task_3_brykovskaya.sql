/*
 * Для отклика на эту вакансию необходимо ответить на несколько вопросов работодателя.
У вас есть SQL база данных с таблицами международной частной клиники, которая существует много лет:
1) patients(patientid, age)
2) visits(visitid, patientid, serviceid, date)
3) services(serviceid, cost)
Напишите четыре SQL запроса для расчета следующих метрик. В расчете учитывайте повышенную вероятность коллизий(противоречий) по агрегатам различных метрик, например, существует несколько услуг с одинаковой доходностью в промежутке времени.
А) какую сумму в среднем в месяц тратит:
- пациент в возрастном диапазоне от 18 до 25 лет включительно
- пациент в возрастном диапазоне от 26 до 35 лет включительно

Б) в каком месяце года доход от пациентов в возрастном диапазоне 35+ самый большой
В) какая услуга обеспечивает наибольший вклад в доход за последний год
Г) ежегодные топ-5 услуг по доходу и их доля в общем доходе за год

для удобства - сформировала Бд в PostgreSQL схема med с тремя таблицами patients services visits
данные за 2 полных года

 */ 
--посмотрим как загрузились данные
SELECT * 
FROM med.patients p 
LIMIT 5;

SELECT * 
FROM med.services
LIMIT 5;

SELECT * 
FROM med.visits
LIMIT 5;

/*
для удобства - сформировала Бд в PostgreSQL схема med с тремя таблицами patients services visits
данные за 2 полных года
ЗАДАЧА 1
какую сумму в среднем в месяц тратит:
- пациент в возрастном диапазоне от 18 до 25 лет включительно
- пациент в возрастном диапазоне от 26 до 35 лет включительно
*/

WITH cte1 AS ( 
	SELECT 
		*,
		CASE 
			WHEN age BETWEEN 26 AND 35
				THEN '26-35 лет'
			WHEN age BETWEEN 18 AND 25
				THEN '18-25 лет'
			WHEN age > 35
				THEN '35+ лет '
			WHEN age < 18
				THEN '0-17 лет'
		END AS category
	FROM 
		med.visits AS v
	LEFT OUTER JOIN 
		med.services AS s USING(serviceid) 
	LEFT OUTER JOIN med.patients AS p USING(patientid)
),
cte2 AS ( 
	SELECT 
		*,
		EXTRACT(MONTH FROM date) AS month,
		COUNT(patientid) OVER (PARTITION BY category, EXTRACT(MONTH FROM date)
			) AS patients_cnt,
		SUM(cost) OVER (PARTITION BY category, EXTRACT(MONTH FROM date)
			) AS month_costs
	FROM 
		cte1
	ORDER BY 
		month DESC
),
cte3 AS ( 
	SELECT 
		category, 
		month,
		ROUND(month_costs::NUMERIC / patients_cnt
				) AS avg_month_costs
	FROM 
		cte2
	GROUP BY 
		category, 
		MONTH, 
		month_costs, 
		patients_cnt
	ORDER BY 
		category
),
tasc_1 AS ( 
SELECT 
	category,
	ROUND(AVG(avg_month_costs),2) AS avg_month_costs_category
FROM 
	cte3
WHERE category IN ('26-35 лет', '18-25 лет')	
GROUP BY 
	category
)
/*для удобства - сформировала Бд в PostgreSQL схема med с тремя таблицами patients services visits
данные за 2 полных года
ЗАДАЧА 2*/
SELECT 
	category,
	MAX(avg_month_costs) AS max_costs
FROM 
	cte3
WHERE category = '35+ лет '
GROUP BY 
	category;

/*
 для удобства - сформировала Бд в PostgreSQL схема med с тремя таблицами patients services visits
данные  сгенерированы за полные 2024 и 2023 год.
 ЗАДАЧА 3
какая услуга обеспечивает наибольший вклад в доход за последний год
*/

SELECT *
FROM (
	SELECT 
		serviceid,
		SUM(cost) AS amount
	FROM 
		med.visits
	LEFT OUTER JOIN 
		med.services USING(serviceid)
	WHERE EXTRACT(YEAR FROM date) = 2024
	GROUP BY serviceid
		) AS tab
ORDER BY amount DESC
LIMIT 1;

/* ЗАДАЧА 4 
  для удобства - сформировала Бд в PostgreSQL схема med с тремя таблицами patients services visits
данные  сгенерированы за полные 2024 и 2023 год.
 * ежегодные топ-5 услуг по доходу и их доля в общем доходе за год*/

WITH cte AS ( 
SELECT 
	*,
	sum(amount) OVER (PARTITION BY year) AS year_amount,
	ROW_NUMBER() OVER (PARTITION BY YEAR ORDER BY amount DESC) AS top_by_year
FROM (
	SELECT 
		serviceid,
		EXTRACT(YEAR FROM date) AS year,
		SUM(cost) AS amount
	FROM 
		med.visits
	LEFT OUTER JOIN 
		med.services USING(serviceid)
	GROUP BY 
		serviceid,
		YEAR
	ORDER BY 
		year, 
		amount DESC
	) AS tab
)
SELECT
	year,
	serviceid,
	top_by_year,
	ROUND(amount::NUMERIC / year_amount, 4) AS part_amount
FROM 
	cte
WHERE 
	top_by_year <=5;















