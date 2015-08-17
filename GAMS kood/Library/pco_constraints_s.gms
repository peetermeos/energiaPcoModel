********************************************************************************
**                                                                             *
** This file contains constraints related to feedstock mining, acquisitions    *
** and sales. It touches also logistics, but most logistics are described in   *
** pco_constraints_l.gms                                                       *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

Equations
* General mining capacity and distribution constraints
   v_k_fs_mined(time_t, k, feedstock)               "Daily quantity of feedstock mined (t)"
   v_k_fs_acquired(time_t, feedstock)         "Daily quantity of feedstock acquired from external sources (t)"
   v_mining_dist(time_t, feedstock, k)        "Distribution of mined feedstock for mines w/o enrichment plant"
   v_aquisition_dist(time_t, feedstock)       "Distribution of externally acquired feedstock"

* Constraints for enrichment plants
  v_tailings_sum(time_t, k)                         "Balance equation for oil shale tailings"
  v_sieve_sum(time_t, k)                            "Balance equation for sieved oil shale"
  v_concentrate_sum(time_t, k)                      "Balance equation for concentrated oil shale"
  v_enrichment1(time_t, k, feedstock)               "Combination of enrichment components by energy"
  v_enrichment2(time_t, k, feedstock)               "Combination of enrichment components by mass"

  v_perm_mining1(year, month, k, feedstock)   "Limit on products that given mine can produce at given time"
  v_perm_mining2(year, month, k)                    "Limit on products that given mine can produce at given time"
  v_open_pit_combo(time_t, k, feedstock)            "Final product can be combined from more than one raw shale type"

* Concentrated oil shale sales and purchase
  v_sales(year, month, k, feedstock, t_mk)          "Sales of concentrated shale - required quantity"
  v_sales_m(time_t, k, feedstock, t_mk)             "Sales of concentrated shale - balance equation"
  v_k_compulsory_kkt(time_t)                        "Contractually binding quantity of shale to be acquired"
  v_k_min_acquisition(year, month, k, feedstock)    "Contractually binding minimum quantity of shale to be acquired"

  v_k_fs_max_acq(time_t, feedstock)   

* Purchase contracts
$ifthen.two "%prc%" == "true"
  v_fs_purchase(serial, time_t, k, feedstock)"Feedstock purchase contracts for external sources"
$endif.two

* Additional constraints for fixed costs
$ifthen.two "%fc%" == "true"
*  v_k_closure(year, k)                              "Opening already closed mine is not permitted"
*  v_k_closure_mining(time_t, k)                     "Cannot use mine that has been shut down"
$endif.two
;

$ifthen.two "%mine_storage%" == "false"
* In case of storage at mines turned off we will not store feedstock at
* mines' storage
mine_to_storage.fx(time_t, l_k, k, feedstock)= 0;
storage_to_logs.fx(time_t, l_k, route, feedstock) = 0;
$endif.two

* Cuts in solution space.
fs_mined.fx(time_t, p2, feedstock, k)$(not fs_k(k, feedstock)
                                       or not k_mines(k, p2)) = 0;

********************************************************************************
** Calculate working days in month for mines.                                  *
** this is required since we are given monthly mining capacities as input,     *
** but may required daily capacities in the model.                             *
**                                                                             *
** Macros used: y_m_t - tuple for connecting calendar time and model time      *
** Peeter Meos 15. august 2014                                                 *
********************************************************************************
Parameter monthly_workdays(year, month, k);
monthly_workdays(year, month, k) = sum(time_t$(y_m_t),
                              1$(day_type(time_t) = 0)
                                    +
                              1$(day_type(time_t) = 1 and k_workday(k, "6") = 1)
                                    +
                              1$(day_type(time_t) = 2 and k_workday(k, "7") = 1)
                                  );

* No production on Sundays and holidays (unnecessary for monthly production)
fs_mined.fx(time_t, p2, feedstock, k)$(fs_k(k, feedstock)
                                   and day_type(time_t) = 2
                                   and k_workday(k, "7") = 0) = 0;

* No production on Saturdays (unnecessary for monthly model)
fs_mined.fx(time_t, p2, feedstock, k)$(fs_k(k, feedstock)
                                   and day_type(time_t) = 1
                                   and k_workday(k, "6") = 0) = 0;

********************************************************************************
** The use of purchase contracts                                               *
**                                                                             *
** Taaniel Uleksin                                                             *
** Peeter Meos                                                                 *
********************************************************************************
$ifthen.two "%prc%" == "true"
fs_purchase_f(sim, serial, time_t, k, feedstock)$(fs_k(k, feedstock) and sum((year, month)
 $y_m_t, contract_s(sim, serial, year, month, k, feedstock, "kogus")) = 0) = 0;

