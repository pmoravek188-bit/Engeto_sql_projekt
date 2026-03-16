-- Projekt SQL (PostgreSQL)
-- Secondary finalni tabulka: evropske staty (HDP, GINI, populace) ve stejnem obdobi jako primary tabulka
-- Autor: Patrik Moravek
--
-- ZDROJE DAT (v DB):
-- - economies (HDP, GINI, populace)
-- - countries (kontinent)

DROP TABLE IF EXISTS t_Patrik_Moravek_project_SQL_secondary_final;

CREATE TABLE t_Patrik_Moravek_project_SQL_secondary_final AS
WITH
-- roky, ktere jsou v primary (spolecne roky mezd a cen)
roky_primary AS (
    SELECT DISTINCT rok
    FROM t_Patrik_Moravek_project_SQL_primary_final
),

-- evropske staty (kontinent Europe) + jen roky z primary
evropa AS (
    SELECT
        e.year AS rok,
        c.country AS stat,
        c.continent AS kontinent,
        e.GDP AS hdp,
        e.gini AS gini,
        e.population AS populace
    FROM economies e
    JOIN countries c
        ON c.country = e.country
    JOIN roky_primary rp
        ON rp.rok = e.year
    WHERE 1=1
        AND c.continent = 'Europe'
)
SELECT
    rok,
    stat,
    kontinent,
    hdp,
    gini,
    populace
FROM evropa
;

CREATE INDEX IF NOT EXISTS idx_t_pm_secondary_rok ON t_Patrik_Moravek_project_SQL_secondary_final(rok);
CREATE INDEX IF NOT EXISTS idx_t_pm_secondary_stat ON t_Patrik_Moravek_project_SQL_secondary_final(stat);
