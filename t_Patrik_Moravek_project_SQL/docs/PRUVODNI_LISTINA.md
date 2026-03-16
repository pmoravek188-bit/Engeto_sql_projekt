## Pruvodni listina (mezivysledky, transformace, limity)

### Odkud jsou data (zdroje)
Vsechno se pocita **primo z databaze** (zadne upravy primarnich tabulek, zadne externi zdroje).

Pouzite tabulky:
- `czechia_payroll` + ciselniky `czechia_payroll_*` (mzdy)
- `czechia_price` + `czechia_price_category` (ceny potravin)
- `economies` + `countries` (HDP, GINI, populace)

### CIL
Pripravit datove podklady pro porovnani dostupnosti potravin na zaklade prumernych prijmu v case (CR) a dodat evropsky kontext (HDP, GINI, populace).

### Prehled vystupu
- **`t_Patrik_Moravek_project_SQL_primary_final`**
  - sjednocuje mzdy a ceny potravin na **spolecne roky**
  - granularita: **rok × odvetvi × potravina**
  - sloupce jsou **cesky (bez diakritiky)**

- **`t_Patrik_Moravek_project_SQL_secondary_final`**
  - evropske staty a roky shodne s primary tabulkou
  - sloupce: `rok`, `stat`, `hdp`, `gini`, `populace`

### Transformace – primary tabulka
- **Mzdy**
  - filtr: `calculation_code = 200` a `value_type_code = 5958` (nejcasteji "prumerna hruba mzda")
  - filtr: `region_code IS NULL` jako "cela CR" (pokud je u tebe jinak, uprav)
  - agregace: `AVG(value)` na uroven **rok × odvetvi**
  - `kod_odvetvi IS NULL` je vedeno jako **Vsechna odvetvi** (agregace)

- **Ceny potravin**
  - rocni agregace: `EXTRACT(YEAR FROM date_from)`
  - agregace: `AVG(value)` na uroven **rok × kategorie potraviny**
  - prenasi se i jednotka (`mnozstvi`, `jednotka`) z `czechia_price_category`

- **Spolecne roky**
  - primary tabulka obsahuje jen prunik roku, kde existuji data mezd i cen

- **Doplnkova metrika**
  - `kupni_sila_jednotek = prumerna_mzda_czk / prumerna_cena_czk` (kolik jednotek potraviny lze koupit za prumernou mzdu)

### Transformace – secondary tabulka
- filtr: `kontinent = 'Europe'`
- filtr na roky: pouze roky existujici v primary tabulce

### Limity / rizika kvality dat
- **Kody mezd**: pokud v DB neodpovidaji `calculation_code=200` a `value_type_code=5958`, je nutne upravit filtr dle ciselniku.
- **Cela CR**: nektere implementace datasetu nemusi pouzivat `region_code IS NULL` pro celou CR.
- **Otazka 2**: identifikace mleka/chleba pres nazev muze selhat pri jinem pojmenovani; idealne pouzit `kod_potraviny`.
- **Agregace cen**: prumer pres vsechny zaznamy v roce (neni vahovany spotrebou).

### Doporucene overeni po spusteni
- rozsah roku v primary: `SELECT MIN(rok), MAX(rok) FROM t_Patrik_Moravek_project_SQL_primary_final;`
- existence "Vsechna odvetvi": `SELECT COUNT(*) FROM t_Patrik_Moravek_project_SQL_primary_final WHERE kod_odvetvi IS NULL;`
- existence CR v secondary: `SELECT DISTINCT stat FROM t_Patrik_Moravek_project_SQL_secondary_final WHERE LOWER(stat) LIKE 'czech%';`
