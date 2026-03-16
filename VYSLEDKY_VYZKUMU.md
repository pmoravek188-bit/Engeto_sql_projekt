# Vysledky vyzkumu: mzdy, ceny potravin a HDP (CR)

## Ucel dokumentu
Tento dokument shrnuje hlavni zaveri SQL analyzy nad tabulkami `t_Patrik_Moravek_project_SQL_primary_final` a `t_Patrik_Moravek_project_SQL_secondary_final`. Slouzi jako podklad pro prezentaci vysledku mimo technicky tym.

## Datovy ramec a omezeni
- Srovnatelne obdobi mezd a cen: `2006-2018`.
- Mzdy: prumerna hruba mzda (prepocteny stav), 19 odvetvi + agregace za CR.
- Ceny: rocni prumery cen potravin podle kategorii.
- Pro mezirocni srovnani cen je pouzit konzistentni pristup, aby nebyly vysledky zkreslene kategoriemi bez cele casove rady.

Tento ramec zajistuje, ze porovnavame stejne obdobi a stejnou datovou zakladnu napric otazkami.

## 1) Rostou mzdy ve vsech odvetvich?
**Zaver:** Ano, dlouhodobe mzdy rostou ve vsech 19 odvetvich.

Hlavni poznatky:
- V roce 2018 nema zadne odvetvi nizsi mzdu nez v roce 2006.
- V nekterych odvetvich se objevuji kratkodobe mezirocni poklesy.

Odvetvi s nejcastejsimi poklesy:
- B - Tezba a dobyvani (4 zaporne roky)
- D - Vyroba a rozvod elektriny/plynu/tepla (3)
- M - Profesionalni, vedecke a technicke cinnosti (2)
- O - Verejna sprava a obrana (2)
- L - Cinnosti v oblasti nemovitosti (2)

Interpretace:
Kratkodoba volatilita existuje, ale dlouhodoby trend mezd je jednoznacne rustovy.

## 2) Kolik mleka a chleba lze koupit za prumernou mzdu?
**Zaver:** Kupni sila vuci chlebu i mleku vzrostla.

Vypocet je zalozen na agregovane mzde za CR (`kod_odvetvi IS NULL`).

Vysledky:
- `2006`
- Chleb: `1211.91 kg`
- Mleko: `1352.91 l`
- `2018`
- Chleb: `1321.91 kg`
- Mleko: `1616.70 l`

Interpretace:
Kupni sila se v obou sledovanych komoditach zlepsila, vyrazneji u mleka.

## 3) Ktera potravina zdrazuje nejpomaleji?
**Zaver:** Nejpomalejsi rust (v prumeru dokonce pokles) vykazal krystalovy cukr.

Nejpomalejsi prumerne mezirocni zmeny:
1. Cukr krystalovy: `-1.92 % rocne`
2. Rajska jablka: `-0.74 % rocne`
3. Banany zlate: `+0.81 % rocne`
4. Veprova pecene s kosti: `+0.99 % rocne`
5. Mineralni voda: `+1.03 % rocne`

Interpretace:
Ne vsechny potraviny dlouhodobe zdrazuji stejnym tempem; cast kategorii rostla velmi pomalu, nebo i klesala.

## 4) Byl nektery rok, kdy ceny rostly o vice nez 10 p.b. rychleji nez mzdy?
**Zaver:** Ne.

V analyzovanem obdobi nebyl identifikovan zadny rok, kdy by rozdil `(mezirocni rust cen - mezirocni rust mezd)` prekrocil hranici 10 procentnich bodu.

Interpretace:
Ceny potravin sice mohly v jednotlivych letech rust rychleji nez mzdy, ale ne natolik vyrazne, aby splnily zadane kriterium.

## 5) Vliv HDP na mzdy a ceny
**Zaver:** Vazba HDP je vyraznejsi u mezd nez u cen potravin, a to zejmena s rocni prodlevou.

Korelace mezi rustem HDP a dalsimi velicinami:
- HDP vs mzdy (stejny rok): `0.486`
- HDP vs ceny (stejny rok): `0.413`
- HDP vs mzdy (nasledujici rok): `0.744`
- HDP vs ceny (nasledujici rok): `0.084`

Interpretace:
- Rust HDP je zretelneji spojen s nasledujicim rustem mezd.
- Vazba mezi HDP a cenami potravin je slabsi.
- Korelace neimplikuje kauzalitu; jde o statisticke souvislosti, ne dukaz prime priciny.

## Zaverecne shrnuti
Data podporuji tezi, ze ve sledovanem obdobi rostly mzdy napric odvetvimi a kupni sila u zakladnich potravin se zlepsila. Vyvoj cen potravin nebyl jednotny a neukazal se rok s extremnim odtrzenim rustu cen od rustu mezd nad stanovenou hranici. Vliv HDP se projevil vice u mzdove dynamiky nez u cen potravin.
