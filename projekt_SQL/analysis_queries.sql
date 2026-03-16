-- Q1: Rostou mzdy ve vsech odvetvich, nebo nekde klesaji?
-- Vystup: pro kazde odvetvi pocet zapornych YoY roku + nejvetsi pokles
WITH wage_year AS (
    -- Rocni mzda na odvetvi (vynecha agregaci Celkem)
    -- Poznamka: hodnoty jsou uz rocni prumery; GROUP BY drzi 1 radek na rok+odvetvi
    SELECT year, industry_branch_code, industry_branch_name, avg_wage
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_primary_final
    WHERE industry_branch_code IS NOT NULL
    GROUP BY year, industry_branch_code, industry_branch_name, avg_wage
),
yoy AS (
    -- Mezirocni zmena mzdy podle odvetvi
    -- pct_change je v % (napr. 2.5 = +2.5 %)
    SELECT
        industry_branch_code,
        industry_branch_name,
        year,
        avg_wage,
        LAG(avg_wage) OVER (PARTITION BY industry_branch_code ORDER BY year) AS prev_wage,
        ROUND((avg_wage / NULLIF(LAG(avg_wage) OVER (PARTITION BY industry_branch_code ORDER BY year), 0) - 1) * 100, 2) AS pct_change
    FROM wage_year
)
SELECT
    industry_branch_code,
    industry_branch_name,
    COUNT(*) FILTER (WHERE pct_change < 0) AS negative_years,
    MIN(pct_change) AS worst_decline_pct
FROM yoy
GROUP BY industry_branch_code, industry_branch_name
ORDER BY negative_years DESC, industry_branch_name;

-- Q2: Kolik litru mleka a kg chleba lze koupit za prvni a posledni rok?
WITH years AS (
    -- Najde prvni a posledni rok v primarni tabulce
    -- Jde o spolecne roky pro mzdy i ceny
    SELECT MIN(year) AS min_year, MAX(year) AS max_year
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_primary_final
),
wage AS (
    -- Pouzije celkovou prumernou mzdu (industry_branch_code IS NULL)
    -- MIN slouzi ke slouceni stejnych hodnot opakovanych pres kategorie
    SELECT year, MIN(avg_wage) AS avg_wage
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_primary_final
    WHERE industry_branch_code IS NULL
    GROUP BY year
),
price AS (
    -- Rocni prumerna cena mleka a chleba
    -- MIN slouci duplicity (cena je v primarni tabulce opakovana pres odvetvi)
    SELECT
        year,
        category_code,
        category_name,
        price_value,
        price_unit,
        MIN(avg_price) AS avg_price
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_primary_final
    WHERE category_code IN (114201, 111301) -- milk, bread
    GROUP BY year, category_code, category_name, price_value, price_unit
)
SELECT
    y.year,
    p.category_code,
    p.category_name,
    -- Nakupitelne jednotky = mzda / cena (da kg nebo litry dle jednotky)
    ROUND(w.avg_wage / NULLIF(p.avg_price, 0), 2) AS purch_units,
    p.price_value,
    p.price_unit
FROM (
    SELECT min_year AS year FROM years
    UNION ALL
    SELECT max_year AS year FROM years
) y
JOIN wage w ON w.year = y.year
JOIN price p ON p.year = y.year
ORDER BY y.year, p.category_code;

-- Q3: Ktera kategorie zdrazuje nejpomaleji (nejnizsi prumerne YoY %)?
-- Poznamka: omezeni na kategorie dostupne po cele obdobi (bez zkresleni)
-- This prevents newer categories from shortening the time series
WITH year_span AS (
    SELECT MIN(year) AS min_year, MAX(year) AS max_year
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_primary_final
),
full_categories AS (
    SELECT category_code
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_primary_final
    GROUP BY category_code
    HAVING MIN(year) = (SELECT min_year FROM year_span)
       AND MAX(year) = (SELECT max_year FROM year_span)
       AND COUNT(DISTINCT year) = (SELECT max_year - min_year + 1 FROM year_span)
),
price_year AS (
    -- Rocni prumerna cena pro kazdou kategorii
    -- MIN slouci duplicity (stejna cena opakovana pres odvetvi)
    SELECT year, category_code, category_name, MIN(avg_price) AS avg_price
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_primary_final
    WHERE category_code IN (SELECT category_code FROM full_categories)
    GROUP BY year, category_code, category_name
),
yoy AS (
    -- Mezirocni zmena ceny podle kategorie
    -- pct_change v % pro kazdou kategorii
    SELECT
        category_code,
        category_name,
        year,
        ROUND((avg_price / NULLIF(LAG(avg_price) OVER (PARTITION BY category_code ORDER BY year), 0) - 1) * 100, 2) AS pct_change
    FROM price_year
)
SELECT
    category_code,
    category_name,
    ROUND(AVG(pct_change), 2) AS avg_yoy_pct
FROM yoy
WHERE pct_change IS NOT NULL
GROUP BY category_code, category_name
ORDER BY avg_yoy_pct ASC
LIMIT 1;

