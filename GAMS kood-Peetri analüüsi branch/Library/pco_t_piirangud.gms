Equations
* Tootmisüksuste maksimum- ja miinimumkoormused
* Praegu on koostootmine löödud lahku elektrtootmisplokkidest
* Tegelikult annaks üldistada ja defineerida kõik plokid kui koostootmisplokid
* ainult, et enamuse soojusvõimsus oleks null. Ilmselt see muudaks koodi lühemaks
* aga võimalik, et nõuaks rohkem mälu.
  v_max_koormus_el(opt_paev_max, slott, t_el)
  v_max_koormus_ty(opt_paev_max, slott, t_el)

  v_min_koormus_sj(opt_paev_max, slott, t_el)
  v_min_koormus_sj_M(opt_paev_max, slott, t_el)

$ifthen.two "%soojus%" == "true"
  v_sooja_tarne(opt_paev_max, slott)          "Kohustuslik soojatootmine koostootmisplokkides"
  v_sisemine_sooja_tarne(opt_paev_max, slott) "Kohustuslik sisemine soojatootmine"
$endif.two

* Soojatootmise ja elektritootmise koormuste arvutamine
  v_koorm_el(opt_paev_max, slott, t_el)

$ifthen.two "%l_k_sees%" == "true"
* Killustiku lisamine tuleb logistikasse juurde arvestada
  v_killustiku_kasutus(opt_paev_max, t_killustik)

$ifthen.three "%katlad%" == "true"
  v_killustiku_kasutus3(opt_paev_max, slott, t_killustik, katel)
$endif.three

* Kui ploki koormus on null, pole killustikku ja lupja vaja kasutada
$ifthen.three "%katlad%" == "true"
  v_lubja_kasutus(opt_paev_max, slott, t_lubi, katel)
$else.three
  v_lubja_kasutus(opt_paev_max, slott, t_lubi)
$endif.three
$endif.two

* Primaarenergia segamine segudeks
$ifthen.two "%uus_logistika%" == "true"
  v_primaarenergia_segamine(opt_paev_max, slott, k, primaarenergia, t_el)
  v_primaarenergia_segamine_ol(opt_paev_max, slott, k, primaarenergia, t_ol)
  v_primaarenergia_segamine2(opt_paev_max, slott, k, primaarenergia, t_el)
$else.two
  v_primaarenergia_segamine(opt_paev_max, k, primaarenergia, t_el)
$ifthen.three "%katlad%" == "true"
  v_max_osakaal(opt_paev_max, slott, katel, k, primaarenergia, t_el)
$else.three
  v_max_osakaal(opt_paev_max, slott, k, primaarenergia, t_el)
$endif.three
  v_max_osakaal_ol(opt_paev_max, k, primaarenergia, t_ol)
$endif.two

* Kütteväärtuse minimaalne piir
v_min_kyttevaartus(opt_paev_max, t)

* Uttegaasi kasutamise piirangud
$ifthen.two "%oli%" == "true"
  v_max_uttegaas(opt_paev_max) "Uttegaasi maksimumhulk per päev"
$endif.two

$ifthen.two "%uttegaasi_jaotus%" == "true"
  v_uttegaas_el2(opt_paev_max, slott, t_el)  "Uttegaasi ühtlane jaotus"
$endif.two

  v_delta_yles_el(opt_paev_max, slott, t_el) "Plokkide koormuse muutmise kiirus üles"
  v_delta_alla_el(opt_paev_max, slott, t_el) "Plokkide koormuse muutmise kiirus alla"


* Kasutegurite lähendamise piirangud
  v_lambda1(opt_paev_max, slott, t_el)
  v_lambda2(opt_paev_max, slott, t_el)

$ifthen.two "%eesti_etteande_piirang%" == "true"
 v_eesti_etteanne(opt_paev_max, segu)          "Eesti Jaama etteanne võimaldab ühte segu korraga"
$endif.two

$ifthen.two "%pysikulud%" == "true"
 v_ty_lammutamine(aasta, t)      "Lammutatud plokki ei saa taastada"
 v_ty_lammutamine_koorm(opt_paev_max, t) "Saame toota ainult käigushoitud plokis"
$endif.two

* Müügi nõue, praegu kontsentraadi müük VKGle
  v_myyk(aasta, kuu, k, primaarenergia, t_mk)

$ifthen.three "%logistika%" == "true"
  v_myyk_m(opt_paev_max, k, primaarenergia, t_mk)
$endif.three

* Õlitootmine
  v_oli(opt_paev_max, t_ol) "Õli tootmise ülemine piirang per päev"
  v_max_toodang_ol(opt_paev_max, t_ol) "Remondigraafikute asenduseks maksimaalne õlitootmine kuus (ka uute tehaste tööleminek)"
  v_oli_el_koostootmine(opt_paev_max, t_ol) "Õli ja elektri koostootmine (kui toodetakse õli siis ka elektrit)"

  v_min_production_el(opt_paev_max, slott)   "Minimal requiredload for electricity production (MW)"

$ifthen.two "%remondigraafikud%" == "true"
  v_remont_opt(opt_paev, t_el)
  v_remont_s(t_el, aasta)
  v_remontg(t_el, aasta)
  v_remontg2(opt_paev, t_el)
$endif.two

* Plokkide puhastuse piirangud
$ifthen.two "%puhastused%" == "true"
  v_puhastus2(opt_paev_max, t_el)
  v_puhastus3(opt_paev_max, slott, t_el)
