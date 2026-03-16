-- Projekt SQL (PostgreSQL)
-- Q5: Má výška HDP vliv na změny ve mzdách a cenách potravin?
--     (ČR v secondary) a porovnání YoY HDP vs YoY mzdy/ceny
--     ve stejném roce i s posunem o 1 rok.
-- Autor: Patrik Moravek

WITH
nazev_cr AS (
    SELECT stat
    FROM t_Patrik_Moravek_project_SQL_secondary_final
    WHERE LOWER(stat) IN ('czech republic', 'czechia')
    LIMIT 1
),

cr_eko AS (
    SELECT
        s.rok,
        s.stat,
        s.hdp,
        LAG(s.hdp) OVER (ORDER BY s.rok) AS hdp_minuly_rok
    FROM t_Patrik_Moravek_project_SQL_secondary_final s
    JOIN nazev_cr n
        ON n.stat = s.stat
),

cr_mzda AS (
    SELECT
        rok,
        AVG(prumerna_mzda_czk) AS prumerna_mzda_czk
    FROM t_Patrik_Moravek_project_SQL_primary_final
    WHERE kod_odvetvi IS NULL
    GROUP BY rok
),
cr_cena AS (
    SELECT
        rok,
        AVG(prumerna_cena_czk) AS prumerna_cena_potravin_czk
    FROM t_Patrik_Moravek_project_SQL_primary_final
    GROUP BY rok
),

spojene AS (
    SELECT
        e.rok,
        e.hdp,
        e.hdp_minuly_rok,
        m.prumerna_mzda_czk,
        LAG(m.prumerna_mzda_czk) OVER (ORDER BY e.rok) AS mzda_minuly_rok,
        c.prumerna_cena_potravin_czk,
        LAG(c.prumerna_cena_potravin_czk) OVER (ORDER BY e.rok) AS cena_minuly_rok
    FROM cr_eko e
    JOIN cr_mzda m
        ON m.rok = e.rok
    JOIN cr_cena c
        ON c.rok = e.rok
),

mezirocne AS (
    SELECT
        rok,
        ((hdp - hdp_minuly_rok) / NULLIF(hdp_minuly_rok, 0) * 100) AS mezirocni_zmena_hdp_pct,
        ((prumerna_mzda_czk - mzda_minuly_rok) / NULLIF(mzda_minuly_rok, 0) * 100) AS mezirocni_zmena_mzdy_pct,
        ((prumerna_cena_potravin_czk - cena_minuly_rok) / NULLIF(cena_minuly_rok, 0) * 100) AS mezirocni_zmena_cen_pct
    FROM spojene
    WHERE hdp_minuly_rok IS NOT NULL AND mzda_minuly_rok IS NOT NULL AND cena_minuly_rok IS NOT NULL
)
SELECT
    rok,
    ROUND(mezirocni_zmena_hdp_pct::numeric, 2) AS mezirocni_zmena_hdp_pct,
    ROUND(mezirocni_zmena_mzdy_pct::numeric, 2) AS mezirocni_zmena_mzdy_pct,
    ROUND(mezirocni_zmena_cen_pct::numeric, 2) AS mezirocni_zmena_cen_pct,
    -- Posun o 1 rok (HDP v roce t vs mzdy/ceny v roce t+1)
    ROUND(LEAD(mezirocni_zmena_mzdy_pct) OVER (ORDER BY rok)::numeric, 2) AS mezirocni_zmena_mzdy_pct_dalsi_rok,
    ROUND(LEAD(mezirocni_zmena_cen_pct) OVER (ORDER BY rok)::numeric, 2) AS mezirocni_zmena_cen_pct_dalsi_rok
FROM mezirocne
ORDER BY rok;
