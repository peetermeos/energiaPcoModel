********************************************************************************
**                                                                             *
** See fail sisaldab mudeli järeltöötluse arvutusloogikat                      *
**                                                                             *
** Peeter Meos                                                                 *
** Taaniel Uleksin                                                             *
********************************************************************************
* Paneme selle .l lisamise makrodes automaatselt juurde
$onDotL

$if "%jareltootlus_m2%" == "true" $goto m2


Sets
* Muutuvkulu komponendid
    mkulu        "Muutuvkulu komponent (€/MWh(el))"
                 /
                  co      "CO2 hind"
                  so      "SOx keskkonnamaksud "
                  no      "NOx keskkonnamaksud"
                  lt      "Lendtuha keskkonnamaksud"
                  jv      "Jahutusvese kulu"
                  th      "Ladestatava tuha keskkonnamaksud"
                  at      "Atmosfääri saastemaks"
                  lubkulu "Lubja kulu"
                  kilkulu "Killustiku kulu"
                  ketkulu "KET kulu"
                  logist  "Logistikakulud"
                  kythind "Kütuse hind"
                  muud    "Muud muutuvkulud"
                  kokku   "Kokku"
                 /

*Potentsiaalse kütuse hind ja kogus
    kogus_hind   "Tarnitava kütuse hind/kogus"
                 /
                  kogus
                  hind
                 /

    tarne       "Kütuse tarneallikas (kas liin või ladu)"
                /set.liinid
                 EEJ_Ladu
                 EEJ8_Ladu
                 BEJ_Ladu
                 Uhendladu
                /

   tarne_laod_tuple(tarne, l_t) "Tehtud lao laienduste kokkuliitmiseks"
                /
                 EEJ_Ladu   .(EEJ_M)
                 EEJ8_Ladu  .(EEJ8_M)
                 BEJ_Ladu   .(BEJ_M)
                 Uhendladu  .(Uhendladu_M, Uhendladu_L1,Uhendladu_l2,Uhendladu_L3)
                /

   sort "Rikastusvabriku vahepealsed tooted"
        /
        soelis
        kontsentraat
        aheraine
        /

   toode "Tootmisüksuste poolt toodetavad tooted"
         /
         Elekter
         Soojus
         SisemineSoojus
         Oli
         /

;

alias(slott, slott2);

Positive variable
**Hinnad
  kaalutud_keskmine_hind_slott(opt_paev_max, slott, t)          "Elektri kaalutud keskmine hind slotis (€/MWh(el))"
  kaalutud_keskmine_hind_paev(opt_paev_max, t)                  "Elektri kaalutud keskmine hind päevas (€/MWh(el))"
  kaalutud_keskmine_hind_kuu(aasta, kuu, t)                 "Elektri kaalutud keskmine hind kuus (€/MWh(el))"
  kaalutud_keskmine_hind_kvartal(aasta, kvartal, t)         "Elektri kaalutud keskmine hind kvartalis (€/MWh(el))"
  kaalutud_keskmine_hind_aasta(aasta, t)                    "Elektri kaalutud keskmine hind aastas (€/MWh(el))"

  kaalutud_keskmine_hind_NEJ_kuu(aasta, kuu)                "Elektri kaalutud keskmine hind NEJ-s kuus (€/MWh(el))"
  kaalutud_keskmine_hind_NEJ_kvartal(aasta, kvartal)        "Elektri kaalutud keskmine hind NEJ-s kvartalis (€/MWh(el))"
  kaalutud_keskmine_hind_NEJ_aasta(aasta)                   "Elektri kaalutud keskmine hind NEJ-s aastas (€/MWh(el))"


**Kaevandamine
  kyttevaartus_var(primaarenergia, k)                                    "Kütteväärtused (MJ/kg)"
  k_muutuvkulud_mwh(aasta, kuu, k, primaarenergia)                       "Kütuse hinnad (EUR/MWh)"

  kaeve_toodang_paev(opt_paev_max, k, primaarenergia, yhik)                  "Päevane kaevanduste ja karjääride toodang (t, MWh(küt) või EUR)"
  kaeve_toodang_kuu(aasta, kvartal, kuu, k, primaarenergia, yhik)        "Kuine kaevanduste ja karjääride toodang (t, MWh(küt) või EUR)"

  rikastus_kuus(aasta, kuu, k_rikastus, sort, yhik)                        "Rikastusvõimekuse kasutus kuus (t või MWh)"

$ontext
  kaevevoimekus_paev(opt_paev, k, primaarenergia, yhik)                  "Päevane kaevanduste ja karjääride võimekus (t, MWh(küt) või EUR)"
  kaevevoimekus_kuu(aasta, kvartal, kuu, k, primaarenergia, yhik)        "Kuine kaevanduste ja karjääride võimekus (t, MWh(küt) või EUR)"
$offtext

**Laoseisud
  alguse_laoseisud_mwh(laod, k, primaarenergia)          "Alguse laoseis primaarenergia (MWh(küt))"
$ifthen.two "%uus_logistika%" == "true"
  laoseis_kuu_lopp(aasta, kuu, l_n, k, primaarenergia)     "Kuu lõpu laoseis (t)"
$else.two
*Ühik puudu
  laoseis_kuu_lopp(aasta, kvartal, kuu, laod, k, primaarenergia, yhik)                   "Kuu lõpu laoseis (t ja MWh)"
  laoseis_kuu_lopp_agg(aasta, kvartal, kuu, laod_kokku, k, primaarenergia, yhik)         "Kuu lõpu agregeeritud laoseis (t ja MWh)"
$endif.two

**Logistika
  k_tarne_paev(opt_paev_max, k, primaarenergia, l, yhik)             "Tarne kaevandusest sihtkohta päevas (t, MWh(küt) või EUR(kaeve + logistika))"
  k_tarne_kuu(aasta, kvartal, kuu, k, primaarenergia, l, yhik)   "Tarne kaevandusest sihtkohta kuus (t, MWh(küt) või EUR(kaeve + logistika))"

  logistika_paev(opt_paev_max, liinid, yhik)                 "Liinidel transporditav kütuse hulk päevas (t või EUR(logistika)"
  logistika_kuu(aasta, kvartal, kuu, liinid, yhik)       "Liinidel transporditav kütuse hulk kuus (t või EUR(logistika)"

**Tootmine
*Toodangud
  t_toodang_slott(opt_paev_max, slott, t, toode)             "Tootmisüksuse toodang slotis (MWh(el), MWh(sj) või t(õli))"
  t_toodang_paev(opt_paev_max, t, toode)                     "Tootmisüksuse toodang päevas (MWh(el), MWh(sj) või t(õli))"
  t_toodang_kuu(aasta, kvartal, kuu, t, toode)           "Tootmisüksuse toodang kuus (MWh(el), MWh(sj) või t(õli))"
  t_toodang_teh_kuu(aasta, kvartal, kuu, tehnoloogia, t, toode)           "Tootmisüksuse toodang tehnoloogiaga kuus (MWh(el), MWh(sj) või t(õli))"

  oli_toodang_paev(opt_paev_max, t_ol, oli_toode)                     "Õli toodete müüdav toodang päevas (t(õli))"
  oli_toodang_kuu(aasta, kvartal, kuu, t_ol, oli_toode)           "Õli toodete müüdav toodang kuus (t(õli))"

  t_tootunnid_kuus(aasta, kuu, t)                        "Tootmisüksuse töötunnid kuus"
  t_remondipaevad_kuus(aasta, kuu, t)                    "Remondipäevade  arv kuus (päeva)"
  t_puhastuspaevad_kuus(aasta, kuu, t)                   "Puhastuspäevade arv kuus (päeva)"

*Kütuse kasutus
  kytuse_proportsioon_el_slott(opt_paev_max, slott, t, k, primaarenergia)            "Kütuse proportsioon tootmisüksuses (%)"

  kytuse_kasutus_slott(opt_paev_max, slott, t, toode, k, primaarenergia, yhik)           "Kütuse kasutus slotis (t(kütus) või MWh(kütus))"
  kytuse_kasutus_paev(aasta, kuu, paev, opt_paev_max, t, toode, k, primaarenergia, yhik) "Kütuse kasutus päevas (t(kütus) või MWh(kütus))"
  kytuse_kasutus_kuu(aasta, kvartal, kuu, t, toode, k, primaarenergia, yhik)             "Kütuse kasutus kuus (t(kütus) või MWh(kütus))"

  keskmine_kyttevaartus_kuu(aasta, kvartal, kuu, t)                              "Tootmisüksuses kasutatud primaarenergia keskmine kütteväärtus kuus (MWh/t)"
  keskmine_kyttevaartus_aasta(aasta, t)                                       "Tootmisüksuses kasutatud primaarenergia keskmine kütteväärtus kuus (MWh/t)"

  killustiku_kasutus_paevas(opt_paev_max, t_killustik)               "Ploki killustiku kasutus t/paev"
  killustiku_kasutus_kuus(aasta, kvartal, kuu, t_killustik)      "Ploki killustiku kasutus t/kuu"

  lubja_kasutus_paevas(opt_paev_max, t_lubi)                         "Ploki lubja kasutus t/paev"
  lubja_kasutus_kuus(aasta, kvartal, kuu, t_lubi)                "Ploki lubja kasutus t/kuu"

*Lepingu kasutus
  lepingu_kasutus_paev(lepingu_nr, opt_paev_max, k, primaarenergia, yhik)                    "Kasutatud lepingu hulk päevas (t või MWh)"
  lepingu_kasutus_kuus(lepingu_nr, aasta, kvartal, kuu, k, primaarenergia, yhik)         "Kasutatud lepingu hulk kuus (t või MWh)"

*Müük VKG-le (päev, kuu)
  myyk_paev(opt_paev_max, k, primaarenergia, t_mk, yhik)             "Müüdud kütuse hulk või müügitulu päevas (t(kütus), MWh(kütus) või EUR)"
  myyk_kuu(aasta, kvartal, kuu, k, primaarenergia, t_mk, yhik)   "Müüdud kütuse hulk või müügitulu kuus (t(kütus), MWh(kütus) või EUR)"

*Uttegaasi kasutus (slott, päev, kuu)
  uttegaasi_kasutus_slott(opt_paev_max, slott, t_el, yhik)      "Uttegaasi kasutus tootmisüksuses slotis (m3 või MWh(kütus))"
  uttegaasi_kasutus_paev(opt_paev_max, t_el, yhik)              "Uttegaasi kasutus tootmisüksuses päevas (m3 või MWh(kütus))"
  uttegaasi_kasutus_kuu(aasta, kvartal, kuu, t_el, yhik)    "Uttegaasi kasutus tootmisüksuses kuus (m3 või MWh(kütus))"

