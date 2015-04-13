********************************************************************************
**                                                                             *
** Post-processing calculations. Mostly aggregations.                          *
**                                                                             *
** Peeter Meos                                                                 *
** Taaniel Uleksin                                                             *
********************************************************************************
* Paneme selle .l lisamise makrodes automaatselt juurde
$onDotL

$if "%jareltootlus_m2%" == "true" $goto m2


Sets
* Components of variable costs
    vc        "Variable cost component (�/MWh(el))"
                 /
                  co      "CO2 hind"
                  so      "SOx keskkonnamaksud "
                  no      "NOx keskkonnamaksud"
                  lt      "Lendtuha keskkonnamaksud"
                  jv      "Jahutusvese kulu"
                  th      "Ladestatava tuha keskkonnamaksud"
                  at      "Atmosf��ri saastemaks"
                  lubkulu "Lubja kulu"
                  kilkulu "Killustiku kulu"
                  ketkulu "KET kulu"
                  logist  "Logistikakulud"
                  kythind "K�tuse hind"
                  muud    "Muud muutuvkulud"
                  kokku   "Kokku"
                 /

*Potentsiaalse k�tuse hind ja kogus
    kogus_hind   "Tarnitava k�tuse hind/kogus"
                 /
                  kogus
                  hind
                 /

    tarne       "K�tuse tarneallikas (kas liin v�i ladu)"
                /set.route
                 EEJ_Ladu
                 EEJ8_Ladu
                 BEJ_Ladu
                 Uhendladu
                /

   tarne_laod_tuple(tarne, s_t) "Tehtud lao laienduste kokkuliitmiseks"
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

   product "Tootmis�ksuste poolt toodetavad tooted"
         /
         Elekter
         Soojus
         SisemineSoojus
         Oil
         /

;

alias(slot, slott2);

Positive variable
**Hinnad
  weightavg_price_slot(sim, time_t, slot, t)                    "Elektri kaalutud keskmine hind slotis (�/MWh(el))"
  weightavg_price_day(sim, time_t, t)                           "Elektri kaalutud keskmine hind p�evas (�/MWh(el))"
  weightavg_price_month(sim, year, month, t)                    "Elektri kaalutud keskmine hind kuus (�/MWh(el))"
  weightavg_price_quarter(sim, year, quarter, t)                "Elektri kaalutud keskmine hind kvartalis (�/MWh(el))"
  weightavg_price_year(sim, year, t)                            "Elektri kaalutud keskmine hind aastas (�/MWh(el))"

  weightavg_price_NEJ_month(sim, year, month)                    "Elektri kaalutud keskmine hind NEJ-s kuus (�/MWh(el))"
  weightavg_price_NEJ_quarter(sim, year, quarter)                "Elektri kaalutud keskmine hind NEJ-s kvartalis (�/MWh(el))"
  weightavg_price_NEJ_year(sim, year)                            "Elektri kaalutud keskmine hind NEJ-s aastas (�/MWh(el))"

**Kaevandamine
  cv_var(feedstock, k)                                 "K�ttev��rtused (MJ/kg)"
  k_varcost_mwh(year, k, feedstock)                   "K�tuse hinnad (EUR/MWh)"

  mine_production_day(sim, time_t, k, feedstock, unit)             "P�evane kaevanduste ja karj��ride toodang (t, MWh(k�t) v�i EUR)"
  mine_production_month(sim, year, quarter, month, k, feedstock, unit)"Kuine kaevanduste ja karj��ride toodang (t, MWh(k�t) v�i EUR)"

  enrichment_month(year, month, k_enrichment, sort, unit)           "Rikastusv�imekuse kasutus kuus (t v�i MWh)"

$ontext
  kaevevoimekus_paev(time_t, k, feedstock, unit)                 "P�evane kaevanduste ja karj��ride v�imekus (t, MWh(k�t) v�i EUR)"
  kaevevoimekus_kuu(year, quarter, month, k, feedstock, unit)    "Kuine kaevanduste ja karj��ride v�imekus (t, MWh(k�t) v�i EUR)"
$offtext

**Laoseisud
  start_storage_mwh(storage, k, feedstock)                    "Alguse laoseis feedstock (MWh(k�t))"

*�hik puudu
  storage_month(sim, year, quarter, month, storage, k, feedstock, unit)        "Kuu l�pu laoseis (t ja MWh)"
  storage_agg_month(sim, year, quarter, month, storage_agg, k, feedstock, unit)"Kuu l�pu agregeeritud laoseis (t ja MWh)"

**Logistika
  k_delivery_day(sim, time_t, k, feedstock, l, unit)              "Tarne kaevandusest sihtkohta p�evas (t, MWh(k�t) v�i EUR(kaeve + logistika))"
  k_delivery_month (sim, year, quarter, month, k, feedstock, l, unit) "Tarne kaevandusest sihtkohta kuus (t, MWh(k�t) v�i EUR(kaeve + logistika))"

  logistics_day(sim, time_t, route, unit)                      "Liinidel transporditav k�tuse hulk p�evas (t v�i EUR(logistika)"
  logistics_month(sim, year, quarter, month, route, unit)      "Liinidel transporditav k�tuse hulk kuus (t v�i EUR(logistika)"

  production(sim, time_t, t)                                   "Flow into production (t)"

**Tootmine
*Toodangud
  t_production_slot(sim, time_t, slot, t, product)                     "Tootmis�ksuse toodang slotis (MWh(el), MWh(sj) v�i t(�li))"
  t_production_day(sim, time_t, t, product)                            "Tootmis�ksuse toodang p�evas (MWh(el), MWh(sj) v�i t(�li))"
  t_production_month(sim, year, quarter, month, t, product)            "Tootmis�ksuse toodang kuus (MWh(el), MWh(sj) v�i t(�li))"
  t_production_tech_month(sim, year, quarter, month, tech, t, product) "Tootmis�ksuse toodang tehnoloogiaga kuus (MWh(el), MWh(sj) v�i t(�li))"

  ol_production_day(sim, time_t, t_ol, ol_product)                "�li toodete m��dav toodang p�evas (t(�li))"
  ol_production_month(sim, year, quarter, month, t_ol, ol_product)   "�li toodete m��dav toodang kuus (t(�li))"

  t_productionhours_month(sim, year, month, t)                         "Tootmis�ksuse t��tunnid kuus"
  t_repair_month(sim, year, month, t)                     "Remondip�evade arv kuus (p�eva)"
  t_maintenance_month(sim, year, month, t)                    "Puhastusp�evade arv kuus (p�eva)"

*K�tuse kasutus
  kytuse_proportsioon_el_slott(sim, time_t, slot, t, k, feedstock) "K�tuse proportsioon tootmis�ksuses (%)"

  fuel_consumption_slot(sim, time_t, slot, t, product, k, feedstock, unit)            "K�tuse kasutus slotis (t(k�tus) v�i MWh(k�tus))"
  fuel_consumption_day(sim, year, month, day, time_t, t, product, k, feedstock, unit) "K�tuse kasutus p�evas (t(k�tus) v�i MWh(k�tus))"
  fuel_consumption_month(sim, year, quarter, month, t, product, k, feedstock, unit)      "K�tuse kasutus kuus (t(k�tus) v�i MWh(k�tus))"

  avg_cv_month(sim, year, quarter, month, t)                          "Tootmis�ksuses kasutatud feedstock keskmine k�ttev��rtus kuus (MWh/t)"
  avg_cv_year(sim, year, t)                                        "Tootmis�ksuses kasutatud feedstock keskmine k�ttev��rtus kuus (MWh/t)"

  killustiku_kasutus_paevas(sim, time_t, t_cl)                                     "Ploki killustiku kasutus t/paev"
  killustiku_kasutus_kuus(sim, year, quarter, month, t_cl)                         "Ploki killustiku kasutus t/kuu"

  lubja_kasutus_paevas(sim, time_t, t_lime)                                        "Ploki lubja kasutus t/paev"
  lubja_kasutus_kuus(sim, year, quarter, month, t_lime)                            "Ploki lubja kasutus t/kuu"

*Lepingu kasutus
  contracts_inuse_day(sim, serial, time_t, k, feedstock, unit)                    "Kasutatud lepingu hulk p�evas (t v�i MWh)"
  contracts_inuse_month(sim, serial, year, quarter, month, k, feedstock, unit)      "Kasutatud lepingu hulk kuus (t v�i MWh)"

*M��k VKG-le (p�ev, month)
  myyk_paev(sim, time_t, k, feedstock, t_mk, unit)             "M��dud k�tuse hulk v�i m��gitulu p�evas (t(k�tus), MWh(k�tus) v�i EUR)"
  myyk_kuu(sim, year, quarter, month, k, feedstock, t_mk, unit)"M��dud k�tuse hulk v�i m��gitulu kuus (t(k�tus), MWh(k�tus) v�i EUR)"

*Uttegaasi kasutus (slot, p�ev, month)
  retortgas_usage_slot(sim, time_t, slot, t_el, unit)      "Uttegaasi kasutus tootmis�ksuses slotis (m3 v�i MWh(k�tus))"
  retortgas_usage_day(sim, time_t, t_el, unit)             "Uttegaasi kasutus tootmis�ksuses p�evas (m3 v�i MWh(k�tus))"
  retortgas_usage_month(sim, year, quarter, month, t_el, unit)"Uttegaasi kasutus tootmis�ksuses kuus (m3 v�i MWh(k�tus))"

*V�imekused
  t_productioncapacity_slot(sim, time_t, slot, t, product, unit)      "Tootmis�ksuse tootmisv�imekus slotis (MWh(k�t); MWh(el), MWh(sj) v�i t(�li))"
  t_productioncapacity_day(sim, time_t, t, product, unit)             "Tootmis�ksuse tootmisv�imekus p�evas (MWh(k�t); MWh(el), MWh(sj) v�i t(�li))"
  t_productioncapacity_month(sim, year, quarter, month, t, product, unit)"Tootmis�ksuse tootmisv�imekus kuus (MWh(k�t); MWh(el), MWh(sj) v�i t(�li))"

*Kasutegurid ja erikulud
  avg_efficiency_day(sim, time_t, t_el)    "Ploki keskmine kasutegur p�evas (MWh(el)/MWh(k�tus))"
  avg_efficiency_month(sim, year, month, t_el)"Ploki keskmine kasutegur kuus (MWh(el)/MWh(k�tus))"
  avg_efficiency_year(sim, year, t_el)     "Ploki keskmine kasutegur aastas (MWh(el)/MWh(k�tus))"
  avg_special_consumption_month(sim, year, month, t_el)  "Ploki keskmine erikulu kuus (MWh(k�tus)/MWh(el))"

*Heitmed
  heide_fs_slotis(sim, time_t, slot, t, k, feedstock, product, em, unit)       "Tootmis�ksuse heide slotis k�tuse kaupa (t(heide), m3(jahutusvesi) v�i EUR(soojuse aktsiisita))"
  emission_slot(sim, time_t, slot, t, product, em, unit)       "Tootmis�ksuse heide slotis (t(heide), m3(jahutusvesi) v�i EUR(soojuse aktsiisita))"
  emission_day(sim, time_t, t, product, em, unit)             "Tootmis�ksuse heide p�evas (t(heide), m3(jahutusvesi) v�i EUR(soojuse aktsiisita))"
  emission_month(sim, year, quarter, month, t, product, em, unit) "Tootmis�ksuse heide kuus (t(heide), m3(jahutusvesi) v�i EUR(soojuse aktsiisita))"

