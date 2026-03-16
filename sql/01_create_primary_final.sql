-- Projekt SQL (PostgreSQL)
-- Primární finální tabulka: mzdy + ceny potravin v ČR sjednocené na společné roky
-- Autor: Patrik Moravek
--
-- ZDROJE DAT (v DB):
-- - czechia_payroll (mzdy) + číselníky czechia_payroll_*
-- - czechia_price (ceny) + czechia_price_category
--
-- Pozn.: Filtry calculation_code/value_type_code odpovídají nejčastějšímu nastavení datasetu
-- (calculation_code = 200, value_type_code = 5958). Pokud máš v DB jiné kódy,
-- uprav je podle číselníků czechia_payroll_calculation a czechia_payroll_value_type.

DROP TABLE IF EXISTS t_Patrik_Moravek_project_SQL_primary_final;

CREATE TABLE t_Patrik_Moravek_project_SQL_primary_final AS
WITH
-- 1) MZDY: průměrná hrubá mzda na zaměstnance
--    industry_branch_code IS NULL často představuje agregaci "všechna odvětví".
mzdy AS (
    SELECT
        p.payroll_year AS rok,
        p.industry_branch_code AS kod_odvetvi,
        COALESCE(ib.name, 'Vsechna odvetvi') AS nazev_odvetvi,
        AVG(p.value) AS prumerna_mzda_czk
    FROM czechia_payroll p
    LEFT JOIN czechia_payroll_industry_branch ib
        ON ib.code = p.industry_branch_code
    WHERE 1=1
        AND p.value IS NOT NULL
        AND p.calculation_code = 200
        AND p.value_type_code = 5958
        AND p.unit_code = 200
    GROUP BY
        p.payroll_year,
        p.industry_branch_code,
        COALESCE(ib.name, 'Vsechna odvetvi')
),

-- 2) CENY: průměrné ceny potravin za rok (agregace přes regiony a pozorování)
--    Rok bereme z date_from.
ceny AS (
    SELECT
        EXTRACT(YEAR FROM cp.date_from)::int AS rok,
        cp.category_code AS kod_potraviny,
        pc.name AS nazev_potraviny,
        pc.price_value AS mnozstvi,
        pc.price_unit AS jednotka,
        AVG(cp.value) AS prumerna_cena_czk
    FROM czechia_price cp
    JOIN czechia_price_category pc
        ON pc.code = cp.category_code
    WHERE 1=1
        AND cp.value IS NOT NULL
        AND cp.category_code IS NOT NULL
    GROUP BY
        EXTRACT(YEAR FROM cp.date_from)::int,
        cp.category_code,
        pc.name,
        pc.price_value,
        pc.price_unit
),

-- 3) SPOLEČNÉ ROKY: průnik roků, kde máme i mzdy i ceny
spolecne_roky AS (
    SELECT rok FROM mzdy
    INTERSECT
    SELECT rok FROM ceny
)

-- 4) Finální dataset: join přes rok => (rok x odvětví x potravina)
SELECT
    r.rok,

    m.kod_odvetvi,
    m.nazev_odvetvi,
    ROUND(m.prumerna_mzda_czk::numeric, 2) AS prumerna_mzda_czk,

    c.kod_potraviny,
    c.nazev_potraviny,
    c.mnozstvi,
    c.jednotka,
    ROUND(c.prumerna_cena_czk::numeric, 2) AS prumerna_cena_czk,

    -- Kolik jednotek (mnozstvi + jednotka) koupím za průměrnou mzdu
    ROUND((m.prumerna_mzda_czk / NULLIF(c.prumerna_cena_czk, 0))::numeric, 2) AS kupni_sila_jednotek
FROM spolecne_roky r
JOIN mzdy m
    ON m.rok = r.rok
JOIN ceny c
    ON c.rok = r.rok
;

-- Doporučené indexy (volitelné)
CREATE INDEX IF NOT EXISTS idx_t_pm_primary_rok ON t_Patrik_Moravek_project_SQL_primary_final(rok);
CREATE INDEX IF NOT EXISTS idx_t_pm_primary_odvetvi ON t_Patrik_Moravek_project_SQL_primary_final(kod_odvetvi);
CREATE INDEX IF NOT EXISTS idx_t_pm_primary_potravina ON t_Patrik_Moravek_project_SQL_primary_final(kod_potraviny);
