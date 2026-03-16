-- Projekt SQL (PostgreSQL)
-- Q5: Má výška HDP vliv na změny ve mzdách a cenách potravin?
--     Výstup: korelace růstu HDP vůči růstu mezd a cen
--     ve stejném i následujícím roce.
-- Autor: Patrik Moravek

WITH
nazev_cr AS (
    SELECT stat
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_secondary_final
    WHERE LOWER(stat) IN ('czech republic', 'czechia')
    LIMIT 1
),
cr_hdp AS (
    SELECT
        s.rok,
        (s.hdp / NULLIF(LAG(s.hdp) OVER (ORDER BY s.rok), 0) - 1) * 100 AS mezirocni_zmena_hdp_pct
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_secondary_final s
    JOIN nazev_cr n
        ON n.stat = s.stat
),
cr_mzda AS (
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
cr_cena AS (
    SELECT
        rok,
        AVG(prumerna_cena_czk) AS prumerna_cena_potravin_czk
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_primary_final
    WHERE kod_potraviny IN (SELECT kod_potraviny FROM plne_kategorie)
    GROUP BY rok
),
spojene AS (
    SELECT
        h.rok,
        h.mezirocni_zmena_hdp_pct,
        (m.prumerna_mzda_czk / NULLIF(LAG(m.prumerna_mzda_czk) OVER (ORDER BY h.rok), 0) - 1) * 100 AS mezirocni_zmena_mzdy_pct,
        (c.prumerna_cena_potravin_czk / NULLIF(LAG(c.prumerna_cena_potravin_czk) OVER (ORDER BY h.rok), 0) - 1) * 100 AS mezirocni_zmena_cen_pct
    FROM cr_hdp h
    JOIN cr_mzda m
        ON m.rok = h.rok
    JOIN cr_cena c
        ON c.rok = h.rok
),
posun AS (
    SELECT
        rok,
        mezirocni_zmena_hdp_pct,
        mezirocni_zmena_mzdy_pct,
        mezirocni_zmena_cen_pct,
        LEAD(mezirocni_zmena_mzdy_pct) OVER (ORDER BY rok) AS mezirocni_zmena_mzdy_pct_dalsi_rok,
        LEAD(mezirocni_zmena_cen_pct) OVER (ORDER BY rok) AS mezirocni_zmena_cen_pct_dalsi_rok
    FROM spojene
)
SELECT
    ROUND(CORR(mezirocni_zmena_hdp_pct, mezirocni_zmena_mzdy_pct)::numeric, 3) AS corr_hdp_mzdy_stejny_rok,
    ROUND(CORR(mezirocni_zmena_hdp_pct, mezirocni_zmena_cen_pct)::numeric, 3) AS corr_hdp_ceny_stejny_rok,
    ROUND(CORR(mezirocni_zmena_hdp_pct, mezirocni_zmena_mzdy_pct_dalsi_rok)::numeric, 3) AS corr_hdp_mzdy_dalsi_rok,
    ROUND(CORR(mezirocni_zmena_hdp_pct, mezirocni_zmena_cen_pct_dalsi_rok)::numeric, 3) AS corr_hdp_ceny_dalsi_rok
FROM posun
WHERE mezirocni_zmena_hdp_pct IS NOT NULL;
