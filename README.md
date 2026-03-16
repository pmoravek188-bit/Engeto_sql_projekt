# Engeto SQL projekt

## O projektu
Tento repozitář obsahuje SQL projekt zaměřený na porovnání vývoje mezd a cen základních potravin v České republice. Cílem je připravit robustní datový základ pro odpovědi na výzkumné otázky o dostupnosti potravin a doplnit jej o makroekonomický kontext evropských států.

Projekt je navržen tak, aby byl snadno reprodukovatelný: od vytvoření výstupních tabulek až po dotazy, které generují podklady pro interpretaci výsledků.

## Výzkumné otázky
1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
2. Kolik litrů mléka a kilogramů chleba je možné koupit za první a poslední srovnatelné období?
3. Která kategorie potravin zdražuje nejpomaleji (nejnižší procentuální meziroční nárůst)?
4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (více než 10 p.b.)?
5. Má výška HDP vliv na změny mezd a cen potravin ve stejném nebo následujícím roce?

## Datové zdroje
Projekt využívá tabulky dostupné v databázi akademie:
- `czechia_payroll`, `czechia_payroll_*`
- `czechia_price`, `czechia_price_category`
- `countries`, `economies`

## Výstupní tabulky
Skripty vytvářejí dvě finální tabulky:
- `t_Patrik_Moravek_project_SQL_primary_final`
- `t_Patrik_Moravek_project_SQL_secondary_final`

`primary_final` obsahuje data mezd a cen ve společném časovém okně.
Granularita: `rok x odvětví x kategorie potravin`.

`secondary_final` obsahuje evropské státy se sloupci `rok`, `stat`, `kontinent`, `hdp`, `gini`, `populace`, omezené na stejné roky jako primary tabulka.

## Jak projekt spustit
Doporučené pořadí:
1. `sql/01_create_primary_final.sql`
2. `sql/02_create_secondary_final.sql`
3. Dotazy k výzkumným otázkám:
- `sql/03_q1_mzdy_mezirocni.sql`
- `sql/03_q2_mleko_chleb.sql`
- `sql/03_q3_zdrazovani_potravin.sql`
- `sql/03_q4_ceny_vs_mzdy.sql`
- `sql/03_q5_hdp_vliv.sql`

Soubor `sql/03_research_questions.sql` slouží jako přehled mapování dotazů na jednotlivé výzkumné otázky.

## Metodické poznámky
- Mzdy jsou filtrované na standardní kombinaci kódů (`calculation_code = 200`, `value_type_code = 5958`) a na celou ČR (`region_code IS NULL`).
- Ceny jsou agregované na roční průměr podle kategorie potravin.
- Finální primary tabulka je postavena na průniku roků, kde existují zároveň data mezd i cen.
- U kupní síly je výpočet `prumerna_mzda_czk / prumerna_cena_czk`.

## Struktura repozitáře
- `sql/` - SQL skripty pro vytvoření tabulek a analýzy
- `docs/` - doprovodná dokumentace
- `VYSLEDKY_VYZKUMU.md` - interpretace výstupů pro jednotlivé výzkumné otázky

## Autor
Patrik Moravek