$else.two

* Kui puhastuse piiranguid arvesse ei võta, tuleb katelde maksimaalset võimsust allapoole korrigeerida
* Vaata puhastuse piiranguid allpool.
* Peeter Meos (18.12.2013)
  v_puhastus4(opt_paev_max, slott, t_el)
$endif.two

$ifthen.two "%koostootmistoetus%" == "true"
  v_koostootmine1(opt_paev_max, slott, t_sj)
  v_koostootmine2(opt_paev_max, slott, t_sj)
  v_koostootmine3(opt_paev_max, slott, t_sj)
  v_koostootmine4(aasta)
$endif.two

$ifthen.two "%jp%" == "true"
  v_plokk_aktiivne(opt_paev_max, slott, t_el)
$endif.two

$ontext
v_auru_piirang(opt_paev, slott, t_el)
v_auru_binaar(opt_paev, slott)
$offtext
;

********************************************************************************
** Piirangute asemel seame muutujatele ülemisi ja alumisi piire                *
** Peeter Meos                                                                 *
********************************************************************************
$ifthen.two "%oli%" == "false"
oli.up(opt_paev, t_ol) = 0;
$endif.two

koorm_el.up(opt_paev, slott, t_el) =
         sum((aasta,kuu),max_koormus_el(t_el, aasta, kuu)$tee_paevaks)
;

koorm_el.lo(opt_paev, slott, t_el) = 0;
koorm_sj.lo(opt_paev, slott, t_sj) = 0;
koorm_sj.up(opt_paev, slott, t_el) = 0;

$ifthen.two "%soojus%" == "true"
koorm_sj.up(opt_paev, slott, t_el) = max_koormus_sj(t_el);
$endif.two

********************************************************************************
** Lõigume lahendiruumi ja seame piirid Q'le, lubjale ja killustikule          *
** Peeter Meos                                                                 *
********************************************************************************

  q.up(opt_paev, slott, k, "Uttegaas", t_el)$(kyttevaartus("Uttegaas", k) > 0)
     = sum((aasta, kuu)$tee_paevaks, t_uttegaas(t_el, aasta, kuu)) * kyttevaartus("Uttegaas", k);

$ifthen.two "%l_k_sees%" == "true"
  s_k.up(opt_paev, slott, t_el, k_tase) = 0;
  s_l.up(opt_paev, slott, t_el, l_tase) = 0;
  s_k.up(opt_paev, slott, t_killustik, k_tase) = 1;
  s_l.up(opt_paev, slott, t_lubi, l_tase)      = 1;
$endif.two

********************************************************************************
** Elektritootmisüksuste maksimumkoormused (elekter bruto + soojus)            *
** Peeter Meos                                                                 *
********************************************************************************

$ifthen.op "%MT%" == "OP"
  v_max_koormus_el(opt_paev, slott, t_el)$(ord(opt_paev) > card(paev))..
$else.op
  v_max_koormus_el(opt_paev, slott, t_el)..
$endif.op
  koorm_el(opt_paev, slott, t_el)
  =l=
  sum((aasta,kuu)$tee_paevaks,max_koormus_el(t_el, aasta, kuu)
           *(paevi_kuus(kuu) + liigaasta(aasta)$sameas(kuu, "2")
           - (sum(t_ol$sameas(t_ol, t_el), p_paevi_kuus_ol(t_ol, aasta, kuu) + r_paevi_kuus_ol(t_ol, aasta, kuu)))
           )
           / (paevi_kuus(kuu) + liigaasta(aasta)$sameas(kuu, "2"))
  )
$ifthen.three "%remondigraafikud%" == "true"
 * (1 - remondi_opt(opt_paev, t_el))
$else.three
 * (1 - t_remondigraafik(opt_paev, t_el))
$endif.three
;

$ifthen.op "%MT%" == "OP"
  v_max_koormus_ty(opt_paev, slott, t_el)$(ord(opt_paev) > card(paev))..
$else.op
  v_max_koormus_ty(opt_paev, slott, t_el)..
$endif.op
  koorm_el(opt_paev, slott, t_el) + koorm_sj(opt_paev, slott, t_el)
=l=
         sum((aasta,kuu)$tee_paevaks, max_koormus_ty(t_el, aasta, kuu))
$ifthen.three "%remondigraafikud%" == "true"
         * (1 - remondi_opt(opt_paev, t_el))
$else.three
         * (1 - t_remondigraafik(opt_paev, t_el))
$endif.three
;

********************************************************************************
** Tootmisüksuste sulgemise piirangud.                                         *
** Kõigepealt eeldame, et esimele aastal on meil kõik tootmisüksused töös.     *
**                                                                             *
** Esimene keelab järgnevatel aastate üksus taas töösse lülitada, kui eelmisel*
** aastal see juba sulgetud on                                                 *
**                                                                             *
** Teine ei luba toota sulgetud plokis                                         *
** Peeter Meos                                                                 *
** Taaniel Uleksin                                                             *
********************************************************************************

$ifthen.two "%pysikulud%" == "true"
*ty_aktiivne.lo(t, aasta)$(ord(aasta) eq 1) = 1;

v_ty_lammutamine(aasta, t)..
ty_aktiivne(t, aasta)$(ord(aasta) gt 1) =l= ty_aktiivne(t, aasta - 1)$(ord(aasta) gt 1)
;

