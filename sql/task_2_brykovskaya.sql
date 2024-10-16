drop table LOANS_TABLE;
CREATE TABLE LOANS_TABLE (
LOAN_ID int, ----номер договора
CLIENT_ID int, ---- идентификатор клиента
LOAN_DATE date, ----дата договора
LOAN_AMOUNT float); --сумма по договору

drop table CLIENTS_TABLE;
CREATE TABLE CLIENTS_TABLE (
CLIENT_ID int, --идентификатор клиента
CLIENT_NAME VARCHAR(20), --ФИО клиента
BIRTHDAY date, --ДР клиента
GENDER VARCHAR(20)); --пол клиента

INSERT INTO CLIENTS_TABLE
VALUES
(1, 'bob', '20200115', 'male'),
(2, 'rocky', '20200215', 'female'),
(3, 'like', '20200215', 'female'),
(4, 'ricky', '20200215', 'male');

INSERT INTO LOANS_TABLE
VALUES
(1, 1, '20200115', 10000), 
(2, 2, '20200215', 20000), 
(3, 3, '20200315', 30000), 
(4, 4, '20200415', 40000), 
(5, 1, '20200116', 15000),
(6, 2, '20200315', 35000),
(7, 3, '20200315', 5000),
(8, 1, '20200115', 1500),
(9, 2, '20200115', 500),
(10, 1, '20200115', 1500);

SELECT * FROM CLIENTS_TABLE;
WITH cte AS (
	SELECT 
		t.client_id, 
		gender, 
		enum_loan, 
		loan_amount
	FROM (
		SELECT 
			*,
			ROW_NUMBER () OVER (PARTITION BY client_id ORDER BY loan_date) 
				AS enum_loan
		FROM 
		LOANS_TABLE
		) AS t
	JOIN 
		CLIENTS_TABLE AS c 
			ON t.client_id=c.client_id
)
SELECT 
	gender,
	COUNT(
		case 
			when enum_loan = 1 
				then enum_loan 
		end) as first_loan,
	COUNT(
		case 
			when enum_loan = 2 
				then enum_loan 
		end) as second_loan,
	COUNT(
		case 
			when enum_loan = 3 
				then enum_loan 
		end) as third_loan,
	COUNT(
		case 
			when enum_loan = 4 
				then enum_loan 
		end) as fourth_loan
FROM cte
GROUP BY gender;




--loan_id, client_id, loan_amount