*Võimekused
  t_tootmisvoimekus_slott(opt_paev_max, slott, t, toode, yhik)     "Tootmisüksuse tootmisvõimekus slotis (MWh(küt); MWh(el), MWh(sj) või t(õli))"
  t_tootmisvoimekus_paev(opt_paev_max, t, toode, yhik)             "Tootmisüksuse tootmisvõimekus päevas (MWh(küt); MWh(el), MWh(sj) või t(õli))"
  t_tootmisvoimekus_kuu(aasta, kvartal, kuu, t, toode, yhik)   "Tootmisüksuse tootmisvõimekus kuus (MWh(küt); MWh(el), MWh(sj) või t(õli))"

*Kasutegurid ja erikulud
  keskmine_kasutegur_paev(opt_paev_max, t_el)    "Ploki keskmine kasutegur päevas (MWh(el)/MWh(kütus))"
  keskmine_kasutegur_kuu(aasta, kuu, t_el)   "Ploki keskmine kasutegur kuus (MWh(el)/MWh(kütus))"
  keskmine_kasutegur_aasta(aasta, t_el)      "Ploki keskmine kasutegur aastas (MWh(el)/MWh(kütus))"
  keskmine_erikulu_kuu(aasta, kuu, t_el)     "Ploki keskmine erikulu kuus (MWh(kütus)/MWh(el))"

*Heitmed
  heide_slotis(opt_paev_max, slott, t, toode, eh, yhik)      "Tootmisüksuse heide slotis (t(heide), m3(jahutusvesi) või EUR(soojuse aktsiisita))"
  heide_paevas(opt_paev_max, t, toode, eh, yhik)             "Tootmisüksuse heide päevas (t(heide), m3(jahutusvesi) või EUR(soojuse aktsiisita))"
  heide_kuus(aasta, kvartal, kuu, t, toode, eh, yhik)    "Tootmisüksuse heide kuus (t(heide), m3(jahutusvesi) või EUR(soojuse aktsiisita))"

*Eriheitmed
  keskmine_eriheide_paev(opt_paev_max, t, eh, toode)                 "Tootmisüksuse keskmine eriheide päevas (t(heide)/MWh(el) või m3(jahutusvesi)/MWh(el))"
  keskmine_eriheide_kuu(aasta, kuu, t, eh, toode)                "Tootmisüksuse keskmine eriheide kuus (t(heide)/MWh(el) või m3(jahutusvesi)/MWh(el))"
  keskmine_eriheide_aasta(aasta, t, eh, toode)                   "Tootmisüksuse keskmine eriheide aastas (t(heide)/MWh(el) või m3(jahutusvesi)/MWh(el))"
  keskmine_eriheide_teh_aasta(aasta, tehnoloogia, t, eh, toode)     "Tehnoloogiate keskmine eriheide aastas (t(heide)/MWh(el) või m3(jahutusvesi)/MWh(el))"

*Kulud/Kasumid
  ostetud_kytuse_keskmine_hind(opt_paev_max, k, primaarenergia)           "Lepingutega ostetud primaarenergia keskmine hind (€/t)"

  t_mkul_slott(opt_paev_max, slott, t, toode, mkulu)                 "Tootmisüksuse muutuvkulud komponentide kaupa slotis (EUR)"
  t_mkul_paev(opt_paev_max, t, toode, mkulu)                         "Tootmisüksuse muutuvkulud komponentide kaupa paevas (EUR)"
  t_mkul_kuu(aasta, kvartal, kuu, t, toode, mkulu)               "Tootmisüksuse muutuvkulud komponentide kaupa kuus (EUR)"

  t_mkul_slott_EurPerToode(opt_paev_max, slott, t, toode, mkulu)     "Tootmisüksuse muutuvkulu komponentide kaupa slotis (EUR/MWh(el), EUR/MWh(sj) või EUR/t(õli))"
  t_mkul_paev_EurPerToode(opt_paev_max, t, toode, mkulu)             "Tootmisüksuse muutuvkulu komponentide kaupa päevas (EUR/MWh(el), EUR/MWh(sj) või EUR/t(õli))"
  t_mkul_kuu_EurPerToode(aasta, kuu, t, toode, mkulu)            "Tootmisüksuse muutuvkulu komponentide kaupa kuus (EUR/MWh(el), EUR/MWh(sj) või EUR/t(õli))"
  t_mkul_kvartal_EurPerToode(aasta, kvartal, t, toode, mkulu)    "Tootmisüksuse muutuvkulu komponentide kaupa kvartalis (EUR/MWh(el), EUR/MWh(sj) või EUR/t(õli))"
  t_mkul_aasta_EurPerToode(aasta, t, toode, mkulu)               "Tootmisüksuse muutuvkulu komponentide kaupa aastas (EUR/MWh(el), EUR/MWh(sj) või EUR/t(õli))"

  t_tulu_slott(opt_paev_max, slott, t, toode)                        "Tootmisüksuse müügitulu slotis (EUR)"
  t_tulu_paev(opt_paev_max, t, toode)                                "Tootmisüksuse müügitulu päevas (EUR)"
  t_tulu_kuu(aasta, kvartal, kuu, t, toode)                      "Tootmisüksuse müügitulu kuus (EUR)"

  t_mkas_slott(opt_paev_max, slott, t, toode)                        "Tootmisüksuse muutuvkasum slotis (EUR)"
  t_mkas_paev(opt_paev_max, t, toode)                                "Tootmisüksuse muutuvkasum paevas (EUR)"
  t_mkas_kuu(aasta, kvartal, kuu, t, toode)                      "Tootmisüksuse muutuvkasum kuus (EUR)"

  t_mkas_slott_EurPerToode(opt_paev_max, slott, t, toode)            "Tootmisüksuse muutuvkasum slotis (EUR/MWh(el), EUR/MWh(sj) või EUR/t(õli))"
  t_mkas_paev_EurPerToode(opt_paev_max, t, toode)                    "Tootmisüksuse muutuvkasum paevas (EUR/MWh(el), EUR/MWh(sj) või EUR/t(õli))"
  t_mkas_kuu_EurPerToode(aasta, kuu, t, toode)                   "Tootmisüksuse muutuvkasum kuus (EUR/MWh(el), EUR/MWh(sj) või EUR/t(õli))"
  t_mkas_kvartal_EurPerToode(aasta, kvartal, t, toode)           "Tootmisüksuse muutuvkasum kvartalis (EUR/MWh(el), EUR/MWh(sj) või EUR/t(õli))"
  t_mkas_aasta_EurPerToode(aasta, t, toode)                      "Tootmisüksuse muutuvkasum aastas (EUR/MWh(el), EUR/MWh(sj) või EUR/t(õli))"

  t_mkul_teh_kuu(aasta, kvartal, kuu, tehnoloogia, t, toode, mkulu)               "Tootmisüksuse muutuvkulud komponentide kaupa kuus (EUR)"
  t_mkul_teh_kuu_EurPerToode(aasta, kuu, tehnoloogia, t, toode, mkulu)            "Tootmisüksuse muutuvkulu komponentide kaupa kuus (EUR/MWh(el), EUR/MWh(sj) või EUR/t(õli))"
  t_mkas_teh_kuu(aasta, kvartal, kuu, tehnoloogia, t, toode)                      "Tootmisüksuse muutuvkasum kuus (EUR)"
  t_mkas_teh_kuu_EurPerToode(aasta, kuu, tehnoloogia, t, toode)                   "Tootmisüksuse muutuvkasum kuus (EUR/MWh(el), EUR/MWh(sj) või EUR/t(õli))"

  t_mkul_kuu_pk_vaba_EurPerToode(aasta, kuu, t, toode)           "Tootmisüksuse muutuvkulu ilma kütuseta aastas (EUR/MWh(el), EUR/MWh(sj) või EUR/t(õli))"
  t_mkul_kuu_NEJ_EurPerToode(aasta, kuu, toode, mkulu)                        "NEJ muutuvkulud komponentide kaupa kuus (EUR/MWh(el), EUR/MWh(sj) või EUR/t(õli))"
  t_mkul_kvartal_NEJ_EurPerToode(aasta, kvartal, toode, mkulu)                        "NEJ muutuvkulud komponentide kaupa kvartalis (EUR/MWh(el), EUR/MWh(sj) või EUR/t(õli))"

$ifthen.mk "%mkul%" == "true"
  ploki_mkul_kyt_per_MWh_aasta(aasta, t_el, k, primaarenergia, l_tase, mkulu)  "Ploki muutuvkulud eri kütuste jaoks, aasta (EUR/MWh)"
$endif.mk

;

alias(uus_paev, opt_paev);
alias(uus_aasta, aasta);

$if "%jareltootlus_m1%" == "true" $goto lopp_m1
$label m2

**KAEVANDAMINE

********************************************************************************
**  Calorific values in MJ/kg                                                  *
********************************************************************************

kyttevaartus_var.l(primaarenergia, k) = kyttevaartus(primaarenergia, k) * 3.6;

********************************************************************************
**  Fuel prices in €/MWh                                                       *
********************************************************************************

k_muutuvkulud_mwh.l(aasta, kuu, k, primaarenergia)$(kyttevaartus(primaarenergia, k) > 0)
   = k_muutuvkulud(aasta, kuu, k, primaarenergia) / kyttevaartus(primaarenergia, k);

********************************************************************************
**  Mine production                                                            *
**  macro: tee_paevaks                                                         *
********************************************************************************
$ifthen.k "%kaevandused%" == "true"
kaeve_toodang_paev.l(opt_paev, k, primaarenergia, "t")
=
  sum(p2, kaeve.l(opt_paev, p2, primaarenergia, k) * rikastuskoefitsent(p2 ,k, primaarenergia))
;

kaeve_toodang_paev.l(opt_paev, k, primaarenergia, "MWh")
=
  kaeve_toodang_paev.l(opt_paev, k, primaarenergia, "t")*kyttevaartus(primaarenergia, k)
;

kaeve_toodang_paev.l(opt_paev, k, primaarenergia, "EUR")
=
  kaeve_toodang_paev.l(opt_paev, k, primaarenergia, "t")
  *sum((aasta, kuu)$tee_paevaks, k_muutuvkulud(aasta, kuu, k, primaarenergia))
;

kaeve_toodang_kuu.l(aasta, kvartal, kuu, k, primaarenergia, yhik)$kvartali_kuud(kvartal, kuu)
=
  sum(opt_paev$tee_paevaks, kaeve_toodang_paev.l(opt_paev, k, primaarenergia, yhik))
;
$endif.k

********************************************************************************
** Rikastus                                                                    *
********************************************************************************
$ifthen.k "%kaevandused%" == "true"
rikastus_kuus.l(aasta, kuu, k_rikastus, sort, "t") =
  sum((opt_paev, primaarenergia)$(tee_paevaks and sameas(sort, "soelis")), soel_p.l(opt_paev, k_rikastus, primaarenergia))
  +
  sum((opt_paev, primaarenergia)$(tee_paevaks and sameas(sort, "aheraine")), aher_p.l(opt_paev, k_rikastus, primaarenergia))
  +
  sum((opt_paev, primaarenergia)$(tee_paevaks and sameas(sort, "kontsentraat")), konts_p.l(opt_paev, k_rikastus, primaarenergia))