-- Q4: Je rok, kdy ceny rostly o >10 p.b. rychleji nez mzdy?
-- Poznamka: omezeni na kategorie dostupne po cele obdobi (bez zkresleni)
-- Price index uses only categories with complete data
WITH year_span AS (
    SELECT MIN(year) AS min_year, MAX(year) AS max_year
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_primary_final
),
full_categories AS (
    SELECT category_code
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_primary_final
    GROUP BY category_code
    HAVING MIN(year) = (SELECT min_year FROM year_span)
       AND MAX(year) = (SELECT max_year FROM year_span)
       AND COUNT(DISTINCT year) = (SELECT max_year - min_year + 1 FROM year_span)
),
price_year AS (
    -- Rocni prumerna cena na kategorii
    -- MIN slouci duplicity (stejna cena opakovana pres odvetvi)
    SELECT year, category_code, MIN(avg_price) AS avg_price
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_primary_final
    WHERE category_code IN (SELECT category_code FROM full_categories)
    GROUP BY year, category_code
),
price_index AS (
    -- Jednoduchy cenovy index: prumer pres kategorie
    -- (nevazeny prumer cen kategorii)
    SELECT year, AVG(avg_price) AS avg_food_price
    FROM price_year
    GROUP BY year
),
wage_year AS (
    -- Celkova prumerna mzda za rok (Celkem)
    -- MIN slouci duplicity (stejna mzda opakovana pres kategorie)
    SELECT year, MIN(avg_wage) AS avg_wage
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_primary_final
    WHERE industry_branch_code IS NULL
    GROUP BY year
),
yoy AS (
    -- Mezirocni zmena cen a mezd
    -- Porovnavaji se procentni tempa rustu
    SELECT
        p.year,
        ROUND((p.avg_food_price / NULLIF(LAG(p.avg_food_price) OVER (ORDER BY p.year), 0) - 1) * 100, 2) AS price_yoy_pct,
        ROUND((w.avg_wage / NULLIF(LAG(w.avg_wage) OVER (ORDER BY w.year), 0) - 1) * 100, 2) AS wage_yoy_pct
    FROM price_index p
    JOIN wage_year w ON w.year = p.year
)
SELECT
    year,
    price_yoy_pct,
    wage_yoy_pct,
    ROUND(price_yoy_pct - wage_yoy_pct, 2) AS diff_pct
FROM yoy
WHERE price_yoy_pct - wage_yoy_pct > 10
ORDER BY year;

-- Q5: Ma HDP vliv na rust mezd a cen? (stejny rok i nasledujici rok)
-- Poznamka: omezeni na kategorie dostupne po cele obdobi (bez zkresleni)
-- Keeps the food price index consistent in time
WITH year_span AS (
    SELECT MIN(year) AS min_year, MAX(year) AS max_year
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_primary_final
),
full_categories AS (
    SELECT category_code
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_primary_final
    GROUP BY category_code
    HAVING MIN(year) = (SELECT min_year FROM year_span)
       AND MAX(year) = (SELECT max_year FROM year_span)
       AND COUNT(DISTINCT year) = (SELECT max_year - min_year + 1 FROM year_span)
),
gdp AS (
    -- Rust HDP pro CR
    -- gdp_yoy je % zmena oproti predchozimu roku
    SELECT
        year,
        gdp,
        (gdp / NULLIF(LAG(gdp) OVER (ORDER BY year), 0) - 1) * 100 AS gdp_yoy
    FROM data_academy_content.economies
    WHERE country = 'Czech Republic'
),
wage_year AS (
    -- Celkova prumerna mzda za rok
    -- MIN slouci duplicity (stejna mzda opakovana pres kategorie)
    SELECT year, MIN(avg_wage) AS avg_wage
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_primary_final
    WHERE industry_branch_code IS NULL
    GROUP BY year
),
price_year AS (
    -- Rocni prumerna cena na kategorii
    -- MIN slouci duplicity (stejna cena opakovana pres odvetvi)
    SELECT year, category_code, MIN(avg_price) AS avg_price
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_primary_final
    WHERE category_code IN (SELECT category_code FROM full_categories)
    GROUP BY year, category_code
),
price_index AS (
    -- Jednoduchy cenovy index: prumer pres kategorie
    -- (nevazeny prumer cen kategorii)
    SELECT year, AVG(avg_price) AS avg_food_price
    FROM price_year
    GROUP BY year
),
joined AS (
    -- Spoji rust HDP, rust mezd a rust cen ve stejnem roce
    SELECT
        g.year,
        g.gdp_yoy,
        (w.avg_wage / NULLIF(LAG(w.avg_wage) OVER (ORDER BY w.year), 0) - 1) * 100 AS wage_yoy,
        (p.avg_food_price / NULLIF(LAG(p.avg_food_price) OVER (ORDER BY p.year), 0) - 1) * 100 AS price_yoy
    FROM gdp g
    JOIN wage_year w ON w.year = g.year
    JOIN price_index p ON p.year = g.year
),
lagged AS (
    -- Prida rust v nasledujicim roce pro test zpozdeneho efektu
    -- (Zda HDP pusobi vic do dalsiho roku)
    SELECT
        year,
        gdp_yoy,
        wage_yoy,
        price_yoy,
        LEAD(wage_yoy) OVER (ORDER BY year) AS wage_yoy_next,
        LEAD(price_yoy) OVER (ORDER BY year) AS price_yoy_next
    FROM joined
)
SELECT
    corr(gdp_yoy, wage_yoy) AS corr_gdp_wage_same_year,
    corr(gdp_yoy, price_yoy) AS corr_gdp_price_same_year,
    corr(gdp_yoy, wage_yoy_next) AS corr_gdp_wage_next_year,
    corr(gdp_yoy, price_yoy_next) AS corr_gdp_price_next_year
FROM lagged
WHERE gdp_yoy IS NOT NULL;
