-- Projekt SQL (PostgreSQL)
-- Q2: Kolik je možné si koupit litrů mléka a kilogramů chleba
--     za první a poslední srovnatelné období?
-- Pozn.: Použity jsou konkrétní kódy kategorií z czechia_price_category:
--        114201 = Mléko polotučné pasterované, 111301 = Chléb konzumní kmínový.
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
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_primary_final
    WHERE kod_odvetvi IS NULL -- Všechna odvětví
),
prvni_posledni AS (
    SELECT MIN(rok) AS prvni_rok, MAX(rok) AS posledni_rok
    FROM zaklad
),
vyber AS (
    SELECT z.*
    FROM zaklad z
    WHERE z.kod_potraviny IN (114201, 111301)
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
