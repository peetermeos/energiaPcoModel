**************************************************************
* Operatiivne tootmise planeerimise mudel.                   *
* Rakendatakse peale seda, kui elektriturg on realiseerunud  *
* või ka pikema ajahorisondi koormamise arvutamiseks.        *
* Granulaarsus: tunni täpsusega                              *
* Allan Puusepp, Peeter Meos                                 *
**************************************************************

$ifthen %MT% == "OP"

Equations
  v_op_tootmispiirang(time_t, slot)               "Turul realiseerunud koguse tuleb aggregeeritult toota"
  v_op_max_koormus(time_t, slot, t_el)            "Tootmisüksuse lühikese perspektiivi maksimumkoormus"
  v_op_max_tarne(time_t, l, k, feedstock)         "Maksimaalne deklareeritud tarnevõimekus päevas"
  v_op_max_uttegaas(time_t)                       "Maksimaalne uttegaasi tarnevõimekus päevas "
  v_op_koormus(paev, slot, t_el)                  "Unit commmitment koormamised op mudeli ajaaknas"
;

v_op_tootmispiirang(time_t, slot)$
       (time_t_s(time_t)
    and sum((paev, time_hour)$(ord(time_t) = ord(paev)
*                           and slot_hours(slot, time_hour)
                              ),
                           op_real_koorm(paev, time_hour)) > 0)..
  sum(t_el, load_el(time_t, slot, t_el) * slot_length(time_t, slot, t_el))
  =e=
  sum((paev, weekday, time_hour)$(ord(time_t) = ord(paev)
                     and wkday_number(time_t) = ord(weekday)
                     and slot_hours(slot, weekday, time_hour)),
  op_real_koorm(paev, time_hour)) / sum(t_el$(ord(t_el) = 1), slot_length(time_t, slot, t_el))
;

********************************************************
* Operatiivmudeli piirtingimused.                      *
* Allan Puusepp, Peeter Meos                           *
********************************************************

v_op_koormus(paev, slot, t_el)$(sum((time_t, weekday, time_hour)$(ord(time_t) = ord(paev)
                                           and wkday_number(time_t) = ord(weekday)
                                           and slot_hours(slot, weekday, time_hour)),
                                           op_max_koorm(paev, time_hour, t_el)) > 0)..
  sum(time_t$(ord(time_t) = ord(paev)),  load_el(time_t, slot, t_el))
  =e=
  load_el_op(paev, slot, t_el)
;

load_el_op.lo(paev, slot, t_el)$(sum((time_t, weekday, time_hour)$(ord(time_t) = ord(paev)
                                                       and wkday_number(time_t) = ord(weekday)
                                                       and slot_hours(slot, weekday, time_hour)),
  op_min_koorm(paev, time_hour, t_el) > 0 and op_max_koorm(paev, time_hour, t_el) > 0
  ))
  =
  sum((time_t, weekday, time_hour)$(wkday_number(time_t) = ord(weekday)
                        and ord(time_t) = ord(paev)
                        and slot_hours(slot, weekday, time_hour)),
    op_min_koorm(paev, time_hour, t_el))
*/ sum(time_t$(ord(time_t) = ord(paev)), slot_length(time_t, slot, t_el))
;

v_op_max_koormus(time_t, slot, t_el)$
  (time_t_s(time_t) and sum((paev, weekday, time_hour)$(ord(time_t) = ord(paev)
                    and wkday_number(time_t) = ord(weekday)
                    and slot_hours(slot, weekday, time_hour)),
  op_max_koorm(paev, time_hour, t_el))> 0)..
  load_el(time_t, slot, t_el)
  =l=
  sum((paev, weekday, time_hour)$(ord(time_t) = ord(paev)
                    and wkday_number(time_t) = ord(weekday)
                    and slot_hours(slot, weekday, time_hour)),
   op_max_koorm(paev, time_hour, t_el))
*/ slot_length(time_t, slot, t_el)
;

v_op_max_tarne(time_t, l, k, feedstock)$
  (time_t_s(time_t) and sum(paev$(ord(time_t) = ord(paev)), op_max_tarne(l, k, feedstock, paev)) > 0)..
  sum(t$(not t_mk(t)),

  (sum(s_t$(prod_storage(s_t, t)
       and (max_ratio(k, feedstock, t) > 0)
       and fs_k(k, feedstock) ) ,
      storage_to_production(time_t, s_t, t, k, feedstock)
      )
  +
  sum((route)
      $(route_endpoint(route, k, l)
       and (max_ratio(k, feedstock, t)>0)
       and fs_k(k, feedstock)
       and t_dp_prod(l, t)),
      logs_to_production(time_t, route, t, feedstock)
      ))
  )
  =l=
  sum(paev$(ord(time_t) = ord(paev)), op_max_tarne(l, k, feedstock, paev))
;

v_op_max_uttegaas(time_t)$
  (time_t_s(time_t) and sum(paev$(ord(time_t) = ord(paev)), op_max_uttegaas(paev)) > 0)..
  sum((slot, t_el),  q(time_t, slot, "Hange", "Uttegaas", t_el) *
                     cv("Uttegaas", "Hange", "MWh") *
                     slot_length(time_t, slot, t_el))
  =l=
  sum(paev$(ord(time_t) = ord(paev)), op_max_uttegaas(paev))
;

* Soojuse piirang on pco_t_piirangutes!!

$endif
