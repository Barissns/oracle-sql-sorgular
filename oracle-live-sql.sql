--------------- SELECT – WHERE – ORDER BY ---------------
-- Tüm çalışanların ad ve soyadlarını listele
SELECT first_name, last_name 
FROM hr.employees;

-- Maaşı 10000’den fazla olan çalışanları getir
SELECT first_name, salary 
FROM hr.employees 
WHERE salary > 10000;

-- Çalışanları işe giriş tarihine göre sıralayarak listele
SELECT first_name, hire_date 
FROM hr.employees 
ORDER BY hire_date ASC;

-- Maaşı 10.000'den fazla olan çalışanların adlarını ve maaşlarını getir
SELECT first_name, salary 
FROM hr.employees 
WHERE salary > 10000
order by salary desc;

-- deprtmen_id 'si 20, 30 veya 40 olan çalışanları bul 
select first_name,last_name, department_id
from hr.employees
where department_id in (20,30,40)
order by department_id

--------------- Fonksiyonlar (String, Sayısal, Tarih) ---------------
-- Ad ve soyadı birleştirerek tam isim göster
SELECT first_name || ' ' || last_name AS full_name FROM hr.employees;

-- Concat ile birleştirme
SELECT CONCAT(first_name, last_name) FROM hr.employees;

-- lower hepsini küçük olarak getiriyor.
select upper (FIRST_NAME), upper(last_name)
from hr.employees

-- mod alma
select Mod(salary, 500) 
from hr.employees

-- Maaşın %25 zamlı halini göster
SELECT salary, salary * 1.25 AS increased_salary 
FROM hr.employees;

-- İşe giriş tarihinden bu yana geçen gün sayısını hesapla
SELECT first_name, SYSDATE - hire_date AS days_worked 
FROM hr.employees;

-- 1999-01-01 tarihinden sonra işe başlayanları göster.
SELECT FIRST_NAME, LAST_NAME, HIRE_DATE 
FROM HR.EMPLOYEES 
WHERE HIRE_DATE > DATE '1999-01-01';

-- Bugünün tarhi (dual)
SELECT TO_CHAR(SYSDATE, 'DD-MM-YYYY') AS today_date 
FROM DUAL;

--------------- GROUP BY, HAVING ve Toplama Fonksiyonları ---------------
-- Departmanlara göre ortalama maaşları göster
SELECT department_id, AVG(salary) AS avg_salary
FROM hr.employees
GROUP BY department_id;

-- Departmanlara göre çalışan sayısını göster
SELECT department_id, COUNT(*) AS employee_count
FROM hr.employees
GROUP BY department_id;

-- Sadece 8’ten fazla çalışanı olan departmanları listele
SELECT department_id, COUNT(*) AS employee_count
FROM hr.employees
GROUP BY department_id
HAVING COUNT(*) > 8;

-- ortalama maaşı 777 den büyük olan iş pozisyonlarını getir.
select job_id, avg(salary) as avg_salary
from hr.employees
group by job_id
having avg(salary) > 777

-- yıl ve departmana göre işe alım sayısını göster
select extract(year from hire_date) as hire_year,
department_id,
count(*) as hires
from hr.employees
group by extract(year from hire_date), department_id 
order by hire_year, department_id

--------------- JOIN’ler (Çoklu Tablo İşlemleri) ---------------
/* İsveç'de ( Sweden ) çalışan personellerin isimlerini ve şehirlerini listeleyin. */
select e.first_name, e.last_name, l.city
from hr.EMPLOYEES e
inner join hr.departments d on e.department_id = d.department_id 
inner join hr.locations l on d.location_id = l.location_id
inner join hr.countries c on l.country_id = c.country_id
where c.country_name = 'Sweden'

/* Maaşı 7.750'den fazla olan çalışanların isimlerini, maaşlarını ve iş ünvanlarını (job_title) gösterin */
select e.first_name, e.last_name, e.salary, j.job_title
from hr.EMPLOYEES e
inner join hr.JOBS j 
on e.job_id = j.job_id
where e.salary > 7750