;

rikastus_kuus.l(aasta, kuu, k_rikastus, sort, "MWh") =
  sum((opt_paev, primaarenergia)$(tee_paevaks and sameas(sort, "soelis")), soel_p.l(opt_paev, k_rikastus, primaarenergia)*soelise_kyttevaartus(k_rikastus))
  +
  sum((opt_paev, primaarenergia)$(tee_paevaks and sameas(sort, "aheraine")), aher_p.l(opt_paev, k_rikastus, primaarenergia)*kyttevaartus("Aheraine", k_rikastus))
  +
  sum((opt_paev, primaarenergia)$(tee_paevaks and sameas(sort, "kontsentraat")), konts_p.l(opt_paev, k_rikastus, primaarenergia)*kyttevaartus("Tykikivi", k_rikastus))
;
$endif.k
**LAOSEISUD

********************************************************************************
** Alguse laoseis                                                              *
********************************************************************************

alguse_laoseisud_mwh.l(laod, k, primaarenergia) =
  alguse_laoseisud(laod, k, primaarenergia) * kyttevaartus(primaarenergia, k);


********************************************************************************
** Kuu lõpu laoseisud                                                          *
**  macro: tee_paevaks                                                         *
********************************************************************************

$ifthen.k "%logistika%" == "true"
$ifthen.two "%uus_logistika%" == "true"
laoseis_kuu_lopp.l(aasta, kuu, l_n, k, primaarenergia)
=
sum(opt_paev$tee_paevaks,
  (
  sum(lao_laiendus, laoseis(opt_paev, l_n, k, primaarenergia, lao_laiendus))
  )$(gday(jdate(esimene_aasta, esimene_kuu, 1) + ord(opt_paev) - 1 + %esimene_paev%) eq 1)
)
;
$else.two
laoseis_kuu_lopp.l(aasta, kvartal, kuu, laod, k, primaarenergia, "t")$(primaar_k(k, primaarenergia) and kvartali_kuud(kvartal, kuu))
=
sum(opt_paev$tee_paevaks,
  (
  sum(l_t$(sameas(l_t, laod)),
* Tänane laoseis
  laoseis_t(opt_paev, l_t, k, primaarenergia)$(primaar_k(k, primaarenergia))
  +
* Rongilt lattu tulnud kivi
  sum((liinid, l)$liini_otsad(liinid, k, l),
       liinilt_lattu.l(opt_paev, liinid, l_t, primaarenergia)
       $t_jp_ladu(l, l_t)
       )
  -
* Laost tootmisüksusesse läinud kivi
  sum(t, laost_tootmisse(opt_paev, l_t, t, k, primaarenergia)
      $(tootmine_ja_laod(l_t, t) and primaar_k(k, primaarenergia)))
  )
     +
  sum(l_k$(sameas(l_k, laod)),
* Tänane laoseis
  laoseis_k(opt_paev, l_k, k, primaarenergia)
   +
* Kaevandusest lattu tulnud kivi
  kaevandusest_lattu(opt_paev, l_k, k, primaarenergia)$(kaevandused_ja_laod(k, l_k) and primaar_k(k, primaarenergia))

   -
* Laost rongi peale läinud kivi, kõigile liinidele per ladu
  sum((liinid, l)$(liini_otsad(liinid, k, l)
               and kaevandused_ja_laod(k, l_k)
               and primaar_k(k, primaarenergia)),
        laost_liinile(opt_paev, l_k, liinid, primaarenergia)
        )
  )
  )$(gday(jdate(esimene_aasta, esimene_kuu, 1) + ord(opt_paev) - 1 + %esimene_paev%) eq 1)
)
;

laoseis_kuu_lopp.l(aasta, kvartal, kuu, laod, k, primaarenergia, "MWh")
=
  laoseis_kuu_lopp.l(aasta, kvartal, kuu, laod, k, primaarenergia, "t")*kyttevaartus(primaarenergia, k)
;

laoseis_kuu_lopp_agg.l(aasta, kvartal, kuu, laod_kokku, k, primaarenergia, "t")$(primaar_k(k, primaarenergia) and kvartali_kuud(kvartal, kuu))
=
sum(opt_paev$tee_paevaks,
  (
  sum((laod, l_t)$(sameas(l_t, laod) and laod_tuple(laod_kokku, laod)),
* Tänane laoseis
  laoseis_t(opt_paev, l_t, k, primaarenergia)$(primaar_k(k, primaarenergia))
  +
* Rongilt lattu tulnud kivi
  sum((liinid, l)$liini_otsad(liinid, k, l),
       liinilt_lattu(opt_paev, liinid, l_t, primaarenergia)
       $t_jp_ladu(l, l_t)
       )
  -
* Laost tootmisüksusesse läinud kivi
  sum(t, laost_tootmisse(opt_paev, l_t, t, k, primaarenergia)
      $(tootmine_ja_laod(l_t, t) and primaar_k(k, primaarenergia)))

   )
     +
  sum((laod, l_k)$(sameas(l_k, laod) and laod_tuple(laod_kokku, laod)),
* Tänane laoseis
  laoseis_k(opt_paev, l_k, k, primaarenergia)
   +
* Kaevandusest lattu tulnud kivi
  kaevandusest_lattu(opt_paev, l_k, k, primaarenergia)$(kaevandused_ja_laod(k, l_k) and primaar_k(k, primaarenergia))

   -
* Laost rongi peale läinud kivi, kõigile liinidele per ladu
  sum((liinid, l)$(liini_otsad(liinid, k, l)
               and kaevandused_ja_laod(k, l_k)
               and primaar_k(k, primaarenergia)),
        laost_liinile(opt_paev, l_k, liinid, primaarenergia)
        )
   )
  )$(gday(jdate(esimene_aasta, esimene_kuu, 1) + ord(opt_paev) - 1 + %esimene_paev%) eq 1)
)
;

laoseis_kuu_lopp_agg.l(aasta, kvartal, kuu, laod_kokku, k, primaarenergia, "mwh")$primaar_k(k, primaarenergia)
=
laoseis_kuu_lopp_agg.l(aasta, kvartal, kuu, laod_kokku, k, primaarenergia, "t")$primaar_k(k, primaarenergia) *
  kyttevaartus(primaarenergia, k);
$endif.two

$endif.k


**LOGISTIKA
$ifthen.log "%logistika%" == "true"

k_tarne_paev.l(opt_paev, k, primaarenergia, l, "t")
=
* Kaevandusest rongile
  sum(liinid, kaevandusest_liinile.l(opt_paev, liinid, primaarenergia)$(liini_otsad(liinid, k, l)))
+
* Ladudest rongile
  sum((l_k, liinid),laost_liinile.l(opt_paev, l_k, liinid, primaarenergia)$(liini_otsad(liinid, k, l) and kaevandused_ja_laod(k, l_k)))
;

k_tarne_paev.l(opt_paev, k, primaarenergia, l, "MWh")
=
  k_tarne_paev.l(opt_paev, k, primaarenergia, l, "t")*kyttevaartus(primaarenergia, k)
;

k_tarne_paev.l(opt_paev, k, primaarenergia, l, "EUR")
=
  k_tarne_paev.l(opt_paev, k, primaarenergia, l, "t")*
  sum((aasta, kuu)$tee_paevaks, k_muutuvkulud(aasta, kuu, k, primaarenergia))
;

k_tarne_kuu.l(aasta, kvartal, kuu, k, primaarenergia, l, yhik)$kvartali_kuud(kvartal, kuu)
=
  sum(opt_paev$tee_paevaks, k_tarne_paev.l(opt_paev, k, primaarenergia, l, yhik))
;

********************************************************************************
**                                                                             *
**  Logsistics                                                                 *
********************************************************************************

logistika_paev.l(opt_paev, liinid, "t")
=
   sum(primaarenergia,
       kaevandusest_liinile.l(opt_paev, liinid, primaarenergia)
      )
   +
   sum((l_k, primaarenergia),
       laost_liinile.l(opt_paev, l_k, liinid, primaarenergia)
      )
;

logistika_paev.l(opt_paev, liinid, "EUR")
=
  logistika_paev.l(opt_paev, liinid, "t")
  *
  sum((aasta, kuu)$tee_paevaks, logistikakulu(aasta, kuu, liinid))
;

logistika_kuu.l(aasta, kvartal, kuu, liinid, yhik)$kvartali_kuud(kvartal, kuu)
=
  sum(opt_paev$tee_paevaks, logistika_paev.l(opt_paev, liinid, yhik))
;
$endif.log
**TOOTMINE

*VÕIMEKUSED

********************************************************************************
**                                                                             *
**  Arvutame tootmisüksuste tehnilised tootmisvõimekused                       *
**  nii sekundaarenergias kui primaarenergias                                  *
**                                                                             *
********************************************************************************

t_tootmisvoimekus_slott.l(opt_paev, slott, t, toode, "Toode")
=
  (sum(t_el$(sameas(t_el, t)),
         sum((aasta, kuu)$tee_paevaks,
          max_koormus_el(t_el, aasta, kuu)
*         max_koormus_ty(t_el, aasta, kuu) - koorm_sj.l(opt_paev, slott, t_el)
         )
         *(1 - t_remondigraafik(opt_paev, t))
         *(1 - 0.5*t_puhastus(opt_paev, t_el))
* Õlitehaste korrektuur
         * sum((aasta, kuu)$tee_paevaks,
                 (paevi_kuus(kuu) + liigaasta(aasta)$sameas(kuu, "2")
                         - sum(t_ol$sameas(t_ol, t_el), p_paevi_kuus_ol(t_ol, aasta, kuu) + r_paevi_kuus_ol(t_ol, aasta, kuu))
                 )
                 / (paevi_kuus(kuu) + liigaasta(aasta)$sameas(kuu, "2"))
         )
  )*sloti_pikkus(opt_paev, slott, t))$sameas(toode, "Elekter")
  +
  sum(t_el$(sameas(t_el, t)),
         koorm_sj.l(opt_paev, slott, t_el)$(sameas(toode, "Soojus") and t_sj(t_el))
  +
         koorm_sj.l(opt_paev, slott, t_el)$(sameas(toode, "SisemineSoojus") and not t_sj(t_el))
  )*sloti_pikkus(opt_paev, slott, t)
  +
  (sum(t_ol$sameas(t_ol, t),
              sum((aasta, kuu)$tee_paevaks, max_koormus_ol(t_ol, aasta, kuu)
                                * tootlikkus_ol(t_ol, aasta)
* Korrigeerime remondipäevade ja puhastuspäevade arvuga
                                * (paevi_kuus(kuu) + liigaasta(aasta)$sameas(kuu, "2")
                                - p_paevi_kuus_ol(t_ol, aasta, kuu)
                                - r_paevi_kuus_ol(t_ol, aasta, kuu)
                                  )
                               / (paevi_kuus(kuu) + liigaasta(aasta)$sameas(kuu, "2")))
  )  * sloti_pikkus(opt_paev, slott, t))$sameas(toode, "Oli")
