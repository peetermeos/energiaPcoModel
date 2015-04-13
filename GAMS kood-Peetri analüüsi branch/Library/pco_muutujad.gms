* Sihifunktsiooni juurika definitsioon
Free variables
  kasum                 "EUR"
  muutuvkasum(opt_paev_max) "EUR/kuu"
  algne_kasum           "EUR"
  lepingu_ja_algse_vahe "EUR"
;

Positive variables
* Kaevandatud primaarenergia
  kaeve(opt_paev_max, primaarenergia, p2, k)     "Kaevandatud primaarenergia (t)"
  maemass(opt_paev_max, k)                       "Rikastusvabrikuga kaevandusest kaevandatud mäemass (t)"
  konts_p(opt_paev_max, k, primaarenergia)       "Rikastusvabrikuga kaevandusest toodetud kontsentraat (t)"
  aher_p(opt_paev_max, k, primaarenergia)        "Rikastusvabrikuga kaevandusest toodetud aheraine (t)"
  soel_p(opt_paev_max, k, primaarenergia)        "Rikastusvabrikuga kaevandusest toodetud sõelis (t)"

$ifthen.two "%ost%" == "true"
  kytuse_ost(lepingu_nr, opt_paev_max, k, primaarenergia) "Palju me kütust mingist lepingust ostame? (t)"
$endif.two

  myyk(opt_paev_max, k, primaarenergia, t_mk)     "Primaarenergia müügiks (t/päevas)"
  koorm_sj(opt_paev_max, slott, t_el)             "Soojatootmise netokoormus slotis (MWh/h)"
  oli(opt_paev_max, t_ol)                         "Päevane õlitoodang (t/päevas)"
  daily_res_f(opt_paev_max, k, primaarenergia, l) "Daily quantity of fuel reserved for non-production uses (t)"

$ifthen.two "%uus_logistika%" == "false"
* Laoseisud on rehkendatud päeva lõpu seisuga
  laoseis_k(opt_paev_max, l_k, k, primaarenergia)            "Ladude päevased laoseisud kaevandustes (t)"
  laoseis_t(opt_paev_max, l_t, k, primaarenergia)            "Ladude päevased laoseisud tootmisüksustes (t)"

  kaevandusest_lattu(opt_paev_max, l_k, k, primaarenergia)   "Kui palju kaevest tuleb ladustada päevas (t)"
  kaevandusest_liinile(opt_paev_max, liinid, primaarenergia) "Kui palju läheb otse logistikasse logistikasse (t)"
  laost_liinile(opt_paev_max, l_k, liinid, primaarenergia)   "Kui palju läheb laost logistikasse (t)"
  liinilt_lattu(opt_paev_max, liinid, l_t, primaarenergia)   "Kui palju ladustada tootmisüksuses (t)"

  liinilt_tootmisse(opt_paev_max, liinid, t, primaarenergia) "Kui palju saata tootmisesse (t)"
  laost_tootmisse(opt_paev_max, l_t, t, k, primaarenergia)   "Kui palju saata laost tootmisse (t)"
$endif.two
;

* Teeme võimaluse pikema aja mudelis arvutada keskmised koormused LPna
* seega vältides eksponentsiaalseid jubedusi
* Lühikeses mudelis jääb võimalus MIPiks alles.
Positive variable koorm_el(opt_paev_max, slott, t_el)          "Elektritootmise netokoormus slotis (MWh/h)";
Positive variable k_alpha(opt_paev_max, slott, t_el)           "Elektrikoormuse miinimumkomponent (MWh/h)";
Positive variable k_beta(opt_paev_max, slott, t_el)            "Elektrikoormuse muutuvkomponent (MWh/h)";

Positive variable lambda_p(opt_paev_max, slott, t_el, para_lk) "Kasutegurite lähendamise parameeter";
Positive variable lambda_e(opt_paev_max, slott, t_el, k, primaarenergia, k_tase, l_tase, para_lk) "Eriheitmete lähendamise parameeter";
Positive variable z_emission(opt_paev_max, slott, k, primaarenergia, t_el, para_lk) "Replacement variable for emissions";

Positive variable
  q(opt_paev_max, slott, k, primaarenergia, t_el)              "Primaarenergia hulk plokki (MWh)"

