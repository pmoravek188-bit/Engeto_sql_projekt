# Pruvodni listina

## Vstupni tabulky
- czechia_payroll, czechia_payroll_calculation, czechia_payroll_industry_branch
- czechia_price, czechia_price_category
- countries, economies

## Transformace
- Mzdy: vybrana hodnota `value_type_code = 5958` (average gross wage), `calculation_code = 200` (full-time equivalent) a `unit_code = 200` (CZK).
- Mzdy jsou zprumerovane po roce (prumer z kvartalu) a ponechan je rozpad podle odvetvi. Zahrnuta je i agregace za celek (industry_branch_code IS NULL) pod nazvem `Celkem`.
- Ceny: pouzit nacionalni prumer (`region_code IS NULL`) a zprumerovani po roce pro kazdou kategorii potravin.
- Spolecne roky pro mzdy a ceny: 2006-2018 (prunik obou sad).
Komentar: Data v primarnich tabulkach nejsou upravovana, vsechny transformace jsou az v novych tabulkach.

## Vystupni tabulky
- `t_Patrik_Moravek_project_SQL_primary_final`
  - rok, odvetvi (kod + nazev), prumerna mzda
  - kategorie potravin (kod + nazev), prumerna cena, jednotka a mnozstvi
- `t_Patrik_Moravek_project_SQL_secondary_final`
  - evropske staty, rok, GDP, GINI, populace
Komentar: Primarni tabulka je granularita (rok x odvetvi x kategorie), sekundarni je (zeme x rok).

## Kvalita dat / poznamky
- V cenach je 26 kategorii v letech 2006-2014 a 27 kategorii v letech 2015-2018.
  - Kategorie `212101` (Jakostni vino bile) je dostupna az od roku 2015.
- Mzdy maji 19 odvetvi v kazdem roce plus agregaci `Celkem`.
- Ceny jsou v ruznych jednotkach a mnozstvich (napr. jogurt 150 g, vejce 10 ks, vino 0.75 l). Pri interpretaci je nutne pouzivat `price_value` + `price_unit`.
Komentar: Pri porovnavani dynamiky cen je vhodne pracovat s konzistentnim vyberem kategorii v celkove casove rade.

## Poznamka k pouziti
- Vsechny dotazy pro vyzkumne otazky jsou v souboru `analysis_queries.sql`.
- SQL pro vytvoreni tabulek je v souboru `create_tables.sql`.
