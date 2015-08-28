********************************************************************************
**                                                                             *
** Storage and logistics constraints for PCO                                   *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

Equations
* Storage level updates
  v_k_storage(time_t, s_k, k, feedstock)  "Mine storage balance equation"
*  v_k_storage2(time_t, s_k, k, feedstock) "Last day's mine storage outflow"
*  v_k_storage3(time_t, s_k)               "Last day's mine storage minimum level"
  v_t_storage(time_t, s_t, k, feedstock)  "Production unit storage balance equation"
*  v_t_storage2(time_t, s_t, k, feedstock) "Last day's production storage outflow"
*  v_t_storage3(time_t, s_t)               "Last day's production storage minimum level"

* Storage constraints
  v_max_storage_k(time_t, s_k)            "Ladude maksimumi piirang kaevandustes (t)"
  v_max_storage_t(time_t, s_t)            "Ladude maksimumi piirang tootmisüksustes (t)"
  v_min_storage(time_t, storage)          "Ladude miinimumi piirang (t)"

* Logistic route equations
  v_logistics(time_t, route, feedstock)   "Logistics balance equation"
  v_max_throughput(time_t, l)             "Maximum throughput of logistic routes (t/unit time)"
  v_max_loading_k(time_t, k)              "Maximal loading capacity at mines (t/unit time)"
  v_max_loading_l(time_t, l)              "Maximal unloading capacity at production units (t/unit time)"

* Fuel reservation constraint for non-production fuel use
  v_reserved_fuel(time_t, k, feedstock, l)      "Monthly non-production fuel consumption (t)"
  v_last_day_storage(storage)                   "Storage level for the end of last period (t)"
;

* Don't store stuff that can't be stored
storage_k.fx(time_t, s_k, k, feedstock)$no_storage(k, feedstock, s_k) = 0;
storage_t.fx(time_t, s_t, k, feedstock)$no_storage(k, feedstock, s_t) = 0;
last_day_storage.fx(storage, k, feedstock)$no_storage(k, feedstock, storage) = 0;

storage_to_production.fx(time_t, s_t, t, k, feedstock)$no_storage(k, feedstock, s_t) = 0;
logs_to_storage.fx(time_t, route, s_t, feedstock)$(sum((k, l)$(route_endpoint(route, k, l) and no_storage(k, feedstock, s_t)), 1) > 0) = 0;

* Initial storage levels
storage_k.fx(time_t, s_k, k, feedstock)$(not fs_k(k, feedstock) or gas(feedstock)) = 0;
storage_t.fx(time_t, s_t, k, feedstock)$(not fs_k(k, feedstock) or gas(feedstock)) = 0;
last_day_storage.fx(storage, k, feedstock)$(not fs_k(k, feedstock) or gas(feedstock)) = 0;

storage_k.fx(time_t, "Estonia_Aher", k, feedstock)$fs_k(k, feedstock) = 0;

storage_t.fx("1", s_t, k, feedstock)$fs_k(k, feedstock) = initial_storage(s_t, k, feedstock);
storage_k.fx("1", s_k, k, feedstock)$fs_k(k, feedstock) = initial_storage(s_k, k, feedstock);

********************************************************************************
** Logistics foolproofing: Will not deliver if there is no production capacity.*
** This eliminates unexpected waste                                            *
**                                                                             *
** Taaniel Uleksin                                                             *
********************************************************************************

storage_to_production_f(sim, time_t, s_t, t, k, feedstock)$(fs_k(k, feedstock)
and max_ratio(k, feedstock, t) > 0
and
  (
   sum((year, month, t_ol)$sameas(t, t_ol),
                                 max_load_ol_s(sim, t_ol, year, month)$y_m_t) = 0
and
  sum((year, month, t_el)$sameas(t, t_el),
                                 max_load_pu(t_el, year, month)$y_m_t) = 0
and
  sum((year, month, t_mk)$sameas(t, t_mk),
                      sale_contract(t_mk, k, feedstock, year, month)$y_m_t) = 0)
or
  sum(slot, slot_length_s(sim, time_t, slot, t)) = 0
) = 0;