v_ty_lammutamine_koorm(opt_paev, t)..
sum((slott, t_el)$sameas(t, t_el), koorm_el(opt_paev, slott, t_el))
+
sum(t_ol$sameas(t, t_ol), oli(opt_paev, t_ol))
=l=
sum((aasta, kuu), ty_aktiivne(t, aasta)$tee_paevaks * M)
;
$endif.two

********************************************************************************
** Plokkide koormuse suurendamise ja vahendamise suurim samm                   *
** Peeter Meos                                                                 *
********************************************************************************
v_delta_yles_el(opt_paev, slott, t_el)$(not sameas(t_el, "Katlamaja") and
                                        delta_yles(t_el) > 0 and
      not (ord(opt_paev) eq 1 and ord(slott) eq 1) and (not t_ol(t_el)))..

  q_out(opt_paev, slott, t_el) - delta_yles(t_el) * sloti_pikkus(opt_paev, slott, t_el)
  =l=
  q_out(opt_paev, slott--1, t_el)$(ord(slott) gt 1)
  +
  q_out(opt_paev-1, slott--1, t_el)$(ord(slott) eq 1)
;

v_delta_alla_el(opt_paev, slott, t_el)$(not sameas(t_el, "Katlamaja") and
                                        delta_alla(t_el) > 0 and
      not (ord(opt_paev) eq 1 and ord(slott) eq 1) and (not t_ol(t_el)))..

  q_out(opt_paev, slott, t_el) + delta_alla(t_el) * sloti_pikkus(opt_paev, slott, t_el)
  =g=
  q_out(opt_paev, slott--1, t_el)$(ord(slott) gt 1)
  +
  q_out(opt_paev-1, slott--1, t_el)$(ord(slott) eq 1)
;


********************************************************************************
** Kivi müügi nõue                                                             *
** Peeter Meos                                                                 *
********************************************************************************

myyk.up(opt_paev, k, primaarenergia, t_mk)$(not max_osakaal(k, primaarenergia, t_mk) > 0
                                           or sum((aasta, kuu)$tee_paevaks,
                                                  myygileping(aasta, kuu, t_mk, k, primaarenergia) = 0)) = 0;
myyk.up(opt_paev, k, primaarenergia, t_mk)$(max_osakaal(k, primaarenergia, t_mk) > 0
                                        and sum((aasta, kuu)$tee_paevaks,
                                                myygileping(aasta, kuu, t_mk, k, primaarenergia) > 0)) = M;

v_myyk(aasta, kuu, k, primaarenergia, t_mk)$(sum(opt_paev$tee_paevaks, 1) > 1)..
  sum(opt_paev$tee_paevaks, myyk(opt_paev, k, primaarenergia, t_mk))
$ifthen.two "%myyk_vaba%" == "true"
  =l=
$else.two
 =e=
$endif.two
  sum(opt_paev$tee_paevaks, myygileping(aasta, kuu, t_mk, k, primaarenergia))
  / paevi_kuus_l(aasta, kuu)
;

$ifthen.three "%logistika%" == "true"
v_myyk_m(opt_paev, k, primaarenergia, t_mk)..
$ifthen.two "%uus_logistika%" == "false"
  tootmisse(opt_paev, k, primaarenergia, t_mk)
$else.two
  sum((l_n, slott)$t_log(t_mk, l_n), tootmisse(opt_paev, slott, l_n, t_mk, k, primaarenergia)*sloti_pikkus(slott))
$endif.two
  =e=
  myyk(opt_paev, k, primaarenergia, t_mk)
;
$endif.three

********************************************************************************
** Kasutegurite lähendamise piirangud. Lähendame interpolatsiooni lambdade     *
** kaudu                                                                       *
** Peeter Meos                                                                 *
** Lisatud on piirang, milliseid kütuseid tootmisüksus tarbib                  *
** Taaniel Uleksin                                                             *
********************************************************************************

v_lambda1(opt_paev, slott, t_el)$(not t_ol(t_el))..
  sum(para_lk, lambda_p(opt_paev, slott, t_el, para_lk))
  =l= card(para_lk) - 1
;

v_lambda2(opt_paev, slott, t_el)$(not t_ol(t_el))..
  q_in(opt_paev, slott, t_el)
  +
  koorm_sj(opt_paev, slott, t_el) / soojuse_kasutegur(t_el)
  =e=
  q_out(opt_paev, slott, t_el)
;

********************************************************************************
** Uttegaasi saame lisada ainult nii palju kui õlitehastesse kivi läheb        *
** Taaniel Uleksin                                                             *
** Peeter Meos                                                                 *
********************************************************************************
$ifthen.three "%oli%" == "true"
v_max_uttegaas(opt_paev)..
  sum((slott, t_el), q(opt_paev, slott, "Hange", "Uttegaas", t_el) * sloti_pikkus(opt_paev, slott, t_el))

$ifthen.two "%uttegaasi_bilanss%" == "true"
  =e=
$else.two
  =l=
$endif.two

* See $ifthen jubin lülitab tootmisüksuste laodusid sisse välja
* Sisuliselt kui ladudest rongi peale toodet laadida ei saa,
* pole mõtet ka ladusid kasutada
* -Peeter Meos
$ifthen.four "%uus_logistika%" == "false"
  sum((k, primaarenergia, t_ol), tootmisse(opt_paev, k, primaarenergia, t_ol)
    * uttegaasi_tootlikkus(t_ol)
    * kyttevaartus("Uttegaas", "Hange"))