/* Hangi departmanlarda hiç çalışan yoktur? Bu departmanları listeleyin */
select d.department_name
from hr.DEPARTMENTS d 
left join hr.EMPLOYEES e
on d.DEPARTMENT_ID = e. DEPARTMENT_ID
where e.employee_id is null

-- Right Outer Join
select e.first_name, e.last_name, d.department_name
from hr.EMPLOYEES e
Right Join hr.DEPARTMENTS d 
On e.DEPARTMENT_ID = d.DEPARTMENT_ID

-- Full Join 
select e.first_name,e.last_name,d.department_name
from hr.EMPLOYEES e
full Outer Join hr.DEPARTMENTS d
on e.DEPARTMENT_ID = d.DEPARTMENT_ID

-- Cross Join
select e.first_name, e.last_name,d.department_name
from hr.EMPLOYEES e
cross join hr.DEPARTMENTS d

-- Self Join
select e.first_name as EMPLOYEE_NAME,
    m.first_name as MANAGER_NAME
from hr.EMPLOYEES e
left join hr.EMPLOYEES m
on e.manager_id = m.employee_id

--------------- Alt Sorgular (Subqueries)  ---------------
-- En yüksek maaşı alan çalışanı getir
SELECT first_name, salary
FROM hr.employees
WHERE salary = (SELECT MAX(salary) FROM hr.employees);

-- Ortalama maaştan fazla kazanan çalışanlar
SELECT first_name, salary
FROM hr.employees
WHERE salary > (SELECT AVG(salary) FROM hr.employees);

-- IT departmanındaki çalışanlar
SELECT first_name
FROM hr.employees
WHERE department_id = (
  SELECT department_id FROM hr.departments WHERE department_name = 'IT'
);

/* Belirli bir departmanın ortalama maaşından fazla kazanan kişileri bulan sorguyu yazın. (10) */
select first_name, last_name, salary, department_id
from hr.employees
where salary > (
    select Avg(salary)
    from hr.employees
    where department_id = 10
)

--------------- UNION – UNION ALL, CTE (WITH)  ---------------
-- IT ve Finance departmanlarındaki çalışanlar (UNION ile)
SELECT first_name 
FROM hr.employees 
WHERE department_id = 60
UNION
SELECT first_name 
FROM hr.employees 
WHERE department_id = 100;

-- Yüksek maaşlı çalışanlar ve yöneticileri birleştir
select first_name, last_name, 'Yüksek Maaşlı' as Category, salary
from hr.employees
where salary > 10000
Union
select first_name, last_name, 'Manager' as Category ,salary
from hr.employees
where employee_id In (
    select distinct manager_id 
    from hr.employees 
where manager_id is not null)

-- Aynı sorgu ama tekrarları da gösterir (UNION ALL)
SELECT first_name FROM hr.employees WHERE department_id = 60
UNION ALL
SELECT first_name FROM hr.employees WHERE department_id = 100;

-- Basit CTE
WITH HIGH_EARNERS AS (
    SELECT FIRST_NAME, LAST_NAME, SALARY, DEPARTMENT_ID
    FROM HR.EMPLOYEES
    WHERE SALARY > (SELECT AVG(SALARY) FROM HR.EMPLOYEES)
)
SELECT D.DEPARTMENT_NAME, COUNT(*) AS HIGH_EARNER_COUNT
FROM HIGH_EARNERS H
JOIN HR.DEPARTMENTS D ON H.DEPARTMENT_ID = D.DEPARTMENT_ID
GROUP BY D.DEPARTMENT_NAME
ORDER BY HIGH_EARNER_COUNT DESC;

