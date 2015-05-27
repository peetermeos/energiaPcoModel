********************************************************************************
**                                                                             *
** See fail sisaldab primaarenergia kaevandamise ja hankimisega seotud         *
** piiranguid. Selle alla käib ka rikastamine.                                 *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

$if setglobal kompileeri $goto edasi
$abort Kompileeri pco.gms!
$label edasi

Equations
   v_k_paevane_kaeve(opt_paev_max, k, primaarenergia)

$ifthen.two "%ost%" == "true"
   v_kytuse_ost(lepingu_nr, opt_paev_max, k, primaarenergia)
$endif.two

$ifthen.two "%uus_logistika%" == "false"
   v_kaeve_jaotus(opt_paev_max, primaarenergia, k)
$endif.two
   v_open_pit_combo(opt_paev_max, k, primaarenergia) "Combining more than one layer of raw shale into product."

   v_k_kohustuslik_kkt(opt_paev_max)

* Need on ainult Estonia jaoks
   v_aheraine_sum(opt_paev_max, k)
   v_soelise_sum(opt_paev_max, k)
   v_kontsentraadi_sum(opt_paev_max, k)
   v_rikastus1(opt_paev_max, k, primaarenergia)
   v_rikastus2(opt_paev_max, k, primaarenergia)

$ifthen.two "%pysikulud%" == "true"
   v_k_sulgemine(aasta, k)
   v_k_sulgemine_kaev(opt_paev_max, k)
$endif.two
   v_k_min_tarne(aasta, kuu, k, primaarenergia)
;

$ifthen.three "%uus_logistika%" == "false"
$ifthen.two "%kaevanduste_laod%" == "false"
* Ei ladusta kivi.
kaevandusest_lattu.fx(opt_paev_max, l_k, k, primaarenergia)= 0;
laost_liinile.fx(opt_paev_max, l_k, liinid, primaarenergia) = 0;
$endif.two
$endif.three

kaeve.up(opt_paev, p2, primaarenergia, k)$(not primaar_k(k, primaarenergia)) = 0;

$ifthen.two "%ost%" == "true"
  lp_aktiivne.up(lepingu_nr) = 1;
$endif.two

********************************************************************************
** Arvutame välja kaevanduse tööpäevad kuus                                    *
** Peeter Meos 15. august 2014                                                 *
********************************************************************************
Parameter toopaevi_kuus(aasta, kuu, k);
toopaevi_kuus(aasta, kuu, k) = sum(opt_paev$(tee_paevaks),
                                    1$(paeva_tyyp(opt_paev) = 0)
                                    +
                                    1$(paeva_tyyp(opt_paev) = 1 and k_toopaev(k, "6") = 1)
                                    +
                                    1$(paeva_tyyp(opt_paev) = 2 and k_toopaev(k, "7") = 1)
                                  );

********************************************************************************
** Kaevandused ja karjäärid kaevandavad ainult etteantud nädalapäevadel        *
** Peeter Meos                                                                 *
** Taaniel Uleksin                                                             *
********************************************************************************

v_k_min_tarne(aasta, kuu, k, primaarenergia)$(prim_min_tarne(aasta, kuu, k, primaarenergia) > 0)..
  sum(opt_paev$tee_paevaks, sum(p2, kaeve(opt_paev, p2, primaarenergia, k)
   * rikastuskoefitsent(p2, k, primaarenergia)))
  =g=
$ifthen.two  "%kkt_vaba%" == "true"
  0
$else.two
  sum(opt_paev$tee_paevaks, prim_min_tarne(aasta, kuu, k, primaarenergia)
   / paevi_kuus_l(aasta, kuu))
$endif.two
;

* Pühapäeval ja riigipühadel on kaevandus kinni
kaeve.up(opt_paev, p2, primaarenergia, k)$(paeva_tyyp(opt_paev) = 2 and k_toopaev(k, "7") = 0) = 0;

* Laupäeval on kaevandus kinni
kaeve.up(opt_paev, p2, primaarenergia, k)$(paeva_tyyp(opt_paev) = 1 and k_toopaev(k, "6") = 0) = 0;

********************************************************************************
** Me ei saa toota, ladustada ja laadida tooteid, mida antud                   *
** kaevandused ei tooda                                                        *
** Peeter Meos                                                                 *
********************************************************************************

*kaevandusest_lattu.up(opt_paev, l_k, primaarenergia)
*                    $(not primaar_k(k, primaarenergia) ) = 0;
*kaevandusest_liinile.up(opt_paev, liinid, primaarenergia)
*                      $(not primaar_k(k, primaarenergia)) = 0;


********************************************************************************
** Ostulepingute kasutus (t)                                                   *
**                                                                             *
** Taaniel Uleksin                                                             *
** Peeter Meos                                                                 *
********************************************************************************

