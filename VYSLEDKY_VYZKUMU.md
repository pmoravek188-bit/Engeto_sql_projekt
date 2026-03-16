# Výsledky výzkumu: mzdy, ceny potravin a HDP (ČR)

## Účel dokumentu
Tento dokument shrnuje hlavní závěry SQL analýzy nad tabulkami `t_Patrik_Moravek_project_SQL_primary_final` a `t_Patrik_Moravek_project_SQL_secondary_final`. Slouží jako podklad pro prezentaci výsledků mimo technický tým.

## Datový rámec a omezení
- Srovnatelné období mezd a cen: `2006-2018`.
- Mzdy: průměrná hrubá mzda (přepočtený stav), 19 odvětví + agregace za ČR.
- Ceny: roční průměry cen potravin podle kategorií.
- Pro meziroční srovnání cen je použit konzistentní přístup, aby nebyly výsledky zkreslené kategoriemi bez celé časové řady.

Tento rámec zajišťuje, že porovnáváme stejné období a stejnou datovou základnu napříč otázkami.

## 1) Rostou mzdy ve všech odvětvích?
**Závěr:** Ano, dlouhodobě mzdy rostou ve všech 19 odvětvích.

Hlavní poznatky:
- V roce 2018 nemá žádné odvětví nižší mzdu než v roce 2006.
- V některých odvětvích se objevují krátkodobé meziroční poklesy.

Odvětví s nejčastějšími poklesy:
- B - Těžba a dobývání (4 záporné roky)
- D - Výroba a rozvod elektřiny/plynu/tepla (3)
- M - Profesionální, vědecké a technické činnosti (2)
- O - Veřejná správa a obrana (2)
- L - Činnosti v oblasti nemovitostí (2)

Interpretace:
Krátkodobá volatilita existuje, ale dlouhodobý trend mezd je jednoznačně růstový.

## 2) Kolik mléka a chleba lze koupit za průměrnou mzdu?
**Závěr:** Kupní síla vůči chlebu i mléku vzrostla.

Výpočet je založen na agregované mzdě za ČR (`kod_odvetvi IS NULL`).

Výsledky:
- `2006`
- Chléb: `1211.91 kg`
- Mléko: `1352.91 l`
- `2018`
- Chléb: `1321.91 kg`
- Mléko: `1616.70 l`

Interpretace:
Kupní síla se v obou sledovaných komoditách zlepšila, výrazněji u mléka.

## 3) Která potravina zdražuje nejpomaleji?
**Závěr:** Nejpomalejší růst (v průměru dokonce pokles) vykázal krystalový cukr.

Nejpomalejší průměrné meziroční změny:
1. Cukr krystalový: `-1.92 % ročně`
2. Rajská jablka: `-0.74 % ročně`
3. Banány žluté: `+0.81 % ročně`
4. Vepřová pečeně s kostí: `+0.99 % ročně`
5. Minerální voda: `+1.03 % ročně`

Interpretace:
Ne všechny potraviny dlouhodobě zdražují stejným tempem; část kategorií rostla velmi pomalu, nebo i klesala.

## 4) Byl některý rok, kdy ceny rostly o více než 10 p.b. rychleji než mzdy?
**Závěr:** Ne.

V analyzovaném období nebyl identifikován žádný rok, kdy by rozdíl `(meziroční růst cen - meziroční růst mezd)` překročil hranici 10 procentních bodů.

Interpretace:
Ceny potravin sice mohly v jednotlivých letech růst rychleji než mzdy, ale ne natolik výrazně, aby splnily zadané kritérium.

## 5) Vliv HDP na mzdy a ceny
**Závěr:** Vazba HDP je výraznější u mezd než u cen potravin, a to zejména s roční prodlevou.

Korelace mezi růstem HDP a dalšími veličinami:
- HDP vs mzdy (stejný rok): `0.486`
- HDP vs ceny (stejný rok): `0.413`
- HDP vs mzdy (následující rok): `0.744`
- HDP vs ceny (následující rok): `0.084`

Interpretace:
- Růst HDP je zřetelněji spojen s následujícím růstem mezd.
- Vazba mezi HDP a cenami potravin je slabší.
- Korelace neimplikuje kauzalitu; jde o statistické souvislosti, ne důkaz přímé příčiny.

## Závěrečné shrnutí
Data podporují tezi, že ve sledovaném období rostly mzdy napříč odvětvími a kupní síla u základních potravin se zlepšila. Vývoj cen potravin nebyl jednotný a neukázal se rok s extrémním odtržením růstu cen od růstu mezd nad stanovenou hranicí. Vliv HDP se projevil více u mzdové dynamiky než u cen potravin.
