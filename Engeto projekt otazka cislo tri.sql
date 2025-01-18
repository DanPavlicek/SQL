-- Otázka č. 3: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?


-- 1. Vytvoření přehledu odvětví a vývoje cen v jednotlivých letech pomocí poheldu Common Table Expression a LAG funkce


WITH prumerne_ceny_odvetvi_rok AS (
SELECT 
    mc.category_code, 
    mc.kategorie, 
    YEAR(DATE(mc.date_from)) AS year_from, 
    AVG(mc.value) AS prumerna_cena
FROM 
    mezikrok_ceny AS mc
GROUP BY 
    mc.category_code, 
    mc.kategorie, 
    YEAR(DATE(mc.date_from))
ORDER BY 
    mc.category_code,
    mc.date_from
   )
 SELECT 
    p.category_code, 
    p.kategorie, 
    p.year_from, 
    p.prumerna_cena,
    LAG(p.prumerna_cena) OVER (PARTITION BY p.category_code, p.kategorie ORDER BY p.year_from) AS prumerna_cena_predchozi_rok,
    p.prumerna_cena - LAG(p.prumerna_cena) OVER (PARTITION BY p.category_code, p.kategorie ORDER BY p.year_from) AS mezirocni_zmena,
    CASE
        WHEN LAG(p.prumerna_cena) OVER (PARTITION BY p.category_code, p.kategorie ORDER BY p.year_from) = 0 THEN NULL
        ELSE (p.prumerna_cena - LAG(p.prumerna_cena) OVER (PARTITION BY p.category_code, p.kategorie ORDER BY p.year_from)) / 
             LAG(p.prumerna_cena) OVER (PARTITION BY p.category_code, p.kategorie ORDER BY p.year_from) * 100
    END AS procentualni_zmena
FROM 
    prumerne_ceny_odvetvi_rok AS p
ORDER BY 
    p.category_code, 
    p.year_from;

-- 2. pro posouzení rychlosti nárůstu jsem se rozhodnnul porovnat pouze rok 2006 a 2018 a vybrat položky,které zdražovaly nejpomaleji. Sestava výše mi přišla nepraktická.

-- a) SELECT pro ceny roku 2006 případně 2018


SELECT 
        category_code, 
        kategorie, 
        AVG(value) AS prumerna_cena
    FROM 
        mezikrok_ceny AS mc
    WHERE 
        YEAR(DATE(date_from)) = 2006
    GROUP BY 
       category_code, kategorie

-- b) vnořený SELECT spojí výsledky cen za rok 2006 a 2018, vypočítá rozdíl a porovná s rokem 2006 a vypočítá procentní nárůst mezi roky 2006 a 2018
    
    SELECT 
    mc_2006.category_code, 
    mc_2006.kategorie, 
    mc_2006.prumerna_cena AS prumerna_cena_2006,
    mc_2018.prumerna_cena AS prumerna_cena_2018,
    (mc_2018.prumerna_cena - mc_2006.prumerna_cena) AS rozdil_cena,
    ((mc_2018.prumerna_cena - mc_2006.prumerna_cena) / mc_2006.prumerna_cena) * 100 AS narust_procenta
FROM 
    (SELECT 
        category_code, 
        kategorie, 
        AVG(value) AS prumerna_cena
    FROM 
        mezikrok_ceny AS mc
    WHERE 
        YEAR(DATE(date_from)) = 2006
    GROUP BY 
        category_code, kategorie) AS mc_2006
JOIN 
    (SELECT 
        category_code, 
        kategorie, 
        AVG(value) AS prumerna_cena
    FROM 
        mezikrok_ceny
    WHERE 
        YEAR(DATE(date_from)) = 2018
    GROUP BY 
        category_code, kategorie) AS mc_2018
ON mc_2006.category_code = mc_2018.category_code
AND mc_2006.kategorie = mc_2018.kategorie
ORDER BY 
   narust_procenta ASC;
 
--  Výslekdem je pokles cen u krystalového curku, rajských jablek a nejmenší nárůst mezi roky 2006 a 2018 je u banánů žlutých
    

