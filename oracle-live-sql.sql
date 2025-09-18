--------------- SELECT – WHERE – ORDER BY ---------------

-- Bu sorgu, tüm çalışanların ad ve soyadlarını listeler.
-- SELECT ile sütunları seçiyoruz, FROM ile tabloyu belirtiyoruz.
SELECT first_name, last_name 
FROM hr.employees;

-- Bu sorgu, maaşı 10.000’den fazla olan çalışanları getirir.
-- WHERE ile filtreleme yapıyoruz, sadece salary > 10000 olanlar gelir.
SELECT first_name, salary 
FROM hr.employees 
WHERE salary > 10000;

-- Bu sorgu, çalışanları işe giriş tarihine göre sıralar.
-- ORDER BY hire_date ASC → en eski işe girenler en üstte olur.
SELECT first_name, hire_date 
FROM hr.employees 
ORDER BY hire_date ASC;

-- Bu sorgu, maaşı 10.000’den fazla olan çalışanları maaşlarına göre azalan şekilde sıralar.
-- ORDER BY salary DESC → en yüksek maaş en üstte olur.
SELECT first_name, salary 
FROM hr.employees 
WHERE salary > 10000
ORDER BY salary DESC;

-- Bu sorgu, departman ID’si 20, 30 veya 40 olan çalışanları listeler.
-- WHERE IN (...) ifadesiyle birden fazla değeri filtreleyebiliriz.
-- ORDER BY department_id → departmanlara göre sıralama yapılır.
SELECT first_name, last_name, department_id
FROM hr.employees
WHERE department_id IN (20, 30, 40)
ORDER BY 

--------------- Fonksiyonlar (String, Sayısal, Tarih) ---------------

-- Bu sorgu, çalışanların ad ve soyadlarını birleştirerek tam isim oluşturur.
-- || operatörü ile string birleştirme yapılır.
SELECT first_name || ' ' || last_name AS full_name 
FROM hr.employees;

-- Bu sorgu, CONCAT fonksiyonu ile ad ve soyadı birleştirir.
-- CONCAT sadece iki string alır, boşluk eklemek için ayrı bir CONCAT gerekebilir.
SELECT CONCAT(first_name, last_name) 
FROM hr.employees;

-- Bu sorgu, çalışanların ad ve soyadlarını büyük harfe çevirir.
-- UPPER fonksiyonu string ifadeleri büyük harfe dönüştürür.
SELECT UPPER(first_name), UPPER(last_name)
FROM hr.employees;

-- Bu sorgu, maaşların 500’e bölümünden kalanı verir.
-- MOD fonksiyonu sayısal işlemlerde kalan hesaplamak için kullanılır.
SELECT MOD(salary, 500) 
FROM hr.employees;

-- Bu sorgu, çalışanların maaşına %25 zam eklenmiş halini gösterir.
-- Sayısal işlemler doğrudan SELECT içinde yapılabilir.
SELECT salary, salary * 1.25 AS increased_salary 
FROM hr.employees;

-- Bu sorgu, çalışanların işe giriş tarihinden bugüne kadar geçen gün sayısını hesaplar.
-- SYSDATE bugünün tarihini verir, DATE farkı gün cinsinden hesaplanır.
SELECT first_name, SYSDATE - hire_date AS days_worked 
FROM hr.employees;

-- Bu sorgu, 1999-01-01 tarihinden sonra işe başlayan çalışanları listeler.
-- DATE 'YYYY-MM-DD' formatı ile sabit tarih karşılaştırması yapılır.
SELECT first_name, last_name, hire_date 
FROM hr.employees 
WHERE hire_date > DATE '1999-01-01';

-- Bu sorgu, bugünün tarihini DD-MM-YYYY formatında gösterir.
-- DUAL tablosu Oracle’da tek satırlık işlemler için kullanılır.
SELECT TO_CHAR(SYSDATE, 'DD-MM-YYYY') AS today_date 
FROM DUAL;

--------------- GROUP BY, HAVING ve Toplama Fonksiyonları ---------------

-- Bu sorgu, her departmanın ortalama maaşını hesaplar.
-- AVG(salary) ile ortalama alınır, GROUP BY ile departman bazında gruplama yapılır.
SELECT department_id, AVG(salary) AS avg_salary
FROM hr.employees
GROUP BY department_id;

-- Bu sorgu, her departmanda kaç çalışan olduğunu gösterir.
-- COUNT(*) ile toplam kişi sayısı alınır, GROUP BY ile departmanlara göre ayrılır.
SELECT department_id, COUNT(*) AS employee_count
FROM hr.employees
GROUP BY department_id;

