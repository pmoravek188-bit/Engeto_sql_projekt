## Projekt z SQL – dostupnost potravin vs mzdy (CR) + evropsky kontext

Tohle jsou **SQL skripty**, ktere pracuji primo s tabulkami z databaze (zadne externi stahovani dat).

### Odkud jsou data (z ceho se to pocita)
Skripty pocitaji z techto tabulek, ktere mas v DB dle zadani:
- **Mzdy**: `czechia_payroll` + ciselniky (`czechia_payroll_*`)
- **Ceny**: `czechia_price` + `czechia_price_category`
- **Evropa (HDP/GINI/populace)**: `economies` + `countries`

### Vystupni tabulky
- **Primary**: `t_Patrik_Moravek_project_SQL_primary_final`
  - mzdy + ceny potravin sjednocene na **spolecne roky** (prunik let mezd a cen)
  - granularita: **rok × odvetvi × potravina**
  - sloupce jsou **cesky (bez diakritiky)**, napr. `rok`, `nazev_odvetvi`, `prumerna_mzda_czk`, `nazev_potraviny`, `prumerna_cena_czk`, `kupni_sila_jednotek`
  - obsahuje i agregaci **"Vsechna odvetvi"** (`kod_odvetvi IS NULL`) pro jednodussi agregovane analyzy

- **Secondary**: `t_Patrik_Moravek_project_SQL_secondary_final`
  - evropske staty (`kontinent = 'Europe'`)
  - pouze roky, ktere jsou v primary tabulce
  - sloupce: `rok`, `stat`, `hdp`, `gini`, `populace`

### Jak spustit
Spust SQL soubory v tomto poradi:
- `sql/01_create_primary_final.sql`
- `sql/02_create_secondary_final.sql`
- Vyzkumne otazky (jednotlive soubory):
  - `sql/03_q1_mzdy_mezirocni.sql` – Q1: mezirocni zmena mezd po odvetvi
  - `sql/03_q2_mleko_chleb.sql` – Q2: kupni sila mleka a chleba
  - `sql/03_q3_zdrazovani_potravin.sql` – Q3: nejpomaleji zdrazujici potraviny
  - `sql/03_q4_ceny_vs_mzdy.sql` – Q4: roky s vyrazne vetsim rustem cen nez mezd
  - `sql/03_q5_hdp_vliv.sql` – Q5: vliv HDP na mzdy a ceny (CR)

### Dulezite poznamky / predpoklady
- **Mzdy – filtry kodu**: ve skriptu je pouzito nejcastejsi nastaveni:
  - `calculation_code = 200`
  - `value_type_code = 5958`
  Pokud to u tebe nesedi, uprav filtry podle ciselniku `czechia_payroll_calculation` a `czechia_payroll_value_type`.

- **Cela CR**: mzdy jsou filtrovane na `region_code IS NULL` (typicky "cela CR"). Pokud mas celou CR jinak znacenu, uprav filtr.

- **Agregace cen**: ceny potravin jsou prumerovane za rok (pres vsechny regiony a pozorovani v roce).

- **Otazka 2 (mleko/chleb)**: vyber potravin je pres `LIKE` nad nazvem. Pokud se netrefi, pouzij primo spravny `kod_potraviny`.

### Struktura slozek
- `sql/` – SQL skripty
- `docs/` – pruvodni listina a poznamky