;

t_tootmisvoimekus_slott.l(opt_paev, slott, t, toode, "MWh")
=
  sum(t_el$(sameas(t_el, t)),
         t_tootmisvoimekus_slott.l(opt_paev, slott, t, toode, "Toode")
         /(sum(para_lk$(ord(para_lk) = card(para_lk)), kasutegur(t_el, para_lk, "b")))
  )$sameas(toode, "Elekter")
  +
  sum(t_el$(sameas(t_el, t) and soojuse_kasutegur(t_el) > 0),
         t_tootmisvoimekus_slott.l(opt_paev, slott, t, toode, "Toode")/soojuse_kasutegur(t_el)
  )$(sameas(toode, "Soojus") or sameas(toode, "SisemineSoojus"))
  +
  (sum((t_ol, aasta, kuu)$(sameas(t_ol, t) and tee_paevaks and tootlikkus_ol(t_ol, aasta) > 0),
* Toote tootmisvõimekus (t õli slotis)
         t_tootmisvoimekus_slott.l(opt_paev, slott, t, toode, "Toode")
* Jagades tootlikkusega saame t primaarenergiat slotis
         / tootlikkus_ol(t_ol, aasta)
* Korrutades kütteväärtusega saame primaarenergia
         * kv_oli_std
       )
  )$sameas(toode, "Oli")
;


t_tootmisvoimekus_paev.l(opt_paev, t, toode, yhik)
=
  sum(slott, t_tootmisvoimekus_slott.l(opt_paev, slott, t, toode, yhik))
;

t_tootmisvoimekus_kuu.l(aasta, kvartal, kuu, t, toode, yhik)$kvartali_kuud(kvartal, kuu)
=
  sum(opt_paev$tee_paevaks, t_tootmisvoimekus_paev.l(opt_paev, t, toode, yhik))
;

*TOODANGUD

********************************************************************************
**                                                                             *
**  Arvutame toodangu kõikidele tootmisüksustele                               *
**                                                                             *
********************************************************************************

t_toodang_slott.l(opt_paev, slott, t, toode)
=
 sum(t_el$sameas(t_el, t), koorm_el.l(opt_paev, slott, t_el)*sloti_pikkus(opt_paev, slott, t))$sameas(toode, "Elekter")
 +
 sum(t_el$(sameas(t_el, t)),
         koorm_sj.l(opt_paev, slott, t_el)$(sameas(toode, "Soojus") and t_sj(t_el))
 +
         koorm_sj.l(opt_paev, slott, t_el)$(sameas(toode, "SisemineSoojus") and not t_sj(t_el))
 ) * sloti_pikkus(opt_paev, slott, t)
 +
 (
 sum(t_ol$sameas(t_ol, t), oli(opt_paev, t_ol))
         *sloti_pikkus(opt_paev, slott, t) / sum(slott2$(sloti_pikkus(opt_paev, slott2, t) > 0), sloti_pikkus(opt_paev, slott2, t))
 )$sameas(toode, "Oli")
;

t_toodang_paev.l(opt_paev, t, toode)
=
  sum(slott, t_toodang_slott.l(opt_paev, slott, t, toode))
;

t_toodang_kuu.l(aasta, kvartal, kuu, t, toode)$kvartali_kuud(kvartal, kuu)
=
 sum(opt_paev$tee_paevaks, t_toodang_paev.l(opt_paev, t, toode))
;

t_toodang_teh_kuu.l(aasta, kvartal, kuu, tehnoloogia, t, toode)$t_tehnoloogia(tehnoloogia, t)
=
  t_toodang_kuu.l(aasta, kvartal, kuu, t, toode)
;

********************************************************************************
** Hours in production                                                         *
** macro: tee_paevaks                                                          *
********************************************************************************

t_tootunnid_kuus.l(aasta, kuu, t)
=
  sum((opt_paev, slott)$(tee_paevaks and
         (sum(t_el$sameas(t, t_el), koorm_el(opt_paev, slott, t_el)) > 0
         or
         sum(t_el$sameas(t, t_el), koorm_sj(opt_paev, slott, t_el)) > 0)
         and
         sum(t_ol$sameas(t, t_ol), oli.l(opt_paev, t_ol)) eq 0
         ),
         sloti_pikkus(opt_paev, slott, t)
  )
  +
  sum(opt_paev$(tee_paevaks and
         sum(t_ol$sameas(t, t_ol), oli.l(opt_paev, t_ol)) > 0),
         sum(slott, sloti_pikkus(opt_paev, slott, t))
     )
;

********************************************************************************
** Number of days in maintenance                                               *
** macro: tee_paevaks                                                          *
********************************************************************************

t_remondipaevad_kuus.l(aasta, kuu, t)  =
* Elektritootmisele
  (sum(opt_paev$tee_paevaks, t_remondigraafik(opt_paev, t)))$t_el(t)
  +
* Õlitootmisele
  (sum(t_ol$sameas(t, t_ol), r_paevi_kuus_ol(t_ol, aasta, kuu)))$t_ol(t)
;

********************************************************************************
** Number of days in cleaning                                                  *
** macro: tee_paevaks                                                          *
********************************************************************************

t_puhastuspaevad_kuus.l(aasta, kuu, t)
=
* Elektritootmisele
  (sum((opt_paev, t_el)$(sameas(t, t_el) and tee_paevaks), t_puhastus(opt_paev, t_el) / katelt_plokis(t_el))
  )$(t_el(t) and sum(t_el$sameas(t, t_el), katelt_plokis(t_el)) > 0)
  +
* Õlitootmisele
  (sum(t_ol$sameas(t, t_ol), p_paevi_kuus_ol(t_ol, aasta, kuu)))$t_ol(t)
;

********************************************************************************
**  Oil production                                                             *
**  macro: tee_paevaks
********************************************************************************

oli_toodang_paev.l(opt_paev, t_ol, oli_toode)
=
  oli.l(opt_paev, t_ol)*oli_toote_osakaal(t_ol, oli_toode)
;

oli_toodang_kuu.l(aasta, kvartal, kuu, t_ol, oli_toode)$kvartali_kuud(kvartal, kuu)
=
  sum(opt_paev$tee_paevaks, oli_toodang_paev(opt_paev, t_ol, oli_toode))
;

********************************************************************************
**                                                                             *
**  Arvutame kütuse proportsiooni elektriplokkides                             *
**                                                                             *
**  Taaniel Uleksin                                                            *
********************************************************************************

kytuse_proportsioon_el_slott.l(opt_paev, slott, t, k, primaarenergia)$(
  (
$ifthen.three "%katlad%" == "true"
    sum((k2, p2, t_el, katel)$sameas(t, t_el), q.l(opt_paev, slott, k2, p2, t_el, katel) *
                     sloti_pikkus(opt_paev, slott, t_el)
       )
$else.three
    sum((k2, p2, t_el)$sameas(t, t_el), q.l(opt_paev, slott, k2, p2, t_el) * sloti_pikkus(opt_paev, slott, t_el))
$endif.three
  ) > 0
)
=
  (
$ifthen.three "%katlad%" == "true"
    sum((t_el, katel)$sameas(t, t_el), q.l(opt_paev, slott, k, primaarenergia, t_el, katel) *
                     sloti_pikkus(opt_paev, slott, t_el)
       )
$else.three
    sum(t_el$sameas(t, t_el), q.l(opt_paev, slott, k, primaarenergia, t_el) * sloti_pikkus(opt_paev, slott, t_el) )
$endif.three
  )/(
$ifthen.three "%katlad%" == "true"
    sum((k2, p2, t_el, katel)$sameas(t, t_el), q.l(opt_paev, slott, k2, p2, t_el, katel) *
                     sloti_pikkus(opt_paev, slott, t_el)
       )
$else.three
    sum((k2, p2, t_el)$sameas(t, t_el), q.l(opt_paev, slott, k2, p2, t_el) * sloti_pikkus(opt_paev, slott, t_el))
$endif.three
  )
;

********************************************************************************
**                                                                             *
**  Arvutame kütuse kasutuse tootmisüksustes                                   *
**                                                                             *
********************************************************************************

kytuse_kasutus_slott.l(opt_paev, slott, t, toode, k, primaarenergia, "MWh")
=
*Elekter
$ifthen.three "%katlad%" == "true"
  sum((t_el, katel)$sameas(t, t_el), q.l(opt_paev, slott, k, primaarenergia, t_el, katel) *
                     sloti_pikkus(slott)
     )$sameas(toode, "Elekter")
$else.three
  (
    sum(t_el$sameas(t, t_el), q.l(opt_paev, slott, k, primaarenergia, t_el) * sloti_pikkus(opt_paev, slott, t_el))
  )$sameas(toode, "Elekter")
$endif.three
*Soojus
  +(
         (
                 - sum(t_el$sameas(t, t_el), koorm_sj(opt_paev, slott, t_el) * sloti_pikkus(opt_paev, slott, t_el)/soojuse_kasutegur(t_el))$sameas(toode, "Elekter")
                 + sum(t_el$(sameas(t, t_el) and t_sj(t_el)), koorm_sj(opt_paev, slott, t_el) * sloti_pikkus(opt_paev, slott, t_el)/soojuse_kasutegur(t_el))$sameas(toode, "Soojus")
                 + sum(t_el$(sameas(t, t_el) and not t_sj(t_el)), koorm_sj(opt_paev, slott, t_el) * sloti_pikkus(opt_paev, slott, t_el)/soojuse_kasutegur(t_el))$sameas(toode, "SisemineSoojus")
         ) * kytuse_proportsioon_el_slott.l(opt_paev, slott, t, k, primaarenergia)
  )$(sum(t_el$sameas(t, t_el), soojuse_kasutegur(t_el)) > 0)
*Õli
  +
  (sum(t_ol$sameas(t, t_ol),
$ifthen.three "%uus_logistika%" == "true"
         sum((l_n, k, primaarenergia, slott)$(t_log(t_ol, l_n) and primaar_k(k, primaarenergia) and (max_osakaal(k, primaarenergia, t_ol)>0) ),
                 tootmisse(opt_paev, slott, l_n, t_ol, k, primaarenergia)
                 * sloti_pikkus(opt_paev, slott, t_el)
         )
$else.three
         tootmisse(opt_paev, k, primaarenergia, t_ol)
$endif.three
         )*kyttevaartus(primaarenergia, k)
         *sloti_pikkus(opt_paev, slott, t) / sum(slott2$(sloti_pikkus(opt_paev, slott2, t) > 0), sloti_pikkus(opt_paev, slott2, t))
  )$sameas(toode, "Oli")
