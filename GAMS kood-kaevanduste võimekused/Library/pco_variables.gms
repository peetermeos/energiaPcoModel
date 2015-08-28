********************************************************************************
** This file contains overall variable definitons                              *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

* Definition of main components of the objective function
Free variables
  total_profit                        "Main deterministic objective function (EUR)"
;

********************************************************************************
** Decision variables describing feedstock mining and acquisition              *
** Peeter Meos                                                                 *
********************************************************************************
Positive variables
  fs_mined(time_t, feedstock, p2, k)  "Mined feedstock (t)"
  fs_acqd(time_t, feedstock)          "Externally acquired feedstock (t)"
  raw_shale(time_t, k)                "Raw oil shale mined at minewith enrichment plant (t)"
  cont_p(time_t, k, feedstock)        "Concentrated oil shale component produced by enrichment plant (t)"
  tailings_p(time_t, k, feedstock)    "Tailings produced by enrichment plant (t)"
  sieve_p(time_t, k, feedstock)       "Sieved oil shale component produced by enrichment plant (t)"
  daily_res_f(time_t, k, feedstock, l)"Daily quantity of fuel reserved for non-production uses (t)"
$ifthen.two "%prc%" == "true"
  fs_purchase(serial, time_t, k, feedstock) "How much feedstock to purchase using given contract (t)"
$endif.two
;

Binary variable
  feedstock_choice(year, month, k, feedstock) "Selection of feedstock to produce at a given mine (0/1)"
;

********************************************************************************
** Decision variables describing logistics                                     *
** Peeter Meos                                                                 *
********************************************************************************
Positive variables
* Storage levels are at the end of each time unit (ie day or month)
  storage_k(time_t, s_k, k, feedstock)               "Storage levels at mines(t)"
  storage_t(time_t, s_t, k, feedstock)               "Storage levels at production units (t)"
  last_day_storage(storage, k, feedstock)            "Final storage level (t)"

* Logistic flows
  mine_to_storage(time_t, s_k, k, feedstock)         "Feedstock moved from mine to storage (t)"
  mine_to_logs(time_t, route, feedstock)             "Feedstock moved from mine to logistics (t)"
  storage_to_logs(time_t, s_k, route, feedstock)     "Feedstock moved from storage to logistics (t)"
  logs_to_storage(time_t, route, s_t, feedstock)     "Feedstock moved from logistics to storage (t)"
  logs_to_production(time_t, route, t, feedstock)    "Feedstock moved from logistics to production (t)"
  storage_to_production(time_t, s_t, t, k, feedstock)"Feedstock moved from storage to production (t)"

********************************************************************************
** Continuous decision variables describing production                         *
** Peeter Meos                                                                 *
********************************************************************************
  sales(time_t, k, feedstock, t_mk)    "Processed shale for sale (t/day)"
  load_el(time_t, slot, t_el)          "Net power production in time slot (MWh/h)"
  load_ht(time_t, slot, t_el)          "Net heat production in time slot (MWh/h)"
  oil(time_t, t_ol)                    "Daily oil production (t/day)"

  lambda_p(time_t, slot, t_el)         "Linear approximation of efficiencies (%)"

$ifthen.two "%mx_schedule%" == "true"
  maint_opt(time_t, t)                 "Are we doing maintenance at this day (0/1)"
$endif.two

* These penalty variables are for Bender's decomposition to avoid infeasibilities
  heat_penalty(time_t, slot)           "Penalty variable for heat production requirement (EUR)"
  heat_penalty_internal(time_t, slot)  "Penalty variable for inernal heat production requirement (EUR)"
  el_penalty(time_t)                   "Penalty variable for power production requirement (EUR)"
  oil_penalty(time_t, t_ol)            "Penalty variable for oil production requirement (EUR)"
  mining_penalty(time_t, k, feedstock) "Penalty for not mining at full capacity (EUR)"
  sieve_penalty(time_t, k)             "Penalty for not mining at full capacity (EUR)"
  cont_penalty(time_t, k)              "Penalty for not mining at full capacity (EUR)"

  t_cleaning_s(time_t, t_el)           "Day counter since last boiler cleaning (days)"
;

********************************************************************************
** Discrete decision variables describing production                           *
** Peeter Meos                                                                 *
********************************************************************************
Binary variables
  k_alpha(time_t, t_el)                "Minimum component for power load (MWh/h)"

$ifthen.two "%cleanings%" == "true"
  t_cleaning(time_t, t_el)             "Loss of capacity due to boiler cleaning (0..1)"
$endif.two

$ifthen.two "%fc%" == true
  p_work(year, month, t)               "Is the production unit operational in a given year (1/0)"
  k_active(k, year)                    "Is the mine operational in a given year (0/1)"
$endif.two

$ifthen.two "%mx_schedule%" == "true"
  maint_start(time_t2, t_el)           "Are we starting maintenance at this day (0/1)"
$endif.two

  ht_active(time_t, t_el)              "Are we producing heat in this time slot (0/1)"
  st_active(time_t, slot, t_stack)     "Is the smokestack used in this time slot (0/1)"
;

********************************************************************************
** Decision variables for operational planning                                 *
** Peeter Meos                                                                 *
********************************************************************************
$ifthen.two "%MT%" == "OP"
Positive variable
  load_el_op(paev, slot, t_el)         "Semicontinuous power load variable for exact loadings"
;
$endif.two

********************************************************************************
** Decision variables for emissions                                            *
**                                                                             *
** Note that q macro used widely in production is actually sum of z_emissons   *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

Positive variable
  lambda_e(time_t, slot, t_el, k, feedstock, k_level, l_level, para_lk) "Piecewise linear variable for emissions"
  z_emission(time_t, slot, k, feedstock, t_el, para_lk)                 "Replacement variable for emissions"

$ifthen.two "%l_k_invoked%" == "true"
  add_k(time_t, slot, t_el, k_level) "Level of crushed limestone added (0..25 t/h)"
  add_l(time_t, slot, t_el, l_level) "Level of lime added (0..3 units)"
$endif.two
;

********************************************************************************
** Decision variables for unit startups. Binary k_alpha guarantees binary here *
** Peeter Meos                                                                 *
********************************************************************************
Positive variables
  t_startup(time_t, t_el)    "Are we starting the unit in this slot (0/1)"
;

*Binary variables
*  t_startup(time_t, t_el)    "Are we starting the unit in this slot (0/1)"
*;

********************************************************************************
** Decision variables for fixed costs                                          *
** Peeter Meos                                                                 *
********************************************************************************
$ifthen.two "%fc%" == true
*Positive variable
*  maint_cost(year, month, t_el)          "Additional maintenance costs for production unit"
*  st_cost(year, month, t_el)             "Addition startup costs."
*;
*
*Integer variable
*  ot_teams(year, month, plant )          "How many teams are working overtime?"
*;
$endif.two

********************************************************************************
** Decision variables for hedging and energy trading                           *
** Peeter Meos                                                                 *
********************************************************************************
Positive variable
* CO2 emissions related variables
  co2_cert_usage(serial, time_t)             "Amount of CO2 allowance used in given time unit (t)"
  co2_spot_market(time_t)                    "Purchase of CO2 from spot marktet (t)"

* Electricity hedging related variables, we are allowing both long and short positions
  el_fwd_position(serial, fwd_type, year, month)   "Position in electricity forward market (long or short)"
  el_spot_position(time_t, slot)             "Position in electricity spot market (long or short)"
;




