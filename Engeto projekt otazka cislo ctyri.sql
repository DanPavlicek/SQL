-- Otázka č.4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

-- 1. Vytvoření přehledu procentní změny cen potravin všech kategorií sesupených po jednotlivých letech

SELECT 
    YEAR(DATE(mc.date_from)) AS year_from, 
    AVG(mc.value) AS prumerna_cena,
    LAG (AVG(mc.value)) OVER (ORDER BY YEAR(DATE(mc.date_from))) AS prum_cena_predchazejici_rok,
    CASE 
	    WHEN LAG(AVG(mc.value)) OVER (ORDER BY YEAR(DATE(mc.date_from))) IS NOT NULL 
    	THEN (AVG(mc.value) - LAG(AVG(mc.value)) OVER (ORDER BY YEAR(DATE(mc.date_from)))) /  LAG(AVG(mc.value)) OVER (ORDER BY YEAR(DATE(mc.date_from))) * 100
    	ELSE NULL
    END AS procentni_zmena_potraviny
FROM 
    mezikrok_ceny AS mc
GROUP BY 
	YEAR(DATE(mc.date_from))
ORDER BY
	YEAR(DATE(mc.date_from));

-- Závěr: Průměrný nárůst potravin v žádné roce nepřevýšil 10%
	
	
-- 2. Vytvoření přehledu procentní změny mezd všech kategorií sesupených po jednotlivých letech

	
SELECT 
	mm.payroll_year,
	AVG(mm.value) AS prumernamzda,
	LAG(AVG(mm.value)) OVER (ORDER BY mm.payroll_year) AS prumerna_mzda_minule_obdobi,
	CASE
		WHEN LAG(AVG(mm.value)) OVER (ORDER BY mm.payroll_year) IS NOT NULL
		THEN ((AVG(mm.value)) - LAG(AVG(mm.value)) OVER (ORDER BY mm.payroll_year))/ LAG(AVG(mm.value)) OVER (ORDER BY mm.payroll_year)*100
		ELSE NULL
		END AS procentni_zmena_mzdy
FROM 
		mezikrok_mzdy AS mm 
WHERE payroll_year BETWEEN 2006 AND 2018
GROUP BY 
		mm.payroll_year 
ORDER BY
		mm.payroll_year; 
		
-- V žádném roce nepřevýšil nárůst mezd 10%
		
-- 3. Propojední výše uvedených výběrů do jedné jednoduché tabulky % změn cen a % platů v jednotlivých letech
		
SELECT
	zmena_cen.year_from,
	zmena_cen.procentni_zmena_potraviny,
	zmena_platu.procentni_zmena_mzdy
FROM (
SELECT 
    YEAR(DATE(mc.date_from)) AS year_from, 
    AVG(mc.value) AS prumerna_cena,
    LAG (AVG(mc.value)) OVER (ORDER BY YEAR(DATE(mc.date_from))) AS prum_cena_predchazejici_rok,
    CASE 
	    WHEN LAG(AVG(mc.value)) OVER (ORDER BY YEAR(DATE(mc.date_from))) IS NOT NULL 
    	THEN (AVG(mc.value) - LAG(AVG(mc.value)) OVER (ORDER BY YEAR(DATE(mc.date_from)))) /  LAG(AVG(mc.value)) OVER (ORDER BY YEAR(DATE(mc.date_from))) * 100
    	ELSE NULL
    END AS procentni_zmena_potraviny
FROM 
    mezikrok_ceny AS mc
GROUP BY 
	YEAR(DATE(mc.date_from))
ORDER BY
	YEAR(DATE(mc.date_from))) AS zmena_cen
JOIN(
SELECT 
	mm.payroll_year,
	AVG(mm.value) AS prumernamzda,
	LAG(AVG(mm.value)) OVER (ORDER BY mm.payroll_year) AS prumerna_mzda_minule_obdobi,
	CASE
		WHEN LAG(AVG(mm.value)) OVER (ORDER BY mm.payroll_year) IS NOT NULL
		THEN ((AVG(mm.value)) - LAG(AVG(mm.value)) OVER (ORDER BY mm.payroll_year))/ LAG(AVG(mm.value)) OVER (ORDER BY mm.payroll_year)*100
		ELSE NULL
		END AS procentni_zmena_mzdy
FROM 
		mezikrok_mzdy AS mm 
WHERE payroll_year BETWEEN 2006 AND 2018
GROUP BY 
		mm.payroll_year 
ORDER BY
		mm.payroll_year ) AS zmena_platu
		ON zmena_cen.year_from = zmena_platu.payroll_year;
		