*Eriheitmed
  avg_specific_emission_day(sim, time_t, t, em, product)         "Tootmis�ksuse keskmine eriheide p�evas (t(heide)/MWh(el) v�i m3(jahutusvesi)/MWh(el))"
  avg_specific_emission_month(sim, year, month, t, em, product)     "Tootmis�ksuse keskmine eriheide kuus (t(heide)/MWh(el) v�i m3(jahutusvesi)/MWh(el))"
  avg_specific_emission_year(sim, year, t, em, product)          "Tootmis�ksuse keskmine eriheide aastas (t(heide)/MWh(el) v�i m3(jahutusvesi)/MWh(el))"
  avg_specific_emission_tech_year(sim, year, tech, t, em, product)"Tehnoloogiate keskmine eriheide aastas (t(heide)/MWh(el) v�i m3(jahutusvesi)/MWh(el))"

*Kulud/Kasumid
  ostetud_kytuse_keskmine_hind(sim, time_t, k, feedstock)   "Lepingutega ostetud feedstock keskmine hind (�/t)"

  t_varcost_slot(sim, time_t, slot, t, product, vc)             "Tootmis�ksuse muutuvkulud komponentide kaupa slotis (EUR)"
  t_varcost_day(sim, time_t, t, product, vc)                    "Tootmis�ksuse muutuvkulud komponentide kaupa paevas (EUR)"
  t_varcost_month(sim, year, quarter, month, t, product, vc)       "Tootmis�ksuse muutuvkulud komponentide kaupa kuus (EUR)"

  t_mkul_fs_slott(sim, time_t, slot, t, k, feedstock, product, vc)             "Tootmis�ksuse muutuvkulud komponentide kaupa k�tustele slotis (EUR)"
  t_mkul_fs_paev(sim, time_t, t, k, feedstock, product, vc)                    "Tootmis�ksuse muutuvkulud komponentide kaupa k�tustele p�evas (EUR)"
  t_mkul_fs_kuu(sim, year, quarter, month, t, k, feedstock, product, vc)       "Tootmis�ksuse muutuvkulud komponentide kaupa k�tustele kuus (EUR)"

  t_varcost_perunit_slot(sim, time_t, slot, t, product, vc) "Tootmis�ksuse muutuvkulu komponentide kaupa slotis (EUR/MWh(el), EUR/MWh(sj) v�i EUR/t(�li))"
  t_varcost_perunit_day(sim, time_t, t, product, vc)        "Tootmis�ksuse muutuvkulu komponentide kaupa p�evas (EUR/MWh(el), EUR/MWh(sj) v�i EUR/t(�li))"
  t_varcost_perunit_month(sim, year, month, t, product, vc)    "Tootmis�ksuse muutuvkulu komponentide kaupa kuus (EUR/MWh(el), EUR/MWh(sj) v�i EUR/t(�li))"
  t_varcost_perunit_quarter(sim, year, quarter, t, product, vc)"Tootmis�ksuse muutuvkulu komponentide kaupa kvartalis (EUR/MWh(el), EUR/MWh(sj) v�i EUR/t(�li))"
  t_varcost_perunit_year(sim, year, t, product, vc)         "Tootmis�ksuse muutuvkulu komponentide kaupa aastas (EUR/MWh(el), EUR/MWh(sj) v�i EUR/t(�li))"

  t_sales_slot(sim, time_t, slot, t, product)                 "Tootmis�ksuse m��gitulu slotis (EUR)"
  t_sales_day(sim, time_t, t, product)                        "Tootmis�ksuse m��gitulu p�evas (EUR)"
  t_sales_month(sim, year, quarter, month, t, product)           "Tootmis�ksuse m��gitulu kuus (EUR)"

  t_mkas_fs_slott(sim, time_t, slot, t, k, feedstock, product)       "Tootmis�ksuse muutuvkasum k�tuse kohta slotis (EUR)"
  t_mkas_fs_paev(sim, time_t, t, k, feedstock, product)              "Tootmis�ksuse muutuvkasum k�tuse kohta paevas (EUR)"
  t_mkas_fs_kuu(sim, year, quarter, month, t, k, feedstock, product) "Tootmis�ksuse muutuvkasum k�tuse kohta kuus (EUR)"

  t_contribution_slot(sim, time_t, slot, t, product)                 "Tootmis�ksuse muutuvkasum slotis (EUR)"
  t_contribution_day(sim, time_t, t, product)                        "Tootmis�ksuse muutuvkasum paevas (EUR)"
  t_contribution_month(sim, year, quarter, month, t, product)           "Tootmis�ksuse muutuvkasum kuus (EUR)"

  t_contribution_margin_slot(sim, time_t, slot, t, product)     "Tootmis�ksuse muutuvkasum slotis (EUR/MWh(el), EUR/MWh(sj) v�i EUR/t(�li))"
  t_contribution_margin_day(sim, time_t, t, product)            "Tootmis�ksuse muutuvkasum paevas (EUR/MWh(el), EUR/MWh(sj) v�i EUR/t(�li))"
  t_contribution_margin_month(sim, year, month, t, product)        "Tootmis�ksuse muutuvkasum kuus (EUR/MWh(el), EUR/MWh(sj) v�i EUR/t(�li))"
  t_contribution_margin_quarter(sim, year, quarter, t, product)  "Tootmis�ksuse muutuvkasum kvartalis (EUR/MWh(el), EUR/MWh(sj) v�i EUR/t(�li))"
  t_contribution_margin_year(sim, year, t, product)             "Tootmis�ksuse muutuvkasum aastas (EUR/MWh(el), EUR/MWh(sj) v�i EUR/t(�li))"

  t_varcost_tech_month(sim, year, quarter, month, tech, t, product, vc)   "Tootmis�ksuse muutuvkulud komponentide kaupa kuus (EUR)"
  t_varcost_perunit_tech_month(sim, year, month, tech, t, product, vc)"Tootmis�ksuse muutuvkulu komponentide kaupa kuus (EUR/MWh(el), EUR/MWh(sj) v�i EUR/t(�li))"
  t_contribution_tech_month(sim, year, quarter, month, tech, t, product)       "Tootmis�ksuse muutuvkasum kuus (EUR)"
  t_contribution_margin_tech_month(sim, year, month, tech, t, product)    "Tootmis�ksuse muutuvkasum kuus (EUR/MWh(el), EUR/MWh(sj) v�i EUR/t(�li))"

  t_varcost_perunit_wofuel_month(sim, year, month, t, product)      "Tootmis�ksuse muutuvkulu ilma k�tuseta aastas (EUR/MWh(el), EUR/MWh(sj) v�i EUR/t(�li))"
  t_varcost_perunit_NEJ_month(sim, year, month, product, vc)         "NEJ muutuvkulud komponentide kaupa kuus (EUR/MWh(el), EUR/MWh(sj) v�i EUR/t(�li))"
  t_varcost_perunit_NEJ_quarter(sim, year, quarter, product, vc)   "NEJ muutuvkulud komponentide kaupa kvartalis (EUR/MWh(el), EUR/MWh(sj) v�i EUR/t(�li))"

$ifthen.mk "%mkul%" == "true"
  ploki_mkul_kyt_per_MWh_aasta(sim, year, t_el, k, feedstock, route, l_level, vc)  "Ploki muutuvkulud eri k�tuste jaoks, year (EUR/MWh)"
$endif.mk

;

alias(uus_paev, time_t);
alias(uus_aasta, year);

$if "%jareltootlus_m1%" == "true" $goto lopp_m1
$label m2

**KAEVANDAMINE

********************************************************************************
**  Calorific values in MJ/kg                                                  *
********************************************************************************

cv_var.l(feedstock, k) = cv(feedstock, k, "MJ");

********************************************************************************
**  Fuel prices in �/MWh                                                       *
********************************************************************************

k_varcost_mwh.l(year, k, feedstock)$(fs_k(k, feedstock) and cv(feedstock, k, "MWh") > 0)
   = fs_vc(k, feedstock, year) / cv(feedstock, k, "MWh");

********************************************************************************
**  Mine production                                                            *
**  macro: y_m_t                                                               *
********************************************************************************
$ifthen.k "%mines%" == "true"
mine_production_day.l(sim, time_t, k, feedstock, "t")$fs_k(k, feedstock)
=
  sum(p2, fs_mined.l(time_t, p2, feedstock, k) * enrichment_coef(p2 ,k, feedstock))$(not sameas(k, "Hange"))
  +
  fs_acqd_l(sim, time_t, feedstock)$(sameas(k, "Hange"))
;

mine_production_day.l(sim, time_t, k, feedstock, "MWh")$fs_k(k, feedstock)
=
  mine_production_day.l(sim, time_t, k, feedstock, "t") * cv(feedstock, k, "MWh")
;

mine_production_day.l(sim, time_t, k, feedstock, "EUR")$fs_k(k, feedstock)
=
  mine_production_day.l(sim, time_t, k, feedstock, "t")
  *sum((year, month)$y_m_t, fs_vc(k, feedstock, year))
;

mine_production_month.l(sim, year, quarter, month, k, feedstock, unit)$(fs_k(k, feedstock) and q_months(quarter, month))
=
  sum(time_t$y_m_t, mine_production_day.l(sim, time_t, k, feedstock, unit))
;
$endif.k

********************************************************************************
** Enrichment                                                                  *
********************************************************************************
$ifthen.k "%mines%" == "true"
enrichment_month.l(year, month, k_enrichment, sort, "t") =
  sum((time_t, feedstock)$(y_m_t and sameas(sort, "soelis")),
               sieve_p.l(time_t, k_enrichment, feedstock))
  +
  sum((time_t, feedstock)$(y_m_t and sameas(sort, "aheraine")),
               tailings_p.l(time_t, k_enrichment, feedstock))
  +
  sum((time_t, feedstock)$(y_m_t and sameas(sort, "kontsentraat")),
               cont_p.l(time_t, k_enrichment, feedstock))
;

enrichment_month.l(year, month, k_enrichment, sort, "MWh") =
  sum((time_t, feedstock)$(y_m_t and sameas(sort, "soelis")),
                sieve_p.l(time_t, k_enrichment, feedstock)
              * sieve_cv(k_enrichment))
  +
  sum((time_t, feedstock)$(y_m_t and sameas(sort, "aheraine")),
                tailings_p.l(time_t, k_enrichment, feedstock)
              * cv("Aheraine", k_enrichment, "MWh"))
  +
  sum((time_t, feedstock)$(y_m_t and sameas(sort, "kontsentraat")),
                cont_p.l(time_t, k_enrichment, feedstock)
              * cv("Tykikivi", k_enrichment, "MWh"))
;
$endif.k
**STORAGE

********************************************************************************
** Initial storage levels                                                      *
********************************************************************************

