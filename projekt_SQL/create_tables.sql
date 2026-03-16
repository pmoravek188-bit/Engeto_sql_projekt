-- Vytvori primarni tabulku: rocni mzdy a ceny potravin ve spolecnem obdobi (CR)
-- Vystup: jeden radek na (rok x odvetvi x kategorie potravin)
DROP TABLE IF EXISTS data_academy_content.t_Patrik_Moravek_project_SQL_primary_final;

CREATE TABLE data_academy_content.t_Patrik_Moravek_project_SQL_primary_final AS
WITH payroll AS (
    -- Rocni prumerna hruba mzda v CZK (prepocteny stav) podle odvetvi
    -- AVG() agreguje kvartalni hodnoty na jednu rocni hodnotu
    SELECT
        cp.payroll_year AS year,
        cp.industry_branch_code,
        -- COALESCE pridava citelny nazev pro agregaci Celkem (industry_branch_code IS NULL)
        COALESCE(ib.name, 'Celkem') AS industry_branch_name,
        -- Zaokrouhleno pro prehlednost (v tabulce zustava numeric)
        ROUND(AVG(cp.value)::numeric, 2) AS avg_wage
    FROM data_academy_content.czechia_payroll cp
    LEFT JOIN data_academy_content.czechia_payroll_industry_branch ib
        ON cp.industry_branch_code = ib.code
    WHERE cp.value_type_code = 5958 -- average gross wage
      AND cp.calculation_code = 200 -- full-time equivalent
      AND cp.unit_code = 200        -- CZK
    GROUP BY cp.payroll_year, cp.industry_branch_code, COALESCE(ib.name, 'Celkem')
),
price AS (
    -- Rocni prumerna cena potravin podle kategorie (pouze narodny prumer)
    -- AVG() agreguje vice mericich zaznamu v roce
    SELECT
        EXTRACT(YEAR FROM p.date_from)::int AS year,
        p.category_code,
        pc.name AS category_name,
        pc.price_value,
        pc.price_unit,
        -- Zaokrouhleno pro prehlednost
        ROUND(AVG(p.value)::numeric, 2) AS avg_price
    FROM data_academy_content.czechia_price p
    JOIN data_academy_content.czechia_price_category pc
        ON p.category_code = pc.code
    WHERE p.region_code IS NULL -- national average
    GROUP BY EXTRACT(YEAR FROM p.date_from)::int, p.category_code, pc.name, pc.price_value, pc.price_unit
)
-- Spojeni podle roku zachova pouze prunik obdobi mezd a cen
-- Tim se vynuti spolecne casove okno napric daty
SELECT
    pr.year,
    pr.industry_branch_code,
    pr.industry_branch_name,
    pr.avg_wage,
    pc.category_code,
    pc.category_name,
    pc.price_value,
    pc.price_unit,
    pc.avg_price
FROM payroll pr
JOIN price pc ON pc.year = pr.year
ORDER BY pr.year, pr.industry_branch_code, pc.category_code;

-- Vytvori sekundarni tabulku: evropske staty s HDP, GINI a populaci
-- Zarovnano na stejne obdobi jako primarni tabulka
DROP TABLE IF EXISTS data_academy_content.t_Patrik_Moravek_project_SQL_secondary_final;

CREATE TABLE data_academy_content.t_Patrik_Moravek_project_SQL_secondary_final AS
WITH years AS (
    -- Zjisti minimalni a maximalni rok z primarni tabulky
    SELECT MIN(year) AS min_year, MAX(year) AS max_year
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_primary_final
)
SELECT
    e.country,
    e.year,
    e.gdp,
    e.gini,
    e.population
FROM data_academy_content.economies e
JOIN data_academy_content.countries c
    ON e.country = c.country
JOIN years y
    ON e.year BETWEEN y.min_year AND y.max_year
WHERE c.continent = 'Europe'
ORDER BY e.country, e.year;
