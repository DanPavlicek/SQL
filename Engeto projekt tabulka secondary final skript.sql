
-- Vytvoření tabulky  HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR.



-- t_Dan_Pavlicek_project_SQL_secondary_final


-- 1. Připomenutí si názvu zemí v tabulce countries
SELECT 
DISTINCT (country)
FROM economies AS e;

-- 2.Vytovření SELECTu za roky 2006 až 2018 pro vybrané země Evropy s HDP, GINI, populací

CREATE OR REPLACE TABLE t_Dan_Pavlicek_project_SQL_secondary_final AS
SELECT
	`year`,
	 country,
	 GDP,
	 gini,
	 population
FROM economies AS e
WHERE
	e.`year` BETWEEN 2006 AND 2018 AND
	e.country IN ("Czech Republic", "Poland", "Hungary", "Slovakia", "Germany", "France", "United Kingdom")
ORDER BY
	e.country ASC, e.`year` ASC;



