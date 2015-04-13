********************************************************************************
** Väärtusketi optimeerimismudel                                               *
** 5 aasta perspektiiv täpsusega 1 hr max                                      *
** Eesti Energia, Energiakaubandus, 2013                                       *
**                                                                             *
** Peeter Meos                                                                 *
** Taaniel Uleksin                                                             *
** Allan Puusepp                                                               *
**                                                                             *
********************************************************************************
$setglobal kompileeri
$setglobal UNIX

* Lülitame välja portsu listinguid ja valime solveriks CPLEXi
option
* Ei trüki välja optimeerimisülesande ridasid (piiranguid)
  limrow = 0,
* Ei trüki välja veerge (sihifunktsiooni)
  limcol = 0,
  solprint = off,
  sysout = off,

* Valime CPLEXi
   mip = cplex
;

$offlisting
$offsymlist
$offsymxref
$offuellist
$offuelxref

$title Eesti Energia vaartusketi optimeerimismudel. ENK 2013

********************************************************************************
** Parameetrid, hulgad ja muud andmed sisalduvad modulaarsuse huvides          *
** include failides, mitte mudeli põhifailis endas.                            *
** Peeter Meos                                                                 *
********************************************************************************

* Parameetrite definitsioonid ja algandmed

* Kuupäevad tulevad interface kaudu
$set algus_aasta        2013
$set algus_kuu            10
$set algus_paev            1
$set lopp_aasta         2018
$set lopp_kuu             12
$set lopp_paev            31

$set max_marginaalid      30


$set valjundfail        'c:\PCO_tulemused\jareltootlus.gdx'

$set kaivituskulud      false
$set laojaak            false
$set oli                true
$set soojus             true
$set myyk               true
*$set laod              true
$set logistika          true
$set tootmise_laod      true
$set kaevanduse_laod    false
$set kaevandused        true
$set uttegaasi_bilanss  false
$set uttegaasi_jaotus   false
$set ostulepingud       false
$set mip                false
$set katla_arvutus      false
$set remondigraafikud   false
$set puhastused         false
$set uus_logistika      true
$set uus_koormamine     true
$set lopu_simplex       false
$set spot_hinnad        false
$set marginaalid_pm     false
$set diskonteerimine    false

$show

$GDXin _gams_net_gdb0.gdx
* Kogu see kraam asub GAMSi alamkataloogis "inclib"
$libinclude pco_konstandid
$libinclude pco_kalender
$libinclude pco_primaarenergia
$libinclude pco_tootmine
$libinclude pco_logistika
$libinclude pco_eriheitmed
$libinclude pco_sekundaarenergia
$libinclude pco_lepingud
$libinclude pco_spot
$GDXin

$if not set sox $goto edasi_2
eh_kvoot("so") = eh_kvoot("so") - %sox%
$label edasi_2

* Makrode definitsioonid
$ifthen.uus "%uus_logistika%" == "true"
* Tootmise piirangud
$libinclude pco_makrod_uus
$else.uus
$libinclude pco_makrod
$endif.uus

* Muutujate definitsioonid
$libinclude pco_muutujad

Equations sihifunktsioon                    "Üldine sihifunktsioon (EUR)";

********************************************************************************
** Sihifunktsioon koosneb muutuvtuludest (toodang * referentshinnad)           *
** miinus muutuvkulud (heitmed, transa jne)                                    *
** Peeter Meos                                                                 *
********************************************************************************
sihifunktsioon..
  kasum
  =e=
