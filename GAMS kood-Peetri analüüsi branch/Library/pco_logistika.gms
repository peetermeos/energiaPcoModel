Set laod    "Kõik laod";
Set laod_kokku "Ladude agregeering"
$loaddc laod laod_kokku

Set laod_tuple(laod_kokku, laod) "Ladude laienduste agregeerimine"
$loaddc laod_tuple

Set l_t(laod)     "Tootmisüksuse ladu";
Set l_k(laod)     "Kaevanduste laod";

$loaddc l_k l_t

Sets
  kaevandused_ja_laod(k, l_k) "Seosed kaevanduste ja nende ladude vahel"
  tootmine_ja_laod(l_t, t)    "Tootmisüksuseid ja ladusid siduv tuple"
;
$loaddc kaevandused_ja_laod tootmine_ja_laod

Set
  liinid     "Logistikaliinid kaevandustest tootmisüksustesse"
  l          "Liini lõppjaamad"
;
$loaddc liinid l

Set
  ladustamatu_primaarenergia(k, primaarenergia, laod) "Millist primaarenergiat ei saa ladustada"
  k_jp_ladu(liinid, l_k)                              "Kaevanduste ladude ühtne laadimispunkt"
  liini_otsad(liinid, k, l)                           "Kus liinid algavad ja lõpevad"
  t_jp_tootmine(l, t)                                 "Liinidelt tootmisse laadimise ühtne jaotuspunkt"
  t_jp_ladu(l, l_t)                                   "Liinidelt ladudesse laadimise ühtne jaotuspunkt"
  log_f_constraint(liinid, primaarenergia)            "Allowed combinations of logistic lines and fuel types"
;
$loaddc ladustamatu_primaarenergia k_jp_ladu liini_otsad t_jp_tootmine t_jp_ladu
$loaddc log_f_constraint

* No gas storage allowed
ladustamatu_primaarenergia(k, primaarenergia, laod)$gaas(primaarenergia) = yes;

Parameter
  max_laomaht(laod)                 "Ladude maksimaalsed laomahud (t)"
  min_laomaht(laod)                 "Ladude minimaalsed laomahud (t)"
  laokulud(laod)                    "Ladude sisse- ja väljavõtmise kulud (EUR/t)"

  max_labilase(l)                   "Liinide maksimaalne läbilaskevõime (t/päevas)"
  max_laadimine_k(k, aasta)         "Maksimaalne laadimisvõimekus kaevandustes (t/päevas)"
  max_laadimine_l(l, aasta)         "Maksimaalne laadimisvõimekus sihtjaamades (t/päevas)"
  logistikakulu(aasta, kuu, liinid) "Logistikakulu liinide kaupa (EUR/t)"
;

Parameter
  alguse_laoseisud(laod, k, primaarenergia) "Mudeli alguse laoseisud primaarenergias (t)"
;

$loaddc max_laomaht min_laomaht laokulud
$loaddc max_labilase max_laadimine_k max_laadimine_l logistikakulu

$loaddc alguse_laoseisud

$ifthen.two "%uus_logistika%" == "true"

Set
  l_n        "Logistikaliinide sõlmpunktid"
  l_n_k(l_n) "Kaevanduste laod"
  l_n_t(l_n) "Tootmise laod"
  l_n_p(l_n) "Tootmise jaamad"
  l_n_m(l_n) "Kaevanduse jaamad"
  l_vah      "Logistikavahendid"
;
$loaddc l_n, l_n_k, l_n_t, l_n_p, l_n_m, l_vah


Alias(l_n, l_n1);

Parameter l_e(l_vah, l_n, l_n1) "Suunatud logistikagraafi servad (kust, kuhu)";
$loaddc l_e

Set
k_log(k, l_n) "Kaeve ja logistika seosed"
t_log(t, l_n) "Tootmise ja logistika seosed"
;
$load k_log, t_log

Set lao_laiendus "Lao laiendused"
;
$loaddc lao_laiendus

Parameter
  alguse_laoseis_uus(l_n, k, primaarenergia) "Mudeli alguse laoseisud"
;
$loaddc alguse_laoseis_uus