start_storage_mwh.l(storage, k, feedstock)$fs_k(k, feedstock) =
  initial_storage(storage, k, feedstock) * cv(feedstock, k, "MWh");


********************************************************************************
** End of month storage levels                                                 *
**  macro: y_m_t                                                               *
********************************************************************************

$ifthen.k "%logistics%" == "true"

storage_month.l(sim, year, quarter, month, storage, k, feedstock, "t")$(fs_k(k, feedstock) and q_months(quarter, month))
=
sum(time_t$y_m_t,
  (
  sum(s_t$(sameas(s_t, storage)),
* T�nane laoseis
  storage_t_l(sim, time_t, s_t, k, feedstock)$(fs_k(k, feedstock))
  +
* Rongilt lattu tulnud kivi
  sum((route, l)$route_endpoint(route, k, l),
       logs_to_storage_l(sim, time_t, route, s_t, feedstock)
       $t_dp_storage(l, s_t)
       )
  -
* Laost tootmis�ksusesse l�inud kivi
  sum(t, storage_to_production_l(sim, time_t, s_t, t, k, feedstock)
      $(prod_storage(s_t, t) and fs_k(k, feedstock)))
  )
     +
  sum(s_k$(sameas(s_k, storage)),
* T�nane laoseis
  storage_k_l(sim, time_t, s_k, k, feedstock)
   +
* Kaevandusest lattu tulnud kivi
  mine_to_storage_l(sim, time_t, s_k, k, feedstock)$(mine_storage(k, s_k) and fs_k(k, feedstock))

   -
* Laost rongi peale l�inud kivi, k�igile liinidele per ladu
  sum((route, l)$(route_endpoint(route, k, l)
               and mine_storage(k, s_k)
               and fs_k(k, feedstock)),
        storage_to_logs_l(sim, time_t, s_k, route, feedstock)
        )
  )
  )$(gday(jdate(%beg_year%, %beg_month%, 1) + ord(time_t) - 1) eq days_in_month_l(year, month) or days_in_month_l(year, month) = 1)
)
;

storage_month.l(sim, year, quarter, month, storage, k, feedstock, "MWh")$fs_k(k, feedstock)
=
  storage_month.l(sim, year, quarter, month, storage, k, feedstock, "t") * cv(feedstock, k, "MWh")
;

storage_agg_month.l(sim, year, quarter, month, storage_agg, k, feedstock, "t")$(fs_k(k, feedstock) and q_months(quarter, month))
=
sum(time_t$y_m_t,
  (
  sum((storage, s_t)$(sameas(s_t, storage) and storage_tuple(storage_agg, storage)),
* T�nane laoseis
  storage_t_l(sim, time_t, s_t, k, feedstock)$(fs_k(k, feedstock))
  +
* Rongilt lattu tulnud kivi
  sum((route, l)$route_endpoint(route, k, l),
       logs_to_storage_l(sim, time_t, route, s_t, feedstock)
       $t_dp_storage(l, s_t)
       )
  -
* Laost tootmis�ksusesse l�inud kivi
  sum(t, storage_to_production_l(sim, time_t, s_t, t, k, feedstock)
      $(prod_storage(s_t, t) and fs_k(k, feedstock)))

   )
     +
  sum((storage, s_k)$(sameas(s_k, storage) and storage_tuple(storage_agg, storage)),
* T�nane laoseis
  storage_k_l(sim, time_t, s_k, k, feedstock)
   +
* Kaevandusest lattu tulnud kivi
  mine_to_storage_l(sim, time_t, s_k, k, feedstock)$(mine_storage(k, s_k) and fs_k(k, feedstock))

   -
* Laost rongi peale l�inud kivi, k�igile liinidele per ladu
  sum((route, l)$(route_endpoint(route, k, l)
               and mine_storage(k, s_k)
               and fs_k(k, feedstock)),
        storage_to_logs_l(sim, time_t, s_k, route, feedstock)
        )
   )
  )$(gday(jdate(%beg_year%, %beg_month%, 1) + ord(time_t) - 1) eq days_in_month_l(year, month) or days_in_month_l(year, month) = 1)
)
;

storage_agg_month.l(sim, year, quarter, month, storage_agg, k, feedstock, "mwh")$fs_k(k, feedstock)
=
storage_agg_month.l(sim, year, quarter, month, storage_agg, k, feedstock, "t")$fs_k(k, feedstock) *
  cv(feedstock, k, "MWh");
$endif.k


**LOGISTICS
$ifthen.log "%logistics%" == "true"

k_delivery_day.l(sim, time_t, k, feedstock, l, "t")$fs_k(k, feedstock)
=
* Kaevandusest rongile
  sum(route, mine_to_logs_l(sim, time_t, route, feedstock)$(route_endpoint(route, k, l)))
+
* Ladudest rongile
  sum((s_k, route), storage_to_logs_l(sim, time_t, s_k, route, feedstock)$(route_endpoint(route, k, l) and mine_storage(k, s_k)))
;

k_delivery_day.l(sim, time_t, k, feedstock, l, "MWh")$fs_k(k, feedstock)
=
  k_delivery_day.l(sim, time_t, k, feedstock, l, "t") * cv(feedstock, k, "MWh")
;

k_delivery_day.l(sim, time_t, k, feedstock, l, "EUR")$fs_k(k, feedstock)
=
  k_delivery_day.l(sim, time_t, k, feedstock, l, "t")*
  sum((year, month)$y_m_t, fs_vc(k, feedstock, year))
;

k_delivery_month.l(sim, year, quarter, month, k, feedstock, l, unit)$(fs_k(k, feedstock) and q_months(quarter, month))
=
  sum(time_t$y_m_t, k_delivery_day.l(sim, time_t, k, feedstock, l, unit))
;

********************************************************************************
**                                                                             *
**  Logsistics                                                                 *
********************************************************************************

logistics_day.l(sim, time_t, route, "t")
=
   sum(feedstock,
       mine_to_logs_l(sim, time_t, route, feedstock)
      )
   +
   sum((s_k, feedstock),
       storage_to_logs_l(sim, time_t, s_k, route, feedstock)
      )
;

logistics_day.l(sim, time_t, route, "EUR")
=
  logistics_day.l(sim, time_t, route, "t")
  *
  sum((year, month)$y_m_t, log_vc(route, year))
;

logistics_month.l(sim, year, quarter, month, route, unit)$q_months(quarter, month)
=
  sum(time_t$y_m_t, logistics_day.l(sim, time_t, route, unit))
;

*production.l(sim, time_t, t)
*=
*   sum((k ,feedstock), to_production_s(sim, time_t, k, feedstock, t))
*;

$endif.log
**TOOTMINE

********************************************************************************
** Number of days in cleaning                                                  *
** macro: y_m_t                                                                *
********************************************************************************

t_maintenance_month.l(sim, year, month, t)
=
* Elektritootmisele
  (
  trunc(
    sum((time_t, t_el)$(sameas(t, t_el)
                   and y_m_t
                   and not t_tech("CFB", t_el)
                   and not sameas(t_el, "Katlamaja")
                   ),
                sum(slot, slot_length_orig(time_t, slot, t_el) - t_mx_schedule(time_t, slot, t_el))
    )
    / 24 / 7
  ) / 2
  )$t_el(t)
  +
* �litootmisele
  (sum(t_ol$sameas(t, t_ol), p_days_month_oil(t_ol, year, month)))$t_ol(t)
;

*V�IMEKUSED

********************************************************************************
**                                                                             *
**  Arvutame tootmis�ksuste tehnilised tootmisv�imekused                       *
**  nii sekundaarenergias kui primaarenergias                                  *
**                                                                             *
********************************************************************************

t_productioncapacity_slot.l(sim, time_t, slot, t, product, "Toode")
=
  (sum(t_el$(sameas(t_el, t)),
         sum((year, month)$y_m_t,
            max_load_el_s(sim, t_el, year, month) * slot_length_s(sim, time_t, slot, t_el)
*         min( max_load_el_s(sim, t_el, year, month),
*              (max_load_pu(t_el, year, month) - load_ht_l(sim, time_t, slot, t_el)))
         )
**         *(1 - t_mx_schedule(time_t, slot, t))
*         * (1 - cleaning_coeff * t_cleaning(time_t, t_el))
  ) )$sameas(product, "Elekter")
  +
  sum(t_el$(sameas(t_el, t)),
         load_ht_l(sim, time_t, slot, t_el)$(sameas(product, "Soojus") and t_ht(t_el))
  +
         load_ht_l(sim, time_t, slot, t_el)$(sameas(product, "SisemineSoojus") and not t_ht(t_el))
  ) * slot_length_s(sim, time_t, slot, t)
  +
  (sum(t_ol$sameas(t_ol, t),
              sum((year, month)$y_m_t, max_load_ol_s(sim, t_ol, year, month)
  ) * (slot_length_orig(time_t, slot, t_ol) / sum(slot2, slot_length_orig(time_t, slot2, t_ol) ))
  ))$sameas(product, "oil")
;

t_productioncapacity_slot.l(sim, time_t, slot, t, product, "MWh")
=
  sum(t_el$(sameas(t_el, t)),
         t_productioncapacity_slot.l(sim, time_t, slot, t, product, "Toode")
         /(sum(para_lk$(ord(para_lk) = card(para_lk)), efficiency(t_el, para_lk, "b")))
  )$sameas(product, "Elekter")
  +
  sum(t_el$(sameas(t_el, t) and ht_efficiency(t_el) > 0),
         t_productioncapacity_slot.l(sim, time_t, slot, t, product, "Toode")/ht_efficiency(t_el)
  )$(sameas(product, "Soojus") or sameas(product, "SisemineSoojus"))
  +
  (sum((t_ol, year, month)$(sameas(t_ol, t) and y_m_t and yield_oil(t_ol, year) > 0),
* Toote tootmisv�imekus (t �li slotis)
         t_productioncapacity_slot.l(sim, time_t, slot, t, product, "Toode")
* Jagades tootlikkusega saame t primaarenergiat slotis
         / yield_oil(t_ol, year)
* Korrutades k�ttev��rtusega saame feedstock
         * st_oil_cv
       )
  )$sameas(product, "oil")
;


t_productioncapacity_day.l(sim, time_t, t, product, unit)
=
  sum(slot, t_productioncapacity_slot.l(sim, time_t, slot, t, product, unit))
;

t_productioncapacity_month.l(sim, year, quarter, month, t, product, unit)$q_months(quarter, month)
=
  sum(time_t$y_m_t, t_productioncapacity_day.l(sim, time_t, t, product, unit))
  -
  (
     t_maintenance_month(sim, year, month, t)
   * 24 * (1 - failure_s(sim, t, year))
   * sum(t_el$sameas(t_el, t), max_load_el_s(sim, t_el, year, month))

  )$(t_el(t) and not t_ol(t)
             and not t_tech("CFB", t)
             and (sameas(unit, "Toode") or sameas(unit, "MWh"))
             and sameas(product, "Elekter")

    )
;

*TOODANGUD

********************************************************************************
**                                                                             *
**  Arvutame toodangu k�ikidele tootmis�ksustele                               *
**                                                                             *
********************************************************************************

