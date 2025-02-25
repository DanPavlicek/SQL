-- Otázka č.2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

-- 1. Provedení selectů v tabulkách czechia_price, czechia_price_category, czechia_region

SELECT *
FROM czechia_price AS cp;

SELECT *
FROM czechia_price_category AS cpc;

SELECT *
FROM czechia_region AS cr;

-- 2. připojení sloupců z czechia price category a czechia region do czechia_price pro lepší přehled a porozumění a vytvoření view mezikrok_ceny

CREATE OR REPLACE VIEW mezikrok_ceny AS
SELECT 	cp.*, 
		cpc.name AS kategorie, 
		cpc.price_value AS velikostbaleni, 
		cpc.price_unit AS jednotka, 
		cr.name AS kraj
FROM 
		czechia_price AS cp 
LEFT JOIN 
		czechia_price_category cpc ON cpc.code = cp.category_code 
LEFT JOIN 
		czechia_region cr ON cr.code = cp.region_code; 

-- 3. identifikace sloupců s null hodnotami - existují řádky s null hodnotami ve sloupci region_code - kraj, pro otázku č. 2 nepodstatné, podle mě

SELECT *
FROM 
		mezikrok_ceny AS mc 
WHERE 	
		mc.id IS NULL OR 
		mc.value IS NULL OR 
		mc.category_code IS NULL OR 
		mc.date_from IS NULL OR 
		mc.date_to IS NULL OR 
		mc.region_code IS NULL;


-- 4. Identifikace category code mléko a chleba 

SELECT DISTINCT 
		mc.kategorie, mc.category_code 
FROM 
		mezikrok_ceny AS mc 
ORDER BY 
		mc.kategorie ASC;

-- Výsledek mléko (114201) a chleba (111301)

-- 5.  zúžení výběru na mléko a chleba a selecty zaměřžeené na datumy - první období 2006 a poslední 2018, czechia payroll má rozmezí 2000 až 2021

SELECT 
		*, year (date_from)
FROM mezikrok_ceny AS mc 
WHERE 
		mc.category_code = 114201 or 
		mc.category_code = 111301
ORDER BY 
		mc.date_from DESC; 

-- 6. Níže select pro zobrazení průměrných cen za rok 2006 a 2018 

SELECT
    mc.category_code, 
    mc.kategorie, 
    YEAR(DATE(mc.date_from)) AS year_from, 
    AVG(mc.value) AS avg_value
FROM 
    mezikrok_ceny AS mc
WHERE 
    (mc.category_code = 111301 or mc.category_code = 114201)
    AND YEAR(DATE(mc.date_from)) IN (2006, 2018)
GROUP BY 
    mc.category_code, 
    mc.kategorie, 
    YEAR(DATE(mc.date_from))
ORDER BY 
    mc.category_code, 
    year_from;

-- 7. Výsledkem jsou průměrné ceny:

/*
16.12364000000002 chleba 2006
24.238500000000013 chleba 2018

14.437840000000001 mleko 2006
19.817555555555558 mleko 2018
*/

-- 8. Níže zjistím průměrné mzdy přes všechny odvětví za roky 2006 a 2018 a vypočítám, kolik si mohu koupit
 
SELECT 
		payroll_year, 
		AVG(value) AS prumerna_mzda,
		CASE 
        WHEN payroll_year = 2006 THEN (AVG(value) / 16.12364000000002)
        WHEN payroll_year = 2018 THEN (AVG(value) / 24.238500000000013)
        ELSE NULL
    END AS pocet_ks_chleba,
    	CASE
    	WHEN payroll_year = 2006 THEN (AVG(value) / 14.437840000000001)
    	WHEN payroll_year = 2018 THEN (AVG(value) / 19.817555555555558)
    	ELSE NULL
    END AS pocet_lt_mleka
FROM 	mezikrok_mzdy AS mm 
WHERE 
		payroll_year IN (2006,2018)
GROUP BY 
		payroll_year;

-- 9. Výsledkem je počet ks chleba a litrů mléka, které si za průměrnou mzdu ze všech odvětví můžeme koupit v letech 2006 a 2018
/*
payroll_year  prumerna_mzda    pocet_ks_chleba  pocet_lt_mleka
2006	        21165.1842  	1312.68027632	  1465.95226229
2018	        33091.4474	    1365.24320269	  1669.80469794
*/
