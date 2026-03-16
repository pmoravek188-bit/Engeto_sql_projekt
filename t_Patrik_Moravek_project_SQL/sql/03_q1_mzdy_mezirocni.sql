-- Projekt SQL (PostgreSQL)
-- Q1: Rostou v prubehu let mzdy ve vsech odvetvich, nebo v nekterych klesaji?
-- Vystup: mezirocni zmena mezd (YoY %) po odvetvi.
-- Autor: Patrik Moravek

-- Hlavni vystup: mezirocni zmena mezd po odvetvi
WITH mzdy AS (
    SELECT
        rok,
        kod_odvetvi,
        nazev_odvetvi,
        AVG(prumerna_mzda_czk) AS prumerna_mzda_czk
    FROM t_Patrik_Moravek_project_SQL_primary_final
    GROUP BY rok, kod_odvetvi, nazev_odvetvi
),
mezirocne AS (
    SELECT
        rok,
        kod_odvetvi,
        nazev_odvetvi,
        prumerna_mzda_czk,
        LAG(prumerna_mzda_czk) OVER (PARTITION BY kod_odvetvi ORDER BY rok) AS prumerna_mzda_minuly_rok
    FROM mzdy
)
SELECT
    rok,
    kod_odvetvi,
    nazev_odvetvi,
    ROUND(prumerna_mzda_czk::numeric, 2) AS prumerna_mzda_czk,
    ROUND(prumerna_mzda_minuly_rok::numeric, 2) AS prumerna_mzda_minuly_rok,
    ROUND(((prumerna_mzda_czk - prumerna_mzda_minuly_rok) / NULLIF(prumerna_mzda_minuly_rok, 0) * 100)::numeric, 2) AS mezirocni_zmena_mzdy_pct
FROM mezirocne
WHERE prumerna_mzda_minuly_rok IS NOT NULL
ORDER BY nazev_odvetvi, rok;

-- Rychly prehled: odvetvi a pocet poklesu
WITH mzdy AS (
    SELECT
        rok,
        kod_odvetvi,
        nazev_odvetvi,
        AVG(prumerna_mzda_czk) AS prumerna_mzda_czk
    FROM t_Patrik_Moravek_project_SQL_primary_final
    WHERE kod_odvetvi IS NOT NULL
    GROUP BY rok, kod_odvetvi, nazev_odvetvi
),
mezirocne AS (
    SELECT
        rok,
        kod_odvetvi,
        nazev_odvetvi,
        prumerna_mzda_czk,
        LAG(prumerna_mzda_czk) OVER (PARTITION BY kod_odvetvi ORDER BY rok) AS prumerna_mzda_minuly_rok
    FROM mzdy
)
SELECT
    nazev_odvetvi,
    COUNT(*) FILTER (WHERE prumerna_mzda_minuly_rok IS NOT NULL) AS pocet_mezirocnych_bodu,
    COUNT(*) FILTER (WHERE prumerna_mzda_czk < prumerna_mzda_minuly_rok) AS pocet_poklesu
FROM mezirocne
GROUP BY nazev_odvetvi
ORDER BY pocet_poklesu DESC, nazev_odvetvi;