t_production_slot.l(sim, time_t, slot, t, product)
=
 sum(t_el$sameas(t_el, t), load_el_l(sim, time_t, slot, t_el) * slot_length_s(sim, time_t, slot, t))$sameas(product, "Elekter")
 +
 sum(t_el$(sameas(t_el, t)),
         load_ht_l(sim, time_t, slot, t_el)$(sameas(product, "Soojus") and t_ht(t_el))
 +
         load_ht_l(sim, time_t, slot, t_el)$(sameas(product, "SisemineSoojus") and not t_ht(t_el))
 ) * slot_length_s(sim, time_t, slot, t)
 +
 (
 sum(t_ol$sameas(t_ol, t), oil_l(sim, time_t, t_ol))
         * slot_length_s(sim, time_t, slot, t)
         / (1$(slot_length_s(sim, time_t, slot, t) = 0)
            + sum(slott2$(slot_length_s(sim, time_t, slott2, t) > 0), slot_length_s(sim, time_t, slott2, t)))
 )$sameas(product, "oil")
;

t_production_day.l(sim, time_t, t, product)
=
  sum(slot, t_production_slot.l(sim, time_t, slot, t, product))
;

t_production_month.l(sim, year, quarter, month, t, product)$q_months(quarter, month)
=
 sum(time_t$y_m_t, t_production_day.l(sim, time_t, t, product))
;

t_production_tech_month.l(sim, year, quarter, month, tech, t, product)$t_tech(tech, t)
=
  t_production_month.l(sim, year, quarter, month, t, product)
;

********************************************************************************
** Hours in production                                                         *
** macro: y_m_t                                                          *
********************************************************************************

t_productionhours_month.l(sim, year, month, t)
=
  sum((time_t, slot)$(y_m_t and
         (sum(t_el$sameas(t, t_el), load_el_l(sim, time_t, slot, t_el)) > 0
         or
         sum(t_el$sameas(t, t_el), load_ht_l(sim, time_t, slot, t_el)) > 0)
         and
         sum(t_ol$sameas(t, t_ol), oil_l(sim, time_t, t_ol)) eq 0
         ),
         slot_length_s(sim, time_t, slot, t)
  )
  +
  sum(time_t$(y_m_t and
         sum(t_ol$sameas(t, t_ol), oil_l(sim, time_t, t_ol)) > 0),
         sum(slot, slot_length_s(sim, time_t, slot, t))
     )
;

********************************************************************************
** Number of days in maintenance                                               *
** macro: y_m_t                                                                *
********************************************************************************

t_repair_month.l(sim, year, month, t)  =
* Elektritootmisele
  (sum((time_t, slot)$y_m_t, t_mx_schedule(time_t, slot, t)) / 24)$t_el(t)
  +
* �litootmisele
  (sum(t_ol$sameas(t, t_ol), r_days_month_oil(t_ol, year, month)))$t_ol(t)
;


********************************************************************************
**  Oil production                                                             *
**  macro: y_m_t                                                               *
********************************************************************************

ol_production_day.l(sim, time_t, t_ol, ol_product)
=
  oil_l(sim, time_t, t_ol) * oil_prod_prop(t_ol, ol_product)
;

ol_production_month.l(sim, year, quarter, month, t_ol, ol_product)$q_months(quarter, month)
=
  sum(time_t$y_m_t, ol_production_day(sim, time_t, t_ol, ol_product))
;

********************************************************************************
**                                                                             *
**  Arvutame k�tuse proportsiooni elektriplokkides                             *
**                                                                             *
**  Taaniel Uleksin                                                            *
********************************************************************************

kytuse_proportsioon_el_slott.l(sim, time_t, slot, t, k, feedstock)$(
  (
$ifthen.three "%katlad%" == "true"
    sum((k2, p2, t_el, katel)$sameas(t, t_el), q.l(sim, time_t, slot, k2, p2, t_el, katel) *
                     slot_length(sim, time_t, slot, t_el)
       )
$else.three
    sum((k2, p2, t_el)$sameas(t, t_el), q_s(sim, time_t, slot, k2, p2, t_el) * slot_length_s(sim, time_t, slot, t_el))
$endif.three
  ) > 0
)
=
  (
$ifthen.three "%katlad%" == "true"
    sum((t_el, katel)$sameas(t, t_el), q_s(sim, time_t, slot, k, feedstock, t_el, katel) *
                     slot_length_s(sim, time_t, slot, t_el)
       )
$else.three
    sum(t_el$sameas(t, t_el), q_s(sim, time_t, slot, k, feedstock, t_el) * slot_length_s(sim, time_t, slot, t_el) )
$endif.three
  )/(
$ifthen.three "%katlad%" == "true"
    sum((k2, p2, t_el, katel)$sameas(t, t_el), q_s(sim, time_t, slot, k2, p2, t_el, katel) *
                     slot_length_s(sim, time_t, slot, t_el)
       )
$else.three
    sum((k2, p2, t_el)$sameas(t, t_el), q_s(sim, time_t, slot, k2, p2, t_el) * slot_length_s(sim, time_t, slot, t_el))
$endif.three
  )
;

********************************************************************************
**                                                                             *
**  Arvutame k�tuse kasutuse tootmis�ksustes                                   *
**                                                                             *
********************************************************************************

fuel_consumption_slot.l(sim, time_t, slot, t, product, k, feedstock, "MWh")$(cv(feedstock, k, "MWh") > 0 and max_ratio(k, feedstock, t) > 0)
=
*Elekter
  (
    sum(t_el$sameas(t, t_el), q_s(sim, time_t, slot, k, feedstock, t_el) * slot_length_s(sim, time_t, slot, t_el))
  )$sameas(product, "Elekter")
*Soojus
  +(
         (
                 - sum(t_el$sameas(t, t_el), load_ht_l(sim, time_t, slot, t_el) * slot_length_s(sim, time_t, slot, t_el)/ht_efficiency(t_el))$sameas(product, "Elekter")
                 + sum(t_el$(sameas(t, t_el) and t_ht(t_el)), load_ht_l(sim, time_t, slot, t_el) * slot_length_s(sim, time_t, slot, t_el)/ht_efficiency(t_el))$sameas(product, "Soojus")
                 + sum(t_el$(sameas(t, t_el) and not t_ht(t_el)), load_ht_l(sim, time_t, slot, t_el) * slot_length_s(sim, time_t, slot, t_el)/ht_efficiency(t_el))$sameas(product, "SisemineSoojus")
         ) * kytuse_proportsioon_el_slott.l(sim, time_t, slot, t, k, feedstock)
  )$(sum(t_el$sameas(t, t_el), ht_efficiency(t_el)) > 0)
*�li
  +
  (sum(t_ol$sameas(t, t_ol), to_production_s(sim, time_t, k, feedstock, t_ol)) * cv(feedstock, k, "MWh")
          *slot_length_s(sim, time_t, slot, t) / (1$(slot_length_s(sim, time_t, slot, t) = 0) + sum(slott2$(slot_length_s(sim, time_t, slott2, t) > 0), slot_length_s(sim, time_t, slott2, t)))
  )$sameas(product, "oil")
;

fuel_consumption_slot.l(sim, time_t, slot, t, product, k, feedstock, "MWh")
   $(fuel_consumption_slot.l(sim, time_t, slot, t, product, k, feedstock, "MWh") < 0 ) = 0;

fuel_consumption_slot.l(sim, time_t, slot, t, product, k, feedstock, "t")$(
   cv(feedstock, k, "MWh") > 0 and not gas(feedstock) and max_ratio(k, feedstock, t) > 0)

=
  fuel_consumption_slot.l(sim, time_t, slot, t, product, k, feedstock, "MWh")
  /cv(feedstock, k, "MWh")
;

fuel_consumption_slot.l(sim, time_t, slot, t, product, k, feedstock, "m3")$(
   cv(feedstock, k, "MWh") > 0 and gas(feedstock) and max_ratio(k, feedstock, t) > 0)

=
  fuel_consumption_slot.l(sim, time_t, slot, t, product, k, feedstock, "MWh")
  /cv(feedstock, k, "MWh")
;

fuel_consumption_day.l(sim, year, month, day, time_t, t, product, k, feedstock, unit)$(
   date_cal(time_t, year, month) and day_cal(time_t, day) and cv(feedstock, k, "MWh") > 0 and max_ratio(k, feedstock, t) > 0)
=
  sum(slot, fuel_consumption_slot.l(sim, time_t, slot, t, product, k, feedstock, unit))
;

fuel_consumption_month.l(sim, year, quarter, month, t, product, k, feedstock, unit)$(
   q_months(quarter, month) and cv(feedstock, k, "MWh") > 0 and max_ratio(k, feedstock, t) > 0)
=
  sum((time_t, slot)$(y_m_t),
         fuel_consumption_slot.l(sim, time_t, slot, t, product, k, feedstock, unit))
;

********************************************************************************
**                                                                             *
**  Arvutame killustiku ja lubja kasutuse                                      *
**                                                                             *
********************************************************************************
$ifthen.two "%l_k_invoked%" == "true"
killustiku_kasutus_paevas.l(sim, time_t, t_cl)
=
$ifthen.three "%katlad%" == "true"
sum((slot, katel, k_level), add_k(sim, time_t, slot, t_cl, katel, k_level) * slot_length(sim, time_t, slot, t_cl) * cl_level(k_level))
$else.three
sum((slot, k_level), add_k(sim, time_t, slot, t_cl, k_level) * slot_length(sim, time_t, slot, t_cl) * cl_level(k_level))
$endif.three
;

killustiku_kasutus_kuus.l(sim, year, quarter, month, t_cl)$q_months(quarter, month)
=
sum(time_t$y_m_t, killustiku_kasutus_paevas.l(sim, time_t, t_cl))
;

lubja_kasutus_paevas.l(sim, time_t, t_lime)
=
$ifthen.three "%katlad%" == "true"
sum((slot, katel, l_level), add_l(sim, time_t, slot, t_lime, katel ,l_level) * slot_length(sim, time_t, slot, t_lime) * katelt_plokis(t_lime) * lime_level(l_level))
$else.three
sum((slot, l_level), add_l(sim, time_t, slot, t_lime, l_level) * slot_length(sim, time_t, slot, t_lime) * katelt_plokis(t_lime) * lime_level(l_level))
$endif.three
;

lubja_kasutus_kuus.l(sim, year, quarter, month, t_lime)$q_months(quarter, month)
=
sum(time_t$y_m_t, lubja_kasutus_paevas.l(sim, time_t, t_lime))
;
$endif.two
********************************************************************************
**                                                                             *
**  Arvutame uttegaasi tarvitamise                                             *
**                                                                             *
** macro: y_m_t                                                          *
********************************************************************************

retortgas_usage_slot.l(sim, time_t, slot, t_el, "m3")$(cv("Uttegaas", "Hange", "MWh") > 0)
=
$ifthen.three "%katlad%" == "true"
         sum(katel, q(sim, time_t, slot, "Hange", "Uttegaas", t_el, katel) * slot_length(sim, time_t, slot, t_el))
      /  cv("Uttegaas", "Hange", "MWh")