-- Bu sorgu, sadece 8’den fazla çalışanı olan departmanları listeler.
-- HAVING COUNT(*) > 8 → gruplama sonrası filtreleme yapılır.
SELECT department_id, COUNT(*) AS employee_count
FROM hr.employees
GROUP BY department_id
HAVING COUNT(*) > 8;

-- Bu sorgu, ortalama maaşı 777’den büyük olan iş pozisyonlarını getirir.
-- GROUP BY job_id → pozisyona göre gruplama, HAVING ile filtreleme yapılır.
SELECT job_id, AVG(salary) AS avg_salary
FROM hr.employees
GROUP BY job_id
HAVING AVG(salary) > 777;

-- Bu sorgu, yıl ve departmana göre işe alım sayısını gösterir.
-- EXTRACT(year from hire_date) → işe alım yılını çıkarır.
-- GROUP BY ile yıl ve departman bazında gruplama yapılır.
-- ORDER BY ile sıralama yapılır.
SELECT EXTRACT(YEAR FROM hire_date) AS hire_year,
       department_id,
       COUNT(*) AS hires
FROM hr.employees
GROUP BY EXTRACT(YEAR FROM hire_date), department_id 
ORDER BY hire_year, department_id;

--------------- JOIN’ler (Çoklu Tablo İşlemleri) ---------------

-- Bu sorgu, İsveç'te çalışan personellerin ad, soyad ve şehir bilgilerini listeler.
-- employees → departments → locations → countries tabloları INNER JOIN ile bağlanır.
-- WHERE ile sadece country_name = 'Sweden' olanlar filtrelenir.
SELECT e.first_name, e.last_name, l.city
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id 
INNER JOIN hr.locations l ON d.location_id = l.location_id
INNER JOIN hr.countries c ON l.country_id = c.country_id
WHERE c.country_name = 'Sweden';

-- Bu sorgu, maaşı 7750’den fazla olan çalışanların ad, soyad, maaş ve iş unvanlarını gösterir.
-- employees tablosu jobs tablosuyla INNER JOIN ile bağlanır.
SELECT e.first_name, e.last_name, e.salary, j.job_title
FROM hr.employees e
INNER JOIN hr.jobs j ON e.job_id = j.job_id
WHERE e.salary > 7750;

-- Bu sorgu, hiç çalışanı olmayan departmanları listeler.
-- LEFT JOIN ile tüm departmanlar alınır, çalışanı olmayanlar NULL olur.
-- WHERE e.employee_id IS NULL → çalışanı olmayanları filtreler.
SELECT d.department_name
FROM hr.departments d 
LEFT JOIN hr.employees e ON d.department_id = e.department_id
WHERE e.employee_id IS NULL;

-- Bu sorgu, çalışanları ve departman adlarını RIGHT JOIN ile eşleştirir.
-- RIGHT JOIN → tüm departmanlar alınır, çalışanı olmayanlar da görünür.
SELECT e.first_name, e.last_name, d.department_name
FROM hr.employees e
RIGHT JOIN hr.departments d ON e.department_id = d.department_id;

-- Bu sorgu, çalışanlar ve departmanlar arasında FULL OUTER JOIN yapar.
-- FULL JOIN → hem çalışanı olmayan departmanlar hem de departmanı olmayan çalışanlar görünür.
SELECT e.first_name, e.last_name, d.department_name
FROM hr.employees e
FULL OUTER JOIN hr.departments d ON e.department_id = d.department_id;

-- Bu sorgu, CROSS JOIN ile her çalışanı her departmanla eşleştirir.
-- CROSS JOIN → kartesyen çarpım, toplam satır sayısı = çalışan × departman sayısı.
SELECT e.first_name, e.last_name, d.department_name
FROM hr.employees e
CROSS JOIN hr.departments d;

-- Bu sorgu, çalışanların yöneticilerini gösterir.
-- SELF JOIN → aynı tablo kendisiyle bağlanır.
-- manager_id → employee_id eşleştirilerek çalışan ve yöneticisi eşleştirilir.
SELECT e.first_name AS employee_name,
       m.first_name AS manager_name
FROM hr.employees e
LEFT JOIN hr.employees m ON e.manager_id = m.employee_id;

--------------- Alt Sorgular (Subqueries) ---------------

-- Bu sorgu, en yüksek maaşı alan çalışanı getirir.
-- İçteki alt sorgu MAX(salary) ile en yüksek maaşı bulur.
-- Dış sorgu, bu maaşa sahip olan çalışanı listeler.
SELECT first_name, salary
FROM hr.employees
WHERE salary = (SELECT MAX(salary) FROM hr.employees);

-- Bu sorgu, ortalama maaştan fazla kazanan çalışanları listeler.
-- Alt sorgu AVG(salary) ile ortalama maaşı hesaplar.
-- Dış sorgu, bu değerden yüksek maaş alanları filtreler.
SELECT first_name, salary
FROM hr.employees
WHERE salary > (SELECT AVG(salary) FROM hr.employees);

