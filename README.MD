# Kontakt na Discord
	Zobrazované jméno: Dan Pavlíček
	Uživatelské jméno: dan.pavlicek


# Zadání projektu: 
	Zodpovědět 5 výzkumných otázek, které se zabývají dostupností základní potravit široké veřejnosti.
	
	1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
	2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední 
	   srovnatelné období v dostupných datech cen a mezd?
	3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
	4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
	5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
	   projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
	
	   Výsledkem jsou dvě finální tabulky zaměřené na ČR a zahraničí. V mém případě také kompletní postup, 
	   pro všech 5 otázek uložených v samostatných SQL souborech, uložených přes GITHUB.
	   
# Obecné problémy při práci s SQL:
		SQL je pro mě nová záležitost, se kterou jsem neměl v minulosti žádné zkušenosti. Na mé pozici pracuji
		s ERP systémy (plánování, nákup) a s Excelem jako nástrojem pro export, interpretaci výsledků a
		analýzy pro rozhodování. Úkony jako vytváření nových tabulek, spojování přes SVYHLEDAT, ukládání, provádění 
		mezikroků apod. jsou pro mě v SQL složitější a méně intuitivní. K práci využívám materiálů Engeta, WEB a velmi 
		se mi pro výukové účely osvědčil ChatGPT, které dokáže posoudit můj kód, upozornit např. na chybějící čárku a
		inspirovat k možným řešením. Člověk si rychleji zažije principy práce z SQL, i když je to, pro mě, nekončící proces.
	   
# 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
		- Postup je uložený ve v souboru Engeto projekt otázka číslo jedna včetně komentářů.
		
		- provádím obecné průzkumné SELECTy ve všech relevantních tabulkách
		- propouji ostatní tabulky s tabulkou czechia_paroll s cílem porozumět údajům (LEFT JOIN)
		- zaměřuji se na průměrnou mzdu zaměstnace a přepočtený počet zaměstnanců zohledňující částečné úvazky
		- kontroluji výsky null hodnot, vytvářím view mezikrok_mzdy, zjišťuji, kde jsou null hodnoty,
		  aktualizuji výše vytovřené VIEW a odstraňuji null hodnoty	
		- provádím další SELETy a zjišťuji, že rok 2021 má jen dva kvartály a nebudu ho v analýze brát v potaz
		- zobrazuji sestavu přes seskuepnou přes rok, odvětví s průměrnou hodnotou mezd
		- rozhoduji se, že pro finální porovnání posoudím roky 2000 a 2020. 
		- Za dané období vidíme nárůstv mezd ve všech odvětvích, což odpovídá obecnému vývoji v ekonomice: růst ekonomiky a cenové hladiny
		  

# 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
		- Postup je uložený ve v souboru Engeto projekt otázka číslo dva včetně komentářů.
		
		- provádím obecné průzkumné SELECTy v tabulkách czechia_price, czechia_price_category, czechia_region
		- připojuji sloupce z czechia_price_category a czechia_region do czechia_price, vytvářím view mezikrok_ceny
		- identifikuji řády s NULL hodnotami - pouze ve sloupci region_code (pro otázku nepodstatné)
		- identifkuji kategorie pro mléko a chleba, dále zkoumám SELECTy
		- zjišťuji, že relevatní období jsou v letech  2006 až 2018, zatímco údaje o mzdách jsou použitelné v letech 
		  2000 - 2020
		- zjišťuji průměrné ceny pro chleba a mléko pro roky 2006 a 2018
		- zjišťuji průměrné mzdy pro roky 2006 a 2018, vydělím průměrno cenou chleba a mléka
		- výsledek:
		  ayroll_year  prumerna_mzda    pocet_ks_chleba  pocet_lt_mleka
		  2006	        21165.1842  	1312.68027632	  1465.95226229
		  2018	        33091.4474	    1365.24320269	  1669.80469794


# 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
		- Postup je uložený ve v souboru Engeto projekt otázka číslo tři včetně komentářů.
		
		- Vytvářím přehled odvětví a vývoje cen v jednotlivých letech, používám CTE a LAG klauzuli
		- Rozhoduji se porovnat roky 2006 a 2018 a vybrat položky s nejpomalejším nárůstem
		- používám vnořený SELECT poskytující náhled na ceny 2006 a 2018 a seřadí položky dle nejmenšího
		  procentního nárůstu
		- Výslekdem je pokles cen u krystalového curku, rajských jablek a nejmenší nárůst mezi roky 
		  2006 a 2018 je u banánů žlutých
		  
# 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?	 
		- Postup je uložený ve v souboru Engeto projekt otázka číslo čtyři včetně komentářů.
		
		- vytvářím přehled procetní změny cen potravin všechn kategorií seskupených po jednotlivých letech
		- využívám klauzule LAG, CASE
		- vytvářím procentní změny mezd seskupených po jednotlivých letech
		- propouji výše uvedené výběry do jednoho SELECTu pro jednoduchost a přehlednost
		- Závěr: nárůst potravin v žádné roce nepřevýšil 10%
		- Závěr: nárůst mezd v žádném roce nepřevýšil 10%
		
# 5.Má výška HDP vliv na změny ve mzdách a cenách potravin?

	##Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
		
		- Postup je uložený ve v souboru Engeto projekt otázka číslo pět včetně komentářů.
		
		- Průzkum tabuly economies a ověření názvu pro českou republiku
		- Vytvoření sestavy zobrazující % změnu v HDP v České republice v letech 2006 a 2018
		- Finální dotaz spoující % změny cen potravin, % změny mezd, a % změny HDP v letech 2006 až 2018
		- Jedná se o vytovření přehled ze třech SELECTů, nejdelší dotaz, který je součástí mého projektu
		
		Závěr:
			Obecně můžeme konstatovat, že za sledované období roste HDP, rovněž roste cenová hladina potravin a úroveň mezd. Pokud jde o změnu HDP, tak 
			se pokles HDP období krize 2008 - 2009 projevil na zpomalení růstu platů cca s ročním zpoždění a během let 2011 - 2013 doško opětovně
			k poklesu HDP i ke zpomalení růstu platů a dokonce k jejich poklesu. V obdobích růstu je podobný vývoj, akorát opačným směrem. Tzn. výraznější
			růst HDP vede k výraznějším růstum v oblasti platů.
			Pokud jde o vzah změny HDP ke změnám cen potravin, nelze najít jasnou souvislos mezi změnami HDP a vývojem cen v daném/následujícím roce.
			Do vývoje cen potravin vstupují i ji jiné vlivy (obecná inflace v ekonomice, světové ceny).
			
	
# Poznámky na Závěr
		- Během přípravy dat na jednotlivé dotazy jsem si připravil VIEW mezikrok_ceny a mezikrok_mzdy, se kterými jsem pak dále pracoval.
		- Rovněž jsem je používal ke vnořeným SELECTům, zejména k otázce číslo 5. Během své práce jsem si tedy na začátku nevytvořil
		  tabulku t_{jmeno}_{prijmeni}_project_SQL_primary_final - nicméně její funkci nahrazují právě výše zmíněné VIEWs. Přišlo mi přehlednější
		  vytvořit VIEW spojující tabulky zaměřené na mzdy a ceny zvlášť a poté tyto VIEW použít jako zdroj pro finální zobrazení. Osobně bych si nevytvářel
		  jednu extrémně velkou zdrojovou tabulku se všemi daty. Možná se takto nepracuje, jsem teprve začátečník :)
		  
		- Tabulku t_{jmeno}_{prijmeni}_project_SQL_secondary_final jsem vytovřil pro několi vybraných evropských zemí.
		  
		

		  
		