;

kytuse_kasutus_slott.l(opt_paev, slott, t, toode, k, primaarenergia, "t")$(
  kyttevaartus(primaarenergia, k) > 0 and not gaas(primaarenergia)
)
=
  kytuse_kasutus_slott.l(opt_paev, slott, t, toode, k, primaarenergia, "MWh")
  /kyttevaartus(primaarenergia, k)
;

kytuse_kasutus_slott.l(opt_paev, slott, t, toode, k, primaarenergia, "m3")$(
  kyttevaartus(primaarenergia, k) > 0 and gaas(primaarenergia)
)
=
  kytuse_kasutus_slott.l(opt_paev, slott, t, toode, k, primaarenergia, "MWh")
  /kyttevaartus(primaarenergia, k)
;

kytuse_kasutus_paev.l(aasta, kuu, paev, opt_paev_max, t, toode, k, primaarenergia, yhik)$(paev_kalendriks(opt_paev_max, aasta, kuu) and day_cal(opt_paev_max, paev))
=
  sum(slott, kytuse_kasutus_slott.l(opt_paev_max, slott, t, toode, k, primaarenergia, yhik))
;

kytuse_kasutus_kuu.l(aasta, kvartal, kuu, t, toode, k, primaarenergia, yhik)$kvartali_kuud(kvartal, kuu)
=
  sum((paev, opt_paev)$(tee_paevaks and day_cal(opt_paev, paev)),
         kytuse_kasutus_paev(aasta, kuu, paev, opt_paev, t, toode, k, primaarenergia, yhik))
;

********************************************************************************
**                                                                             *
**  Arvutame killustiku ja lubja kasutuse                                      *
**                                                                             *
********************************************************************************
$ifthen.two "%l_k_sees%" == "true"
killustiku_kasutus_paevas.l(opt_paev, t_killustik)
=
$ifthen.three "%katlad%" == "true"
sum((slott, katel, k_tase), s_k(opt_paev, slott, t_killustik, katel, k_tase) * sloti_pikkus(opt_paev, slott, t_killustik) * kil_tase(k_tase))
$else.three
sum((slott, k_tase), s_k(opt_paev, slott, t_killustik, k_tase) * sloti_pikkus(opt_paev, slott, t_killustik) * kil_tase(k_tase))
$endif.three
;

killustiku_kasutus_kuus.l(aasta, kvartal, kuu, t_killustik)$kvartali_kuud(kvartal, kuu)
=
sum(opt_paev$tee_paevaks, killustiku_kasutus_paevas.l(opt_paev, t_killustik))
;

lubja_kasutus_paevas.l(opt_paev, t_lubi)
=
$ifthen.three "%katlad%" == "true"
sum((slott, katel, l_tase), s_l(opt_paev, slott, t_lubi, katel ,l_tase) * sloti_pikkus(opt_paev, slott, t_lubi) * katelt_plokis(t_lubi) * lub_tase(l_tase))
$else.three
sum((slott, l_tase), s_l(opt_paev, slott, t_lubi, l_tase) * sloti_pikkus(opt_paev, slott, t_lubi) * katelt_plokis(t_lubi) * lub_tase(l_tase))
$endif.three
;

lubja_kasutus_kuus.l(aasta, kvartal, kuu, t_lubi)$kvartali_kuud(kvartal, kuu)
=
sum(opt_paev$tee_paevaks, lubja_kasutus_paevas.l(opt_paev, t_lubi))
;
$endif.two
********************************************************************************
**                                                                             *
**  Arvutame uttegaasi tarvitamise                                             *
**                                                                             *
** macro: tee_paevaks                                                          *
********************************************************************************

uttegaasi_kasutus_slott.l(opt_paev, slott, t_el, "m3")$(kyttevaartus("Uttegaas", "Hange") > 0)
=
$ifthen.three "%katlad%" == "true"
         sum(katel, q.l(opt_paev, slott, "Hange", "Uttegaas", t_el, katel) * sloti_pikkus(opt_paev, slott, t_el))
      /  kyttevaartus("Uttegaas", "Hange")
$else.three
         q.l(opt_paev, slott, "Hange", "Uttegaas", t_el) * sloti_pikkus(opt_paev, slott, t_el)
      / kyttevaartus("Uttegaas", "Hange")
$endif.three
;

uttegaasi_kasutus_slott.l(opt_paev, slott, t_el, "MWh")
=
$ifthen.three "%katlad%" == "true"
         sum(katel, q.l(opt_paev, slott, "Hange", "Uttegaas", t_el, katel) * sloti_pikkus(opt_paev, slott, t_el))
$else.three
         q.l(opt_paev, slott, "Hange", "Uttegaas", t_el) * sloti_pikkus(opt_paev, slott, t_el)
$endif.three
;

uttegaasi_kasutus_paev.l(opt_paev, t_el, yhik)
=
  sum(slott, uttegaasi_kasutus_slott(opt_paev, slott, t_el, yhik))
;

uttegaasi_kasutus_kuu.l(aasta, kvartal, kuu, t_el, yhik)$kvartali_kuud(kvartal, kuu)
=
  sum(opt_paev$tee_paevaks, uttegaasi_kasutus_paev(opt_paev, t_el, yhik))
;

********************************************************************************
** Average calorific value for oil shale                                       *
********************************************************************************

keskmine_kyttevaartus_kuu.l(aasta, kvartal, kuu, t)$(
  sum((toode, k, primaarenergia), kytuse_kasutus_kuu.l(aasta, kvartal, kuu, t, toode, k, primaarenergia, "t")) > 0
)
  =
  sum((toode, k, primaarenergia), kytuse_kasutus_kuu.l(aasta, kvartal, kuu, t, toode, k, primaarenergia, "MWh"))
  /
  sum((toode, k, primaarenergia), kytuse_kasutus_kuu.l(aasta, kvartal, kuu, t, toode, k, primaarenergia, "t"))
;

keskmine_kyttevaartus_aasta.l(aasta, t)$(
  sum((kvartal, kuu, toode, k, primaarenergia)$kvartali_kuud(kvartal, kuu), kytuse_kasutus_kuu.l(aasta, kvartal, kuu, t, toode, k, primaarenergia, "t")) > 0
)
  =
  sum((kvartal, kuu, toode, k, primaarenergia)$kvartali_kuud(kvartal, kuu), kytuse_kasutus_kuu.l(aasta, kvartal, kuu, t, toode, k, primaarenergia, "MWh"))
  /
  sum((kvartal, kuu, toode, k, primaarenergia)$kvartali_kuud(kvartal, kuu), kytuse_kasutus_kuu.l(aasta, kvartal, kuu, t, toode, k, primaarenergia, "t"))
;



********************************************************************************
** Ostetud kütus                                                               *
** macro: tee_paevaks                                                          *
********************************************************************************

$ifthen.two "%ost%" == "true"
lepingu_kasutus_paev.l(lepingu_nr, opt_paev, k, primaarenergia, "t")
  =
  kytuse_ost(lepingu_nr, opt_paev, k, primaarenergia)
;

lepingu_kasutus_paev.l(lepingu_nr, opt_paev, k, primaarenergia, "MWh")
  =
  kytuse_ost(lepingu_nr, opt_paev, k, primaarenergia)*kyttevaartus(primaarenergia, k)
;

lepingu_kasutus_paev.l(lepingu_nr, opt_paev, k, primaarenergia, "EUR")$(kyttevaartus(primaarenergia, k) > 0)
  =
* Tonnid
  kytuse_ost(lepingu_nr, opt_paev, k, primaarenergia)
* Korda kütteväärtus
  * kyttevaartus(primaarenergia, k)
* Eurot MWH kohta
  * sum((aasta, kuu)$tee_paevaks, ostuleping(lepingu_nr, aasta, kuu, k, primaarenergia, "hind"))

;


lepingu_kasutus_kuus.l(lepingu_nr, aasta, kvartal, kuu, k, primaarenergia, yhik)$kvartali_kuud(kvartal, kuu)
  =
  sum(opt_paev$tee_paevaks, lepingu_kasutus_paev(lepingu_nr, opt_paev, k, primaarenergia, yhik))
;

$endif.two

********************************************************************************
**                                                                             *
**  Fuel sales                                                                 *
** macro: tee_paevaks                                                          *
********************************************************************************


myyk_paev.l(opt_paev, k, primaarenergia, t_mk, "t")
=
  myyk.l(opt_paev, k, primaarenergia, t_mk)
;

myyk_paev.l(opt_paev, k, primaarenergia, t_mk, "MWh")
=
  myyk.l(opt_paev, k, primaarenergia, t_mk)*kyttevaartus(primaarenergia, k)
;

myyk_paev.l(opt_paev, k, primaarenergia, t_mk, "EUR")
=
  myyk.l(opt_paev, k, primaarenergia, t_mk)
  *sum((aasta, kuu)$tee_paevaks, kontsentraadi_hind(aasta))
;

myyk_kuu.l(aasta, kvartal, kuu, k, primaarenergia, t_mk, yhik)$kvartali_kuud(kvartal, kuu)
=
  sum(opt_paev$tee_paevaks, myyk_paev.l(opt_paev, k, primaarenergia, t_mk, yhik))
;


*KASUTEGURID

********************************************************************************
** Average efficiencies.                                                       *
** Efficiency = Production/Primary energy                                      *
** macro: tee_paevaks                                                          *
********************************************************************************

keskmine_kasutegur_paev.l(opt_paev, t_el)$(
         sum((aasta, kuu, paev, k, primaarenergia)$(tee_paevaks and day_cal(opt_paev, paev)), kytuse_kasutus_paev(aasta, kuu, paev, opt_paev, t_el, "Elekter", k, primaarenergia, "MWh")) > 0
)
=
  t_toodang_paev(opt_paev, t_el, "Elekter")
  /
  (sum((aasta, kuu, paev, k, primaarenergia)$(tee_paevaks and day_cal(opt_paev, paev)), kytuse_kasutus_paev(aasta, kuu, paev, opt_paev, t_el, "Elekter", k, primaarenergia, "MWh"))
  +
  uttegaasi_kasutus_paev(opt_paev, t_el, "MWh"))
;

keskmine_kasutegur_kuu.l(aasta, kuu, t_el)$(
         sum((kvartal, k, primaarenergia)$kvartali_kuud(kvartal, kuu), kytuse_kasutus_kuu(aasta, kvartal, kuu, t_el, "Elekter", k, primaarenergia, "MWh")) > 0
)
=
  sum(kvartal$kvartali_kuud(kvartal, kuu), t_toodang_kuu(aasta, kvartal, kuu, t_el, "Elekter"))
  /
  (sum((kvartal, k, primaarenergia)$kvartali_kuud(kvartal, kuu), kytuse_kasutus_kuu(aasta, kvartal, kuu, t_el, "Elekter", k, primaarenergia, "MWh"))
  +
  sum(kvartal$kvartali_kuud(kvartal, kuu), uttegaasi_kasutus_kuu(aasta, kvartal, kuu, t_el, "MWh"))
  )