$else.four
  sum((l_n, t_ol, k, primaarenergia, slott)$((max_osakaal(k, primaarenergia, t_ol)>0)
                                  and t_log(t_ol, l_n)
                                  and primaar_k(k, primaarenergia)
                                  ),
      tootmisse(opt_paev, slott, l_n, t_ol, k, primaarenergia) * sloti_pikkus(slott) * uttegaasi_tootlikkus(t_ol)
     ) * kyttevaartus("Uttegaas", "Hange")
$endif.four
;
$endif.three

********************************************************************************
** Uttegaasi kasutus on proportsionaalne elektrikoormusega, et ühtlustada      *
** uttegaasi kasutust üle plokkide                                             *
** Taaniel Uleksin                                                             *
********************************************************************************

$ifthen.two "%uttegaasi_jaotus%" == "true"
  v_uttegaas_el2(opt_paev, slott, t_el)$(not t_sj(t_el)
         and (sum((aasta,kuu)$tee_paevaks, max_koormus_el(t_el, aasta, kuu)) > 0)
         and sum((aasta, kuu)$tee_paevaks, t_uttegaas_kokku(aasta, kuu)) > 0
         and kyttevaartus("Uttegaas", "Hange") > 0)..
    q(opt_paev, slott, "Hange", "Uttegaas", t_el) / kyttevaartus("Uttegaas", "Hange")
    =g=
    sum((aasta, kuu)$tee_paevaks, t_uttegaas(aasta, kuu, t_el) / t_uttegaas_kokku(aasta, kuu))
    *
    sum((t_ol,aasta,kuu)$(tootlikkus_ol(t_ol, aasta)>0),
             (
                 (max_koormus_ol(t_ol, aasta, kuu)/paevi_kuus_l(aasta, kuu))
             /tootlikkus_ol(t_ol, aasta))$tee_paevaks
    )
    * uttegaasi_tootlikkus(t_ol)
    / sloti_pikkus(slott)
    * koorm_el(opt_paev, slott, t_el)/
         sum((aasta,kuu)$tee_paevaks, max_koormus_el(t_el, aasta, kuu))
;
$endif.two
********************************************************************************
** Primaarenergia segamine segudeks. Päeva täpsusega.                          *
** Segame energeetilise koosseisu järgi, mitte massi järgi!!                   *
** Peeter Meos                                                                 *
********************************************************************************
$ifthen.three "%katlad%" == "true"
  q.up(opt_paev, slott, k, primaarenergia, t_el, katel)$(max_osakaal(k, primaarenergia, t_el) eq 0) = 0;
$else.three
  q.up(opt_paev, slott, k, primaarenergia, t_el)$(max_osakaal(k, primaarenergia, t_el) eq 0) = 0;
$endif.three

$ifthen.two "%uus_logistika%" == "true"
  tootmisse.up(opt_paev, slott, l_n, t_el, k, primaarenergia)$(max_osakaal(k, primaarenergia, t_el) eq 0) = 0;
$endif.two

** VANA LOGISTIKA *********************
v_primaarenergia_segamine(opt_paev, k, primaarenergia, t_el)$((not t_ol(t_el))
                                                           and not sameas(primaarenergia, "Uttegaas"))..
 tootmisse(opt_paev, k, primaarenergia, t_el) * kyttevaartus(primaarenergia, k)
 =e=
 sum((slott), q(opt_paev, slott, k, primaarenergia, t_el) * sloti_pikkus(opt_paev, slott, t_el))
;

* Kütuse osakaal ei tohi ületada lubatud maksimaalset osakaalu
v_max_osakaal(opt_paev, slott, k, primaarenergia, t_el)$(primaar_k(k, primaarenergia))..
  q(opt_paev, slott, k, primaarenergia, t_el)$(max_osakaal(k, primaarenergia, t_el)>0)
=l=
  sum((k2, p2)$(max_osakaal(k2, p2, t_el)>0), q(opt_paev, slott, k2, p2, t_el))
   * max_osakaal(k, primaarenergia, t_el)
;

v_max_osakaal_ol(opt_paev, k, primaarenergia, t_ol)$((max_osakaal(k, primaarenergia, t_ol) > 0)
                                                 and primaar_k(k, primaarenergia))..
 tootmisse(opt_paev, k, primaarenergia, t_ol)
 =l=
 max_osakaal(k, primaarenergia, t_ol) * sum((k2, p2), tootmisse(opt_paev, k2, p2, t_ol))
;

********************************************************************************
** Minimaalse kütteväärtuse piirang tootmisüksuses.                            *
** Antud piirang on loodud kütusesegude jaoks, et saaks segada kütuseid,       *
** mida üksikult tootmisüksusesse panna ei saa.                                *
** Uttegaasi lisamine võimaldab tahkekütuse alumist kütteväärtust alandada.    *
**                                                                             *
** Taaniel Uleksin                                                             *
** Peeter Meos                                                                 *
********************************************************************************

v_min_kyttevaartus(opt_paev, t)$(sum((aasta, kuu)$tee_paevaks, kyttevaartus_min(t, aasta, kuu)) > 0)..
 sum((k, primaarenergia),
     tootmisse(opt_paev, k, primaarenergia, t) * kyttevaartus(primaarenergia, k))
 +
 sum((k2, p2, slott, t_el)$(sameas(t_el ,t) and gaas(p2)),
                q(opt_paev, slott, k2, p2, t_el)
                * sloti_pikkus(opt_paev, slott, t_el))
