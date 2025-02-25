

-- Otázka č.1 : Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

-- 1. Krok - obecné selecty pro všecny tabulky napojené na tabulku czechia_payroll cp dle ER Diagramů a studium výsledků

SELECT *
FROM czechia_payroll AS cp;

SELECT *
FROM czechia_payroll_calculation AS cpc;

SELECT *
FROM czechia_payroll_industry_branch AS cpib;

SELECT *
FROM czechia_payroll_unit AS cpu;

SELECT *
FROM czechia_payroll_value_type AS cpvt;

-- 2.Krok připojení druhých sloupců ze všech tabulcek k tabulce czechia_payroll s cílem porozumět všem údajům v tabulce czechia_payroll

SELECT 
		cp.*, 
		cpc.name AS fyzneboprepoc, 
		cpib.name AS odvetvi, 
		cpu.name AS Kcneboosoby, 
		cpvt.name AS prummzdaneboosoby
FROM 
		czechia_payroll cp 
LEFT JOIN 
		czechia_payroll_calculation cpc ON cp.calculation_code = cpc.code 
LEFT JOIN 
		czechia_payroll_industry_branch cpib ON cp.industry_branch_code  = cpib.code 
LEFT JOIN 
		czechia_payroll_unit cpu ON cp.unit_code = cpu.code
LEFT JOIN 
		czechia_payroll_value_type cpvt ON cp.value_type_code = cpvt.code; 
		
/*3. Krok dle studia předchozích selectů se zaměřím na průměrnou mzdu zaměstnance (value_type_code 5958) a přepočtený počet zaměstanců zohledňující částečné úvazky (calculation code 200)
   Cílem je se zaměřit na průměrné mzdy a zohlednit částečné úvazky*/

SELECT 
		cp.*, 
		cpc.name AS fyzneboprepoc, 
		cpib.name AS odvetvi, 
		cpu.name AS Kcneboosoby, 
		cpvt.name AS prummzdaneboosoby
FROM 
		czechia_payroll AS cp 
LEFT JOIN 
		czechia_payroll_calculation cpc on cp.calculation_code = cpc.code 
LEFT JOIN 
		czechia_payroll_industry_branch cpib on cp.industry_branch_code  = cpib.code 
LEFT JOIN 
		czechia_payroll_unit cpu on cp.unit_code = cpu.code
LEFT JOIN 
		czechia_payroll_value_type cpvt on cp.value_type_code = cpvt.code
WHERE 
		value_type_code = 5958 
		AND calculation_code = 200;

/*4. Krok zkontroluji výskyt null hodnot v selectu výše a to ve dvou krocích
     a) vytvoření view: mezikrok_mzdy*/

CREATE OR REPLACE VIEW mezikrok_mzdy AS
SELECT 
		cp.*, 
		cpc.name AS fyzneboprepoc, 
		cpib.name AS odvetvi, 
		cpu.name AS Kcneboosoby, 
		cpvt.name AS prummzdaneboosoby
FROM 
		czechia_payroll AS cp 
LEFT JOIN 
		czechia_payroll_calculation cpc ON cp.calculation_code = cpc.code 
LEFT JOIN 
		czechia_payroll_industry_branch cpib ON cp.industry_branch_code  = cpib.code 
LEFT JOIN 
		czechia_payroll_unit cpu ON cp.unit_code = cpu.code
LEFT JOIN 
		czechia_payroll_value_type cpvt ON cp.value_type_code = cpvt.code
WHERE 
		value_type_code = 5958 AND calculation_code = 200;

-- b) kontrola null hodnot - výsledek null hodnoty pouze ve sloupci industry branch code

SELECT *
FROM 
		mezikrok_mzdy AS mm 
WHERE 
		mm.id IS NULL OR mm.value IS NULL OR mm.value_type_code
IS NULL OR 
		mm.unit_code IS NULL OR mm.calculation_code
IS NULL OR 
		mm.industry_branch_code IS NULL OR mm.payroll_year 
IS NULL OR 
		mm.payroll_quarter IS NULL;

-- 5. Krok aktualizace view o odstranění null hodnot z industry branch code a ověření

CREATE OR REPLACE VIEW mezikrok_mzdy AS
SELECT 
		cp.*, 
		cpc.name AS fyzneboprepoc, 
		cpib.name AS odvetvi, 
		cpu.name AS Kcneboosoby, 
		cpvt.name AS prummzdaneboosoby
FROM 
		czechia_payroll AS cp 
LEFT JOIN 
		czechia_payroll_calculation cpc ON cp.calculation_code = cpc.code 
LEFT JOIN 
		czechia_payroll_industry_branch cpib ON cp.industry_branch_code  = cpib.code 
LEFT JOIN 
		czechia_payroll_unit cpu ON cp.unit_code = cpu.code
LEFT JOIN 
		czechia_payroll_value_type cpvt on cp.value_type_code = cpvt.code
WHERE 
		value_type_code = 5958 AND calculation_code = 200 AND industry_branch_code IS NOT NULL;

/* 6. Provádění dalších zkušebních selectů (uvádím jen relevatntní) např. rok 2021 má jen 2 kvartály a není vhodný pro zahrnutí do analýzy (souhnr po kompletních letech)
   Aktualizuji view mezikrok.mzdy */

SELECT *
FROM 
		mezikrok_mzdy AS mm
WHERE 
		mm.industry_branch_code = 'A'
ORDER BY 
		payroll_year DESC, 
		payroll_quarter ASC;

-- 7. Aktualizace view níže, kdy vyjmu z  VIEW nekompletní rok 2021

CREATE OR REPLACE VIEW mezikrok_mzdy AS
SELECT 
		cp.*, 
		cpc.name AS fyzneboprepoc, 
		cpib.name AS odvetvi, 
		cpu.name AS Kcneboosoby, 
		cpvt.name AS prummzdaneboosoby
FROM 
		czechia_payroll AS cp 
LEFT JOIN 
		czechia_payroll_calculation cpc on cp.calculation_code = cpc.code 
LEFT JOIN 
		czechia_payroll_industry_branch cpib on cp.industry_branch_code  = cpib.code 
LEFT JOIN 
		czechia_payroll_unit cpu on cp.unit_code = cpu.code
LEFT JOIN 
		czechia_payroll_value_type cpvt on cp.value_type_code = cpvt.code
WHERE value_type_code = 5958 
		AND calculation_code = 200 
		AND industry_branch_code 
		IS NOT NULL AND payroll_year != 2021;

-- 8. Sestavu seskupím po odvětví a letech, součtové pole value

SELECT 
		mm.odvetvi, 
		mm.payroll_year, 
		avg(value) AS prumernamzda
FROM 
		mezikrok_mzdy mm 
GROUP BY 
		mm.odvetvi, 
		mm.payroll_year;

/* 9. Rozhodnul jsem se zobrazit pouze roky 2000 a 2020 Prostým porovnáním vidím, že průměrné mdzy jsou v roce 2020 větší ve všechn odvětvích, než v roce 2000
   Ostatní selecty přes všechny roky apod. mi přišly příliš nepřehledné */



SELECT 
		mm.odvetvi, 
		mm.payroll_year, 
		avg(value) AS prumernamzda
FROM 
		mezikrok_mzdy mm 
WHERE 
		payroll_year = 2000 
		OR payroll_year = 2020
GROUP BY 
		mm.odvetvi, 
		mm.payroll_year;

-- 10. Odpověď na zadání: Průměrná mzda mezi roky 2000 a 2020 rostla ve všech odvětvích.
