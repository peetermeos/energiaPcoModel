********************************************************************************
** Kalendri ja üleüldise ajaarvamise kirjeldus mudeli jaoks                    *
**                                                                             *
** 30. dets 2013                                                               *
** Peeter Meos                                                                 *
**                                                                             *
********************************************************************************

$setglobal  aasta_1 2013
$set        aasta_2 2030
$eval paevi jdate(%aasta_2%, 12, 31) - jdate(%aasta_1%, 1, 1) + 1

Set
  opt_paev_max                    /1         * %paevi%/
  paev         "Kalendripäevad"   /1         * 31/
  kuu          "Kalendrikuud"     /1         * 12/
  kvartal      "Kalendikvartalid" /Q1, Q2, Q3, Q4/
  aasta        "Kalendiaastad"    /%aasta_1% * %aasta_2%/
  paev_kalendriks(opt_paev_max, aasta, kuu)
  day_cal(opt_paev_max, paev)
  kvartali_kuud(kvartal, kuu)
  /
  Q1.(1,2,3)
  Q2.(4,5,6)
  Q3.(7,8,9)
  Q4.(10,11,12)
  /

;

Parameter intressimaar(aasta);
$load intressimaar

Parameter paevi_kuus(kuu)
/
1  31
2  28
3  31
4  30
5  31
6  30
7  31
8  31
9  30
10 31
11 30
12 31
/

Parameter liigaasta(aasta)
/
2016 1
2020 1
2024 1
2028 1
/

;

* Arvutame optimeerimisperioodi esimese ja viimase kuupäeva stringist
* välja tegelikud aasta, kuu ja päeva

$evalglobal algus_paev  trunc(%algus_kp% / 1E6)
$evalglobal algus_kuu   trunc((%algus_kp% - (%algus_paev% * 1E6)) / 1E4)
$evalglobal algus_aasta %algus_kp% - (%algus_paev% * 1E6) - (%algus_kuu% * 1E4)

$ifthen.max set max_to_kp
$evalglobal max_to_paev  trunc(%max_to_kp% / 1E6)
$evalglobal max_to_kuu   trunc((%max_to_kp% - (%max_to_paev% * 1E6)) / 1E4)
$evalglobal max_to_aasta %max_to_kp% - (%max_to_paev% * 1E6) - (%max_to_kuu% * 1E4)
$endif.max

$evalglobal lopp_paev   trunc(%lopp_kp% / 1E6)
$evalglobal lopp_kuu    trunc((%lopp_kp% - (%lopp_paev% * 1E6)) / 1E4)
$evalglobal lopp_aasta  %lopp_kp% - (%lopp_paev% * 1E6) - (%lopp_kuu% * 1E4)

$ifthen.cal "%MT%" == "STRAT"
* Strat mudel on kuu täpsusega
* Kuu sees slotid määravad ikkagi peaki ja offpeaki
  paev_kalendriks(aasta, kuu, opt_paev_max )$(
     ((ord(aasta) - 1) + (ord(kuu) - 1) + 1) eq
     ord(opt_paev_max)
     ) = yes;
$else.cal
* Teised mudelid on päeva täpsusega
  paev_kalendriks(opt_paev_max, aasta, kuu)$
    ((
     ord(aasta) + %aasta_1% - 1  eq
     gyear(jdate(%aasta_1%, 1, 1) + ord(opt_paev_max) - 1)
    ) and (
     ord(kuu) eq
     gmonth(jdate(%aasta_1%, 1, 1) + ord(opt_paev_max) - 1)
    )) = yes;
$endif.cal

  day_cal(opt_paev_max, paev)$(
     ord(paev) eq
     gday(jdate(%aasta_1%, 1, 1) + ord(opt_paev_max) - 1)
) = yes

$drop aasta_2
$drop paevi

******************

$show

$eval esimese_nr  jdate(%algus_aasta%, %algus_kuu%, %algus_paev%) - (jdate(esimene_aasta, esimene_kuu, 1) - 1)

$ifthen.max set max_to_kp
$eval max_kp_nr  jdate(%max_to_aasta%, %max_to_kuu%, %max_to_paev%) - (jdate(esimene_aasta, esimene_kuu, 1) - 1)
$endif.max

$eval viimase_nr  jdate(%lopp_aasta%, %lopp_kuu%, %lopp_paev%)    - (jdate(esimene_aasta, esimene_kuu, 1) - 1)

$ifthen.two set max_marg
  $$eval marg_lopp %esimese_nr% + %max_marg% - 1
  $$eval marg_algus %esimese_nr% + %max_marg%