;

keskmine_kasutegur_aasta.l(aasta, t_el)$(
         sum((kvartal, kuu, k, primaarenergia)$kvartali_kuud(kvartal, kuu), kytuse_kasutus_kuu(aasta, kvartal, kuu, t_el, "Elekter", k, primaarenergia, "MWh")) > 0
)
=
  sum((kvartal, kuu)$kvartali_kuud(kvartal, kuu), t_toodang_kuu(aasta, kvartal, kuu, t_el, "Elekter"))
  /
  (sum((kvartal, kuu, k, primaarenergia)$kvartali_kuud(kvartal, kuu), kytuse_kasutus_kuu(aasta, kvartal, kuu, t_el, "Elekter", k, primaarenergia, "MWh"))
  +
  sum((kvartal, kuu)$kvartali_kuud(kvartal, kuu), uttegaasi_kasutus_kuu(aasta, kvartal, kuu, t_el, "MWh"))
  )
;

keskmine_erikulu_kuu.l(aasta, kuu, t_el)$(
         keskmine_kasutegur_kuu.l(aasta, kuu, t_el) > 0
)
=
  1/keskmine_kasutegur_kuu.l(aasta, kuu, t_el)
;

*HEITMED

********************************************************************************
**                                                                             *
**  Arvutame heitmed per tootmisüksus ja segu                                  *
**  macros: eh_tase_el, eh_tase_co2, s_eh_tase_co2_u, eh_tase_jv,              *
**          tootmisse                                                          *
********************************************************************************
heide_slotis.l(opt_paev, slott, t, toode, eh, "t")
=
*Elekter
  (
         sum(t_el$sameas(t, t_el),
                 sum((k, primaarenergia)$(max_osakaal(k, primaarenergia, t_el) > 0),
                         eh_tase_el(opt_paev, slott, eh, k, primaarenergia, t_el)$(not sameas(eh, "co") and not sameas(eh, "jv"))
                         +
                         (eh_tase_co2(opt_paev, slott, k, primaarenergia, t_el))$sameas(eh, "co")
                 )
                 +
                 (eh_tase_jv(opt_paev, slott, t_el))$sameas(eh, "jv")
         ) * sloti_pikkus(opt_paev, slott, t)
  )$sameas(toode, "Elekter")
  +
*Õli
  (
         sum((k, primaarenergia, t_ol, eh_ol)$(sameas(t, t_ol) and sameas(eh, eh_ol)),
                 tootmisse(opt_paev, k, primaarenergia, t_ol) * eh_koefitsendid_ol(eh_ol, t_ol)
         )
         *sloti_pikkus(opt_paev, slott, t) / sum(slott2$(sloti_pikkus(opt_paev, slott2, t) > 0), sloti_pikkus(opt_paev, slott2, t))
  )$sameas(toode, "Oli")
;

*Heitmete jaotamine elektrile ja soojusele primaarenergia koguse järgi
heide_slotis.l(opt_paev, slott, t, toode, eh, "t")$(sameas(toode, "Soojus") or sameas(toode, "SisemineSoojus") and not sameas(eh, "jv"))
=
  heide_slotis.l(opt_paev, slott, t, "Elekter", eh, "t")
  * sum(t_el$(sameas(t, t_el) and sum((k, primaarenergia), q.l(opt_paev, slott, k, primaarenergia, t_el)) > 0),
         (
                  koorm_sj(opt_paev, slott, t_el)$(sameas(toode, "Soojus") and t_sj(t_el))
                  +
                  koorm_sj(opt_paev, slott, t_el)$(sameas(toode, "SisemineSoojus") and not t_sj(t_el))
         )
  /
  (
                 soojuse_kasutegur(t_el)
                 *
                 sum((k, primaarenergia), q.l(opt_paev, slott, k, primaarenergia, t_el))
         )
  )
;

heide_slotis.l(opt_paev, slott, t, "Elekter", eh, "t")$(not sameas(eh, "jv"))
=
  heide_slotis.l(opt_paev, slott, t, "Elekter", eh, "t")
  -
  heide_slotis.l(opt_paev, slott, t, "Soojus", eh, "t")
  -
  heide_slotis.l(opt_paev, slott, t, "SisemineSoojus", eh, "t")
;

*Heitmete kulud eurodes
heide_slotis.l(opt_paev, slott, t, toode, eh, "EUR")
=
  (heide_slotis.l(opt_paev, slott, t, toode, eh, "t")*
  sum((aasta, kuu)$tee_paevaks, eh_tariif(eh, aasta)))$(sameas(toode, "Elekter") or sameas(toode, "Soojus") or sameas(toode, "SisemineSoojus"))
  +
  (heide_slotis.l(opt_paev, slott, t, toode, eh, "t")*
  sum((aasta, kuu)$tee_paevaks, co2_referents(aasta)))$((sameas(toode, "Elekter") or sameas(toode, "Soojus") or sameas(toode, "SisemineSoojus")) and sameas(eh, "co"))
  +
  (heide_slotis.l(opt_paev, slott, t, toode, eh, "t")*
  sum((t_ol, aasta, kuu, eh_ol)$(tee_paevaks and sameas(t, t_ol) and sameas(eh, eh_ol)), eh_tariif_ol(t_ol, eh_ol, aasta)))$sameas(toode, "Oli")
  +
  (heide_slotis.l(opt_paev, slott, t, toode, eh, "t")*
  sum((aasta, kuu)$tee_paevaks, co2_referents(aasta)))$(sameas(toode, "Oli") and sameas(eh, "co"))

;

heide_paevas.l(opt_paev, t, toode, eh, yhik) = sum(slott, heide_slotis.l(opt_paev, slott, t, toode, eh, yhik));
heide_kuus.l(aasta, kvartal, kuu, t, toode, eh, yhik)$kvartali_kuud(kvartal, kuu) = sum(opt_paev, heide_paevas.l(opt_paev, t, toode, eh, yhik)$paev_kalendriks(opt_paev, aasta, kuu));

********************************************************************************
** Emission intensities                                                        *
** Emission intensity = Emission/Production                                    *
** macros: tee_paevaks
********************************************************************************

keskmine_eriheide_paev.l(opt_paev, t, eh, toode)$(
         t_toodang_paev(opt_paev, t, toode) > 0
)
 =
  heide_paevas.l(opt_paev, t, toode, eh, "t")
  /
  t_toodang_paev(opt_paev, t, toode)
;

keskmine_eriheide_kuu.l(aasta, kuu, t, eh, toode)$(
         sum(kvartal$kvartali_kuud(kvartal, kuu), t_toodang_kuu.l(aasta, kvartal, kuu, t, toode)) > 0
)
=
  sum(kvartal$kvartali_kuud(kvartal, kuu), heide_kuus.l(aasta, kvartal, kuu, t, toode, eh, "t"))
  /
  sum(kvartal$kvartali_kuud(kvartal, kuu), t_toodang_kuu.l(aasta, kvartal, kuu, t, toode))
;

keskmine_eriheide_aasta.l(aasta, t, eh, toode)$(
         sum((kvartal, kuu)$kvartali_kuud(kvartal, kuu), t_toodang_kuu.l(aasta, kvartal, kuu, t, toode)) > 0
)
=
  sum((kvartal, kuu)$kvartali_kuud(kvartal, kuu), heide_kuus.l(aasta, kvartal, kuu, t, toode, eh, "t"))
  /
  sum((kvartal, kuu)$kvartali_kuud(kvartal, kuu), t_toodang_kuu.l(aasta, kvartal, kuu, t, toode))
;

keskmine_eriheide_teh_aasta.l(aasta, tehnoloogia, t, eh, toode)$t_tehnoloogia(tehnoloogia, t)
=
  keskmine_eriheide_aasta.l(aasta, t, eh, toode)
;

*KULUD/KASUMID

********************************************************************************
**  Average price for imported fuels                                           *
********************************************************************************
$ifthen "%ost%" == "true"
ostetud_kytuse_keskmine_hind.l(opt_paev, k, primaarenergia)$(
  sum((lepingu_nr, opt_paev2)$(ord(opt_paev) ge ord(opt_paev2)), lepingu_kasutus_paev(lepingu_nr, opt_paev, k, primaarenergia, "t")) > 0
)
=
  sum((lepingu_nr, opt_paev2)$(ord(opt_paev) ge ord(opt_paev2)), lepingu_kasutus_paev(lepingu_nr, opt_paev, k, primaarenergia, "EUR"))
  /
  sum((lepingu_nr, opt_paev2)$(ord(opt_paev) ge ord(opt_paev2)), lepingu_kasutus_paev(lepingu_nr, opt_paev, k, primaarenergia, "t"))
;
$endif

********************************************************************************
**  Variable cost calculation for all production units                         *
**                                                                             *
**  macros: tee_paevaks                                                        *
********************************************************************************

t_mkul_slott.l(opt_paev, slott, t, toode, mkulu)
=
*Kulud heitmetele
  sum(eh$sameas(mkulu, eh), heide_slotis.l(opt_paev, slott, t, toode, eh, "EUR"))
*KET
  +
  (
         sum((aasta, kuu)$tee_paevaks, t_ket_kulu(aasta, kuu, t))
         * sum((k, primaarenergia), kytuse_kasutus_slott(opt_paev, slott, t, toode, k, primaarenergia, "t"))
  )$sameas(mkulu, "ketkulu")
*Logistika
  +
  sum((k, primaarenergia),
         sum((aasta, kuu, liinid, l)$(tee_paevaks and liini_otsad(liinid, k, l) and t_jp_tootmine(l, t)), logistikakulu(aasta, kuu, liinid))
         * kytuse_kasutus_slott(opt_paev, slott, t, toode, k, primaarenergia, "t")
  )$sameas(mkulu, "logist")
*Kütuse kulu
  +
  sum((k, primaarenergia),
         (
         sum((aasta, kuu)$tee_paevaks, k_muutuvkulud(aasta, kuu, k, primaarenergia))
$ifthen "%ost%" == "true"
                 +
                 ostetud_kytuse_keskmine_hind(opt_paev, k, primaarenergia)
$endif
         )
         * kytuse_kasutus_slott(opt_paev, slott, t, toode, k, primaarenergia, "t")
  )$sameas(mkulu, "kythind")
*Lubi
  +
  (sum(t_lubi$sameas(t, t_lubi),
         koorm_el(opt_paev, slott, t_lubi) * sloti_pikkus(opt_paev, slott, t_lubi)
         * lime_consumption(t_lubi)
         * sum((aasta, kuu)$tee_paevaks, lubja_hind(aasta)/1000))$(sameas(mkulu, "lubkulu"))
  )$sameas(toode, "Elekter")