$else.three
         q_s(sim, time_t, slot, "Hange", "Uttegaas", t_el) * slot_length_s(sim, time_t, slot, t_el)
      / cv("Uttegaas", "Hange", "MWh")
$endif.three
;

retortgas_usage_slot.l(sim, time_t, slot, t_el, "MWh")
=
$ifthen.three "%katlad%" == "true"
         sum(katel, q(sim, time_t, slot, "Hange", "Uttegaas", t_el, katel) * slot_length(sim, time_t, slot, t_el))
$else.three
         q_s(sim, time_t, slot, "Hange", "Uttegaas", t_el) * slot_length_s(sim, time_t, slot, t_el)
$endif.three
;

retortgas_usage_day.l(sim, time_t, t_el, unit)
=
  sum(slot, retortgas_usage_slot(sim, time_t, slot, t_el, unit))
;

retortgas_usage_month.l(sim, year, quarter, month, t_el, unit)$q_months(quarter, month)
=
  sum(time_t$y_m_t, retortgas_usage_day(sim, time_t, t_el, unit))
;

********************************************************************************
** Average calorific value for oil shale                                       *
********************************************************************************

avg_cv_month.l(sim, year, quarter, month, t)$(q_months(quarter, month) and
  sum((product, k, feedstock), fuel_consumption_month.l(sim, year, quarter, month, t, product, k, feedstock, "t")) > 0
)
  =
  sum((product, k, feedstock), fuel_consumption_month.l(sim, year, quarter, month, t, product, k, feedstock, "MWh"))
  /
  sum((product, k, feedstock), fuel_consumption_month.l(sim, year, quarter, month, t, product, k, feedstock, "t"))
;

avg_cv_year.l(sim, year, t)$(
  sum((quarter, month, product, k, feedstock)$q_months(quarter, month), fuel_consumption_month.l(sim, year, quarter, month, t, product, k, feedstock, "t")) > 0
)
  =
  sum((quarter, month, product, k, feedstock)$q_months(quarter, month), fuel_consumption_month.l(sim, year, quarter, month, t, product, k, feedstock, "MWh"))
  /
  sum((quarter, month, product, k, feedstock)$q_months(quarter, month), fuel_consumption_month.l(sim, year, quarter, month, t, product, k, feedstock, "t"))
;



********************************************************************************
** Ostetud k�tus                                                               *
** macro: y_m_t                                                          *
********************************************************************************

$ifthen.two "%prc%" == "true"
contracts_inuse_day.l(sim, serial, time_t, k, feedstock, "t")$fs_k(k, feedstock)
  =
  fs_purchase_l(sim, serial, time_t, k, feedstock)
;

contracts_inuse_day.l(sim, serial, time_t, k, feedstock, "MWh")$fs_k(k, feedstock)
  =   fs_purchase_l(sim, serial, time_t, k, feedstock) * cv(feedstock, k, "MWh")
;

contracts_inuse_day.l(sim, serial, time_t, k, feedstock, "EUR")$(cv(feedstock, k, "MWh") > 0)
  =
* Tons
  fs_purchase_l(sim, serial, time_t, k, feedstock)
* Times calorific value
  * cv(feedstock, k, "MWh")
* EUR per MWH
  * sum((year, month)$y_m_t, contract_s(sim, serial, year, month, k, feedstock, "hind"))

;


contracts_inuse_month.l(sim, serial, year, quarter, month, k, feedstock, unit)$(fs_k(k, feedstock) and q_months(quarter, month))
  =
  sum(time_t$y_m_t, contracts_inuse_day(sim, serial, time_t, k, feedstock, unit))
;

$endif.two

********************************************************************************
**                                                                             *
**  Fuel sales                                                                 *
** macro: y_m_t                                                          *
********************************************************************************

$ifthen.two "%sales%" == "true"
myyk_paev.l(sim, time_t, k, feedstock, t_mk, "t")$fs_k(k, feedstock)
=
  sales.l(time_t, k, feedstock, t_mk)
;

myyk_paev.l(sim, time_t, k, feedstock, t_mk, "MWh")$fs_k(k, feedstock)
=
  sales.l(time_t, k, feedstock, t_mk) * cv(feedstock, k, "MWh")
;

myyk_paev.l(sim, time_t, k, feedstock, t_mk, "EUR")$fs_k(k, feedstock)
=
  sales.l(time_t, k, feedstock, t_mk)
  *sum((year, month)$y_m_t, concentrate_price(year))
;

myyk_kuu.l(sim, year, quarter, month, k, feedstock, t_mk, unit)$(fs_k(k, feedstock) and q_months(quarter, month))
=
  sum(time_t$y_m_t, myyk_paev.l(sim, time_t, k, feedstock, t_mk, unit))
;
$endif.two

*KASUTEGURID

********************************************************************************
** Average efficiencies.                                                       *
** Efficiency = Production/Primary energy                                      *
** macro: y_m_t                                                          *
********************************************************************************

avg_efficiency_day.l(sim, time_t, t_el)$(
         sum((year, month, day, k, feedstock)$(y_m_t and day_cal(time_t, day)), fuel_consumption_day(sim, year, month, day, time_t, t_el, "Elekter", k, feedstock, "MWh")) > 0
)
=
  t_production_day(sim, time_t, t_el, "Elekter") / sum(slot, slot_length_orig(time_t, slot, t_el))* 24
  /
  (sum((year, month, day, k, feedstock)$(y_m_t and day_cal(time_t, day)), fuel_consumption_day(sim, year, month, day, time_t, t_el, "Elekter", k, feedstock, "MWh"))
* Retort gas is already covered under fuel use.
*  +
*  retortgas_usage_day(sim, time_t, t_el, "MWh")
  )
;