logs_to_production_f(sim, time_t, route, t, feedstock)$(
  (
   sum((year, month, t_ol)$sameas(t, t_ol),
                                 max_load_ol_s(sim, t_ol, year, month)$y_m_t) = 0
and
  sum((year, month, t_el)$sameas(t, t_el),
                                 max_load_pu(t_el, year, month)$y_m_t) = 0
and
  sum((year, month, t_mk, k)$sameas(t, t_mk),
                      sale_contract(t_mk, k, feedstock, year, month)$y_m_t) = 0)
or
  sum(slot, slot_length_s(sim, time_t, slot, t)) = 0
) = 0;

********************************************************************************
**                                                                             *
** Storage levels must not exceed maximum storage capacities                   *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************
v_max_storage_k(time_t, s_k)$time_t_s(time_t)..
   sum((feedstock, k), storage_k(time_t, s_k, k, feedstock))
   =l=
$ifthen.two "%mine_storage%" == "false"
   1000
$else.two
   max_storage(s_k)
$endif.two
;

v_max_storage_t(time_t, s_t)$time_t_s(time_t)..
  sum((feedstock, k), storage_t(time_t, s_t, k, feedstock))
  =l=
  max_storage(s_t)
;

********************************************************************************
**                                                                             *
** Storage levels must not go below minimum storage levels.                    *
**                                                                             *
** Taaniel Uleksin                                                             *
********************************************************************************
v_min_storage(time_t, storage)$time_t_s(time_t)..
   sum((s_t, feedstock, k)$(sameas(s_t, storage)
*                        and fs_k(k, feedstock)
*                        and not no_storage(k, feedstock, storage)
                           ), storage_t(time_t, s_t, k, feedstock))
   +
   sum((s_k, feedstock, k)$(sameas(s_k, storage)
*                       and fs_k(k, feedstock)
*                       and not no_storage(k, feedstock, storage)
                         ), storage_k(time_t, s_k, k, feedstock))
   =g=
   min_storage(storage)
;

********************************************************************************
**                                                                             *
** Mine storage balance equation                                               *
** level = yesterday's level + from mine - to logistics                        *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************
mine_to_storage.up(time_t, s_k, k, feedstock)
      $(not fs_k(k, feedstock) and no_storage(k, feedstock, s_k)) = 0;
mine_to_storage.up(time_t, s_k, k, feedstock)$(no_storage(k, feedstock, s_k)) = 0;

v_last_day_storage(storage)..
  sum((k, feedstock)$(fs_k(k, feedstock) and not no_storage(k, feedstock, storage)),
                 last_day_storage(storage, k, feedstock))
  =g=
  min_storage(storage)
;

v_k_storage(time_t, s_k, k, feedstock)
                 $(time_t_s(time_t)
*               and not (ord(time_t) eq card(time_t))
              and fs_k(k, feedstock)
                  )..
* Storage tomorrow
   storage_k(time_t + 1, s_k, k ,feedstock)$(ord(time_t) < card(time_t_s))
* + %fix_date% * (1-fix_switch))
   +
   last_day_storage(s_k, k, feedstock)$(ord(time_t) = card(time_t_s))
**(fix_switch) or ord(time_t) = card(time_t_s) + %fix_date%)
   =e=
* Storage today
   storage_k(time_t, s_k, k, feedstock)
   +
* Arrival from mining
  mine_to_storage(time_t, s_k, k, feedstock)$(mine_storage(k, s_k)
                                                         and fs_k(k, feedstock))
   -
* Feedstock entering logistics
  sum((route, l)$(route_endpoint(route, k, l)
               and mine_storage(k, s_k)
               and fs_k(k, feedstock)),
        storage_to_logs(time_t, s_k, route, feedstock)
        )
