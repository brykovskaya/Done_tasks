
--Задание 1
--вывести только те строки в таблице, где email является уникальным.

--удалим таблицу Staff если она существует
DROP TABLE Staff;

--создадим таблицу Staff 

CREATE TABLE Staff (
  staff_id SERIAL,
  name VARCHAR(25),
  salary INT,
  email VARCHAR(100),
  birthday DATE,
  jobtitle_id INT
);

INSERT INTO Staff (name, salary, email, birthday, jobtitle_id) VALUES
 ('Иванов Сергей', 100000, 'test@test.ru', '1990-03-03', 1),
 ('Петров Пётр',60000,'petr@test.ru','2000-12-01',7),
 ('Сидоров Василий',80000,'test@test.ru','1999-02-04',6),
 ('Максимов Иван',70000,'ivan.m@test.ru','1997-10-02',4),
 ('Попов Иван',120000,'popov@test.ru','2001-04-25',5);

--запрос строк в таблице, где email является уникальным.
WITH cte AS (
	SELECT 
		email,
		COUNT(email) AS cnt_email
	FROM staff s 
	GROUP BY email
		)
SELECT 
	staff_id, name, salary, email, birthday, jobtitle_id
FROM cte
LEFT JOIN Staff USING(email)
WHERE 
	cnt_email < 2;

--Задание 2
--Задание: вывести должность (Jobtitles.name) со вторым по величине уровнем зарплаты.
--Ожидаемый результат: “Разработчик”.
--Пояснение: в таблице Staff вторая по величине зарплата - 100000. Она соответствует должности “Разработчик”. 

--таблица Staff уже существует - задание 1
--удалим таблицу jobtitles  если она существует
DROP TABLE jobtitles ;

--создадим таблицу jobtitles  
CREATE TABLE jobtitles (
  jobtitle_id INT,
  name VARCHAR
);

INSERT INTO jobtitles (jobtitle_id, name)
VALUES (1, 'Разработчик'),
       (2, 'Системный аналитик'),
       (3, 'Менеджер проектов'),
       (4, 'Системный администратор'),
       (5, 'Руководитель группы'),
       (6, 'Инженер тестирования'),
       (7, 'Сотрудник группы поддержки');

--вариант 1
WITH cte AS(
	SELECT 
		j.name, salary
	FROM Staff AS s
	JOIN jobtitles AS j USING (jobtitle_id)
	WHERE 
		salary NOT IN (SELECT max(salary) FROM Staff) 
	)
SELECT name
FROM cte
WHERE salary = (SELECT MAX(salary) FROM cte);
    
--вариант 2
-- плох если есть более одного претендента на вторую по величине зп
WITH cte AS
(
	SELECT 
		jobtitle_id,
		MAX(salary) OVER() AS max_salary 
	FROM Staff
)
SELECT 
	j.name
FROM jobtitles AS j
JOIN Staff AS s 
	ON j.jobtitle_id=s.jobtitle_id 
JOIN cte 
	ON j.jobtitle_id=cte.jobtitle_id 
WHERE salary < max_salary
ORDER BY salary DESC 
LIMIT 1;

--вариант 3
--проранжируем зп. и если на 2 месте будет более одной должности, то получим их все.
SELECT 
	j.name
FROM 
	jobtitles AS j 
JOIN (
	SELECT *,
		DENSE_RANK() OVER (ORDER BY salary DESC) AS rank_salary      
	FROM Staff
	) AS s USING (jobtitle_id)
WHERE 
	rank_salary = 2;

-- Задача 3
--напишите запрос, с помощью которого можно определить возраст каждого сотрудника из таблицы Staff на момент запроса.
--Ожидаемый результат: находим разницу между текущей датой и датой рождения.
--Вариант 1
-- находим только разницу между текущей датой и датой рождения.
SELECT 
	name, 
	AGE(CURRENT_DATE, birthday) AS age_years--разница между текущей датой и датой рождения
FROM Staff;

-- Вариант 2
-- дополнительно выделяем количество полных лет из возраста

SELECT 
	name, 
	EXTRACT (YEAR FROM AGE(CURRENT_DATE, birthday)) AS exact_age,--разница между текущей датой и датой рождения
	AGE(CURRENT_DATE, birthday) AS age_years                     -- полных лет
FROM Staff;


















