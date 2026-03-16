# Engeto SQL projekt

## O projektu
Tento repozitar obsahuje SQL projekt zamereny na porovnani vyvoje mezd a cen zakladnich potravin v Ceske republice. Cil je pripravit robustni datovy zaklad pro odpovedi na vyzkumne otazky o dostupnosti potravin a doplnit jej o makroekonomicky kontext evropskych statu.

Projekt je navrzen tak, aby byl snadno reprodukovatelny: od vytvoreni vystupnich tabulek az po dotazy, ktere generuji podklady pro interpretaci vysledku.

## Vyzkumne otazky
1. Rostou v prubehu let mzdy ve vsech odvetvich, nebo v nekterych klesaji?
2. Kolik litru mleka a kilogramu chleba je mozne koupit za prvni a posledni srovnatelne obdobi?
3. Ktera kategorie potravin zdrazuje nejpomaleji (nejnizsi procentualni mezirocni narust)?
4. Existuje rok, ve kterem byl mezirocni narust cen potravin vyrazne vyssi nez rust mezd (vice nez 10 p.b.)?
5. Ma vyska HDP vliv na zmeny mezd a cen potravin ve stejnem nebo nasledujicim roce?

## Datove zdroje
Projekt vyuziva tabulky dostupne v databazi akademie:
- `czechia_payroll`, `czechia_payroll_*`
- `czechia_price`, `czechia_price_category`
- `countries`, `economies`

## Vystupni tabulky
Skripty vytvareji dve finalni tabulky:
- `t_Patrik_Moravek_project_SQL_primary_final`
- `t_Patrik_Moravek_project_SQL_secondary_final`

`primary_final` obsahuje data mezd a cen ve spolecnem casovem okne.
Granularita: `rok x odvetvi x kategorie potravin`.

`secondary_final` obsahuje evropske staty se sloupci `rok`, `stat`, `kontinent`, `hdp`, `gini`, `populace`, omezene na stejne roky jako primary tabulka.

## Jak projekt spustit
Doporucene poradi:
1. `sql/01_create_primary_final.sql`
2. `sql/02_create_secondary_final.sql`
3. Dotazy k vyzkumnym otazkam:
- `sql/03_q1_mzdy_mezirocni.sql`
- `sql/03_q2_mleko_chleb.sql`
- `sql/03_q3_zdrazovani_potravin.sql`
- `sql/03_q4_ceny_vs_mzdy.sql`
- `sql/03_q5_hdp_vliv.sql`

Soubor `sql/03_research_questions.sql` slouzi jako prehled mapovani dotazu na jednotlive vyzkumne otazky.

## Metodicke poznamky
- Mzdy jsou filtrovane na standardni kombinaci kodu (`calculation_code = 200`, `value_type_code = 5958`) a na celou CR (`region_code IS NULL`).
- Ceny jsou agregovane na rocni prumer podle kategorie potravin.
- Finalni primary tabulka je postavena na pruniku roku, kde existuji zaroven data mezd i cen.
- U kupni sily je vypocet `prumerna_mzda_czk / prumerna_cena_czk`.

## Struktura repozitare
- `sql/` - SQL skripty pro vytvoreni tabulek a analyzy
- `docs/` - doprovodna dokumentace
- `VYSLEDKY_VYZKUMU.md` - interpretace vystupu pro jednotlive vyzkumne otazky

## Autor
Patrik Moravek
