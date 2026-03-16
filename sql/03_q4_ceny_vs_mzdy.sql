-- Projekt SQL (PostgreSQL)
-- Q4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší
--     než růst mezd (o více než 10 p.b.)?
--     (agregace: průměr cen napříč potravinami vs mzda "Všechna odvětví")
-- Autor: Patrik Moravek

WITH mzda_vse AS (
    SELECT
        rok,
        AVG(prumerna_mzda_czk) AS prumerna_mzda_czk
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_primary_final
    WHERE kod_odvetvi IS NULL
    GROUP BY rok
),
rok_rozsah AS (
    SELECT MIN(rok) AS min_rok, MAX(rok) AS max_rok
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_primary_final
),
plne_kategorie AS (
    SELECT kod_potraviny
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_primary_final
    GROUP BY kod_potraviny
    HAVING MIN(rok) = (SELECT min_rok FROM rok_rozsah)
       AND MAX(rok) = (SELECT max_rok FROM rok_rozsah)
       AND COUNT(DISTINCT rok) = (SELECT max_rok - min_rok + 1 FROM rok_rozsah)
),
cena_prumer AS (
    SELECT
        rok,
        AVG(prumerna_cena_czk) AS prumerna_cena_potravin_czk
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_primary_final
    WHERE kod_potraviny IN (SELECT kod_potraviny FROM plne_kategorie)
    GROUP BY rok
),
spojene AS (
    SELECT
        m.rok,
        m.prumerna_mzda_czk,
        c.prumerna_cena_potravin_czk,
        LAG(m.prumerna_mzda_czk) OVER (ORDER BY m.rok) AS mzda_minuly_rok,
        LAG(c.prumerna_cena_potravin_czk) OVER (ORDER BY m.rok) AS cena_minuly_rok
    FROM mzda_vse m
    JOIN cena_prumer c
        ON c.rok = m.rok
),
mezirocne AS (
    SELECT
        rok,
        ((prumerna_mzda_czk - mzda_minuly_rok) / NULLIF(mzda_minuly_rok, 0) * 100) AS mezirocni_zmena_mzdy_pct,
        ((prumerna_cena_potravin_czk - cena_minuly_rok) / NULLIF(cena_minuly_rok, 0) * 100) AS mezirocni_zmena_cen_pct
    FROM spojene
    WHERE mzda_minuly_rok IS NOT NULL AND cena_minuly_rok IS NOT NULL
)
SELECT
    rok,
    ROUND(mezirocni_zmena_mzdy_pct::numeric, 2) AS mezirocni_zmena_mzdy_pct,
    ROUND(mezirocni_zmena_cen_pct::numeric, 2) AS mezirocni_zmena_cen_pct,
    ROUND((mezirocni_zmena_cen_pct - mezirocni_zmena_mzdy_pct)::numeric, 2) AS rozdil_ceny_minus_mzdy_pb
FROM mezirocne
WHERE (mezirocni_zmena_cen_pct - mezirocni_zmena_mzdy_pct) > 10
ORDER BY rozdil_ceny_minus_mzdy_pb DESC, rok;