avg_efficiency_month.l(sim, year, month, t_el)$(
         sum((quarter, k, feedstock)$q_months(quarter, month), fuel_consumption_month(sim, year, quarter, month, t_el, "Elekter", k, feedstock, "MWh")) > 0
)
=
  sum(quarter$q_months(quarter, month), t_production_month(sim, year, quarter, month, t_el, "Elekter"))
  /
  (sum((quarter, k, feedstock)$q_months(quarter, month), fuel_consumption_month(sim, year, quarter, month, t_el, "Elekter", k, feedstock, "MWh"))
*  +
*  sum(quarter$q_months(quarter, month), retortgas_usage_month(sim, year, quarter, month, t_el, "MWh")
  )
;

avg_efficiency_year.l(sim, year, t_el)$(
         sum((quarter, month, k, feedstock)$q_months(quarter, month), fuel_consumption_month(sim, year, quarter, month, t_el, "Elekter", k, feedstock, "MWh")) > 0
)
=
  sum((quarter, month)$q_months(quarter, month), t_production_month(sim, year, quarter, month, t_el, "Elekter"))
  /
  (sum((quarter, month, k, feedstock)$q_months(quarter, month), fuel_consumption_month(sim, year, quarter, month, t_el, "Elekter", k, feedstock, "MWh"))
*  +
*  sum((quarter, month)$q_months(quarter, month), retortgas_usage_month(sim, year, quarter, month, t_el, "MWh")
  )
;

avg_special_consumption_month.l(sim, year, month, t_el)$(
         avg_efficiency_month.l(sim, year, month, t_el) > 0
)
=
  1/avg_efficiency_month.l(sim, year, month, t_el)
;

*HEITMED

********************************************************************************
**                                                                             *
**  Arvutame heitmed per tootmis�ksus ja segu                                  *
**  macros: eh_tase_el, eh_tase_co2, s_eh_tase_co2_u, eh_tase_jv,              *
**          tootmisse                                                          *
********************************************************************************

heide_fs_slotis.l(sim, time_t, slot, t, k, feedstock, product, em, "t")$(max_ratio(k, feedstock, t) > 0)
=
*Elekter
  (
         sum(t_el$sameas(t, t_el),
                         em_level_el_s(sim, time_t, slot, em, k, feedstock, t_el)$(not sameas(em, "co") and not sameas(em, "jv"))
                         +
                         (em_level_co2_s(sim, time_t, slot, k, feedstock, t_el))$sameas(em, "co")
                 +
                 (em_level_cw_s(sim, time_t, slot, t_el) * kytuse_proportsioon_el_slott(sim, time_t, slot, t, k, feedstock)
                 )$sameas(em, "jv")
         ) * slot_length_s(sim, time_t, slot, t)
  )$sameas(product, "Elekter")
  +
*�li
  (
         sum((t_ol, em_ol)$(sameas(t, t_ol) and sameas(em, em_ol)),
                 to_production_s(sim, time_t, k, feedstock, t_ol) * em_coefficients_ol(em_ol, t_ol)
         )
         * slot_length_s(sim, time_t, slot, t) / (1$(slot_length_s(sim, time_t, slot, t) = 0) + sum(slott2$(slot_length_s(sim, time_t, slott2, t) > 0), slot_length_s(sim, time_t, slott2, t)))
  )$(sameas(product, "oil") and (1$(slot_length_s(sim, time_t, slot, t) = 0) + sum(slott2$(slot_length_s(sim, time_t, slott2, t) > 0), slot_length_s(sim, time_t, slott2, t))) > 0)
;

heide_fs_slotis.l(sim, time_t, slot, t, k, feedstock, product, em, "t")$(sameas(product, "Soojus")
                   or sameas(product, "SisemineSoojus")
                   and not sameas(em, "jv")
                   and sum(t_el$sameas(t, t_el), q_s(sim, time_t, slot, k, feedstock, t_el)) > 0)
=
  heide_fs_slotis.l(sim, time_t, slot, t, k, feedstock, "Elekter", em, "t")
  * sum(t_el$(sameas(t, t_el) and   (ht_efficiency(t_el) * sum((k2, p2), q_s(sim, time_t, slot, k2, p2, t_el)))),
         (
                  load_ht_l(sim, time_t, slot, t_el)$(sameas(product, "Soojus") and t_ht(t_el))
                  +
                  load_ht_l(sim, time_t, slot, t_el)$(sameas(product, "SisemineSoojus") and not t_ht(t_el))
         )
  /
  (ht_efficiency(t_el) * sum((k2, p2), q_s(sim, time_t, slot, k2, p2, t_el)))
  )
;

heide_fs_slotis.l(sim, time_t, slot, t, k, feedstock, "Elekter", em, "t")$(not sameas(em, "jv"))
=
  heide_fs_slotis.l(sim, time_t, slot, t, k, feedstock, "Elekter", em, "t")
  -
  heide_fs_slotis.l(sim, time_t, slot, t, k, feedstock, "Soojus", em, "t")
  -
  heide_fs_slotis.l(sim, time_t, slot, t, k, feedstock, "SisemineSoojus", em, "t")
;

*Heitmete kulud eurodes
heide_fs_slotis.l(sim, time_t, slot, t, k, feedstock, product, em, "EUR")
=
  (heide_fs_slotis.l(sim, time_t, slot, t, k, feedstock, product, em, "t") *
  sum((year, month)$y_m_t, em_tariff(em, year)))$(sameas(product, "Elekter") or sameas(product, "Soojus") or sameas(product, "SisemineSoojus"))
  +
  (heide_fs_slotis.l(sim, time_t, slot, t, k, feedstock, product, em, "t") *
   (
     sum((year, month)$y_m_t, co2_price_s(sim, year)) *  co2_spot_market_l(sim, time_t) / co2_usage_s(sim, time_t)
     +
     sum((year, month, serial)$(y_m_t and co2_certs(serial, year, "kogus") > 0),  co2_certs(serial, year, "hind") * co2_cert_usage_l(sim, serial, time_t) / co2_usage_s(sim, time_t))
   )
  )$(co2_usage_s(sim, time_t) > 0 and (sameas(product, "Elekter") or sameas(product, "Soojus") or sameas(product, "SisemineSoojus")) and sameas(em, "co"))
  +
  (heide_fs_slotis.l(sim, time_t, slot, t, k, feedstock, product, em, "t") *
  sum((t_ol, year, month, em_ol)$(y_m_t and sameas(t, t_ol) and sameas(em, em_ol)), em_tariff_ol(t_ol, em_ol, year)))$sameas(product, "oil")
  +
  (heide_fs_slotis.l(sim, time_t, slot, t, k, feedstock, product, em, "t") *
   (
     sum((year, month)$y_m_t, co2_price_s(sim, year)) *  co2_spot_market_l(sim, time_t) / co2_usage_s(sim, time_t)
     +
     sum((year, month, serial)$y_m_t,  co2_certs(serial, year, "hind") * co2_cert_usage_l(sim, serial, time_t) / co2_usage_s(sim, time_t))
   )
  )$(co2_usage_s(sim, time_t) > 0 and sameas(product, "oil") and sameas(em, "co"))

;


********************************************************************************
**                                                                             *
**  Arvutame heitmed per tootmis�ksus ja segu                                  *
**  macros: eh_tase_el, eh_tase_co2, s_eh_tase_co2_u, eh_tase_jv,              *
**          tootmisse                                                          *
********************************************************************************
emission_slot.l(sim, time_t, slot, t, product, em, "t")
=
*Elekter
  (
         sum(t_el$sameas(t, t_el),
                 sum((k, feedstock)$(max_ratio(k, feedstock, t_el) > 0),
                         em_level_el_s(sim, time_t, slot, em, k, feedstock, t_el)$(not sameas(em, "co") and not sameas(em, "jv"))
                         +
                         (em_level_co2_s(sim, time_t, slot, k, feedstock, t_el))$sameas(em, "co")
                 )
                 +
                 (em_level_cw_s(sim, time_t, slot, t_el))$sameas(em, "jv")
         ) * slot_length_s(sim, time_t, slot, t)
  )$sameas(product, "Elekter")
  +
*�li
  (
         sum((k, feedstock, t_ol, em_ol)$(sameas(t, t_ol) and sameas(em, em_ol)),
                 to_production_s(sim, time_t, k, feedstock, t_ol) * em_coefficients_ol(em_ol, t_ol)
         )
         *slot_length_s(sim, time_t, slot, t) / (1$(slot_length_s(sim, time_t, slot, t) = 0) + sum(slott2$(slot_length_s(sim, time_t, slott2, t) > 0), slot_length_s(sim, time_t, slott2, t)))
  )$sameas(product, "oil")
;

*Heitmete jaotamine elektrile ja soojusele feedstock koguse j�rgi
emission_slot.l(sim, time_t, slot, t, product, em, "t")$(sameas(product, "Soojus") or sameas(product, "SisemineSoojus") and not sameas(em, "jv"))
=
  emission_slot.l(sim, time_t, slot, t, "Elekter", em, "t")
  * sum(t_el$(sameas(t, t_el) and sum((k, feedstock), q_s(sim, time_t, slot, k, feedstock, t_el)) > 0),
         (
                  load_ht_l(sim, time_t, slot, t_el)$(sameas(product, "Soojus") and t_ht(t_el))
                  +
                  load_ht_l(sim, time_t, slot, t_el)$(sameas(product, "SisemineSoojus") and not t_ht(t_el))
         )
  /
  (
                 ht_efficiency(t_el)
                 *
                 sum((k, feedstock), q_s(sim, time_t, slot, k, feedstock, t_el))
         )
  )
;

emission_slot.l(sim, time_t, slot, t, "Elekter", em, "t")$(not sameas(em, "jv"))
=
  emission_slot.l(sim, time_t, slot, t, "Elekter", em, "t")
  -
  emission_slot.l(sim, time_t, slot, t, "Soojus", em, "t")
  -
  emission_slot.l(sim, time_t, slot, t, "SisemineSoojus", em, "t")
;

*Heitmete kulud eurodes
emission_slot.l(sim, time_t, slot, t, product, em, "EUR")
=
  (emission_slot.l(sim, time_t, slot, t, product, em, "t") *
  sum((year, month)$y_m_t, em_tariff(em, year)))$(sameas(product, "Elekter") or sameas(product, "Soojus") or sameas(product, "SisemineSoojus"))
  +
  (emission_slot.l(sim, time_t, slot, t, product, em, "t") *
   (
     sum((year, month)$y_m_t, co2_price_s(sim, year)) *  co2_spot_market_l(sim, time_t) / co2_usage_s(sim, time_t)
     +
     sum((year, month, serial)$(y_m_t and co2_certs(serial, year, "kogus") > 0),  co2_certs(serial, year, "hind") * co2_cert_usage_l(sim, serial, time_t) / co2_usage_s(sim, time_t))
   )
  )$(co2_usage_s(sim, time_t) > 0 and (sameas(product, "Elekter") or sameas(product, "Soojus") or sameas(product, "SisemineSoojus")) and sameas(em, "co"))
  +
  (emission_slot.l(sim, time_t, slot, t, product, em, "t") *
  sum((t_ol, year, month, em_ol)$(y_m_t and sameas(t, t_ol) and sameas(em, em_ol)), em_tariff_ol(t_ol, em_ol, year)))$sameas(product, "oil")
  +
  (emission_slot.l(sim, time_t, slot, t, product, em, "t") *
   (
     sum((year, month)$y_m_t, co2_price_s(sim, year)) *  co2_spot_market_l(sim, time_t) / co2_usage_s(sim, time_t)
     +
     sum((year, month, serial)$y_m_t,  co2_certs(serial, year, "hind") * co2_cert_usage_l(sim, serial, time_t) / co2_usage_s(sim, time_t))
   )
  )$(co2_usage_s(sim, time_t) > 0 and sameas(product, "oil") and sameas(em, "co"))

;

emission_day.l(sim, time_t, t, product, em, unit) = sum(slot, emission_slot.l(sim, time_t, slot, t, product, em, unit));
emission_month.l(sim, year, quarter, month, t, product, em, unit)$q_months(quarter, month) = sum(time_t, emission_day.l(sim, time_t, t, product, em, unit)$date_cal(time_t, year, month));

********************************************************************************
** Emission intensities                                                        *
** Emission intensity = Emission/Production                                    *
** macros: y_m_t
********************************************************************************

avg_specific_emission_day.l(sim, time_t, t, em, product)$(
         t_production_day(sim, time_t, t, product) > 0
)
 =
  emission_day.l(sim, time_t, t, product, em, "t")
  /
  t_production_day(sim, time_t, t, product)
;

avg_specific_emission_month.l(sim, year, month, t, em, product)$(
         sum(quarter$q_months(quarter, month), t_production_month.l(sim, year, quarter, month, t, product)) > 0
)
=
  sum(quarter$q_months(quarter, month), emission_month.l(sim, year, quarter, month, t, product, em, "t"))
  /
  sum(quarter$q_months(quarter, month), t_production_month.l(sim, year, quarter, month, t, product))
;

avg_specific_emission_year.l(sim, year, t, em, product)$(
         sum((quarter, month)$q_months(quarter, month), t_production_month.l(sim, year, quarter, month, t, product)) > 0
)
=
  sum((quarter, month)$q_months(quarter, month), emission_month.l(sim, year, quarter, month, t, product, em, "t"))
  /
  sum((quarter, month)$q_months(quarter, month), t_production_month.l(sim, year, quarter, month, t, product))
;

avg_specific_emission_tech_year.l(sim, year, tech, t, em, product)$t_tech(tech, t)
=
  avg_specific_emission_year.l(sim, year, t, em, product)
;

*KULUD/KASUMID

********************************************************************************
**  Average price for imported fuels                                           *
********************************************************************************
$ifthen "%prc%" == "true"
ostetud_kytuse_keskmine_hind.l(sim, time_t, k, feedstock)$(fs_k(k, feedstock) and
  sum((serial, time_t2)$(ord(time_t) ge ord(time_t2)), contracts_inuse_day(sim, serial, time_t, k, feedstock, "t")) > 0
)
=
  sum((serial, time_t2)$(ord(time_t) ge ord(time_t2)), contracts_inuse_day(sim, serial, time_t, k, feedstock, "EUR"))
  /
  sum((serial, time_t2)$(ord(time_t) ge ord(time_t2)), contracts_inuse_day(sim, serial, time_t, k, feedstock, "t"))
;
$endif

********************************************************************************
**  Variable cost calculation for all production units per fuel                *
**                                                                             *
**  macros: y_m_t                                                              *
********************************************************************************

t_mkul_fs_slott.l(sim, time_t, slot, t, k, feedstock, product, vc)$(max_ratio(k, feedstock, t) > 0)
=
*Kulud heitmetele
  sum(em$sameas(vc, em), heide_fs_slotis.l(sim, time_t, slot, t, k, feedstock, product, em, "EUR"))
*KET
  +
  (
         sum((year, month)$y_m_t, t_supply_vc(t, year) + t_supply_gr_vc(k, feedstock, t, year))
         * fuel_consumption_slot(sim, time_t, slot, t, product, k, feedstock, "t")
  )$sameas(vc, "ketkulu")
*Logistika
  +
  (
         sum((year, month, route, l)$(y_m_t and route_endpoint(route, k, l) and t_dp_prod(l, t)), log_vc(route, year))
         * fuel_consumption_slot(sim, time_t, slot, t, product, k, feedstock, "t")
  )$sameas(vc, "logist")
*K�tuse kulu
  +
  (
         (
         sum((year, month)$y_m_t, fs_vc(k, feedstock, year))
$ifthen "%prc%" == "true"
                 +
                 ostetud_kytuse_keskmine_hind(sim, time_t, k, feedstock)
$endif
         )
         * (fuel_consumption_slot(sim, time_t, slot, t, product, k, feedstock, "t")$(not gas(feedstock))
            + fuel_consumption_slot(sim, time_t, slot, t, product, k, feedstock, "m3")$(gas(feedstock)))
  )$(sameas(vc, "kythind"))
*Lubi
  +
  ((sum(t_lime$sameas(t, t_lime),
         load_el_l(sim, time_t, slot, t_lime) * slot_length_s(sim, time_t, slot, t_lime)
         * lime_consumption(t_lime)
         * sum((year, month)$y_m_t, lime_price(year)/1000))$(sameas(vc, "lubkulu"))
  )
         * kytuse_proportsioon_el_slott.l(sim, time_t, slot, t, k, feedstock)
  )$(sameas(product, "Elekter"))
*Muud kulud
  +
  ((
        sum((year, month, t_el)$(y_m_t and sameas(t_el, t) and sameas(product, "Elekter")), el_other_vc(t_el, year))  *t_production_slot(sim, time_t, slot, t, "Elekter")
        +
        sum((year, month, t_ht)$(y_m_t and sameas(t_ht, t) and sameas(product, "Soojus")), ht_other_vc(t_ht, year)) *t_production_slot(sim, time_t, slot, t, "Soojus")
        +
        sum((year, month, t_el)$(y_m_t and sameas(t_el, t) and sameas(product, "SisemineSoojus")), ht_other_vc(t_el, year)) *t_production_slot(sim, time_t, slot, t, "SisemineSoojus")
        +
        sum((year, month, t_ol)$(y_m_t and sameas(t_ol, t) and sameas(product, "oil")), oil_other_vc(t_ol, year)) *t_production_slot(sim, time_t, slot, t, "oil")
  )
         * kytuse_proportsioon_el_slott.l(sim, time_t, slot, t, k, feedstock)
  )$(sameas(vc, "muud"))
;

t_mkul_fs_slott.l(sim, time_t, slot, t, k, feedstock, product, "kokku")$(max_ratio(k, feedstock, t) > 0)
=
  sum(vc$(not sameas(vc, "kokku")), t_mkul_fs_slott.l(sim, time_t, slot, t, k, feedstock, product, vc))
;

t_mkul_fs_paev.l(sim, time_t, t, k, feedstock, product, vc)$(max_ratio(k, feedstock, t) > 0)
=
  sum(slot, t_mkul_fs_slott.l(sim, time_t, slot, t, k, feedstock, product, vc))
;

t_mkul_fs_kuu.l(sim, year, quarter, month, t, k, feedstock, product, vc)$(max_ratio(k, feedstock, t) > 0 and q_months(quarter, month))
=
  sum(time_t$y_m_t, t_mkul_fs_paev.l(sim, time_t, t, k, feedstock, product, vc))
;

********************************************************************************
**  Variable cost calculation for all production units                         *
**                                                                             *
**  macros: y_m_t                                                              *
********************************************************************************

t_varcost_slot.l(sim, time_t, slot, t, product, vc)
=
*Kulud heitmetele
  sum(em$sameas(vc, em), emission_slot.l(sim, time_t, slot, t, product, em, "EUR"))
*KET
  +
  (
         sum((year, month)$y_m_t, t_supply_vc(t, year))
         * sum((k, feedstock)$fs_k(k, feedstock), fuel_consumption_slot(sim, time_t, slot, t, product, k, feedstock, "t"))
  )$sameas(vc, "ketkulu")
*Logistika
  +
  sum((k, feedstock)$fs_k(k, feedstock),
         sum((year, month, route, l)$(y_m_t and route_endpoint(route, k, l) and t_dp_prod(l, t)), log_vc(route, year))
         * fuel_consumption_slot(sim, time_t, slot, t, product, k, feedstock, "t")
  )$sameas(vc, "logist")
*K�tuse kulu
  +
  sum((k, feedstock),
         (
         sum((year, month)$y_m_t, fs_vc(k, feedstock, year))
$ifthen "%prc%" == "true"
                 +
                 ostetud_kytuse_keskmine_hind(sim, time_t, k, feedstock)
$endif
         )
         * (fuel_consumption_slot(sim, time_t, slot, t, product, k, feedstock, "t")$(not gas(feedstock))
           + fuel_consumption_slot(sim, time_t, slot, t, product, k, feedstock, "m3")$gas(feedstock))
  )$sameas(vc, "kythind")
*Lubi
  +
  (sum(t_lime$sameas(t, t_lime),
         load_el_l(sim, time_t, slot, t_lime) * slot_length_s(sim, time_t, slot, t_lime)
         * lime_consumption(t_lime)
         * sum((year, month)$y_m_t, lime_price(year)/1000))$(sameas(vc, "lubkulu"))
  )$sameas(product, "Elekter")
*Muud kulud
  +
  (
        sum((year, month, t_el)$(y_m_t and sameas(t_el, t) and sameas(product, "Elekter")), el_other_vc(t_el, year))  *t_production_slot(sim, time_t, slot, t, "Elekter")
        +
        sum((year, month, t_ht)$(y_m_t and sameas(t_ht, t) and sameas(product, "Soojus")), ht_other_vc(t_ht, year)) *t_production_slot(sim, time_t, slot, t, "Soojus")
        +
        sum((year, month, t_el)$(y_m_t and sameas(t_el, t) and sameas(product, "SisemineSoojus")), ht_other_vc(t_el, year)) *t_production_slot(sim, time_t, slot, t, "SisemineSoojus")
        +
        sum((year, month, t_ol)$(y_m_t and sameas(t_ol, t) and sameas(product, "oil")), oil_other_vc(t_ol, year)) *t_production_slot(sim, time_t, slot, t, "oil")
  )$sameas(vc, "muud")
;

t_varcost_slot.l(sim, time_t, slot, t, product, "kokku")
=
  sum(vc$(not sameas(vc, "kokku")), t_varcost_slot.l(sim, time_t, slot, t, product, vc))
;

t_varcost_day.l(sim, time_t, t, product, vc)
=
  sum(slot, t_varcost_slot.l(sim, time_t, slot, t, product, vc))
;

t_varcost_month.l(sim, year, quarter, month, t, product, vc)$q_months(quarter, month)
=
  sum(time_t$y_m_t, t_varcost_day.l(sim, time_t, t, product, vc))
;

t_varcost_perunit_slot.l(sim, time_t, slot, t, product, vc)$(
         t_production_slot(sim, time_t, slot, t, product) > 0
)
=
  t_varcost_slot.l(sim, time_t, slot, t, product, vc)
  /
  t_production_slot(sim, time_t, slot, t, product)
;

t_varcost_perunit_day.l(sim, time_t, t, product, vc)$(
  t_production_day(sim, time_t, t, product) > 0
         )
=
  t_varcost_day.l(sim, time_t, t, product, vc)
  /
  t_production_day(sim, time_t, t, product)
;

t_varcost_perunit_month.l(sim, year, month, t, product, vc)$(
  sum(quarter$q_months(quarter, month), t_production_month(sim, year, quarter, month, t, product)) > 0
)
=
  sum(quarter$q_months(quarter, month), t_varcost_month.l(sim, year, quarter, month, t, product, vc))
  /
  sum(quarter$q_months(quarter, month), t_production_month(sim, year, quarter, month, t, product))
;

t_varcost_perunit_quarter.l(sim, year, quarter, t, product, vc)$(
  sum(month$q_months(quarter, month), t_production_month(sim, year, quarter, month, t, product)) > 0
)
=
  sum(month$q_months(quarter, month), t_varcost_month.l(sim, year, quarter, month, t, product, vc))
  /
  sum(month$q_months(quarter, month), t_production_month(sim, year, quarter, month, t, product))
;

t_varcost_perunit_year.l(sim, year, t, product, vc)$(
  sum((quarter, month)$q_months(quarter, month), t_production_month(sim, year, quarter, month, t, product)) > 0
)
=
  sum((quarter, month)$q_months(quarter, month), t_varcost_month.l(sim, year, quarter, month, t, product, vc))
  /
  sum((quarter, month)$q_months(quarter, month), t_production_month(sim, year, quarter, month, t, product))
;

t_varcost_perunit_NEJ_month.l(sim, year, month, product, vc)$(
  sum((quarter, t)$q_months(quarter, month), t_production_month(sim, year, quarter, month, t, product)) > 0
)
=
  sum((quarter, t)$q_months(quarter, month), t_varcost_month.l(sim, year, quarter, month, t, product, vc))
  /
  sum((quarter, t)$q_months(quarter, month), t_production_month(sim, year, quarter, month, t, product))
;

t_varcost_perunit_NEJ_quarter.l(sim, year, quarter, product, vc)$(
  sum((month, t)$q_months(quarter, month), t_production_month(sim, year, quarter, month, t, product)) > 0
)
=
  sum((month, t)$q_months(quarter, month), t_varcost_month.l(sim, year, quarter, month, t, product, vc))
  /
  sum((month, t)$q_months(quarter, month), t_production_month(sim, year, quarter, month, t, product))
;

********************************************************************************
** Profit from sales                                                           *
** profit = price*production                                                   *
** macro: y_m_t                                                          *
********************************************************************************
t_sales_slot.l(sim, time_t, slot, t, product)
=
  t_production_slot(sim, time_t, slot, t, product)*
  (
         el_price_slot_s(sim, time_t, slot)$sameas(product, "Elekter")
         +
         sum((year, month)$y_m_t, oil_price_s(sim, year, month))$sameas(product, "oil")
         +
         sum((year, month)$y_m_t, heat_price_s(sim, year, month))$sameas(product, "Soojus")
  )
;

t_sales_day.l(sim, time_t, t, product)
=
  sum(slot, t_sales_slot.l(sim, time_t, slot, t, product))
;

t_sales_month.l(sim, year, quarter, month, t, product)$q_months(quarter, month)
=
  sum(time_t$y_m_t, t_sales_day.l(sim, time_t, t, product))
;

**HINNAD

********************************************************************************
**  Weighted average electricity prices                                        *
**  macro: y_m_t                                                         *
********************************************************************************

weightavg_price_slot.l(sim, time_t, slot, t)$(
         t_production_slot.l(sim, time_t, slot, t, "Elekter") > 0
)
=
  t_sales_slot.l(sim, time_t, slot, t, "Elekter")
  /
  t_production_slot.l(sim, time_t, slot, t, "Elekter")
;

weightavg_price_day.l(sim, time_t, t)$(
         t_production_day.l(sim, time_t, t, "Elekter") > 0
)
=
  t_sales_day.l(sim, time_t, t, "Elekter")
/
  t_production_day.l(sim, time_t, t, "Elekter")
;

weightavg_price_month.l(sim, year, month, t)
=
  sum(product$(
         sum(quarter$q_months(quarter, month), t_production_month.l(sim, year, quarter, month, t, product)) > 0
         ),
         sum(quarter$q_months(quarter, month), t_sales_month.l(sim, year, quarter, month, t, product))
         /
         sum(quarter$q_months(quarter, month), t_production_month.l(sim, year, quarter, month, t, product))
  )
*  (oli_referents(year, month))$(sum(quarter$q_months(quarter, month), t_production_month.l(year, quarter, month, t, "oil")) > 0)
;

weightavg_price_quarter.l(sim, year, quarter, t)
=
  sum(product$(
         sum(month$q_months(quarter, month), t_production_month.l(sim, year, quarter, month, t, product)) > 0
         ),
         sum(month$q_months(quarter, month), t_sales_month.l(sim, year, quarter, month, t, product))
         /
         sum(month$q_months(quarter, month), t_production_month.l(sim, year, quarter, month, t, product))
  )
;


weightavg_price_year.l(sim, year, t)
=
  sum(product$(
         sum((quarter, month)$q_months(quarter, month), t_production_month.l(sim, year, quarter, month, t, product)) > 0
         ),
         sum((quarter, month)$q_months(quarter, month), t_sales_month.l(sim, year, quarter, month, t, product))
         /
         sum((quarter, month)$q_months(quarter, month), t_production_month.l(sim, year, quarter, month, t, product))
  )
;

weightavg_price_NEJ_month.l(sim, year, month)$(
         sum((quarter, t)$q_months(quarter, month), t_production_month.l(sim, year, quarter, month, t, "Elekter")) > 0
  )
=
  sum((quarter, t)$q_months(quarter, month), t_sales_month.l(sim, year, quarter, month, t, "Elekter"))
  /
  sum((quarter, t)$q_months(quarter, month), t_production_month.l(sim, year, quarter, month, t, "Elekter"))
;

weightavg_price_NEJ_quarter.l(sim, year, quarter)$(
         sum((month, t)$q_months(quarter, month), t_production_month.l(sim, year, quarter, month, t, "Elekter")) > 0
  )
=
  sum((month, t)$q_months(quarter, month), t_sales_month.l(sim, year, quarter, month, t, "Elekter"))
  /
  sum((month, t)$q_months(quarter, month), t_production_month.l(sim, year, quarter, month, t, "Elekter"))
;

weightavg_price_NEJ_year.l(sim, year)$(
         sum((quarter, month, t)$q_months(quarter, month), t_production_month.l(sim, year, quarter, month, t, "Elekter")) > 0
  )
=
  sum((quarter, month, t)$q_months(quarter, month), t_sales_month.l(sim, year, quarter, month, t, "Elekter"))
  /
  sum((quarter, month, t)$q_months(quarter, month), t_production_month.l(sim, year, quarter, month, t, "Elekter"))
;

********************************************************************************
** Variable profit per fuel                                                    *
********************************************************************************

t_mkas_fs_slott.l(sim, time_t, slot, t, k, feedstock, product)$(max_ratio(k, feedstock, t) > 0)
=
  t_sales_slot.l(sim, time_t, slot, t, product)
         * kytuse_proportsioon_el_slott.l(sim, time_t, slot, t, k, feedstock)
  -
  t_mkul_fs_slott.l(sim, time_t, slot, t, k, feedstock, product, "kokku")
;

t_mkas_fs_paev.l(sim, time_t, t, k, feedstock, product)$(max_ratio(k, feedstock, t) > 0)
=
  sum(slot, t_mkas_fs_slott.l(sim, time_t, slot, t, k, feedstock, product))
;

t_mkas_fs_kuu.l(sim, year, quarter, month, t, k, feedstock, product)$(max_ratio(k, feedstock, t) > 0 and q_months(quarter, month))
=
  sum(time_t$y_m_t, t_mkas_fs_paev.l(sim, time_t, t, k, feedstock, product))
;


********************************************************************************
** Variable profit                                                             *
********************************************************************************

t_contribution_slot.l(sim, time_t, slot, t, product)
=
  t_sales_slot.l(sim, time_t, slot, t, product)
  -
  t_varcost_slot.l(sim, time_t, slot, t, product, "kokku")
;

t_contribution_day.l(sim, time_t, t, product)
=
  sum(slot, t_contribution_slot.l(sim, time_t, slot, t, product))
;

t_contribution_month.l(sim, year, quarter, month, t, product)$q_months(quarter, month)
=
  sum(time_t$y_m_t, t_contribution_day.l(sim, time_t, t, product))
;


t_contribution_margin_slot.l(sim, time_t, slot, t, product)$(
  t_production_slot.l(sim, time_t, slot, t, product) > 0
)
=
  t_contribution_slot.l(sim, time_t, slot, t, product)
  /
  t_production_slot.l(sim, time_t, slot, t, product)
;

t_contribution_margin_day.l(sim, time_t, t, product)$(
  t_production_day.l(sim, time_t, t, product) > 0
         )
=
  t_contribution_day.l(sim, time_t, t, product)
  /
  t_production_day.l(sim, time_t, t, product)
;

t_contribution_margin_month.l(sim, year, month, t, product)$(
  sum(quarter$q_months(quarter, month), t_production_month.l(sim, year, quarter, month, t, product)) > 0
)
=
  sum(quarter$q_months(quarter, month), t_contribution_month.l(sim, year, quarter, month, t, product))
  /
  sum(quarter$q_months(quarter, month), t_production_month.l(sim, year, quarter, month, t, product))
;

t_contribution_margin_quarter.l(sim, year, quarter, t, product)$(
  sum(month$q_months(quarter, month), t_production_month.l(sim, year, quarter, month, t, product)) > 0
)
=
  sum(month$q_months(quarter, month), t_contribution_month.l(sim, year, quarter, month, t, product))
  /
  sum(month$q_months(quarter, month), t_production_month.l(sim, year, quarter, month, t, product))
;

t_contribution_margin_year.l(sim, year, t, product)$(
  sum((quarter, month)$q_months(quarter, month), t_production_month(sim, year, quarter, month, t, product)) > 0
)
=
  sum((quarter, month)$q_months(quarter, month), t_contribution_month.l(sim, year, quarter, month, t, product))
  /
  sum((quarter, month)$q_months(quarter, month), t_production_month(sim, year, quarter, month, t, product))
;

********************************************************************************
** Tootmis�ksuse muutuvkulu ilma k�tuseta                                      *
********************************************************************************

t_varcost_perunit_wofuel_month.l(sim, year, month, t, product)
=
  t_varcost_perunit_month.l(sim, year, month, t, product, "kokku")
  -
  t_varcost_perunit_month.l(sim, year, month, t, product, "kythind")
;

********************************************************************************
** Muutuvkulud ja muutuvkasumid tehnoloogiate l�ikes                           *
********************************************************************************

t_varcost_tech_month.l(sim, year, quarter, month, tech, t, product, vc)$t_tech(tech, t)
=
  t_varcost_month(sim, year, quarter, month, t, product, vc)
;

t_varcost_perunit_tech_month.l(sim, year, month, tech, t, product, vc)$t_tech(tech, t)
=
  t_varcost_perunit_month(sim, year, month, t, product, vc)
;

t_contribution_tech_month.l(sim, year, quarter, month, tech, t, product)$t_tech(tech, t)
=
  t_contribution_month(sim, year, quarter, month, t, product)
;

t_contribution_margin_tech_month.l(sim, year, month, tech, t, product)$t_tech(tech, t)
=
  t_contribution_margin_month(sim, year, month, t, product)
;

********************************************************************************
* Ploki muutuvkulud erinevatele k�tustele                                      *
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
                  at      "Atmosf��ri saastemaks"
                  lubkulu "Lubja kulu"
                  kilkulu "Killustiku kulu"
                  ketkulu "KET kulu"
                  logist  "Logistikakulud"
                  kythind "K�tuse hind"
                  muud    "Muud muutuvkulud"
                  kokku   "Kokku"
$offtext

ploki_mkul_kyt_per_MWh_aasta.l(sim, year, t_el, k, feedstock, route, l_level, "co")$(not t_ol(t_el) and max_ratio(k, feedstock, t_el) > 0 and avg_efficiency_year(sim, year, t_el) > 0)
=
   3.6 / 1000 * em_co2(feedstock) * 0.999 * 44.01 / 12
   * co2_reference(year)
   / avg_efficiency_year(sim, year, t_el)
;

ploki_mkul_kyt_per_MWh_aasta.l(sim, year, t_el, k, feedstock, route, l_level, vc)$(not sameas(vc, "co") and not t_ol(t_el) and max_ratio(k, feedstock, t_el) > 0 and avg_efficiency_year(sim, year, t_el)  > 0)
=
  sum(em$(sameas(vc, em)),
         (
                 sum(para_lk, t_sg_m3 * hh_coef(em, t_el, k, feedstock, para_lk))
                  / sum(para_lk$(card(para_lk) = ord(para_lk)), efficiency(t_el, para_lk, "b"))
         )$(sameas(em, "so") or sameas(em, "no"))
         +
         (
                 sum(para_lk$(ord(para_lk) = card(para_lk)), em_coef(em, t_el, k, feedstock, para_lk, "0"))
                  /
                 sum(para_lk$(card(para_lk) = ord(para_lk)), efficiency(t_el, para_lk, "b"))
         )$(not sameas(em, "so") and not sameas(em, "no"))
         * uncertainty
         * em_tariff(em, year)
  )
  / avg_efficiency_year(sim, year, t_el)
;

ploki_mkul_kyt_per_MWh_aasta.l(sim, year, t_el, k, feedstock, route, l_level, "lubkulu")$(sum(month, max_load_el(t_el, year, month)) > 0 and not t_ol(t_el) and max_ratio(k, feedstock, t_el) > 0)
=
  110*lime_level(l_level)/(sum(month, max_load_el(t_el, year, month))/12)
;

***** 10 *****
ploki_mkul_kyt_per_MWh_aasta.l(sim, year, t_el, k, feedstock, route, l_level, "ketkulu")$(not t_ol(t_el) and max_ratio(k, feedstock, t_el) > 0 and sum(month$(avg_efficiency_month(sim, year, month, t_el) > 0), 1) > 0)
=
sum(month$(cv(feedstock, k, "MWh") > 0 and avg_efficiency_month(sim, year, month, t_el) > 0),
         t_supply_vc(t_el, year)
         /(avg_efficiency_month(sim, year, month, t_el))
         / cv(feedstock, k, "MWh")
         )/sum(month$(avg_efficiency_month(sim, year, month, t_el) > 0), 1)
;


ploki_mkul_kyt_per_MWh_aasta.l(sim, year, t_el, k, feedstock, route, l_level, "logist")$(not t_ol(t_el) and max_ratio(k, feedstock, t_el) > 0 and avg_efficiency_year(sim, year, t_el) > 0)
=
     sum((l)$(route_endpoint(route, k, l) and t_dp_prod(l, t_el)), log_vc(route, year))
     / avg_efficiency_year(sim, year, t_el)
     / cv(feedstock, k, "MWh")
;

ploki_mkul_kyt_per_MWh_aasta.l(sim, year, t_el, k, feedstock, route, l_level, "kythind")$(not t_ol(t_el)
                                                   and cv(feedstock, k, "MWh") > 0
                                                   and max_ratio(k, feedstock, t_el) > 0
                                                   and avg_efficiency_year(sim, year, t_el) > 0)
=
         fs_vc(k, feedstock, year)
         / avg_efficiency_year(sim, year, t_el)
         / cv(feedstock, k, "MWh")
;

ploki_mkul_kyt_per_MWh_aasta.l(sim, year, t_el, k, feedstock, route, l_level, "muud")$(not t_ol(t_el)
                                                   and max_ratio(k, feedstock, t_el) > 0
                                                   and avg_efficiency_year(sim, year, t_el) > 0)
=
  el_other_vc(t_el, year) / avg_efficiency_year(sim, year, t_el)
;

ploki_mkul_kyt_per_MWh_aasta.l(sim, year, t_el, k, feedstock, route, l_level, "kokku")$(not t_ol(t_el))
=
  sum(vc$(not sameas("kokku", vc)),
ploki_mkul_kyt_per_MWh_aasta.l(sim, year, t_el, k, feedstock, route, l_level, vc)
)
;

$endif.mk

$label lopp_m1
$offDotL
