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
$if set manuaal $set lopp_kp          31102019
**********************************************

**********************************************
* Üldine arvutusloogika                      *
**********************************************
$if set manuaal $set slott                  PV
$if set manuaal $set kkul                 true
*$if set manuaal $set fix_ladu             1461
$if set manuaal $set tp                  false
$if set manuaal $set jp                  false
$if set manuaal $set mkul                false
$if set manuaal $set ost                 true
$if set manuaal $set soojus_vaba         true
$if set manuaal $set kkt_vaba            true
$if set manuaal $set el_vaba             true
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
$if set manuaal $set n_max_marg            151
$if set manuaal $set m_marg              false
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

execute_load '_gams_net_gdb1.gdx',
*  kasum, muutuvkasum, algne_kasum, lepingu_ja_algse_vahe,
  kaeve,  maemass,  konts_p,  aher_p,  soel_p
  kytuse_ost,
  myyk,  koorm_sj,  oli,  daily_res_f,  laoseis_k,  laoseis_t,
  kaevandusest_lattu,  kaevandusest_liinile,  laost_liinile,  liinilt_lattu,  liinilt_tootmisse,  laost_tootmisse,
  koorm_el, k_alpha, k_beta, lambda_p, lambda_e,
  q, s_k, s_l, s_u,
*  p_work,  k_aktiivne,
  sj_aktiivne, pl_aktiivne, kr_aktiivne, t_kaivitus, t_stop,
  lp_aktiivne,
  t_puhastus,
*  remondi_opt,
  auru_binaar, beta_p, primaari_valik,
  z_emission;


$set jareltootlus_m1  true
$libinclude pco_jareltootlus2
$set jareltootlus_m2  true

** Nüüd saab teha järeltöötlust
$libinclude pco_jareltootlus2

* Salvestame tulemused maha
$if set manuaal execute_unload 'valjund-pp.gdx';

