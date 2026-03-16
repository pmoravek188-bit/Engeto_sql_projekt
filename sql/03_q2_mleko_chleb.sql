-- Projekt SQL (PostgreSQL)
-- Q2: Kolik je možné si koupit litrů mléka a kilogramů chleba
--     za první a poslední srovnatelné období?
-- Pozn.: Identifikace kategorií podle názvu (LIKE). Pokud názvy v DB nesedí,
--        nahraď ručně kod_potraviny.
-- Autor: Patrik Moravek

WITH zaklad AS (
    SELECT
        rok,
        kod_odvetvi,
        nazev_odvetvi,
        prumerna_mzda_czk,
        kod_potraviny,
        nazev_potraviny,
        mnozstvi,
        jednotka,
        prumerna_cena_czk,
        kupni_sila_jednotek
    FROM t_Patrik_Moravek_project_SQL_primary_final
    WHERE kod_odvetvi IS NULL -- Všechna odvětví
),
prvni_posledni AS (
    SELECT MIN(rok) AS prvni_rok, MAX(rok) AS posledni_rok
    FROM zaklad
),
vyber AS (
    SELECT z.*
    FROM zaklad z
    WHERE (
        LOWER(z.nazev_potraviny) LIKE '%ml%c%ko%'
        OR LOWER(z.nazev_potraviny) LIKE '%mleko%'
        OR LOWER(z.nazev_potraviny) LIKE '%milk%'
        OR LOWER(z.nazev_potraviny) LIKE '%chleb%'
        OR LOWER(z.nazev_potraviny) LIKE '%bread%'
    )
)
SELECT
    v.kod_potraviny,
    v.nazev_potraviny,
    v.mnozstvi,
    v.jednotka,
    v.rok,
    ROUND(v.prumerna_mzda_czk::numeric, 2) AS prumerna_mzda_czk,
    ROUND(v.prumerna_cena_czk::numeric, 2) AS prumerna_cena_czk,
    ROUND(v.kupni_sila_jednotek::numeric, 2) AS kupni_sila_jednotek
FROM vyber v
JOIN prvni_posledni pp
    ON v.rok IN (pp.prvni_rok, pp.posledni_rok)
ORDER BY v.nazev_potraviny, v.rok;