-- Bu sorgu, IT departmanındaki çalışanları listeler.
-- Alt sorgu, 'IT' adlı departmanın ID’sini bulur.
-- Dış sorgu, bu ID’ye sahip çalışanları getirir.
SELECT first_name
FROM hr.employees
WHERE department_id = (
  SELECT department_id FROM hr.departments WHERE department_name = 'IT'
);

-- Bu sorgu, departman ID’si 10 olan birimin ortalama maaşından fazla kazanan çalışanları listeler.
-- Alt sorgu, sadece departman 10 için AVG(salary) hesaplar.
-- Dış sorgu, bu değerden yüksek maaş alanları filtreler.
SELECT first_name, last_name, salary, department_id
FROM hr.employees
WHERE salary > (
    SELECT AVG(salary)
    FROM hr.employees
    WHERE department_id = 10
);

--------------- UNION – UNION ALL, CTE (WITH) ---------------

-- Bu sorgu, IT (60) ve Finance (100) departmanlarındaki çalışanları birleştirir.
-- UNION → aynı sütun yapısına sahip iki sorgunun sonucunu birleştirir, tekrarları kaldırır.
SELECT first_name 
FROM hr.employees 
WHERE department_id = 60
UNION
SELECT first_name 
FROM hr.employees 
WHERE department_id = 100;

-- Bu sorgu, maaşı 10.000’den fazla olan çalışanlar ile yöneticileri tek listede birleştirir.
-- UNION ile iki farklı sorgu birleştirilir, 'Category' sütunu ile gruplar etiketlenir.
-- Alt sorgu ile yöneticilerin ID’leri alınır.
SELECT first_name, last_name, 'Yüksek Maaşlı' AS Category, salary
FROM hr.employees
WHERE salary > 10000
UNION
SELECT first_name, last_name, 'Manager' AS Category, salary
FROM hr.employees
WHERE employee_id IN (
    SELECT DISTINCT manager_id 
    FROM hr.employees 
    WHERE manager_id IS NOT NULL
);

-- Bu sorgu, IT ve Finance departmanlarındaki çalışanları tekrarları da dahil ederek birleştirir.
-- UNION ALL → UNION’dan farklı olarak tekrarları kaldırmaz.
SELECT first_name 
FROM hr.employees 
WHERE department_id = 60
UNION ALL
SELECT first_name 
FROM hr.employees 
WHERE department_id = 100;

-- Bu sorgu, CTE (Common Table Expression) kullanarak yüksek maaşlı çalışanları departman bazında sayar.
-- WITH ile geçici bir tablo (HIGH_EARNERS) tanımlanır.
-- Bu tablo JOIN ile departmanlara bağlanır ve COUNT ile kişi sayısı hesaplanır.
WITH HIGH_EARNERS AS (
    SELECT first_name, last_name, salary, department_id
    FROM hr.employees
    WHERE salary > (SELECT AVG(salary) FROM hr.employees)
)
SELECT d.department_name, COUNT(*) AS high_earner_count
FROM HIGH_EARNERS h
JOIN hr.departments d ON h.department_id = d.department_id
GROUP BY d.department_name
ORDER BY high_earner_count DESC;

-- Bu sorgu, çoklu CTE kullanarak yüksek maaşlı departmanlardaki çalışanları ve lokasyon bilgilerini listeler.
-- 1. CTE: DEPT_STATS → departman bazında ortalama maaş ve çalışan sayısı
-- 2. CTE: HIGH_SALARY_DEPTS → ortalama maaşı 8000’den fazla olan departmanlar
-- 3. CTE: LOCATION_INFO → departmanların şehir ve ülke bilgileri
-- Son sorgu: çalışanlar, yüksek maaşlı departmanlar ve lokasyon bilgileri birleştirilir.
WITH 
DEPT_STATS AS (
    SELECT department_id, AVG(salary) AS avg_salary, COUNT(*) AS emp_count
    FROM hr.employees
    GROUP BY department_id
),
HIGH_SALARY_DEPTS AS (
    SELECT department_id
    FROM DEPT_STATS
    WHERE avg_salary > 8000
),
LOCATION_INFO AS (
    SELECT d.department_id, d.department_name, l.city, c.country_name
    FROM hr.departments d
    JOIN hr.locations l ON d.location_id = l.location_id
    JOIN hr.countries c ON l.country_id = c.country_id
)
SELECT e.first_name, e.last_name, e.salary, li.department_name, li.city, li.country_name
FROM hr.employees e
JOIN HIGH_SALARY_DEPTS hsd ON e.department_id = hsd.department_id
JOIN LOCATION_INFO li ON e.department_id = li.department_id
ORDER BY e.salary DESC;