$ifthen.two "%ost%" == "true"
kytuse_ost.fx(lepingu_nr, opt_paev, k, primaarenergia)$(not sameas(k, "Hange") or not primaar_k(k, primaarenergia)
            or sum((aasta, kuu)$tee_paevaks, ostuleping(lepingu_nr, aasta, kuu, k, primaarenergia, "kogus")) = 0) = 0;

v_kytuse_ost(lepingu_nr, opt_paev, k, primaarenergia)$(sameas(k, "Hange") and primaar_k(k, primaarenergia))..
  kytuse_ost(lepingu_nr, opt_paev, k, primaarenergia)$(sum((aasta, kuu)$tee_paevaks, ostuleping(lepingu_nr, aasta, kuu, k, primaarenergia, "kogus")) > 0)
  =l=
  sum((aasta, kuu)
        $(tee_paevaks and ostuleping(lepingu_nr, aasta, kuu, k, primaarenergia, "kogus")) ,
      lp_aktiivne(lepingu_nr) *
      ostuleping(lepingu_nr, aasta, kuu, k, primaarenergia, "kogus")

* Kuna ostulepingu kütteväärtusega saame vale primaarenergia koguse,
* sest ostulepingu kütteväärtust ei arvestata tootmises),
* siis kasutame saadud kütuse sisestatud kütteväärtuseid.
* Hetkel saame ainult vale KET kulu, mis ei ole nii suur viga
*
*      /kyttevaartus(primaarenergia, k)
      / paevi_kuus_l(aasta, kuu)
      )
;
$endif.two

********************************************************************************
** Kaevandamine ei tohi ületada kaevevõimekust (t)                             *
**                                                                             *
** Peeter Meos                                                                 *
** Taaniel Uleksin                                                             *
********************************************************************************

v_k_paevane_kaeve(opt_paev, k, primaarenergia)$k_kaeve(k, primaarenergia)..
   sum(p2$primaar_k(k, p2), kaeve(opt_paev, primaarenergia, p2, k))$((not sameas(k, "Hange")) and (not k_rikastus(k)))
   +
   kaeve(opt_paev, primaarenergia, primaarenergia, k)$(sameas(k, "Hange"))
   +
   maemass(opt_paev, k)$(k_rikastus(k))
   =l=
* Kuine maksimaalne kaeve tuleb läbi jagada tööpäevade arvuga selles kuus
   sum((aasta, kuu)$tee_paevaks, max_kaeve(aasta, kuu, k, primaarenergia) / toopaevi_kuus(aasta, kuu, k))
$ifthen.two "%ost%" == "true"
   + sum(lepingu_nr$(sum((aasta, kuu)$tee_paevaks, ostuleping(lepingu_nr, aasta, kuu, k, primaarenergia, "kogus")) > 0),
             kytuse_ost(lepingu_nr, opt_paev, k, primaarenergia))$(sameas(k, "Hange") and primaar_k(k, primaarenergia) )
$endif.two

;

v_k_kohustuslik_kkt(opt_paev)..
  kaeve(opt_paev, "Energeetiline", "Energeetiline", "KKT")
$ifthen.two  "%kkt_vaba%" == "true"
  =g= 0
$else.two
  =e=
  sum((aasta, kuu)$tee_paevaks, max_kaeve(aasta, kuu, "KKT", "Energeetiline") / toopaevi_kuus(aasta, kuu, "KKT"))
$endif.two
;

$ifthen.two "%ost%" == "true"
kaeve.up(opt_paev, primaarenergia, p2, "Hange")$(not sameas(primaarenergia, p2)) = 0;
$endif.two

********************************************************************************
** Kaeve jaotus muudele allikatele peale Estonia                               *
**                                                                             *
** Makrod: kaevandusest - lattu ja liinile mineva toote summeerimine           *
** Peeter Meos                                                                 *
********************************************************************************
$ifthen.two "%uus_logistika%" == "false"

v_kaeve_jaotus(opt_paev, primaarenergia, k)$(primaar_k(k, primaarenergia))..
  kaevandusest(k, primaarenergia)
  =e=
  sum(p2$k_kaeve(k, p2), kaeve(opt_paev, p2, primaarenergia, k) * rikastuskoefitsent(p2, k, primaarenergia)
  )
;
$endif.two

********************************************************************************
** For open pit mines in special cases we need to combine more than one layer  *
** Specific heats must sum                                                     *
** for each k                                                                  *
** for each primaarenergia                                                     *
**                                                                             *
** Macros: none                                                                *
********************************************************************************
v_open_pit_combo(opt_paev, k, primaarenergia)$(sum(p2$(rikastuskoefitsent(p2, k, primaarenergia) = 1), 1) > 1)..
sum(p2$k_kaeve(k, p2), (kaeve(opt_paev, p2, primaarenergia, k) * rikastuskoefitsent(p2, k, primaarenergia))
                        * kyttevaartus(p2, k))
 =e=
* =l=
sum(p2$k_kaeve(k, p2), (kaeve(opt_paev, p2, primaarenergia, k) * rikastuskoefitsent(p2, k, primaarenergia))
                        * kyttevaartus(primaarenergia, k))