=g=
   sum((k, primaarenergia), tootmisse(opt_paev, k, primaarenergia, t))
 * sum((aasta, kuu)$tee_paevaks, kyttevaartus_min(t, aasta, kuu))
;

********************************************************************************
** Killustiku kasutus. Päeva täpsusega.                                        *
** Peeter Meos                                                                 *
********************************************************************************
$ifthen.two "%l_k_sees%" == "true"
v_killustiku_kasutus(opt_paev, t_killustik)..
*$ifthen.two "%uus_logistika%" == "true"
* sum((l_n, k, slott)$(t_log(t_killustik, l_n) and primaar_k(k, "Killustik")), tootmisse(opt_paev, slott, l_n, t_killustik, k, "Killustik")*sloti_pikkus(slott))
*$else.two
* sum((l_t, k)$(tootmine_ja_laod(l_t, t_killustik) and primaar_k(k, "Killustik")),
*      laost_tootmisse(opt_paev, l_t, t_killustik, k, "Killustik"))
* +
* sum((liinid, k, l)
*      $(liini_otsad(liinid, k, l) and (t_jp_tootmine(l, t_killustik)) and (primaar_k(k, "Killustik"))),
*      liinilt_tootmisse(opt_paev, liinid, t_killustik, "Killustik"))
*$endif.two
M
=g=
* Ma eeldan siin, et killustiku tasemed on antud per katel mitte per plokk.
$ifthen.three "%katlad%" == "true"
 sum((slott, katel, k_tase), s_k(opt_paev, slott, t_killustik, katel, k_tase) * sloti_pikkus(slott) * kil_tase(k_tase))
$else.three
 sum((slott, k_tase), s_k(opt_paev, slott, t_killustik, k_tase) * sloti_pikkus(opt_paev, slott, t_killustik) * kil_tase(k_tase))
$endif.three
;

$ifthen.three "%katlad%" == "true"
v_killustiku_kasutus2(opt_paev, slott, t_killustik)..
  sum((katel, k_tase)$(not sameas(k_tase, "0")), s_k(opt_paev, slott, t_killustik, katel, k_tase)) =l= koorm_el(opt_paev, slott, t_killustik);

v_killustiku_kasutus3(opt_paev, slott, t_killustik, katel)..
  sum((k_tase), s_k(opt_paev, slott, t_killustik, katel, k_tase)) =l= 1;
$endif.three

********************************************************************************
** Lubja kasutus. Sloti täpsusega.                                             *
** Peeter Meos                                                                 *
********************************************************************************
v_lubja_kasutus(opt_paev, slott, t_lubi)..
  sum(l_tase, s_l(opt_paev, slott, t_lubi, l_tase)) =l= koorm_el(opt_paev, slott, t_lubi) * M ;
$endif.two

********************************************************************************
** Tootmisüksuse maksimumkoormus (segu pluss uttegaas) peab olema väiksem kui  *
** maksimaalne lubatud brutokoormus                                            *
** Peeter Meos                                                                 *
********************************************************************************

v_koorm_el(opt_paev, slott, t_el)$(not t_ol(t_el))..
  koorm_el(opt_paev, slott, t_el) =e= s_brutovoimsus_el(opt_paev, slott, t_el)
;

********************************************************************************
** Õlitootmine, saame toota kohaletoodud primaarenergiast                      *
** Peeter Meos                                                                 *
********************************************************************************
v_oli(opt_paev, t_ol)..
$ifthen.three "%uus_logistika%" == "true"
   sum((l_n, k, primaarenergia, slott)$(t_log(t_ol, l_n) and primaar_k(k, primaarenergia) and (max_osakaal(k, primaarenergia, t_ol)>0) ),
       tootmisse(opt_paev, slott, l_n, t_ol, k, primaarenergia)
       * sloti_pikkus(slott)
       * saagis_ol(t_ol, aasta, k, primaarenergia)
      ) * sum((aasta, kuu)$tee_paevaks, tootlikkus_ol(t_ol, aasta))

$else.three
  sum((k, primaarenergia), tootmisse(opt_paev, k, primaarenergia, t_ol)
                         * sum((aasta, kuu)$tee_paevaks, saagis_ol(t_ol, aasta, k, primaarenergia)))

$endif.three
  =e=
  oli(opt_paev, t_ol)
;

********************************************************************************
** Õlitootmine, on piiratud primaarenergia läbilaskevõimekusega (t/päevas)     *
** Õlitehased arvutavad oma võimekust 8.2 MJ/kg kivi peale, seega tuleb see    *
** piirang (t/päevas) ümber arvutada (MWh/päevas) peale.                       *
**
** Macros used: tee_paevaks
** Peeter Meos                                                                 *
********************************************************************************
v_max_toodang_ol(opt_paev, t_ol)..
  sum((k, primaarenergia)$(kyttevaartus(primaarenergia, k) > 0),
                            tootmisse(opt_paev, k, primaarenergia, t_ol)
                          / (1 - kyttevaartus(primaarenergia, k) / kv_oli_std + 1)
                          )
  =l=
  sum((aasta, kuu)$tee_paevaks, max_koormus_ol(t_ol, aasta, kuu)
                                * 24
* Korrigeerime remondipäevade ja puhastuspäevade arvuga
                                * (paevi_kuus(kuu) + liigaasta(aasta)$sameas(kuu, "2")
                                - p_paevi_kuus_ol(t_ol, aasta, kuu)
                                - r_paevi_kuus_ol(t_ol, aasta, kuu)
                                  )
                               / (paevi_kuus(kuu) + liigaasta(aasta)$sameas(kuu, "2")))
