-- Projekt SQL (PostgreSQL)
-- Secondary finální tabulka: evropské státy (HDP, GINI, populace) ve stejném období jako primary tabulka
-- Autor: Patrik Moravek
--
-- ZDROJE DAT (v DB):
-- - economies (HDP, GINI, populace)
-- - countries (kontinent)

DROP TABLE IF EXISTS data_academy_content.t_Patrik_Moravek_project_SQL_secondary_final;

CREATE TABLE data_academy_content.t_Patrik_Moravek_project_SQL_secondary_final AS
WITH
-- Roky, které jsou v primary (společné roky mezd a cen)
roky_primary AS (
    SELECT DISTINCT rok
    FROM data_academy_content.t_Patrik_Moravek_project_SQL_primary_final
),

-- Evropské státy (kontinent Europe) + jen roky z primary
evropa AS (
    SELECT
        e.year AS rok,
        c.country AS stat,
        c.continent AS kontinent,
        e.GDP AS hdp,
        e.gini AS gini,
        e.population AS populace
    FROM data_academy_content.economies e
    JOIN data_academy_content.countries c
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

CREATE INDEX IF NOT EXISTS idx_t_pm_secondary_rok ON data_academy_content.t_Patrik_Moravek_project_SQL_secondary_final(rok);
CREATE INDEX IF NOT EXISTS idx_t_pm_secondary_stat ON data_academy_content.t_Patrik_Moravek_project_SQL_secondary_final(stat);
