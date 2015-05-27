********************************************************************************
** V‰‰rtusketi optimeerimismudel                                               *
** 5 aasta perspektiiv t‰psusega 1 hr max                                      *
** Eesti Energia, Energiakaubandus, 2013                                       *
**                                                                             *
** Peeter Meos                                                                 *
** Taaniel Uleksin                                                             *
** Allan Puusepp                                                               *
**                                                                             *
********************************************************************************
$libinclude pco_header

$title Eesti Energia vaartusketi optimeerimismudel. ENK 2013

********************************************************************************
** Parameetrid, hulgad ja muud andmed sisalduvad modulaarsuse huvides          *
** include failides, mitte mudeli pıhifailis endas.                            *
** Peeter Meos                                                                 *
********************************************************************************

* Parameetrite definitsioonid ja algandmed

* Kuup‰evad tulevad interface kaudu
$set algus_aasta        2013
$set algus_kuu            10
$set algus_paev            1
$set lopp_aasta         2015
$set lopp_kuu              1
$set lopp_paev             1

$set max_marginaalid      30

$set valjundfail        c:\PCO_tulemused\runi_backup_pm_2013-2014_backtest.gdx

$set kaivituskulud      false
$set laojaak            false
$set oli                true
$set soojus             true
$set myyk               true
$set logistika          true
$set laod               true
$set kaevanduse_laod    true
$set kaevandused        true
$set uttegaasi_bilanss  false
$set uttegaasi_jaotus   false
$set ostulepingud       false
$set mip                false
$set remondigraafikud   false
$set puhastused         false
$set uus_logistika      false
$set lopu_laoseis       false
$set spot_hinnad        false
$set marginaalid_pm     false
$set diskonteerimine    false
$set peak_offpeak       false
$set spot_margins       true

$show

$GDXin _gams_net_turuhinnad.gdx
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
$libinclude pco_makrod

* Muutujate definitsioonid
$libinclude pco_muutujad

$ifthen.two "%lopu_laoseis%" == "true"
Parameter lopu_laoseis(l_t, k, primaarenergia)
/
BEJ_M.Estonia.Energeetiline        300000
EEJ_M.Estonia.Madal        13889.9707649652
EEJ_M.KKT.Energeetiline        333253.477984886
EEJ_M.Hange.Killustik        2856.55125014861
EEJ8_M.Estonia.Energeetiline        100000
Uhendladu_M.Narva1.Kaevis        50000
Uhendladu_L2.Narva1.Kaevis        7618.50012489181
/
;
laoseis_t.fx("1096", l_t, k, primaarenergia) = lopu_laoseis(l_t, k, primaarenergia);
$endif.two

*co2_referents(aasta, kuu) = co2_referents(aasta, kuu) - 2;
*elektri_referents(aasta,kuu,opt_paev_max,opt_tund) = elektri_referents(aasta,kuu,opt_paev_max,opt_tund) * 0.9;

Parameter margins(opt_paev, slott, t_el);

margins(opt_paev, slott, t_el) = 0;

margins(opt_paev, slott, "EEJ1")$(ord(opt_paev) < 7)  = 16.92 - 2;
margins(opt_paev, slott, "EEJ2")$(ord(opt_paev) < 7)  = 16.92 - 2;
margins(opt_paev, slott, "EEJ3")$(ord(opt_paev) < 7)  = 17.26 - 2;
margins(opt_paev, slott, "EEJ4")$(ord(opt_paev) < 7)  = 18.40 - 2;
margins(opt_paev, slott, "EEJ5")$(ord(opt_paev) < 7)  = 18.59 - 2;
margins(opt_paev, slott, "EEJ6")$(ord(opt_paev) < 7)  = 17.88 - 2;
margins(opt_paev, slott, "EEJ7")$(ord(opt_paev) < 7)  = 16.92 - 2;
margins(opt_paev, slott, "EEJ8")$(ord(opt_paev) < 7)  = 15.26 - 2;
margins(opt_paev, slott, "BEJ9")$(ord(opt_paev) < 7)  = 17.41 - 2;
margins(opt_paev, slott, "BEJ11")$(ord(opt_paev) < 7) = 15.45 - 2;
margins(opt_paev, slott, "BEJ12")$(ord(opt_paev) < 7) = 17.41 - 2;

* Lisame sihifunktsiooni
Equations
  sihifunktsioon                    "‹ldine sihifunktsioon (EUR)"
  v_muutuvkasum(opt_paev)           "Muutuvkasum kuude kaupa (EUR)"
;
********************************************************************************
** Sihifunktsioon koosneb muutuvtuludest (toodang * referentshinnad)           *
** miinus muutuvkulud (heitmed, transa jne)                                    *
** Peeter Meos                                                                 *
********************************************************************************
sihifunktsioon..
  kasum =e=  sum((opt_paev), muutuvkasum(opt_paev))

$ifthen.one "%laojaak%" == "true"
$libinclude pco_sihifun_laojaak
$endif.one
;

v_muutuvkasum(opt_paev)..
  muutuvkasum(opt_paev)
  =e=
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
$libinclude pco_sihifun_diskonteerimine
$endif.one
;

max_kaeve(aasta, kuu, "Hange", "Killustik")  = 5000;
k_muutuvkulud(aasta, "Hange", "Killustik")   = 2.6;

*alguse_laoseis(laod, k, primaarenergia) = 0;
*alguse_laoseis("BEJ_M","Hange","Killustik")=        100000;
*alguse_laoseis("EEJ_M","Hange","Killustik")=        150000;
*alguse_laoseis("Uhendladu_M","Estonia","Energeetiline")=        16286;
*alguse_laoseis("Uhendladu_M","Narva1","Kaevis")=        33714;

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
$libinclude pco_t_piirangud_uus
$endif.uus

* Heitmete piirangud
$libinclude pco_h_piirangud
$endif.one

* Primaarenergia allikate piirangud (kaevandused ja karj‰‰rid)
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
** Kıik piirangud on kirjeldatud, lahendame mudeli                             *
** Peeter Meos                                                                 *
********************************************************************************
Model pco /all/;
pco.OptFile = 1;

* Konfigureerime CPLEXi
$libinclude pco_cplex_parameetrid

* Lahendame ¸lesande
Solve pco maximizing kasum using mip;

* N¸¸d saab teha j‰reltˆˆtlust
*$libinclude pco_jareltootlus_lyhike
$libinclude pco_jareltootlus2

$ifthen.one "%marginaalid_pm%" == "true"
$libinclude pco_marginaalid_pm
$endif.one

* Salvestame tulemused maha
execute_unload '%valjundfail%';