v_fs_purchase(serial, time_t, k, feedstock)$(time_t_s(time_t)
*  and sum((year, month)
*  $y_m_t, contract(serial, year, month, k, feedstock, "kogus")) > 0
   )..
  fs_purchase(serial, time_t, k, feedstock)
  =l=
  sum((year, month)$(y_m_t
*                and contract(serial, year, month, k, feedstock, "kogus") > 0
                   ) ,
      contract(serial, year, month, k, feedstock, "kogus")

* Calorific values in purchase contracts and in cv() table differ slightly
* Since purchased fuel is delivered to the gate of the production unit and
* never stored, then the only inaccuracy is in fuel supply costs, which
* is not significant enough to worry too much about.
  / (days_in_month_m(year, month))
  / 24
  * sum(slot, smax(t_mk, slot_length_orig(time_t, slot, t_mk)))
  )
;
$endif.two
********************************************************************************
** Mining and acquisition cannot exceed daily maximum capacities.              *
**                                                                             *
** Note: we are separating mining and acquisition, because the latter may      *
**       contain some stochastic elements                                      *
** Macros used: y_m_t - tuple connecting model time to calendar time           *
**                                                                             *
** Peeter Meos                                                                 *
** Taaniel Uleksin                                                             *
********************************************************************************
v_k_fs_max_acq(time_t, feedstock)..
   fs_mined(time_t, feedstock, feedstock, "Hange")
   =l=
   sum((year, month)$y_m_t, max_mining_cap("Hange", feedstock, year, month)
                          / monthly_workdays(year, month, "Hange"))
;

v_k_fs_acquired(time_t, feedstock)$time_t_s(time_t)..
   fs_acqd(time_t, feedstock)
   =l=
* Daily maximal amount must be divided by working days in given month

   fs_mined(time_t, feedstock, feedstock, "Hange")

$ifthen.two "%prc%" == "true"
   + sum(serial, fs_purchase(serial, time_t, "Hange", feedstock))
$endif.two
;

v_k_fs_mined(time_t, k, feedstock)$(time_t_s(time_t)
                                and not sameas(k, "Hange")
                                and k_mines(k, feedstock))..
   sum(p2$fs_k(k, p2), fs_mined(time_t, feedstock, p2, k))
                     $((not sameas(k, "Hange")) and (not k_enrichment(k)))
   +
   raw_shale(time_t, k)$(k_enrichment(k))
   =l=
* Daily maximal amount must be divided by working days in given month
   (sum((year, month)$y_m_t, max_mining_cap(k, feedstock, year, month)
                          / monthly_workdays(year, month, k))
   )$(sum((year, month)$y_m_t, monthly_workdays(year, month, k) > 0))
;

********************************************************************************
** For some acquisition contracts we have required monthly acuisition          *
** levels                                                                      *
**                                                                             *
** Macros used: y_m_t - tuple connecting model time to calendar time           *
**                                                                             *
** Peeter Meos                                                                 *
** Taaniel Uleksin                                                             *
********************************************************************************
v_k_compulsory_kkt(time_t)$time_t_s(time_t)..
  fs_mined(time_t, "Energeetiline", "Energeetiline", "KKT")
$ifthen.two  "%kkt_free%" == "true"
  =g= 0
$else.two
  =l=
  (sum((year, month)$y_m_t, max_mining_cap("KKT", "Energeetiline", year, month)
                         / monthly_workdays(year, month, "KKT"))
   )$(sum((year, month)$y_m_t, monthly_workdays(year, month, "KKT") > 0))
$endif.two
;

********************************************************************************
** For some acquisition contracts we have minimal  monthly acuisition          *
** levels                                                                      *
**                                                                             *
** Macros used: y_m_t - tuple connecting model time to calendar time           *
**                                                                             *
** Peeter Meos                                                                 *
** Taaniel Uleksin                                                             *
********************************************************************************
v_k_min_acquisition(year, month, k, feedstock)..
  sum(time_t$(time_t_s(time_t) and y_m_t),
     sum(p2, fs_mined(time_t, p2, feedstock, k)
   * enrichment_coef(p2, k, feedstock)))
  =g=
$ifthen.two  "%kkt_free%" == "true"
  0
$else.two
  sum(time_t$(time_t_s(time_t) and y_m_t),
   fs_min_acq(k, feedstock, year, month)
   / days_in_month_m(year, month))
