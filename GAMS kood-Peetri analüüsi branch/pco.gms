********************************************************************************
** Väärtusketi optimeerimismudel                                               *
** 5 aasta perspektiiv täpsusega 1 hr max                                      *
** Eesti Energia, Energiakaubandus, 2013, 2014                                 *
**                                                                             *
** Peeter Meos                                                                 *
** Taaniel Uleksin                                                             *
** Allan Puusepp                                                               *
**                                                                             *
********************************************************************************
$libinclude pco_header

$title Eesti Energia vaartusketi optimeerimismudel. ENK 2013, 2014

********************************************************************************
** Parameetrid, hulgad ja muud andmed sisalduvad modulaarsuse huvides          *
** include failides, mitte mudeli põhifailis endas.                            *
**                                                                             *
** NB!  Et neid käsitsi sättida, pane GUIs parameetriks (üleval servas)        *
**      --manuaal=true                                                         *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

**********************************************
* Lisame versioonihalduse                    *
**********************************************
$if not set manuaal $libinclude pco_version
**********************************************

**********************************************
* Kalendri konfiguratsioon (PPKKAAAA)        *
**********************************************
$if set manuaal $set algus_kp         01012015
$if set manuaal $set max_to_kp        31122014
$if set manuaal $set lopp_kp          31122015
**********************************************

**********************************************
* Üldine arvutusloogika                      *
**********************************************
$if set manuaal $set slott                  PV
$if set manuaal $set kkul                 true
$if set manuaal $set tp                   true
$if set manuaal $set jp                  false
$if set manuaal $set mkul                false
$if set manuaal $set ost                 false
$if set manuaal $set soojus_vaba         false
$if set manuaal $set kkt_vaba            false
$if set manuaal $set el_vaba             false
$if set manuaal $set myyk_vaba           false
**********************************************

**********************************************
* Mudeli tüüp                                *
* Kütuse tellimuse mudeli puhul on tunni     *
* täpsus kohustuslik                         *
**********************************************
$if set manuaal $set MT                     ST
$if "%MT%" == "OP" $set slott                T

**********************************************
* Marginaalide arvutamise konfiguratsioon    *
**********************************************
$if set manuaal $set  max_marg             365
$if set manuaal $set m_marg              false
**********************************************

**********************************************
* Nõudluskõvera joonistamise konfiguratsioon *
**********************************************
$if set manuaal $set n_hind_1                4
$if set manuaal $set n_hind_2               16
$if set manuaal $set n_hind_samm          0.25
$if set manuaal $set n_allikas           Hange
$if set manuaal $set nk               Biokytus
**********************************************

**********************************************
* Muu pudru, mida tõenäoliselt pole alati    *
* vaja muuta                                 *
**********************************************
$set laojaak            false
$set puhastused         true
$set oli                true
$set soojus             true
$set myyk               true
$set logistika          true
$set laod               true
$set kaevanduse_laod    true
$set kaevandused        true
$set uttegaasi_bilanss  true
$set uttegaasi_jaotus   false
$set remondigraafikud   false
$set uus_logistika      false
$set diskonteerimine    false
$set katlad             false
$set pysikulud          false
$set l_k_sees           false
**********************************************

$show
$offOrder

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
$libinclude pco_pysikad
$libinclude pco_operatiivne_mudel
$GDXin

$libinclude pco_makrod
$libinclude pco_muutujad

$libinclude pco_sihifun

********************************************************************************
** Sihifunktsioon on kirjeldatud, siit edasi tuleb piirangute kirjeldamine     *
** Peeter Meos                                                                 *
********************************************************************************

* Tootmise piirangud
$libinclude pco_t_piirangud

* Heitmete piirangud
$libinclude pco_h_piirangud

* Primaarenergia allikate piirangud (kaevandused ja karjäärid)
$if "%kaevandused%" == "true"  $libinclude pco_a_piirangud

* Logistika ja laonduse piirangud
$if "%logistika%" == "true"    $libinclude pco_l_piirangud

* Kütuse tellimuse (lühiajalise planeerimise) lisa piirangud
$if "%MT%" == "OP"    $libinclude pco_op_piirangud

$libinclude pco_kontroll

********************************************************************************
** Kõik piirangud on kirjeldatud, lahendame mudeli                             *
** Peeter Meos                                                                 *
********************************************************************************
reserved_fuel(aasta, kuu, k, primaarenergia, l) = 0;

Model pco /all/;

* Kirjeldame ära järeltöötluse andmestiku, arvutama peame neid mitu korda
$set jareltootlus_m1  true
$libinclude pco_jareltootlus2
$set jareltootlus_m2  true

* Konfigureerime CPLEXi
pco.OptFile = 1;
pco.PriorOpt = 1;
pco.SolveLink = 5;
$libinclude pco_cplex_parameetrid

* Lisaks harilikule tootmisplaanile, kas arvutame marginaale ja nõudluskõveraid?
*$if set max_marg $libinclude pco_marginaalid
$if set nk $libinclude pco_noudluskover
*$if "%noudluskover_suur%" == "true" $libinclude pco_noudluskover_suur

* Lahendame ülesande
Solve pco maximizing kasum using mip;

* Nüüd saab teha järeltöötlust
$libinclude pco_jareltootlus2

* Salvestame tulemused maha
$if set manuaal execute_unload 'valjund.gdx';