-- Çoklu CTE
WITH 
DEPT_STATS AS (
    SELECT DEPARTMENT_ID, AVG(SALARY) AS AVG_SALARY, COUNT(*) AS EMP_COUNT
    FROM HR.EMPLOYEES
    GROUP BY DEPARTMENT_ID
),
HIGH_SALARY_DEPTS AS (
    SELECT DEPARTMENT_ID
    FROM DEPT_STATS
    WHERE AVG_SALARY > 8000
),
LOCATION_INFO AS (
    SELECT D.DEPARTMENT_ID, D.DEPARTMENT_NAME, L.CITY, C.COUNTRY_NAME
    FROM HR.DEPARTMENTS D
    JOIN HR.LOCATIONS L ON D.LOCATION_ID = L.LOCATION_ID
    JOIN HR.COUNTRIES C ON L.COUNTRY_ID = C.COUNTRY_ID
)
SELECT E.FIRST_NAME, E.LAST_NAME, E.SALARY, LI.DEPARTMENT_NAME, LI.CITY, LI.COUNTRY_NAME
FROM HR.EMPLOYEES E
JOIN HIGH_SALARY_DEPTS HSD ON E.DEPARTMENT_ID = HSD.DEPARTMENT_ID
JOIN LOCATION_INFO LI ON E.DEPARTMENT_ID = LI.DEPARTMENT_ID
ORDER BY E.SALARY DESC;

--------------- Analitik Fonksiyonlar (ROW_NUMBER, RANK) ---------------
-- Maaşa göre sıralama numarası ver
SELECT first_name, salary,
       ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num
FROM hr.employees;

-- Aynı maaşlar için sıralama (RANK)
SELECT first_name, salary,
       RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM hr.employees;

-- Departman içinde maaş sıralaması
SELECT first_name, department_id, salary,
       RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS dept_rank
FROM hr.employees;

--8. Maaş dağılımında üst %10'da olan çalışanları ve bunların özelliklerini analiz edin.
WITH SALARY_PERCENTILES AS (
    SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME, SALARY,
           PERCENT_RANK() OVER (ORDER BY SALARY DESC) AS SALARY_PERCENTILE
    FROM HR.EMPLOYEES
),
TOP_10_PERCENT AS (
    SELECT * FROM SALARY_PERCENTILES WHERE SALARY_PERCENTILE <= 0.1
)
SELECT T.FIRST_NAME, T.LAST_NAME, T.SALARY, D.DEPARTMENT_NAME, J.JOB_TITLE,
       L.CITY, C.COUNTRY_NAME,
       ROUND(MONTHS_BETWEEN(SYSDATE, E.HIRE_DATE)/12, 1) AS YEARS_EXPERIENCE,
       CASE WHEN E.COMMISSION_PCT IS NOT NULL THEN 'Has Commission' ELSE 'No Commission' END AS COMMISSION_STATUS,
       (SELECT COUNT(*) FROM HR.EMPLOYEES E2 WHERE E2.MANAGER_ID = E.EMPLOYEE_ID) AS DIRECT_REPORTS
FROM TOP_10_PERCENT T
JOIN HR.EMPLOYEES E ON T.EMPLOYEE_ID = E.EMPLOYEE_ID
JOIN HR.DEPARTMENTS D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
JOIN HR.JOBS J ON E.JOB_ID = J.JOB_ID
JOIN HR.LOCATIONS L ON D.LOCATION_ID = L.LOCATION_ID
JOIN HR.COUNTRIES C ON L.COUNTRY_ID = C.COUNTRY_ID
ORDER BY T.SALARY DESC;

--------------- Oracle’a Özgü Fonksiyonlar (NVL, DECODE, DUAL, CONNECT BY) ---------------
-- nvl => oracle db ye özgü fonksiyon, null değerleri istediğimiz değerle değiştirmemize olanak sunar
select first_name, nvl(commission_pct,0) as commissions
from hr.employees

-- Komisyonu olmayanlara “0” değeri ver
SELECT first_name, NVL(commission_pct, 0) AS commission
FROM hr.employees;

-- nvl2
select first_name, nvl2(commission_pct,'yes commission','no commission') as commission_status
from hr.employees

-- İş tanımına göre rol belirle
SELECT job_id,
       DECODE(job_id, 'IT_PROG', 'Developer', 'AD_VP', 'Vice President', 'Other') AS role
FROM hr.employees;

-- CONNECT BY ile hiyerarşi (yönetici → çalışan)
SELECT employee_id, first_name, manager_id
FROM hr.employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;