*Muud kulud
  +
  (
        sum((aasta, kuu, t_el)$(tee_paevaks and sameas(t_el, t) and sameas(toode, "Elekter")), el_muud_kulud(aasta, kuu, t_el))  *t_toodang_slott(opt_paev, slott, t, "Elekter")
        +
        sum((aasta, kuu, t_sj)$(tee_paevaks and sameas(t_sj, t) and sameas(toode, "Soojus")), soojuse_muud_kulud(aasta, kuu, t_sj)) *t_toodang_slott(opt_paev, slott, t, "Soojus")
        +
        sum((aasta, kuu, t_el)$(tee_paevaks and sameas(t_el, t) and not t_sj(t_el) and sameas(toode, "SisemineSoojus")), soojuse_muud_kulud(aasta, kuu, t_el)) *t_toodang_slott(opt_paev, slott, t, "SisemineSoojus")
        +
        sum((aasta, kuu, t_ol)$(tee_paevaks and sameas(t_ol, t) and sameas(toode, "Oli")), oil_muud_kulud(aasta, kuu, t_ol)) *t_toodang_slott(opt_paev, slott, t, "Oli")
  )$sameas(mkulu, "muud")
;

t_mkul_slott.l(opt_paev, slott, t, toode, "kokku")
=
  sum(mkulu$(not sameas(mkulu, "kokku")), t_mkul_slott.l(opt_paev, slott, t, toode, mkulu))
;

t_mkul_paev.l(opt_paev, t, toode, mkulu)
=
  sum(slott, t_mkul_slott.l(opt_paev, slott, t, toode, mkulu))
;

t_mkul_kuu.l(aasta, kvartal, kuu, t, toode, mkulu)$kvartali_kuud(kvartal, kuu)
=
  sum(opt_paev$tee_paevaks, t_mkul_paev.l(opt_paev, t, toode, mkulu))
;

t_mkul_slott_EurPerToode.l(opt_paev, slott, t, toode, mkulu)$(
         t_toodang_slott(opt_paev, slott, t, toode) > 0
)
=
  t_mkul_slott.l(opt_paev, slott, t, toode, mkulu)
  /
  t_toodang_slott(opt_paev, slott, t, toode)
;

t_mkul_paev_EurPerToode.l(opt_paev, t, toode, mkulu)$(
  t_toodang_paev(opt_paev, t, toode) > 0
         )
=
  t_mkul_paev.l(opt_paev, t, toode, mkulu)
  /
  t_toodang_paev(opt_paev, t, toode)
;

t_mkul_kuu_EurPerToode.l(aasta, kuu, t, toode, mkulu)$(
  sum(kvartal$kvartali_kuud(kvartal, kuu), t_toodang_kuu(aasta, kvartal, kuu, t, toode)) > 0
)
=
  sum(kvartal$kvartali_kuud(kvartal, kuu), t_mkul_kuu.l(aasta, kvartal, kuu, t, toode, mkulu))
  /
  sum(kvartal$kvartali_kuud(kvartal, kuu), t_toodang_kuu(aasta, kvartal, kuu, t, toode))
;

t_mkul_kvartal_EurPerToode.l(aasta, kvartal, t, toode, mkulu)$(
  sum(kuu$kvartali_kuud(kvartal, kuu), t_toodang_kuu(aasta, kvartal, kuu, t, toode)) > 0
)
=
  sum(kuu$kvartali_kuud(kvartal, kuu), t_mkul_kuu.l(aasta, kvartal, kuu, t, toode, mkulu))
  /
  sum(kuu$kvartali_kuud(kvartal, kuu), t_toodang_kuu(aasta, kvartal, kuu, t, toode))
;

t_mkul_aasta_EurPerToode.l(aasta, t, toode, mkulu)$(
  sum((kvartal, kuu)$kvartali_kuud(kvartal, kuu), t_toodang_kuu(aasta, kvartal, kuu, t, toode)) > 0
)
=
  sum((kvartal, kuu)$kvartali_kuud(kvartal, kuu), t_mkul_kuu.l(aasta, kvartal, kuu, t, toode, mkulu))
  /
  sum((kvartal, kuu)$kvartali_kuud(kvartal, kuu), t_toodang_kuu(aasta, kvartal, kuu, t, toode))
;

t_mkul_kuu_NEJ_EurPerToode.l(aasta, kuu, toode, mkulu)$(
  sum((kvartal, t)$kvartali_kuud(kvartal, kuu), t_toodang_kuu(aasta, kvartal, kuu, t, toode)) > 0
)
=
  sum((kvartal, t)$kvartali_kuud(kvartal, kuu), t_mkul_kuu.l(aasta, kvartal, kuu, t, toode, mkulu))
  /
  sum((kvartal, t)$kvartali_kuud(kvartal, kuu), t_toodang_kuu(aasta, kvartal, kuu, t, toode))
;

t_mkul_kvartal_NEJ_EurPerToode.l(aasta, kvartal, toode, mkulu)$(
  sum((kuu, t)$kvartali_kuud(kvartal, kuu), t_toodang_kuu(aasta, kvartal, kuu, t, toode)) > 0
)
=
  sum((kuu, t)$kvartali_kuud(kvartal, kuu), t_mkul_kuu.l(aasta, kvartal, kuu, t, toode, mkulu))
  /
  sum((kuu, t)$kvartali_kuud(kvartal, kuu), t_toodang_kuu(aasta, kvartal, kuu, t, toode))
;

********************************************************************************
** Profit from sales                                                           *
** profit = price*production                                                   *
** macro: tee_paevaks                                                          *
********************************************************************************
t_tulu_slott.l(opt_paev, slott, t, toode)
=
  t_toodang_slott(opt_paev, slott, t, toode)*
  (
         (sum((aasta, kuu, opt_tund)$(sloti_tunnid(slott, opt_tund) and tee_paevaks),
                 elektri_referents(aasta, kuu, opt_paev, opt_tund)
         )/sloti_pikkus_orig(slott))$sameas(toode, "Elekter")
         +
         sum((aasta, kuu)$tee_paevaks, oli_referents(aasta, kuu))$sameas(toode, "Oli")
         +
         sum((aasta, kuu)$tee_paevaks, soojuse_referents(aasta, kuu))$sameas(toode, "Soojus")
     )
;

t_tulu_paev.l(opt_paev, t, toode)
=
  sum(slott, t_tulu_slott.l(opt_paev, slott, t, toode))
;

t_tulu_kuu.l(aasta, kvartal, kuu, t, toode)$kvartali_kuud(kvartal, kuu)
=
  sum(opt_paev$tee_paevaks, t_tulu_paev.l(opt_paev, t, toode))
;

**HINNAD

********************************************************************************
**  Weighted average electricity prices                                        *
**  macro: tee_paevaks                                                         *
********************************************************************************

kaalutud_keskmine_hind_slott.l(opt_paev, slott, t)$(
         t_toodang_slott.l(opt_paev, slott, t, "Elekter") > 0
)
=
  t_tulu_slott.l(opt_paev, slott, t, "Elekter")
  /
  t_toodang_slott.l(opt_paev, slott, t, "Elekter")
;

kaalutud_keskmine_hind_paev.l(opt_paev, t)$(
         t_toodang_paev.l(opt_paev, t, "Elekter") > 0
)
=
  t_tulu_paev.l(opt_paev, t, "Elekter")
/
  t_toodang_paev.l(opt_paev, t, "Elekter")
;

kaalutud_keskmine_hind_kuu.l(aasta, kuu, t)
=
  sum(toode$(
         sum(kvartal$kvartali_kuud(kvartal, kuu), t_toodang_kuu.l(aasta, kvartal, kuu, t, toode)) > 0
         ),
         sum(kvartal$kvartali_kuud(kvartal, kuu), t_tulu_kuu.l(aasta, kvartal, kuu, t, toode))
         /
         sum(kvartal$kvartali_kuud(kvartal, kuu), t_toodang_kuu.l(aasta, kvartal, kuu, t, toode))
  )
*  (oli_referents(aasta, kuu))$(sum(kvartal$kvartali_kuud(kvartal, kuu), t_toodang_kuu.l(aasta, kvartal, kuu, t, "Oli")) > 0)
;

kaalutud_keskmine_hind_kvartal.l(aasta, kvartal, t)
=
  sum(toode$(
         sum(kuu$kvartali_kuud(kvartal, kuu), t_toodang_kuu.l(aasta, kvartal, kuu, t, toode)) > 0
         ),
         sum(kuu$kvartali_kuud(kvartal, kuu), t_tulu_kuu.l(aasta, kvartal, kuu, t, toode))
         /
         sum(kuu$kvartali_kuud(kvartal, kuu), t_toodang_kuu.l(aasta, kvartal, kuu, t, toode))
  )
;


kaalutud_keskmine_hind_aasta.l(aasta, t)
=
  sum(toode$(
         sum((kvartal, kuu)$kvartali_kuud(kvartal, kuu), t_toodang_kuu.l(aasta, kvartal, kuu, t, toode)) > 0
         ),
         sum((kvartal, kuu)$kvartali_kuud(kvartal, kuu), t_tulu_kuu.l(aasta, kvartal, kuu, t, toode))
         /
         sum((kvartal, kuu)$kvartali_kuud(kvartal, kuu), t_toodang_kuu.l(aasta, kvartal, kuu, t, toode))
  )
;

kaalutud_keskmine_hind_NEJ_kuu.l(aasta, kuu)$(
         sum((kvartal, t)$kvartali_kuud(kvartal, kuu), t_toodang_kuu.l(aasta, kvartal, kuu, t, "Elekter")) > 0
  )
=
  sum((kvartal, t)$kvartali_kuud(kvartal, kuu), t_tulu_kuu.l(aasta, kvartal, kuu, t, "Elekter"))
  /
  sum((kvartal, t)$kvartali_kuud(kvartal, kuu), t_toodang_kuu.l(aasta, kvartal, kuu, t, "Elekter"))
;

kaalutud_keskmine_hind_NEJ_kvartal.l(aasta, kvartal)$(
         sum((kuu, t)$kvartali_kuud(kvartal, kuu), t_toodang_kuu.l(aasta, kvartal, kuu, t, "Elekter")) > 0
  )
=
  sum((kuu, t)$kvartali_kuud(kvartal, kuu), t_tulu_kuu.l(aasta, kvartal, kuu, t, "Elekter"))
  /
  sum((kuu, t)$kvartali_kuud(kvartal, kuu), t_toodang_kuu.l(aasta, kvartal, kuu, t, "Elekter"))
;

