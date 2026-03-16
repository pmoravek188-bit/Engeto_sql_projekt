-- Projekt SQL (PostgreSQL)
-- Q3: Ktera kategorie potravin zdrazuje nejpomaleji?
--     (nejnizsi prumerny mezirocni percentualni narust)
-- Autor: Patrik Moravek

WITH ceny AS (
    SELECT
        rok,
        kod_potraviny,
        nazev_potraviny,
        AVG(prumerna_cena_czk) AS prumerna_cena_czk
    FROM t_Patrik_Moravek_project_SQL_primary_final
    GROUP BY rok, kod_potraviny, nazev_potraviny
),
mezirocne AS (
    SELECT
        rok,
        kod_potraviny,
        nazev_potraviny,
        prumerna_cena_czk,
        LAG(prumerna_cena_czk) OVER (PARTITION BY kod_potraviny ORDER BY rok) AS prumerna_cena_minuly_rok
    FROM ceny
),
jen_mezirocne AS (
    SELECT
        kod_potraviny,
        nazev_potraviny,
        ((prumerna_cena_czk - prumerna_cena_minuly_rok) / NULLIF(prumerna_cena_minuly_rok, 0) * 100) AS mezirocni_zmena_ceny_pct
    FROM mezirocne
    WHERE prumerna_cena_minuly_rok IS NOT NULL
)
SELECT
    kod_potraviny,
    nazev_potraviny,
    ROUND(AVG(mezirocni_zmena_ceny_pct)::numeric, 2) AS prumerna_mezirocni_zmena_ceny_pct,
    ROUND(MIN(mezirocni_zmena_ceny_pct)::numeric, 2) AS minimalni_mezirocni_zmena_ceny_pct,
    ROUND(MAX(mezirocni_zmena_ceny_pct)::numeric, 2) AS maximalni_mezirocni_zmena_ceny_pct,
    COUNT(*) AS pocet_mezirocnych_bodu
FROM jen_mezirocne
GROUP BY kod_potraviny, nazev_potraviny
ORDER BY prumerna_mezirocni_zmena_ceny_pct ASC, nazev_potraviny;
