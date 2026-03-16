## Průvodní listina (mezivýsledky, transformace, limity)

### Odkud jsou data (zdroje)
Všechno se počítá **přímo z databáze** (žádné úpravy primárních tabulek, žádné externí zdroje).

Použité tabulky:
- `czechia_payroll` + číselníky `czechia_payroll_*` (mzdy)
- `czechia_price` + `czechia_price_category` (ceny potravin)
- `economies` + `countries` (HDP, GINI, populace)

### Cíl
Připravit datové podklady pro porovnání dostupnosti potravin na základě průměrných příjmů v čase (ČR) a dodat evropský kontext (HDP, GINI, populace).

### Přehled výstupů
- **`t_Patrik_Moravek_project_SQL_primary_final`**
  - sjednocuje mzdy a ceny potravin na **společné roky**
  - granularita: **rok × odvětví × potravina**
  - sloupce jsou **česky (bez diakritiky)**

- **`t_Patrik_Moravek_project_SQL_secondary_final`**
  - evropské státy a roky shodné s primary tabulkou
  - sloupce: `rok`, `stat`, `hdp`, `gini`, `populace`

### Transformace – primary tabulka
- **Mzdy**
  - filtr: `calculation_code = 200` a `value_type_code = 5958` (nejčastěji "průměrná hrubá mzda")
  - filtr: `unit_code = 200` (Kč)
  - data mezd jsou vedena na úrovni celé ČR (bez regionálního sloupce)
  - agregace: `AVG(value)` na úroveň **rok × odvětví**
  - `kod_odvetvi IS NULL` je vedeno jako **Všechna odvětví** (agregace)

- **Ceny potravin**
  - roční agregace: `EXTRACT(YEAR FROM date_from)`
  - agregace: `AVG(value)` na úroveň **rok × kategorie potraviny**
  - přenáší se i jednotka (`mnozstvi`, `jednotka`) z `czechia_price_category`

- **Společné roky**
  - primary tabulka obsahuje jen průnik roků, kde existují data mezd i cen

- **Doplňková metrika**
  - `kupni_sila_jednotek = prumerna_mzda_czk / prumerna_cena_czk` (kolik jednotek potraviny lze koupit za průměrnou mzdu)

### Transformace – secondary tabulka
- filtr: `kontinent = 'Europe'`
- filtr na roky: pouze roky existující v primary tabulce

### Limity / rizika kvality dat
- **Kódy mezd**: pokud v DB neodpovídají `calculation_code=200` a `value_type_code=5958`, je nutné upravit filtr dle číselníků.
- **Otázka 2**: dotaz je navázán na konkrétní kódy potravin (`114201` mléko, `111301` chléb); při jiné verzi číselníku je nutné kódy upravit.
- **Agregace cen**: průměr přes všechny záznamy v roce (není vážený spotřebou).

### Doporučené ověření po spuštění
- rozsah roku v primary: `SELECT MIN(rok), MAX(rok) FROM t_Patrik_Moravek_project_SQL_primary_final;`
- existence "Všechna odvětví": `SELECT COUNT(*) FROM t_Patrik_Moravek_project_SQL_primary_final WHERE kod_odvetvi IS NULL;`
- existence CR v secondary: `SELECT DISTINCT stat FROM t_Patrik_Moravek_project_SQL_secondary_final WHERE LOWER(stat) LIKE 'czech%';`
