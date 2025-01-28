/*
Otázka č. 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? 
Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na 
cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
*/

-- 1. Průzkum tabuly economies a ověření názvu pro českou republiku
SELECT *
FROM
	economies AS e

SELECT 
DISTINCT
	country 
FROM 
	economies AS e

-- 2. Vytvoření sestavy zobrazující % změnu v HDP v České republice v letech 2006 a 2018
	
SELECT
	e.`year` AS rok,
	e.country AS zeme,
	e.GDP AS HDP,
	LAG (e.GDP) OVER (ORDER BY e.`year`) AS HDP_predchoziho_roku,
	CASE 
		WHEN LAG(e.GDP) OVER (ORDER BY e.`year`) IS NOT NULL
		THEN (e.GDP - LAG(e.GDP) OVER (ORDER BY e.`year`)) / LAG (e.GDP) OVER (ORDER BY e.`year`) * 100
	ELSE NULL
	END AS procetni_zmeny_HDP
FROM
	economies AS e
WHERE 
	e.`year` BETWEEN 2006 AND 2018 AND
	e.country = "Czech Republic"
ORDER BY
	e.`year` ASC
	
-- Finální dotaz spoující % změny cen potravin, % změny mezd, a % změny HDP v letech 2006 až 2018
	
SELECT
	zmena_cen.year_from,
	zmena_cen.procentni_zmena_potraviny,
	zmena_platu.procentni_zmena_mzdy,
	zmena_hdp.procentni_zmeny_hdp
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
		ON zmena_cen.year_from = zmena_platu.payroll_year
JOIN (SELECT
	e.`year` AS rok,
	e.country AS zeme,
	e.GDP AS HDP,
	LAG (e.GDP) OVER (ORDER BY e.`year`) AS HDP_predchoziho_roku,
	CASE 
		WHEN LAG(e.GDP) OVER (ORDER BY e.`year`) IS NOT NULL
		THEN (e.GDP - LAG(e.GDP) OVER (ORDER BY e.`year`)) / LAG (e.GDP) OVER (ORDER BY e.`year`) * 100
	ELSE NULL
	END AS procentni_zmeny_HDP
FROM
	economies AS e
WHERE 
	e.`year` BETWEEN 2006 AND 2018 AND
	e.country = "Czech Republic"
ORDER BY
	e.`year` ASC) AS zmena_hdp
	ON zmena_cen.year_from = zmena_hdp.rok
	
	/*
	 Obecně můžeme konstatovat, že za sledované období roste HDP, rovněž roste cenová hladina potravin a úroveň mezd. Pokud jde o změnu HDP, tak 
	 se pokles HDP období krize 2008 - 2009 projevil na zpomalení růsta platů cca s ročním zpoždění a během let 2011 - 2013 doško opětovně
	 k poklesu HDP i ke zpomalení růstu platů a dokonce k jejich poklesu. V obdobích růstu je podobný vývoj, akorát opačným směrem. Tzn. Výraznější
	 růst HDP vede k výraznějším růstum v oblasti platů.
	 Pokud jde o vzah změny HDP ke změnám cen potravin, nelze najít jasnou souvislos mezi změnami HDP a vývojem cen v daném/následujícím roce.
	 Do vývoje cen potravin vstupují i ji jiné vlivy (obecná inflace v ekonomice, světové ceny).
*/