$ifthen.two "%l_k_sees%" == "true"
  s_k(opt_paev_max, slott, t_el, k_tase)                       "Killustik tootmisüksuse jaoks (0..25 t/h)"
  s_l(opt_paev_max, slott, t_el, l_tase)                       "Lubi tootmisüksuse jaoks (0..3 ühikut)"
;
$endif.two

$ifthen.two "%pysikulud%" == true
Positive variable
  h_kulu(aasta, kuu, t_el) "Millised on lisanduvad hoolduskulud plokile?"
  k_kulu(aasta, kuu, t_el) "Käimapanemise lisakulud."
;

Integer variable yt_brigaadid(aasta, kuu, jaam) "Mitu brigaadi teevad ületunde?";
yt_brigaadid.lo(aasta, kuu, jaam) = 0;
yt_brigaadid.up(aasta, kuu, jaam) = 12;
$endif.two

Binary variables
$ifthen.two "%pysikulud%" == true
  p_work(aasta, kuu, t_el) "Kas plokk seisab (0) või on töös (1)"
*  ty_aktiivne(t, aasta)               "Kas tootmisüksus on antud aastal töös (0/1)"
  k_aktiivne(k, aasta)                 "Kas kaevandus on antud aastal töös (0/1)"
$endif.two
  pl_aktiivne(opt_paev_max, slott, t_el)       "Kas antud slotis on plokk aktiivne (0/1)"
;

Positive variable
  sj_aktiivne(opt_paev_max, t_el)              "Kas toodame selles slotis sooja (0/1)"
  kr_aktiivne(opt_paev_max, slott, t_korstnad) "Kas korsten on selles slotis kasutusel (0/1)"
;

*Positive variables
*  kr_aktiivne(opt_paev, slott, t_korstnad) "Kas korsten on selles slotis kasutusel (0/1)"
*;

$if "%kkul%" == "true"              Binary variable t_kaivitus(opt_paev_max, slott, t_el)   "Kas käivitame tootmisüksuse selles slotis (0/1)";
$if "%kkul%" == "true"              Binary variable t_stop(opt_paev_max, slott, t_el)       "Kas seiskame tootmisüksuse selles slotis (0/1)";
$if "%ost%"  == "true"              Binary variable lp_aktiivne(lepingu_nr)                 "Kas kasutame seda ostulepingut (0/1)";
$if "%remondigraafikud%" == "true"  Binary variable remondi_start(opt_paev2, t_el    )      "Kas alustame remonti antud päeval (0/1)";
$if "%puhastused%" == "true"        Binary variable t_puhastus(opt_paev_max, t_el)          "Teeme plokil sel päeval puhastust (0/1)";

$if "%koostootmistoetus%" == "true" Positive variable koorm_bio(opt_paev, slott, t_sj);

* Kas sel päeval on remont oli algselt binaarmuutuja, aga peaks toimima ka reaalarvulisena
$if "%remondigraafikud%" == "true"  Positive variable remondi_opt(opt_paev, t) "Kas teeme remonti antud päeval (0/1)";

*** UUE LOGISTIKA MUUTUJAD ***
$ifthen.two "%uus_logistika%" == "true"
Positive variables
  l_voog(opt_paev, primaarenergia, k, l_vah, l_n1, l_n)   "Logistikavoog graafi serval (millal, mis, kust, kuhu)"
  laoseis(opt_paev, l_n, k, primaarenergia, lao_laiendus) "Laoseis logistkasõlmes"
  tootmisse(opt_paev, slott, l_n, t, k, primaarenergia)   "Logistikast tootmisse (t/h)"
  l_vk(opt_paev, l_n_m, l_n_p)                            "Vagunkoosseisude arv liinil"
  laost_kulu(opt_paev, l_n, lao_laiendus)                 "Lao laiendusest võtmise kulu (EUR)"
  lattu_kulu(opt_paev, l_n, lao_laiendus)                 "Lao laiendusse panemise kulu (EUR)"
;
$endif.two

Binary variable auru_binaar(opt_paev_max, slott, t_el);
************ NB BINARY BETA P*************************
Positive variable beta_p(opt_paev_max, slott, t_el, para_lk);

Binary variable primaari_valik(aasta, kuu, k, primaarenergia);

Binary variable
  prod_load(aasta, kuu, k, primaarenergia) "Whether product is being loaded at primary energy production facilities";