$endif.two
;

* In case of purchase contracts are switched on we need to handle
* the external acquisition functionality differently.

$ifthen.two "%prc%" == "true"
  fs_mined.fx(time_t, feedstock, p2, "Hange")$(time_t_s(time_t)
                                           and not sameas(feedstock, p2)) = 0;
$endif.two

********************************************************************************
** Distribution of feedstock into logisics and storage for mines that do not   *
** have an enrichment plant. Both Bender version and regular.                  *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************
v_mining_dist(time_t, feedstock, k)$(time_t_s(time_t)
                                           and fs_k(k, feedstock)
                                           and not sameas(k, "Hange"))..
  sum((s_k)$(mine_storage(k, s_k)
         and fs_k(k, feedstock)
         and not no_storage(k, feedstock, s_k)),
         mine_to_storage(time_t, s_k, k, feedstock))
   +
   sum((route, l)
      $(route_endpoint(route, k, l) and fs_k(k, feedstock)),
          mine_to_logs(time_t, route, feedstock))

  =l=
* Without Bender's decomposition
  (1 - bender) *
  sum(p2$k_mines(k, p2), fs_mined(time_t, p2, feedstock, k)
                  * enrichment_coef(p2, k, feedstock))$(not sameas(k, "Hange"))
  +
* With Bender's decomposition
  (bender) *
  sum(p2$k_mines(k, p2), fs_mined.l(time_t, p2, feedstock, k)
                  * enrichment_coef(p2, k, feedstock))$(not sameas(k, "Hange"))
;

********************************************************************************
** Distribution of feedstock into logisics and storage external                *
** acquisitions. This is separate because of possible stochasticity.           *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************
v_aquisition_dist(time_t, feedstock)$time_t_s(time_t)..
  sum((s_k)$(mine_storage("Hange", s_k)
         and fs_k("Hange", feedstock)
         and not no_storage("Hange", feedstock, s_k)),
         mine_to_storage(time_t, s_k, "Hange", feedstock))
   +
   sum((route, l)
     $(route_endpoint(route, "Hange", l) and fs_k("Hange", feedstock)),
          mine_to_logs(time_t, route, feedstock))

  =l=
  fs_acqd(time_t, feedstock)
;

********************************************************************************
** Enrichment plant separates mined oil shale into three components that       *
** later get blended into specified delivered products                         *
**                                                                             *
** Peeter Meos                                                                 *
** Taaniel Uleksin                                                             *
********************************************************************************
v_tailings_sum(time_t, k)$(time_t_s(time_t) and k_enrichment(k))..
sum(feedstock$fs_k(k, feedstock), tailings_p(time_t, k, feedstock))
=l= tailings_pct(k) * raw_shale(time_t, k);

v_sieve_sum(time_t, k)$(time_t_s(time_t) and k_enrichment(k))..
sum(feedstock$fs_k(k, feedstock), sieve_p(time_t, k, feedstock))
=l= sieve_pct(k) * raw_shale(time_t, k);

v_concentrate_sum(time_t, k)$(time_t_s(time_t) and k_enrichment(k))..
sum(feedstock$fs_k(k, feedstock), cont_p(time_t, k, feedstock))
=l= cont_pct(k) * raw_shale(time_t, k);

********************************************************************************
** Balance equations for enrichment blending                                   *
**                                                                             *
** Peeter Meos                                                                 *
** Taaniel Uleksin                                                             *
********************************************************************************
v_enrichment1(time_t, k, feedstock)$(time_t_s(time_t)
                                 and fs_k(k, feedstock) and k_enrichment(k))..
  cv(feedstock, k, "MWh")  * fs_mined(time_t, "Kaevis", feedstock, k)
  =e=
  cv("Tykikivi", k, "MWh") * cont_p(time_t, k, feedstock)
    +
  cv("Aheraine", k, "MWh") * tailings_p(time_t, k, feedstock)
    +
  sieve_cv(k) * sieve_p(time_t, k, feedstock)
;

v_enrichment2(time_t, k, feedstock)$(time_t_s(time_t)
                                 and fs_k(k, feedstock) and k_enrichment(k))..
fs_mined(time_t, "Kaevis", feedstock, k)
=e=
sieve_p(time_t, k, feedstock)
                                  + cont_p(time_t, k, feedstock)
 + tailings_p(time_t, k, feedstock)
;