$endif.two

$setglobal esimene_paev %esimese_nr%


$ifthen.cal "%MT%" == "STRAT"
  $$eval viimase_nr smax((opt_paev_max, aasta, kuu)$paev_kalendriks, ord(opt_paev_max))
  Set  opt_paev(opt_paev_max)   /1 * %viimase_nr%/;
$else.cal
  Set opt_paev(opt_paev_max);
  opt_paev(opt_paev_max)$(ord(opt_paev_max) ge %esimese_nr% and ord(opt_paev_max) le %viimase_nr%) = yes;
*  Set  opt_paev(opt_paev_max)   /%esimese_nr% * %viimase_nr%/;
$endif.cal

***********************************************************************************************
**                                                                                            *
** Nüüd on opt_paev set valmis tehtud, teeme siit nüüd valmis tööpäevade parameetrite seti.   *
** Parameetrite väärtus on (0 - harilik tööpäev, 1 - laupäev, 2 - pühapäev või riigipüha)     *
**                                                                                            *
** Peeter Meos, 15. august 2014                                                               *
**                                                                                            *
***********************************************************************************************
Parameter paeva_tyyp(opt_paev_max);

* Kõigepealt lihtsamad asjad, märgime ära laupäevad ja pühapäevad
paeva_tyyp(opt_paev)$(gdow(jdate(esimene_aasta, esimene_kuu, 1) - 1 + ord(opt_paev)-1 + %esimene_paev%) = 6) = 1;
paeva_tyyp(opt_paev)$(gdow(jdate(esimene_aasta, esimene_kuu, 1) - 1 + ord(opt_paev)-1 + %esimene_paev%) = 7) = 2;

* Siia tuleb lisada riigipühad, mis ei liigu
* 1 jaanuar
paeva_tyyp(opt_paev)$((gmonth(jdate(esimene_aasta, esimene_kuu, 1) - 1 + ord(opt_paev)-1 + %esimene_paev%) = 1)
                  and (gday(jdate(esimene_aasta, esimene_kuu, 1) - 1 + ord(opt_paev)-1 + %esimene_paev%)   = 1)) = 2;

* 24. veerbuar
paeva_tyyp(opt_paev)$((gmonth(jdate(esimene_aasta, esimene_kuu, 1) - 1 + ord(opt_paev)-1 + %esimene_paev%) = 2)
                  and (gday(jdate(esimene_aasta, esimene_kuu, 1) - 1 + ord(opt_paev)-1 + %esimene_paev%)   = 24)) = 2;

* 1. mai
paeva_tyyp(opt_paev)$((gmonth(jdate(esimene_aasta, esimene_kuu, 1) - 1 + ord(opt_paev)-1 + %esimene_paev%) = 5)
                  and (gday(jdate(esimene_aasta, esimene_kuu, 1) - 1 + ord(opt_paev)-1 + %esimene_paev%)   = 1)) = 2;

* 23. juuni
paeva_tyyp(opt_paev)$((gmonth(jdate(esimene_aasta, esimene_kuu, 1) - 1 + ord(opt_paev)-1 + %esimene_paev%) = 6)
                  and (gday(jdate(esimene_aasta, esimene_kuu, 1) - 1 + ord(opt_paev)-1 + %esimene_paev%)   = 23)) = 2;

* 24. juuni
paeva_tyyp(opt_paev)$((gmonth(jdate(esimene_aasta, esimene_kuu, 1) - 1 + ord(opt_paev)-1 + %esimene_paev%) = 6)
                  and (gday(jdate(esimene_aasta, esimene_kuu, 1) - 1 + ord(opt_paev)-1 + %esimene_paev%)   = 24)) = 2;

* 20. august
paeva_tyyp(opt_paev)$((gmonth(jdate(esimene_aasta, esimene_kuu, 1) - 1 + ord(opt_paev)-1 + %esimene_paev%) = 8)
                  and (gday(jdate(esimene_aasta, esimene_kuu, 1) - 1 + ord(opt_paev)-1 + %esimene_paev%)   = 20)) = 2;

* 24. detsember
paeva_tyyp(opt_paev)$((gmonth(jdate(esimene_aasta, esimene_kuu, 1) - 1 + ord(opt_paev)-1 + %esimene_paev%) = 12)
                  and (gday(jdate(esimene_aasta, esimene_kuu, 1) - 1 + ord(opt_paev)-1 + %esimene_paev%)   = 24)) = 2;