;

********************************************************************************
** Rikastusvabrikuga kaevandus jaotab mäemassi kõigepealt kontsentraadiks      *
** sõeliseks ja aheraineks. Nendest pannakse kokku tegelikud tooted.           *
** Peeter Meos                                                                 *
** Taaniel Uleksin                                                             *
********************************************************************************

v_aheraine_sum(opt_paev, k)$k_rikastus(k)..
sum(primaarenergia$primaar_k(k, primaarenergia), aher_p(opt_paev, k, primaarenergia))
=l= aher_pct(k) * maemass(opt_paev, k);

v_soelise_sum(opt_paev, k)$k_rikastus(k)..
sum(primaarenergia$primaar_k(k, primaarenergia), soel_p(opt_paev, k, primaarenergia))
=l= soel_pct(k) * maemass(opt_paev, k);

v_kontsentraadi_sum(opt_paev, k)$k_rikastus(k)..
sum(primaarenergia$primaar_k(k, primaarenergia), konts_p(opt_paev, k, primaarenergia))
=l= konts_pct(k) * maemass(opt_paev, k);

********************************************************************************
** Rikastusvabrikuga kaevanduse tasakaaluvõrrandid peavad klappima nii         *
** energeetilise koguse kui ka massi pealt.                                    *
** Peeter Meos                                                                 *
** Taaniel Uleksin                                                             *
********************************************************************************

v_rikastus1(opt_paev, k, primaarenergia)$(primaar_k(k, primaarenergia) and k_rikastus(k) and not sameas(primaarenergia, "Kaevis") )..
kyttevaartus(primaarenergia, k) * kaeve(opt_paev, "Kaevis", primaarenergia, k)
=e=
kyttevaartus("Tykikivi", k) * konts_p(opt_paev, k, primaarenergia)
+
kyttevaartus("Aheraine", k) * aher_p(opt_paev, k, primaarenergia)
+
soelise_kyttevaartus(k) * soel_p(opt_paev, k, primaarenergia)
;


v_rikastus2(opt_paev, k, primaarenergia)$(primaar_k(k, primaarenergia) and k_rikastus(k) and not sameas(primaarenergia, "Kaevis") )..
kaeve(opt_paev, "Kaevis", primaarenergia, k)
=e=
soel_p(opt_paev, k, primaarenergia)
                                  + konts_p(opt_paev, k, primaarenergia)
                                  +  aher_p(opt_paev, k, primaarenergia)
;

********************************************************************************
** Kaevanduste püsikad                                                         *
** Kui kaevandus vastu püsikaid ei ole kasumlik, pannakse kaevandus kinni      *
** Taaniel Uleksin                                                             *
********************************************************************************

$ifthen.two "%pysikulud%" == "true"

v_k_sulgemine(aasta, k)..
k_aktiivne(k, aasta)$(ord(aasta) gt 1)
=l=
k_aktiivne(k, aasta - 1)$(ord(aasta) gt 1)
;

v_k_sulgemine_kaev(opt_paev, k)..
sum((primaarenergia, p2),kaeve(opt_paev, primaarenergia, p2, k))
=l=
sum((aasta, kuu), k_aktiivne(k, aasta)$tee_paevaks * M)
;

$endif.two

********************************************************************************
** Karjääride tootmispiirangud.                                                *
** Tehnoloogia tõttu ei saa näiteks kaevandada 7.0 ja 7.5 MJ/kg kivi korraga   *
** Peeter Meos                                                                 *
** August 2014                                                                 *
********************************************************************************

Equation
  v_lubatud_kaeve1(aasta, kuu, k, primaarenergia)
  v_lubatud_kaeve2(aasta, kuu, k)

;

v_lubatud_kaeve1(aasta, kuu, k, primaarenergia)$(lubatud_kaeve(aasta, kuu, k, primaarenergia) > 0)..
   sum(opt_paev$tee_paevaks,
   sum((l_k)$(kaevandused_ja_laod(k, l_k)
         and primaar_k(k, primaarenergia)
         and not ladustamatu_primaarenergia(k, primaarenergia, l_k)),
         kaevandusest_lattu(opt_paev, l_k, k, primaarenergia))
   +
   sum((liinid, l)
      $(liini_otsad(liinid, k, l) and primaar_k(k, primaarenergia)
     ),
          kaevandusest_liinile(opt_paev, liinid, primaarenergia))
  )
  =l=
* Siin jääb üks Big M väheks.
  primaari_valik(aasta, kuu, k, primaarenergia) * M * M
;

v_lubatud_kaeve2(aasta, kuu, k)$(sum(primaarenergia, lubatud_kaeve(aasta, kuu, k, primaarenergia)) > 0)..
  sum(primaarenergia$(lubatud_kaeve(aasta, kuu, k, primaarenergia) > 0), primaari_valik(aasta, kuu, k, primaarenergia))
  =l=
  1
;