;

********************************************************************************
** Kui tootmisüksus on õli ja elektri koostootmisüksus (Enefit),               *
** siis toodetakse seal elektrit samal ajal kui õli.                           *
** Taaniel Uleksin                                                             *
********************************************************************************
v_oli_el_koostootmine(opt_paev, t_ol)$(t_el(t_ol))..
  sum((slott, t_el)$sameas(t_el, t_ol), koorm_el(opt_paev, slott, t_el))
  =l=
  oli(opt_paev, t_ol)
;

********************************************************************************
** Enne kui elektritootmise koormus ei ületa miinimumkoormust,                 *
** sooja toota ei saa                                                          *
********************************************************************************
sj_aktiivne.up(opt_paev, t_el) = 1;

v_min_koormus_sj(opt_paev, slott, t_el)$(sum((aasta,kuu),max_koormus_el(t_el, aasta, kuu)$tee_paevaks) > 0)..
*koorm_sj(opt_paev, slott, t_sj) / M +
koorm_el(opt_paev, slott, t_el)
=g=
min_koormus_sj(t_el)* sj_aktiivne(opt_paev, t_el)
;

********************************************************************************
** Koostootmisplokkidel tuleb enne toota elektrit, siis võib sooja ka toota    *
** Taaniel Uleksin & Peeter Meos                                               *
********************************************************************************

v_min_koormus_sj_M(opt_paev, slott, t_el)$(sum((aasta,kuu),max_koormus_el(t_el, aasta, kuu)$tee_paevaks) > 0)..
  koorm_sj(opt_paev, slott, t_el) =l= sj_aktiivne(opt_paev, t_el) * M
;
********************************************************************************
** Peame müüma prognoositud hulga sooja. Müügikogused on antud MWh per kuudes  *
** Peeter Meos & Taaniel Uleksin                                               *
** Lisatud on kontsernisisene soojatarne.                                      *
** Operatiivmudelil on täpsustatud soojatarne lühikeses perspektiivis          *
** Taaniel Uleksin                                                             *
********************************************************************************
$ifthen.two "%soojus%" == "true"
v_sooja_tarne(opt_paev, slott)..
 sum((t_sj), koorm_sj(opt_paev, slott, t_sj) * sloti_pikkus(opt_paev, slott, t_sj))
$ifthen.three "%soojus_vaba%" == "true"
 =l=
$else.three
 =e=
$endif.three
 sum((aasta, kuu)$tee_paevaks, soojatarne(aasta, kuu)
 / paevi_kuus_l(aasta, kuu))
 / 24 * sloti_pikkus_orig(slott)
;


v_sisemine_sooja_tarne(opt_paev, slott)..
 sum(t_el$(not t_sj(t_el)), koorm_sj(opt_paev, slott, t_el) * sloti_pikkus(opt_paev, slott, t_el))
$ifthen.three "%soojus_vaba%" == "true"
 =l=
$else.three
 =e=
$endif.three
 sum((aasta, kuu)$tee_paevaks, sisemine_soojatarne(aasta, kuu)
      / paevi_kuus_l(aasta, kuu))
      / 24 * sloti_pikkus_orig(slott);

;

$endif.two

********************************************************************************
**                                                                             *
** Minimum required peak and off peak load constraint for power production.    *
**                                                                             *
** Description: For peak (0800 - 2000 weekdays) and offpeak periods            *
** (not weekday 8000 - 2000 hrs) we are given minimum power load in order      *
** to guarantee that cross border price from the South will not make the price *
** in Estonia. The loads are given for every month.                            *
**                                                                             *
** Macros used: tee_paevaks - couples year, month and a model day              *
** Notes: For lower resolution models, the loading needs to be normalised      *
** across the slots. Ie. the average load for the whole day needs to be        *
** proportionally lower than the offpeak load.                                 *
**                                                                             *
********************************************************************************
v_min_production_el(opt_paev, slott)..
     sum((aasta, kuu, t_el)$tee_paevaks,
         koorm_el(opt_paev, slott, t_el)
       * sloti_pikkus(opt_paev, slott, t_el)
        )
  =g=

* For some specific model setups, such as demand curve calculations, this constraint
* needs to be turned off

$ifthen.el "%el_vaba%" == "true"
  0
$else.el

* Kalvi defines peak periods from 8am to 8pm (weekdays)
* therefore production needs to be greater than
* total minimum load across these hours.

  sum((aasta, kuu, opt_tund)$(tee_paevaks
                             and sloti_tunnid(slott, opt_tund)
                             and (   ord(opt_tund) < 8
                                  or ord(opt_tund) > 20
                                  or paeva_tyyp(opt_paev) > 0)
                              ),
         t_el_min_sum_offpeak(aasta, kuu))
  +
  sum((aasta, kuu, opt_tund)$(tee_paevaks
                           and paeva_tyyp(opt_paev) = 0
                           and sloti_tunnid(slott, opt_tund)
                             and ord(opt_tund) > 7
                             and ord(opt_tund) < 21 ),
       t_el_min_sum_peak(aasta, kuu))
$endif.el
;