Parameter
*  l_lao_kulu(l_n)        "Lattu panemise ja laost võtmise kulu (€/t)"
  max_laadimine_ul(l_vah, l_n)
  max_laomaht_ul(l_n, lao_laiendus)
  min_laomaht_ul(l_n)
  max_maht(l_vah, l_n, l_n1) "Logistikagraafi kaarte läbilaskepiirangud (t/p)"
;
$loaddc max_laadimine_ul, max_laomaht_ul, min_laomaht_ul, max_maht

Scalar
  l_suvi_talv   /1.15/
;

Parameter
  l_pikkus(l_n, l_n1) "Liinilõigu pikkus"
  l_tk_kulu(aasta, l_vah) "Tonnkilomeetri hind"
;
$loaddc l_pikkus, l_tk_kulu

Set talvekuud(kuu) "Talvekuud millal kehtivad karmimad logistikapiirangud";
$load talvekuud

Parameter lao_laienduse_kulu(l_n, lao_laiendus)
;
$loaddc lao_laienduse_kulu

**************
*Vana logistika mapping

$ontext
Set liinid
/
Estonia_EEJ
Narva_EEJ
Viivikonna_EEJ
Estonia_BEJ
*Viru_BEJ
Narva_BEJ
Viivikonna_BEJ
Estonia_VKG
Hange_BEJ
Hange_EEJ
KKT_BEJ
Narva2_EEJ
Narva2_BEJ
Estonia_YL
Viivikonna_YL
Narva_A_YL
Narva2_A_YL
KKT_EEJ
/
;

Set liinid_mapping(liinid, l_n, l_n1, l_vah)     "Täpsema logistika mapping lihtsamaks"
/
Estonia_EEJ.(EKV.AH.EKR, AH.VV.EKR, VV.KR.EKR, KR.NKR.EKR, NKR.EEJ.EKR)
Narva_EEJ.(NKR.EEJ.EKR)
Viivikonna_EEJ.(VV.KR.EKR, KR.NKR.EKR, NKR.EEJ.EKR)
*Estonia_BEJ.(EKV.AH.EKR, AH.VA.EVR, VA.BEJ.EVR)
Estonia_BEJ.(EKV.AH.EKR, AH.BEJ.EVR)
*Viru_BEJ
Narva_BEJ.(NKR.KR.EKR, KR.VA.EKR, VA.BEJ.EVR)
Viivikonna_BEJ.(VV.VA.EKR, VA.BEJ.EVR)
Estonia_VKG.(EKV.AH.EKR, AH.VKG.EKR)
Hange_BEJ.(HNG.BEJ.LAD)
Hange_EEJ.(HNG.EEJ.LAD)
KKT_BEJ.(HNG.BEJ.LAD)
Narva2_EEJ.(NKR.EEJ.EKR)
Narva2_BEJ.(NKR.KR.EKR, NKR.VA.EKR, VA.BEJ.EVR)
Estonia_YL.(EKV.AH.EKR, AH.VV.EKR, VV.KR.EKR, KR.NKR.EKR, NKR.YL1.EKR)
Viivikonna_YL.(VV.KR.EKR, KR.NKR.EKR, NKR.YL1.EKR)
Narva_A_YL.(NKR.YL1.AUT)
Narva2_A_YL.(NKR.YL1.AUT)
KKT_EEJ.(HNG.EEJ.LAD)
/
;

Parameter logistikakulu(aasta, kuu, liinid);
Parameter max_labilase(liinid);

max_labilase(liinid) = smin((l_vah, l_n, l_n1)$liinid_mapping(liinid, l_n, l_n1, l_vah),max_maht(l_vah, l_n, l_n1));
logistikakulu(aasta, kuu, liinid) = sum((l_vah, l_n, l_n1)$liinid_mapping(liinid, l_n, l_n1, l_vah), l_tk_kulu(aasta, l_vah)*l_pikkus(l_n, l_n1));
$offtext

$endif.two

alias(laod, l1);

Parameter max_sim_load_cap(liinid) "Maximal simultaneous loading capacity of distinct products at loading point";

*$loaddc max_sim_load_cap
max_sim_load_cap(liinid) = 10;