--------------- Analitik Fonksiyonlar (ROW_NUMBER, RANK) ---------------

-- Bu sorgu, çalışanlara maaşlarına göre sıra numarası verir.
-- ROW_NUMBER() → her satıra benzersiz bir sıra numarası atar.
-- ORDER BY salary DESC → en yüksek maaş en üstte olur.
SELECT first_name, salary,
       ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num
FROM hr.employees;

-- Bu sorgu, aynı maaşa sahip çalışanlara aynı sıralama değerini verir.
-- RANK() → eşit değerlere aynı sıralama numarasını verir, sonraki sıra atlanır.
SELECT first_name, salary,
       RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM hr.employees;

-- Bu sorgu, her departman içinde maaş sıralaması yapar.
-- PARTITION BY department_id → her departman ayrı bir grup gibi değerlendirilir.
-- RANK() → departman içindeki maaş sıralamasını verir.
SELECT first_name, department_id, salary,
       RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS dept_rank
FROM hr.employees;

-- Bu sorgu, maaş dağılımında en üst %10’luk dilimde yer alan çalışanları analiz eder.
-- 1. CTE: SALARY_PERCENTILES → PERCENT_RANK ile maaş yüzdelik dilimi hesaplanır.
-- 2. CTE: TOP_10_PERCENT → %10’dan yüksek olanlar filtrelenir.
-- Son sorgu: çalışan bilgileri, departman, iş unvanı, şehir, ülke, deneyim süresi, komisyon durumu ve yönettiği kişi sayısı gösterilir.
WITH SALARY_PERCENTILES AS (
    SELECT employee_id, first_name, last_name, salary,
           PERCENT_RANK() OVER (ORDER BY salary DESC) AS salary_percentile
    FROM hr.employees
),
TOP_10_PERCENT AS (
    SELECT * FROM SALARY_PERCENTILES WHERE salary_percentile <= 0.1
)
SELECT t.first_name, t.last_name, t.salary, d.department_name, j.job_title,
       l.city, c.country_name,
       ROUND(MONTHS_BETWEEN(SYSDATE, e.hire_date)/12, 1) AS years_experience,
       CASE WHEN e.commission_pct IS NOT NULL THEN 'Has Commission' ELSE 'No Commission' END AS commission_status,
       (SELECT COUNT(*) FROM hr.employees e2 WHERE e2.manager_id = e.employee_id) AS direct_reports
FROM TOP_10_PERCENT t
JOIN hr.employees e ON t.employee_id = e.employee_id
JOIN hr.departments d ON e.department_id = d.department_id
JOIN hr.jobs j ON e.job_id = j.job_id
JOIN hr.locations l ON d.location_id = l.location_id
JOIN hr.countries c ON l.country_id = c.country_id
ORDER BY t.salary DESC;


--------------- Oracle’a Özgü Fonksiyonlar (NVL, DECODE, DUAL, CONNECT BY) ---------------

-- Bu sorgu, çalışanların komisyon bilgilerini gösterir.
-- NVL fonksiyonu, NULL olan commission_pct değerlerini 0 ile değiştirir.
-- Oracle’a özgü bir fonksiyondur, veri eksikliğini yönetmek için kullanılır.
SELECT first_name, NVL(commission_pct, 0) AS commissions
FROM hr.employees;

-- Bu sorgu da aynı şekilde, komisyonu olmayanlara “0” değeri verir.
-- NVL(commission_pct, 0) → NULL olanları 0 yapar.
SELECT first_name, NVL(commission_pct, 0) AS commission
FROM hr.employees;

-- Bu sorgu, NVL2 fonksiyonu ile komisyon durumu hakkında metinsel bilgi verir.
-- NVL2 → NULL değilse 'yes commission', NULL ise 'no commission' döner.
SELECT first_name, NVL2(commission_pct, 'yes commission', 'no commission') AS commission_status
FROM hr.employees;

-- Bu sorgu, çalışanların iş tanımına göre rol belirler.
-- DECODE → Oracle’a özgü koşullu dönüşüm fonksiyonudur.
-- Belirli job_id değerlerine karşılık gelen metinler döner.
SELECT job_id,
       DECODE(job_id, 'IT_PROG', 'Developer', 'AD_VP', 'Vice President', 'Other') AS role
FROM hr.employees;

-- Bu sorgu, CONNECT BY ile çalışan-yönetici hiyerarşisini gösterir.
-- START WITH → en üst düzeyden (yönetici olmayan) başlar.
-- CONNECT BY PRIOR → kendini yöneticisiyle bağlar.
-- Oracle’ın hiyerarşik sorgular için sunduğu özel bir yapıdır.
SELECT employee_id, first_name, manager_id
FROM hr.employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;