* 25. detsember
paeva_tyyp(opt_paev)$((gmonth(jdate(esimene_aasta, esimene_kuu, 1) - 1 + ord(opt_paev)-1 + %esimene_paev%) = 12)
                  and (gday(jdate(esimene_aasta, esimene_kuu, 1) - 1 + ord(opt_paev)-1 + %esimene_paev%)   = 25)) = 2;

* 26. detsember
paeva_tyyp(opt_paev)$((gmonth(jdate(esimene_aasta, esimene_kuu, 1) - 1 + ord(opt_paev)-1 + %esimene_paev%) = 12)
                  and (gday(jdate(esimene_aasta, esimene_kuu, 1) - 1 + ord(opt_paev)-1 + %esimene_paev%)   = 26)) = 2;

* Nüüd lisame liikuvad riigipühad - suur reede, ülestõusmispühade 1 püha ja nelipühade 1 püha

Scalar e_k, e_m, e_s, e_a, e_d, e_r, e_og, e_sz, e_oe, easter;

loop(aasta,
  e_k   = floor(div(%aasta_1% + ord(aasta) - 1, 100));
  e_m   = 15 + floor(div(3 * e_k + 3, 4)) - floor(div(8 * e_k + 13, 25));
  e_s   = 2  - floor(div(3 * e_k + 3, 4));
  e_a   = mod(%aasta_1% + ord(aasta) - 1, 19);
  e_d   = mod(19 * e_a + e_m, 30);
  e_r   = floor(div(e_d, 29)) + (floor(div(e_d, 28)) - floor(div(e_d, 29))) * floor(div(e_a, 11));
  e_og  = 21 + e_d - e_r;
  e_sz  = 7 - mod(%aasta_1% + ord(aasta) - 1 + floor(div(%aasta_1% + ord(aasta) - 1, 4)) + e_s, 7);
  e_oe  = 7 - mod(e_og - e_sz, 7);
  easter = jdate(%aasta_1% + ord(aasta) - 1, 3, e_og + e_oe) + 1;

* Suur reede
  paeva_tyyp(opt_paev)$(ord(opt_paev) = jdate(esimene_aasta, esimene_kuu, 1) - easter + 1 - 2) = 2;

* Ülestõusmispühade 1 püha
  paeva_tyyp(opt_paev)$(ord(opt_paev) = jdate(esimene_aasta, esimene_kuu, 1) - easter + 1) = 2;

* Nelipühade 1 püha
  paeva_tyyp(opt_paev)$(ord(opt_paev) = jdate(esimene_aasta, esimene_kuu, 1) - easter + 1 + 50) = 2;
);
********************** Eesti riigipühade arvutuse lõpp ***********************************************

Set
$ifthen.two set max_marg
  opt_paev_marg(opt_paev_max)        /%esimese_nr% * %marg_lopp%/
  opt_paev_ilma_marg(opt_paev_max)   /%marg_algus% * %viimase_nr%/
$endif.two

* Strat mudeli puhul las jäävad ka need 24 fiktiivset tundi
* jagame kuu ära peakiks off peakiks ja nädalavahetuseks
* umbkaudu proportsioonide järgi

  opt_tund  "Optimeerija tund"   /1*24/
;

Sets
  slott
  sloti_tunnid(slott, opt_tund) "Sloti lõputund 24h paevas"
;

* Operatiivmudel võib olla ainult tunnipõhine
$ifthen.slott "%MT%" == "STRAT"
  $$loaddc slott=slott_paev sloti_tunnid=sloti_tunnid_strat
  Parameter sloti_pikkus_orig(slott)
  $$loaddc sloti_pikkus_orig=sloti_pikkus_strat
$endif.slott

$if "%MT%" == "OP" $set slott T

$ifthen.slott "%slott%" == "PV"
$loaddc slott=slott_paev sloti_tunnid=sloti_tunnid_paev
  Parameter sloti_pikkus_orig(slott)
$loaddc sloti_pikkus_orig=sloti_pikkus_paev
$endif.slott

$ifthen.slott "%slott%" == "PK"
$loaddc slott=slott_peak sloti_tunnid=sloti_tunnid_peak
  Parameter sloti_pikkus_orig(slott)
$loaddc sloti_pikkus_orig=sloti_pikkus_peak
$endif.slott

$ifthen.slott "%slott%" == "T"
$loaddc slott=slott_tund sloti_tunnid=sloti_tunnid_tund
  Parameter sloti_pikkus_orig(slott)
$loaddc sloti_pikkus_orig=sloti_pikkus_tund
$endif.slott

* Remondipäevad
alias(opt_paev, opt_paev2)