********************************************************************************
** Remondigraafikute optimeermine                                              *
** Taaniel Uleksin                                                             *
********************************************************************************
$ifthen.two "%remondigraafikud%" == "true"

* Remont alaku esmaspäeviti
remondi_start.up(opt_paev, t_el)$(not gdow(jdate(esimene_aasta, esimene_kuu, 1)
                                  + ord(opt_paev)-1 + %esimene_paev%) eq 1) = 0;

*Remondipäeval ei saa plokk töötada
v_remont_opt(opt_paev, t_el)..
  sum(slott, koorm_el(opt_paev, slott, t_el))
  =l=
  (1 - remondi_opt(opt_paev, t_el)) * M
;

*Remonte on aastas ainult 1
v_remont_s(t_el, aasta)$(TRemont(t_el, aasta) > 0)..
  sum((opt_paev, kuu), remondi_start(opt_paev, t_el)$tee_paevaks)
  =e=
  1
;

*Aastas peab olema etteantud remondipäevi

v_remontg(t_el, aasta)$(TRemont(t_el, aasta) > 0)..
  sum((opt_paev,kuu), remondi_opt(opt_paev, t_el)$tee_paevaks)
  =e=
  TRemont(t_el, aasta)
;

remondi_opt.up(opt_paev, t_el) = 1;

*Remondipäevast alates on plokk maas etteantud remondipäevad
v_remontg2(opt_paev, t_el)$(sum((aasta, kuu), TRemont(t_el, aasta)) > 0)..
  remondi_opt(opt_paev, t_el)
  =e=
  sum(opt_paev2,
         remondi_start(opt_paev2, t_el)$
         (
                 (ord(opt_paev2) le ord(opt_paev))
                 and
                 (ord(opt_paev2) ge (ord(opt_paev) - sum((aasta, kuu),
                       TRemont(t_el, aasta)$tee_paevaks)+1))
         )
  )
;
$endif.two

********************************************************************************
** Puhastuste optimeermine                                                     *
** Peeter Meos                                                                 *
********************************************************************************

$ifthen.two "%puhastused%" == "true"

t_puhastus.up(opt_paev, t_el) = 1;
t_puhastus.up(opt_paev, t_el)$(t_tehnoloogia("CFB", t_el)) = 0;

t_puhastus.fx(opt_paev, t_el)$(t_remondigraafik(opt_paev, t_el) = 1
                        or sum((aasta, kuu)$tee_paevaks, max_koormus_el(t_el, aasta, kuu) = 0)) = 0;

v_puhastus2(opt_paev, t_el)$(not t_tehnoloogia("CFB", t_el)
                        and (sum(t_ol$sameas(t_ol, t_el), 1) = 0)
                        and ord(opt_paev) < card(opt_paev) - 7
                        and t_remondigraafik(opt_paev, t_el) = 0
                        and sum((aasta, kuu)$tee_paevaks, max_koormus_el(t_el, aasta, kuu) > 0)
                            )..

  sum(opt_paev2$(ord(opt_paev2) < (ord(opt_paev) + 7)
              and ord(opt_paev2) ge ord(opt_paev)
              ), t_puhastus(opt_paev2, t_el)) * 6
  =e=
  sum(opt_paev2$(ord(opt_paev2) < (ord(opt_paev) + 7)
              and ord(opt_paev2) ge ord(opt_paev)
              ), (1-t_puhastus(opt_paev2, t_el)))
;

* Puhastuspäeval ei tooda
*$ifthen.op "%MT%" == "OP"
*  v_puhastus3(opt_paev, slott, t_el)$(not t_tehnoloogia("CFB", t_el) and ord(opt_paev) > card(paev))..
*$elseif.op
  v_puhastus3(opt_paev, slott, t_el)$(not t_tehnoloogia("CFB", t_el))..
*$endif.op
  koorm_el(opt_paev, slott, t_el)
  =l= sum((aasta, kuu)$tee_paevaks, max_koormus_el(t_el, aasta, kuu))
$ifthen.four "%remondigraafikud%" == "true"
      * (1 - remondi_opt(opt_paev, t_el))
$else.four
      * (1 - t_remondigraafik(opt_paev, t_el))
$endif.four
      * (1 - t_puhastus(opt_paev, t_el)
      * 0.5)
;
$else.two
  v_puhastus4(opt_paev, slott, t_el)$(not t_tehnoloogia("CFB", t_el))..
 koorm_el(opt_paev, slott, t_el)
 =l=
 sum((aasta,kuu),max_koormus_el(t_el, aasta, kuu)$tee_paevaks)
$ifthen.three "%remondigraafikud%" == "true"
      * (1 - remondi_opt(opt_paev, t_el))
$else.three                     '
      * (1 - t_remondigraafik(opt_paev, t_el))
$endif.three
*      * 13/14
;
$endif.two

********************************************************************************
** Koostootmistoetused                                                         *
** Peeter Meos                                                                 *
********************************************************************************

$ifthen.two "%koostootmistoetus%" == "true"
v_koostootmine1(opt_paev, slott, t_sj)..
 koorm_bio(opt_paev, slott, t_sj)
 =l=
 sum((k, katel, k_tase, l_tase), q(opt_paev, slott, k, "Biokytus", t_sj, katel, k_tase, l_tase)) * 0.5
;

v_koostootmine2(opt_paev, slott, t_sj)..
 koorm_bio(opt_paev, slott, t_sj)
 =l=
 koorm_el(opt_paev, slott, t_sj) * max_osakaal("Hange", "Biokytus", t_sj)