kaalutud_keskmine_hind_NEJ_aasta.l(aasta)$(
         sum((kvartal, kuu, t)$kvartali_kuud(kvartal, kuu), t_toodang_kuu.l(aasta, kvartal, kuu, t, "Elekter")) > 0
  )
=
  sum((kvartal, kuu, t)$kvartali_kuud(kvartal, kuu), t_tulu_kuu.l(aasta, kvartal, kuu, t, "Elekter"))
  /
  sum((kvartal, kuu, t)$kvartali_kuud(kvartal, kuu), t_toodang_kuu.l(aasta, kvartal, kuu, t, "Elekter"))
;

********************************************************************************
** Variable profit                                                             *
********************************************************************************

t_mkas_slott.l(opt_paev, slott, t, toode)
=
  t_tulu_slott.l(opt_paev, slott, t, toode)
  -
  t_mkul_slott.l(opt_paev, slott, t, toode, "kokku")
;

t_mkas_paev.l(opt_paev, t, toode)
=
  sum(slott, t_mkas_slott.l(opt_paev, slott, t, toode))
;

t_mkas_kuu.l(aasta, kvartal, kuu, t, toode)$kvartali_kuud(kvartal, kuu)
=
  sum(opt_paev$tee_paevaks, t_mkas_paev.l(opt_paev, t, toode))
;


t_mkas_slott_EurPerToode.l(opt_paev, slott, t, toode)$(
  t_toodang_slott.l(opt_paev, slott, t, toode) > 0
)
=
  t_mkas_slott.l(opt_paev, slott, t, toode)
  /
  t_toodang_slott.l(opt_paev, slott, t, toode)
;

t_mkas_paev_EurPerToode.l(opt_paev, t, toode)$(
  t_toodang_paev.l(opt_paev, t, toode) > 0
         )
=
  t_mkas_paev.l(opt_paev, t, toode)
  /
  t_toodang_paev.l(opt_paev, t, toode)
;

t_mkas_kuu_EurPerToode.l(aasta, kuu, t, toode)$(
  sum(kvartal$kvartali_kuud(kvartal, kuu), t_toodang_kuu.l(aasta, kvartal, kuu, t, toode)) > 0
)
=
  sum(kvartal$kvartali_kuud(kvartal, kuu), t_mkas_kuu.l(aasta, kvartal, kuu, t, toode))
  /
  sum(kvartal$kvartali_kuud(kvartal, kuu), t_toodang_kuu.l(aasta, kvartal, kuu, t, toode))
;

t_mkas_kvartal_EurPerToode.l(aasta, kvartal, t, toode)$(
  sum(kuu$kvartali_kuud(kvartal, kuu), t_toodang_kuu.l(aasta, kvartal, kuu, t, toode)) > 0
)
=
  sum(kuu$kvartali_kuud(kvartal, kuu), t_mkas_kuu.l(aasta, kvartal, kuu, t, toode))
  /
  sum(kuu$kvartali_kuud(kvartal, kuu), t_toodang_kuu.l(aasta, kvartal, kuu, t, toode))
;

t_mkas_aasta_EurPerToode.l(aasta, t, toode)$(
  sum((kvartal, kuu)$kvartali_kuud(kvartal, kuu), t_toodang_kuu(aasta, kvartal, kuu, t, toode)) > 0
)
=
  sum((kvartal, kuu)$kvartali_kuud(kvartal, kuu), t_mkas_kuu.l(aasta, kvartal, kuu, t, toode))
  /
  sum((kvartal, kuu)$kvartali_kuud(kvartal, kuu), t_toodang_kuu(aasta, kvartal, kuu, t, toode))
;

********************************************************************************
** Tootmisüksuse muutuvkulu ilma kütuseta                                      *
********************************************************************************

t_mkul_kuu_pk_vaba_EurPerToode.l(aasta, kuu, t, toode)
=
  t_mkul_kuu_EurPerToode.l(aasta, kuu, t, toode, "kokku")
  -
  t_mkul_kuu_EurPerToode.l(aasta, kuu, t, toode, "kythind")
;

********************************************************************************
** Muutuvkulud ja muutuvkasumid tehnoloogiate lõikes                           *
********************************************************************************

t_mkul_teh_kuu.l(aasta, kvartal, kuu, tehnoloogia, t, toode, mkulu)$t_tehnoloogia(tehnoloogia, t)
=
  t_mkul_kuu(aasta, kvartal, kuu, t, toode, mkulu)
;

t_mkul_teh_kuu_EurPerToode.l(aasta, kuu, tehnoloogia, t, toode, mkulu)$t_tehnoloogia(tehnoloogia, t)
=
  t_mkul_kuu_EurPerToode(aasta, kuu, t, toode, mkulu)
;

t_mkas_teh_kuu.l(aasta, kvartal, kuu, tehnoloogia, t, toode)$t_tehnoloogia(tehnoloogia, t)
=
  t_mkas_kuu(aasta, kvartal, kuu, t, toode)
;

t_mkas_teh_kuu_EurPerToode.l(aasta, kuu, tehnoloogia, t, toode)$t_tehnoloogia(tehnoloogia, t)
=
  t_mkas_kuu_EurPerToode(aasta, kuu, t, toode)
;

********************************************************************************
* Ploki muutuvkulud erinevatele kütustele                                      *
* Taaniel Uleksin                                                              *
********************************************************************************
$ifthen.mk "%mkul%" == "true"

$ontext
                  co      "CO2 hind"
                  so      "SOx keskkonnamaksud "
                  no      "NOx keskkonnamaksud"
                  lt      "Lendtuha keskkonnamaksud"
                  jv      "Jahutusvese kulu"
                  th      "Ladestatava tuha keskkonnamaksud"
                  at      "Atmosfääri saastemaks"
                  lubkulu "Lubja kulu"
                  kilkulu "Killustiku kulu"
                  ketkulu "KET kulu"
                  logist  "Logistikakulud"
                  kythind "Kütuse hind"
                  muud    "Muud muutuvkulud"
                  kokku   "Kokku"
$offtext

ploki_mkul_kyt_per_MWh_aasta.l(aasta, t_el, k, primaarenergia, l_tase, "co")$(not t_ol(t_el) and max_osakaal(k, primaarenergia, t_el) > 0)
=
   3.6 / 1000 * eh_co2(primaarenergia) * 0.999 * 44.01 / 12
   * co2_referents(aasta)
;

ploki_mkul_kyt_per_MWh_aasta.l(aasta, t_el, k, primaarenergia, l_tase, mkulu)$(not t_ol(t_el) and max_osakaal(k, primaarenergia, t_el) > 0)
=
  sum(eh$sameas(mkulu, eh),
         (
                 sum(para_lk, t_sg_m3 * hh_koef(eh, t_el, k, primaarenergia, para_lk))
                  / sum(para_lk$(card(para_lk) = ord(para_lk)), kasutegur(t_el, para_lk, "b"))
         )$(sameas(eh, "so") or sameas(eh, "no"))
         +
         (
                 sum(para_lk$(ord(para_lk) = card(para_lk)), eh_koef(eh, t_el, k, primaarenergia, para_lk, "0"))
                  /
                 sum(para_lk$(card(para_lk) = ord(para_lk)), kasutegur(t_el, para_lk, "b"))
         )$(not sameas(eh, "so") and not sameas(eh, "no"))
         * mootemaaramatus
         * eh_tariif(eh, aasta)
  )
;

ploki_mkul_kyt_per_MWh_aasta.l(aasta, t_el, k, primaarenergia, l_tase, "lubkulu")$(sum(kuu, max_koormus_el(t_el, aasta, kuu)) > 0 and not t_ol(t_el) and max_osakaal(k, primaarenergia, t_el) > 0)
=
  110*lub_tase(l_tase)/(sum(kuu, max_koormus_el(t_el, aasta, kuu))/12)
;

***** 10 *****
ploki_mkul_kyt_per_MWh_aasta.l(aasta, t_el, k, primaarenergia, l_tase, "ketkulu")$(not t_ol(t_el) and max_osakaal(k, primaarenergia, t_el) > 0)
=
sum(kuu$(kyttevaartus(primaarenergia, k) > 0 and kasutegur_kuus(aasta, kuu, t_el) > 0),
         t_ket_kulu(aasta, kuu, t_el)
         /(kasutegur_kuus(aasta, kuu, t_el))
         / kyttevaartus(primaarenergia, k)
         )/sum(kuu$(kasutegur_kuus(aasta, kuu, t_el) > 0), 1)
;


ploki_mkul_kyt_per_MWh_aasta.l(aasta, t_el, k, primaarenergia, l_tase, "logist")$(not t_ol(t_el) and max_osakaal(k, primaarenergia, t_el) > 0)
=
sum(kuu$(kyttevaartus(primaarenergia, k) > 0 and kasutegur_kuus(aasta, kuu, t_el) > 0),
$ifthen.two "%uus_logistika%" == "true"
*PUUDU - logistikakulu agregeerimine
0
$else.two
     sum((liinid, l),logistikakulu(aasta, kuu, liinid)$(liini_otsad(liinid, k, l) and t_jp_tootmine(l, t_el)))
$endif.two
     /kasutegur_kuus(aasta, kuu, t_el)
     /kyttevaartus(primaarenergia, k))
     /sum(kuu$(kasutegur_kuus(aasta, kuu, t_el) > 0), 1)
;

ploki_mkul_kyt_per_MWh_aasta.l(aasta, t_el, k, primaarenergia, l_tase, "kythind")$(not t_ol(t_el)
                                                                       and kyttevaartus(primaarenergia, k) > 0
                                                   and max_osakaal(k, primaarenergia, t_el) > 0)
=
sum(kuu$(kasutegur_kuus(aasta, kuu, t_el) > 0),
         k_muutuvkulud(aasta, k, primaarenergia) /(kasutegur_kuus(aasta, kuu, t_el))
                                                 / kyttevaartus(primaarenergia, k)
   ) / sum(kuu$(kasutegur_kuus(aasta, kuu, t_el) > 0), 1)
;

ploki_mkul_kyt_per_MWh_aasta.l(aasta, t_el, k, primaarenergia, k_tase, l_tase, "muud")$(not t_ol(t_el)
                                                   and max_osakaal(k, primaarenergia, t_el) > 0)
=
  sum(kuu$(kasutegur_kuus(aasta, kuu, t_el) > 0), el_muud_kulud(aasta, kuu, t_el))
  / sum(kuu$(kasutegur_kuus(aasta, kuu, t_el) > 0), 1)
;

ploki_mkul_kyt_per_MWh_aasta.l(aasta, t_el, k, primaarenergia, k_tase, l_tase, "kokku")$(not t_ol(t_el))
=
  sum(mkulu$(not sameas("kokku", mkulu)),
ploki_mkul_kyt_per_MWh_aasta.l(aasta, t_el, k, primaarenergia, k_tase, l_tase, mkulu)
)
;

$endif.mk

$label lopp_m1
$offDotL