;

********************************************************************************
**                                                                             *
** Production storage balance equation                                         *
** level = yesterday's level + from logs - to production                       *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************
v_t_storage(time_t, s_t, k, feedstock)
                        $(time_t_s(time_t)
*                      and not (ord(time_t) eq card(time_t))
                          and fs_k(k, feedstock)
                          )..

* Storage tomorrow
  storage_t(time_t+1, s_t, k, feedstock)$(fs_k(k, feedstock) and (ord(time_t) < card(time_t_s)))
* + %fix_date% * (1-fix_switch)))
  +
  last_day_storage(s_t, k, feedstock)$(fs_k(k, feedstock) and (ord(time_t) = card(time_t_s)))
* *(fix_switch) or ord(time_t) = card(time_t_s) + %fix_date%))
=e=
* Storage today
  storage_t(time_t, s_t, k, feedstock)$(fs_k(k, feedstock))
  +
* From logistics to storage
  sum((route, l)$route_endpoint(route, k, l),
       logs_to_storage(time_t, route, s_t, feedstock)
       $t_dp_storage(l, s_t)
       )
  -
* From storage to production
  sum(t, storage_to_production(time_t, s_t, t, k, feedstock)
      $(prod_storage(s_t, t) and fs_k(k, feedstock)))
;

********************************************************************************
** Logistics balance - feedstock in == feedstock out                           *
**                                                                             *
** Macros used: none                                                           *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************
v_logistics(time_t, route, feedstock)$time_t_s(time_t)..
* From mine to logistics
   sum((k, l)$(route_endpoint(route, k, l) and fs_k(k, feedstock)
* If the tuple allows to use this combination of fuel and logistics line
        and (log_f_constraint(route, feedstock)
* .. or the tuple is not defined at all for given logistics line
          or sum(p2$log_f_constraint(route, p2), 1) = 0)
     ),
      mine_to_logs(time_t, route, feedstock))
   +
* From storage to logistics
    sum((k, s_k, l)$(route_endpoint(route, k, l)
* If the tuple allows to use this combination of fuel and logistics line
        and (log_f_constraint(route, feedstock)
* .. or the tuple is not defined at all for given logistics line
          or sum(p2$log_f_constraint(route, p2), 1) = 0)
        ),
        storage_to_logs(time_t, s_k, route, feedstock)
        $(mine_storage(k, s_k) and fs_k(k, feedstock)))

   =e=
* From logistics to storage
  sum((k, s_t, l)$route_endpoint(route, k, l),
       logs_to_storage(time_t, route, s_t, feedstock)
       $(t_dp_storage(l, s_t) and fs_k(k, feedstock)))
  +
* From logistics to production
  sum((k, l, t)$route_endpoint(route, k, l),
      logs_to_production(time_t, route, t, feedstock)
      $(t_dp_prod(l, t)
      and fs_k(k, feedstock)
      )
  )
  +
* Fuel reserved for non-production uses (such as testing and commissioning)
   sum((k, l)$(route_endpoint(route, k, l) and fs_k(k, feedstock)),
     daily_res_f(time_t, k, feedstock, l)
   )
;

********************************************************************************
**                                                                             *
** Maximum throughput constraint for logistic routes (t/time unit)             *
**                                                                             *
** Macros used: none                                                           *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************
v_max_throughput(time_t, l)$(time_t_s(time_t)
                                   and max_throughput(l) > 0)..

  sum((s_t, route, k, feedstock)$route_endpoint(route, k, l),
       logs_to_storage(time_t, route, s_t, feedstock)
       $(t_dp_storage(l, s_t) and
         fs_k(k, feedstock)))
  +
* From logs direct to production
  sum((route, k, t, feedstock)$route_endpoint(route, k, l),
      logs_to_production(time_t, route, t, feedstock)
      $(t_dp_prod(l, t) and fs_k(k, feedstock)))
  +