* Igal päeval arvutame muutuvkasumi
  sum((opt_paev),
(
$libinclude pco_sihifun_elekter

$ifthen.one "%kaivituskulud%" == "true"
$libinclude pco_sihifun_kaivitus
$endif.one

$libinclude pco_sihifun_heitmed

$libinclude pco_sihifun_ket

$ifthen.one "%soojus%" == "true"
$libinclude pco_sihifun_soojus
$endif.one

$ifthen.one "%myyk%" == "true"
$libinclude pco_sihifun_myyk
$endif.one

$ifthen "%oli%" == "true"
$libinclude pco_sihifun_oli
$endif

$libinclude pco_sihifun_lubi

$ifthen.one "%laod%" == "true"
$libinclude pco_sihifun_laod
$endif.one

$ifthen.one "%logistika%" == "true"
$libinclude pco_sihifun_logistika
$endif.one

$ifthen.one "%kaevandused%" == "true"
$libinclude pco_sihifun_kaevandused
$endif.one

$ifthen.one "%ostulepingud%" == "true"
$libinclude pco_sihifun_ostulepingud
$endif.one

)
$ifthen.one "%diskonteerimine%" == "true"
    / prod((opt_paev2, aasta, kuu)$(paev_kalendriks(opt_paev2, aasta, kuu)
                                    and ord(opt_paev2) le ord(opt_paev)),
           (1 + intressimaar(aasta)/365)
          )
$endif.one

)

$ifthen.one "%laojaak%" == "true"
$libinclude pco_sihifun_laojaak
$endif.one
;

********************************************************************************
** Sihifunktsioon on kirjeldatud, siit edasi tuleb piirangute kirjeldamine     *
** Peeter Meos                                                                 *
********************************************************************************

$ifthen.one "%katla_arvutus%" == "true"
* Tootmise piirangud kateldega konfiguratsioonis
$libinclude pco_t_piirangud_katel
* Heitmete piirangud kateldega konfiguratsioonis
$libinclude pco_h_piirangud
$else.one

$ifthen.uus "%uus_logistika%" == "true"
* Tootmise piirangud
$libinclude pco_t_piirangud_uus
$else.uus
$libinclude pco_t_piirangud
$endif.uus

* Heitmete piirangud
$libinclude pco_h_piirangud
$endif.one

* Primaarenergia allikate piirangud (kaevandused ja karjäärid)
$ifthen.one "%kaevandused%" == "true"
$libinclude pco_a_piirangud
$endif.one

* Logistika ja laonduse piirangud
$ifthen.one "%logistika%" == "true"
$libinclude pco_l_piirangud
$endif.one

*SPOT marginaali piirangud
$ifthen.one "%spot_hinnad%" == "true"
$libinclude pco_spot_piirangud
$endif.one

********************************************************************************
** Kõik piirangud on kirjeldatud, lahendame mudeli                             *
** Peeter Meos                                                                 *
********************************************************************************
Model pco /all/;
pco.OptFile = 1;

execute_unload 'c:\PCO_tulemused\algandmed.gdx';

File C_OPT cplex option file  / cplex.opt /;
Put C_OPT;
Put      'barobjrng=1E75' /
         'cliques=3'/
         'covers=3'/
         'heurfreq=100'/
         'lpmethod=4'/
         'memoryemphasis=0'/
*         'mipemphasis=2'/
         'parallelmode=-1'/
$ifthen.one "%lopu_simplex%" == "true"
         'solvefinal=1'/
$else.one
         'solvefinal=0'/
$endif.one
         'startalg=4'/
         'subalg=4'/

         'baralg=2' /
         'barorder=3' /
         'barstartalg=4'/

         'threads=16'/
         'tilim=1E75'/

         'depind=3'/
         'feasoptmode=3'/

$ifthen.one "%marginaalid_pm%" == "true"
         'objrng "koorm_el_marg"'/
         'rngrestart "c:\PCO_tulemused\runi_marginaalid.inc"'/
$endif.one
         ;
Putclose C_OPT;

Solve pco maximizing kasum using mip;

$ifthen.one "%marginaalid_pm%" == "true"
$libinclude pco_marginaalid_pm
$endif.one

* Nüüd saab teha järeltöötlust
*$libinclude pco_jareltootlus_lyhike

execute_unload 'c:\PCO_tulemused\runi_backup_pm.gdx';

$label lopp