********************************************************************************
** Fixed costs for mines.                                                      *
** If mine is not profitable and does not cover its fixed costs we are shutting*
** it down.                                                                    *
**                                                                             *
** Taaniel Uleksin                                                             *
********************************************************************************
$ifthen.two "%fc%" == "true"
** Opening already closed mine is not permitted
*v_k_closure(year, k)..
*k_active(k, year)$(ord(year) gt 1)
*=l=
*k_active(k, year - 1)$(ord(year) gt 1)
*;
*
** Cannot use mine that has been shut down
*v_k_closure_mining(time_t, k)..
*sum((feedstock, p2), fs_mined(time_t, feedstock, p2, k))
*=l=
*sum((year, month), k_active(k, year)$y_m_t * M)
*;
*
$endif.two

********************************************************************************
** Production constraints.                                                     *
** For instance simultaneous mining of 7.0 and 7.5 MJ/kg oil shale is not      *
** possbile.                                                                   *
**                                                                             *
** Peeter Meos                                                                 *
** August 2014                                                                 *
********************************************************************************
v_perm_mining1(year, month, k, feedstock)$(perm_mining(year, month, k, feedstock) > 0)..
   sum(time_t$(time_t_s(time_t) and y_m_t),
   sum((s_k)$(mine_storage(k, s_k)
         and fs_k(k, feedstock)
         and not no_storage(k, feedstock, s_k)),
         mine_to_storage(time_t, s_k, k, feedstock))
   +
   sum((route, l)
      $(route_endpoint(route, k, l) and fs_k(k, feedstock)),
          mine_to_logs(time_t, route, feedstock))
  )
  =l=
* Big M is too small.
* Without Bender's decomposition
  (1 - bender) *
  feedstock_choice(year, month, k, feedstock) * M * M
$ifthen.s  "%two_stage%" == true
  +
* With Bender's decomposition
  (bender) *
  feedstock_choice.l(year, month, k, feedstock) * M * M
$endif.s
;

v_perm_mining2(year, month, k)$(sum(feedstock,
                                    perm_mining(year, month, k, feedstock)) > 0)..
  sum(feedstock$(perm_mining(year, month, k, feedstock) > 0),
              feedstock_choice(year, month, k, feedstock))
  =l=
  1
;

********************************************************************************
** For Narva open pit mine we need to combine final product possibly           *
** from more than one type of raw oil shale.                                   *
**                                                                             *
** Macros used: y_m_t - tuple connecting calendar time to model time           *
** Peeter Meos                                                                 *
********************************************************************************

v_open_pit_combo(time_t, k, feedstock)$(time_t_s(time_t)
* Dollar condition for open pit mines that mine more than one original product
              and (sum(p2$(enrichment_coef(p2, k, feedstock) = 1), 1) > 1))..
sum(p2$k_mines(k, p2), (fs_mined(time_t, p2, feedstock, k)
                        * enrichment_coef(p2, k, feedstock))
                        * cv(p2, k, "MWh"))
 =e=
sum(p2$k_mines(k, p2), (fs_mined(time_t, p2, feedstock, k)
                        * enrichment_coef(p2, k, feedstock))
                        * cv(feedstock, k, "MWh"))
;

********************************************************************************
** Constraints for oil shale sale contracts to external customers.             *
**                                                                             *
** Macros used: y_m_t - tuple connecting calendar time to model time           *
** Peeter Meos                                                                 *
********************************************************************************
sales.fx(time_t, k, feedstock, t_mk)$(not max_ratio(k, feedstock, t_mk) > 0) = 0;
*sales.up(time_t, k, feedstock, t_mk)$(max_ratio(k, feedstock, t_mk) > 0) = M*M;

v_sales(year, month, k, feedstock, t_mk)$(sum(time_t$(time_t_s(time_t)
                                                  and y_m_t), 1) > 0)..
  sum(time_t$(time_t_s(time_t) and y_m_t), sales(time_t, k, feedstock, t_mk))
$ifthen.two "%sales%" == "true"
  =e=
$else.two
  =l=
$endif.two
  sum(time_t$(time_t_s(time_t) and y_m_t),
    sale_contract(t_mk, k, feedstock, year, month))
  / days_in_month_m(year, month)
;

v_sales_m(time_t, k, feedstock, t_mk)$(time_t_s(time_t)
                                   and max_ratio(k, feedstock, t_mk) > 0)..
* With Bender's decomposition
  (bender) *
  sum(p2$k_mines(k, p2), fs_mined(time_t, p2, feedstock, k)
                       * enrichment_coef(p2, k, feedstock))
   +
* Without Bender's decomposition
  (1 - bender) *
  to_production(time_t, k, feedstock, t_mk)
  =e=
  sales(time_t, k, feedstock, t_mk)
;