* Fuel reserved for non-production uses (such as testing and commissioning)
  sum((k, feedstock),
    daily_res_f(time_t, k, feedstock, l)
     )
 =l=
 max_throughput(l) * days_in_t(time_t)
;

********************************************************************************
**                                                                             *
** Constraint for maximum loading capacity at mines (feedstock sources)        *
**                                                                             *
** Macros used: none                                                           *
** Notes: None                                                                 *
**                                                                             *
********************************************************************************
v_max_loading_k(time_t, k)$time_t_s(time_t)..
  sum((route, feedstock, l)$(route_endpoint(route, k, l)
                         and not gas(feedstock)),
        mine_to_logs(time_t, route, feedstock))
  +
  sum((route, s_k, feedstock)$(mine_storage(k, s_k) and fs_k(k, feedstock)
                                                    and not gas(feedstock)
      ),
      storage_to_logs(time_t, s_k, route, feedstock)
     )
  =l=
  sum((year, month)$y_m_t, max_loading_k(k, year)) * days_in_t(time_t)
;

********************************************************************************
**                                                                             *
** Constraint for maximum unloading capacity at production units               *
**                                                                             *
** The constraint is messy because of Bender's decomposition. We are           *
** mixing stochastic bits with non-stochastic.                                 *
**                                                                             *
** Macros used: none                                                           *
** Notes: None                                                                 *
**                                                                             *
********************************************************************************

v_max_loading_l(time_t, l)$time_t_s(time_t)..
  sum((s_t, route, k, feedstock)$(route_endpoint(route, k, l)
                              and not gas(feedstock)),
       logs_to_storage(time_t, route, s_t, feedstock)
       $(t_dp_storage(l, s_t) and
         fs_k(k, feedstock)))
  +
  sum((route, k, t, feedstock)$(route_endpoint(route, k, l)
                            and not gas(feedstock)),
      logs_to_production(time_t, route, t, feedstock)
      $(t_dp_prod(l, t) and fs_k(k, feedstock)))
   +
* Without Bender's decomposition
  (1 - bender) *
* Fuel reserved for non-production uses (such as testing and commissioning)
   sum((route, k, feedstock)$(route_endpoint(route, k, l) and fs_k(k, feedstock)
    and not gas(feedstock)
    and sum((year, month)$y_m_t, reserved_fuel(year, month, k, feedstock, l)) > 0
       ),
     daily_res_f(time_t, k, feedstock, l))
  =l=
  sum((year, month)$y_m_t, max_loading_l(l, year)) * days_in_t(time_t)
$ifthen.s "%two_stage%" == true
  -
* With Bender's decomposition
  (bender) *
   sum((route, k, feedstock)$(route_endpoint(route, k, l) and fs_k(k, feedstock)
    and not gas(feedstock)
    and sum((year, month)$y_m_t, reserved_fuel(year, month, k, feedstock, l)) > 0
       ),
      daily_res_f.l(time_t, k, feedstock, l))
$endif.s
;

********************************************************************************
**                                                                             *
** Constraint for monthly fuel reservations for non-production use             *
**                                                                             *
** Description: Every month the value chain consumes a set amount of           *
** primary energy for non production use, such as testing, commissioning       *
** etc. Since this use is not reflected in revenue and thus absent from        *
** objective function it needs to be modelled as a separate constraint.        *
**                                                                             *
** Macros used: y_m_t - couples model day with cal month and year              *
** Notes: None                                                                 *
**                                                                             *
********************************************************************************

v_reserved_fuel(time_t, k, feedstock, l)$(time_t_s(time_t)
                                      and sum((year, month)$y_m_t,
                               reserved_fuel(year, month, k, feedstock, l)) > 0
                                          )..
  daily_res_f(time_t, k, feedstock, l)
  =e=
  sum((year, month)$y_m_t, reserved_fuel(year, month, k, feedstock, l)
                           / days_in_month_m(year, month))
;