;

v_koostootmine3(opt_paev, slott, t_sj)..
  koorm_bio(opt_paev, slott, t_sj)
  =l=
  koorm_sj(opt_paev, slott, t_sj) * M
;

v_koostootmine4(aasta)..
  sum((t_sj, opt_paev, slott, kuu)$tee_paevaks, koorm_bio(opt_paev, slott, t_sj) * sloti_pikkus(slott))
  =l=
  max_toetuse_kogus(aasta)
;
$endif.two

$ifthen.two "%jp%" == "true"
v_plokk_aktiivne(opt_paev, slott, t_el)..
  koorm_el(opt_paev, slott, t_el) =l= pl_aktiivne(opt_paev, slott, t_el)*M
;
$endif.two


$ontext
v_auru_piirang(opt_paev, slott, t_el)$t_aur(t_el)..
  koorm_el(opt_paev, slott, t_el) =g= auru_binaar(opt_paev, slott, t_el)
  * sum(aasta$tee_paevaks, auru_min_koormus(aasta))
;

v_auru_binaar(opt_paev, slott)..
  sum(t_el$t_aur(t_el), auru_binaar(opt_paev, slott, t_el)) =g= 1
;
$offtext

********************************************************************************
**
**  Tükati lineaarne lähendus kasuteguritele.
**  SOS2 lähendus on liiga uimane, teeme lihtsama.
**
** Peeter Meos
********************************************************************************

lambda_p.up(opt_paev, slott, t_el, para_lk) = 1;
beta_p.up(opt_paev, slott, t_el, para_lk) = 1;

Equations
  v_beta(opt_paev_max, slott, t_el, para_lk)  "Eelmise lõigu väärtus peab olema suurem järgmise omast"
  v_beta1(opt_paev_max, slott, t_el, para_lk) "Esimene lõik peab olema täis koormatud, kui plokk on töös"
  v_beta2(opt_paev_max, slott, t_el, para_lk) "Teised lõigud võivad koormatud olla siis kui esimene on koormatud"

;

v_beta(opt_paev, slott, t_el, para_lk)$(ord(para_lk) > 1 and ord(para_lk) < card(para_lk))..
  lambda_p(opt_paev, slott, t_el, para_lk)
  =l=
  lambda_p(opt_paev, slott, t_el, para_lk-1)
;

v_beta1(opt_paev, slott, t_el, para_lk)$(ord(para_lk) = 2)..
  lambda_p(opt_paev, slott, t_el, para_lk)
  =g=
  beta_p(opt_paev, slott, t_el, para_lk)
;

v_beta2(opt_paev, slott, t_el, para_lk)$(ord(para_lk) > 2)..
  lambda_p(opt_paev, slott, t_el, para_lk)
  =l=
  beta_p(opt_paev, slott, t_el, "2")
;

********************************************************************************
**
**  Primaarenergia kasutuse jõuga ette kirjutamine ettemääratud kuudel
**
** Peeter Meos
********************************************************************************
alias(k, k2);
Equations v_lubatud_kasutus(aasta, kuu, t, k, primaarenergia) "Primaarenergia kasutuse piiramine plokis";

v_lubatud_kasutus(aasta, kuu, t, k, primaarenergia)$(sum((k2, p2), lubatud_kasutus(aasta, kuu, t, k2, p2)) > 0)..
 sum(opt_paev$tee_paevaks, tootmisse(opt_paev, k, primaarenergia, t))
 =l=
 lubatud_kasutus(aasta, kuu, t, k, primaarenergia) * M * M
;

********************************************************************************
**
**  Kahe komponendiga unit commitment koos käivituskuludega
**
** Peeter Meos, 22. august 2014
********************************************************************************

Equation
  v_unit_commitment(opt_paev_max, slott, t_el)
  v_unit_beta(opt_paev_max, slott, t_el)
$ifthen.two "%kkul%" == "true"
*  v_unit_start(opt_paev, slott, t_el)
*  v_unit_stop(opt_paev, slott, t_el)
  v_unit_status(opt_paev_max, slott, t_el)
$endif.two
;

v_unit_commitment(opt_paev, slott, t_el)..
koorm_el(opt_paev, slott, t_el)
=e=
k_alpha(opt_paev, slott, t_el) * min_koormus_el(t_el)
+
k_beta(opt_paev, slott, t_el)
;

v_unit_beta(opt_paev, slott, t_el)..
  k_beta(opt_paev, slott, t_el)
  =l=
  (sum((aasta, kuu)$tee_paevaks, max_koormus_el(t_el, aasta, kuu)) -
    min_koormus_el(t_el))
  * k_alpha(opt_paev, slott, t_el)
;

k_alpha.up(opt_paev, slott, t_el) = 1;


$ifthen.two "%kkul%" == "true"
v_unit_status(opt_paev, slott, t_el)$(ord(opt_paev) > 1 or (ord(opt_paev) = 1 and ord(slott) > 1))..
k_alpha(opt_paev, slott, t_el)
=e=
t_kaivitus(opt_paev, slott, t_el)
+
k_alpha(opt_paev, slott--1, t_el)$(ord(slott) > 1)
+
k_alpha(opt_paev--1, slott--1, t_el)$(ord(slott) = 1)
-
t_stop(opt_paev, slott, t_el)
;
$endif.two



