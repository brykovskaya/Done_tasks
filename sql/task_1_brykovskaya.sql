
--удалим таблицу tab если она существует
DROP TABLE tab;
--создадим таблицу tab 
CREATE TABLE tab( key int, id int, phone varchar(30), mail varchar(30));
--наполним столбцы таблицы данными
INSERT INTO tab (key, id, phone, mail)
VALUES
	(1, 12345, 89997776655, 'test@mail.ru'),
	(2, 54321, 87778885566, 'two@mail.ru'),
	(3, 98765, 87776664577, 'three@mail'),
	(4, 66678, 87778885566, 'four@mail.ru'),
	(5, 34567, 84547895566, 'four@mail.ru'),
	(6, 34567, 89087545678, 'five@mail.ru');
--проверим созданную таблицу
SELECT 
	* 
FROM 
	tab;
--используем рекурсивный запрос 
WITH RECURSIVE req AS
(	--стартовая часть
	SELECT
		1 n
		,key
		,id
		,phone
		,mail
		,CAST(key AS varchar) AS keys
		, 'first' AS fl -- поле для позиции первого вхождения подстроки в строку
  	FROM 
  		tab 
  	WHERE
  		phone = '87778885566'
  	GROUP BY
  		key
  		,id
  		,phone
  		,mail
  	UNION ALL
  	-- рекурсивная часть 
  	SELECT 
  		n+1
  		,b.key
		,b.id
		,b.phone
		,b.mail
     	,CONCAT(keys,',',CAST(b.key AS varchar)) AS keys
     	,CONCAT(
     		CASE 
	     		WHEN b.id=a.id 
	     			THEN 'id ' 
     		ELSE ''
	     	END
			,CASE 
				WHEN b.phone=a.phone 
					THEN 'phone ' 
				ELSE ''
			END
     		,CASE 
	     		WHEN b.mail=a.mail 
	     			THEN 'mail ' 
	     		ELSE ''
	     	END)
  	FROM
  		req AS a 
  	INNER JOIN (
  			SELECT
  				key
  				,id
  				,phone
  				,mail 
  			FROM 
  				tab 
  			GROUP BY
  				key
  				,id
  				,phone
  				,mail
  				) AS b
    ON ((
        (b.id=a.id) 
        OR (b.phone=a.phone)
        OR (b.mail=a.mail)
        ))
        --Функция POSITION () возвращает позицию первого вхождения подстроки в строку. 
        --Если подстрока не найдена в исходной строке, эта функция возвращает 0
    AND POSITION (
    	CAST(b.key AS varchar) IN a.keys
   				 ) < 1
)
SELECT
	key
	,id
	,phone
	,mail
FROM 
	req
GROUP BY
	key
	,id
	,phone
	,mail
ORDER BY
	key;