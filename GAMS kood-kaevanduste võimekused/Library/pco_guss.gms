** Variable replacements

********************************************************************************
** Decision variables describing feedstock mining and acquisition              *
** Peeter Meos                                                                 *
********************************************************************************
Parameters
$ifthen.two not "%two_stage%" == "true"
  total_profit_l(sim)                              "Main deterministic objective function (EUR)"
  fs_mined_l(sim, time_t, feedstock, p2, k)        "Mined feedstock (t)"
  raw_shale_l(sim, time_t, k)                      "Raw oil shale mined at minewith enrichment plant (t)"
  cont_p_l(sim, time_t, k, feedstock)              "Concentrated oil shale component produced by enrichment plant (t)"
  tailings_p_l(sim, time_t, k, feedstock)          "Tailings produced by enrichment plant (t)"
  sieve_p_l(sim, time_t, k, feedstock)             "Sieved oil shale component produced by enrichment plant (t)"
  daily_res_f_l(sim, time_t, k, feedstock, l)      "Daily quantity of fuel reserved for non-production uses (t)"
  feedstock_choice_l(sim, year, month, k, feedstock) "Selection of feedstock to produce at a given mine (0/1)"
  sales_l(sim, time_t, k, feedstock, t_mk)          "Processed shale for sale (t/day)"
$endif.two

  fs_acqd_l(sim, time_t, feedstock)                "Externally acquired feedstock (t)"
$ifthen.two "%prc%" == "true"
  fs_purchase_l(sim, serial, time_t, k, feedstock) "How much feedstock to purchase using given contract (t)"
  fs_purchase_f(sim, serial, time_t, k, feedstock) "How much feedstock to purchase using given contract (t)"
$endif.two
;

********************************************************************************
** Decision variables describing logistics                                     *
** Peeter Meos                                                                 *
********************************************************************************
Parameters
* Storage levels are at the end of each time unit (ie day or month)
  storage_k_l(sim, time_t, s_k, k, feedstock)               "Storage levels at mines(t)"
  storage_t_l(sim, time_t, s_t, k, feedstock)               "Storage levels at production units (t)"

* Logistic flows
  mine_to_storage_l(sim, time_t, s_k, k, feedstock)         "Feedstock moved from mine to storage (t)"
  mine_to_logs_l(sim, time_t, route, feedstock)             "Feedstock moved from mine to logistics (t)"
  storage_to_logs_l(sim, time_t, s_k, route, feedstock)     "Feedstock moved from storage to logistics (t)"
  logs_to_storage_l(sim, time_t, route, s_t, feedstock)     "Feedstock moved from logistics to storage (t)"
  logs_to_production_l(sim, time_t, route, t, feedstock)    "Feedstock moved from logistics to production (t)"
  logs_to_production_f(sim, time_t, route, t, feedstock)    "Feedstock moved from logistics to production (t)"
  storage_to_production_l(sim, time_t, s_t, t, k, feedstock)"Feedstock moved from storage to production (t)"
  storage_to_production_f(sim, time_t, s_t, t, k, feedstock)"Feedstock moved from storage to production (t)"


********************************************************************************
** Continuous decision variables describing production                         *
** Peeter Meos                                                                 *
********************************************************************************
  load_el_l(sim, time_t, slot, t_el)          "Net power production in time slot (MWh/h)"
  load_el_u(sim, time_t, slot, t_el)          "Net power production in time slot (MWh/h)"

  load_ht_l(sim, time_t, slot, t_el)          "Net heat production in time slot (MWh/h)"
  ht_active_l(sim, time_t, t_el)              "Are we producing heat in this time slot (0/1)"
  oil_l(sim, time_t, t_ol)                    "Daily oil production (t/day)"

  k_alpha_l(sim, time_t, t_el)                "Minimum component for power load (MWh/h)"
  k_beta_l(sim, time_t, slot, t_el)           "Variable component of power load (MWh/h)"

  lambda_p_l(sim, time_t, slot, t_el)         "Piecewise linear approximation of efficiencies (%)"

$ifthen.two "%cleanings%" == "true"
  t_cleaning_l(sim, time_t, t_el)             "Loss of capacity due to boiler cleaning (0..1)"
$endif.two

* These penalty variables are for Bender's decomposition to avoid infeasibilities
  heat_penalty_l(sim, time_t, slot)           "Penalty variable for heat production requirement (EUR)"
  heat_penalty_internal_l(sim, time_t, slot)  "Penalty variable for inernal heat production requirement (EUR)"
  el_penalty_l(sim, time_t)                   "Penalty variable for power production requirement (EUR)"
;

********************************************************************************
** Discrete decision variables describing production                           *
** Peeter Meos                                                                 *
********************************************************************************
Parameters
  st_active_l(sim, time_t, slot, t_stack)      "Is the smokestack used in this time slot (0/1)"
;

********************************************************************************
** Decision variables for operational planning                                 *
** Peeter Meos                                                                 *
********************************************************************************
$ifthen.two "%MT%" == "OP"
Parameters
  load_el_op_l(sim, paev, slot, t_el)         "Semicontinuous power load variable for exact loadings"
;
$endif.two

********************************************************************************
** Decision variables for emissions                                            *
**                                                                             *
** Note that q macro used widely in production is actually sum of z_emissons   *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************
Parameters
  lambda_e_l(sim, time_t, slot, t_el, k, feedstock, k_level, l_level, para_lk) "Piecewise linear variable for emissions"
  z_emission_l(sim, time_t, slot, k, feedstock, t_el, para_lk)                 "Replacement variable for emissions"

$ifthen.two "%l_k_invoked%" == "true"
  add_k_l(sim, time_t, slot, t_el, k_level) "Level of crushed limestone added (0..25 t/h)"
  add_l_l(sim, time_t, slot, t_el, l_level) "Level of lime added (0..3 units)"
$endif.two
;

********************************************************************************
** Decision variables for unit startups                                        *
** Peeter Meos                                                                 *
********************************************************************************
Parameters
  t_startup_l(sim, time_t, t_el)    "Are we starting the unit in this slot (0/1)"
  t_stop_l(sim, time_t, t_el)       "Are we stopping the unit in this slot (0/1)"
;

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
Parameters
* CO2 emissions related variables
  co2_cert_usage_l(sim, serial, time_t)             "Amount of CO2 allowance used in given time unit (t)"
  co2_spot_market_l(sim, time_t)                    "Purchase of CO2 from spot marktet (t)"

* Electricity hedging related variables, we are allowing both long and short positions
  el_spot_position_l(sim, time_t, slot)             "Position in electricity spot market (long or short)"
;

******** SHADOW PRICES
Parameters
$ifthen.two not "%two_stage%" == "true"
  v_k_fs_mined_m(time_t, k, feedstock)
  v_k_min_acquisition_m(year, month, k, feedstock)    "Contractually binding minimum quantity of shale to be acquired"

  v_tailings_sum_m(time_t, k)                         "Balance equation for oil shale tailings"
  v_sieve_sum_m(time_t, k)                            "Balance equation for sieved oil shale"
  v_concentrate_sum_m(time_t, k)                      "Balance equation for concentrated oil shale"
  v_enrichment1_m(time_t, k, feedstock)               "Combination of enrichment components by energy"
  v_enrichment2_m(time_t, k, feedstock)               "Combination of enrichment components by mass"

  v_sales_marg(year, month, k, feedstock, t_mk)       "Sales of concentrated shale - required quantity"
  v_sales_m_m(time_t, k, feedstock, t_mk)             "Sales of concentrated shale - balance equation"
  v_k_compulsory_kkt_m(time_t)                        "Contractually binding quantity of shale to be acquired"

  v_perm_mining2_m(year, month, k)                    "Limit on products that given mine can produce at given time"
$ifthen.three "%fc%" == "true"
* v_k_closure_m
* v_k_closure_mining_m
* v_fc_load_m
* v_fc_maintenance_m
* v_fc_startup_m
* v_fc_overtime_m
$endif.three
  v_reserved_fuel_m(time_t, k, feedstock, l)      "Monthly non-production fuel consumption (t)"
$endif.two


  v_mining_dist_m(sim, time_t, feedstock, k)
  v_max_loading_l_m(sim, time_t, l)
  v_perm_mining1_m(sim, year, month, k, feedstock)
  v_el_position_m(sim, time_t, slot)
  v_fc_load_m(sim, year, month, t_el)

  v_k_fs_acquired_m(sim, time_t, feedstock)
  v_so_quota_m(sim, year)
  v_em_lambda4_k_m(sim, time_t, slot, t_cl)
  v_em_lambda4_l_m(sim, time_t, slot, t_lime)
  v_stack_hours_m(sim, t_stack)
  v_cooling_water_m(sim, time_t, slot)
  v_co2_cert_usage_m(sim, serial)
  v_max_storage_k_m(sim, time_t, s_k)
  v_max_storage_t_m(sim, time_t, s_t)
  v_min_storage_m(sim, time_t, storage)
  v_max_throughput_m(sim, time_t, l)
  v_max_loading_k_m(sim, time_t, k)
  v_max_loading_l_m(sim, time_t, l)
  v_ht_delivery_ext_m(sim, time_t, slot)
  v_ht_delivery_int_m(sim, time_t, slot)
  v_max_load_el_m(sim, time_t, slot, t_el)
  v_max_load_pu_m(sim, time_t, slot, t_el)
  v_delta_up_el_m(sim, time_t, slot, t_el)
  v_delta_down_el_m(sim, time_t, slot, t_el)
  v_max_cap_oil_m(sim, time_t, t_ol)
  v_min_production_el_m(sim, time_t, slot)
  v_permitted_use_m(sim, year, month, t, k, feedstock)
;

* INIT
fs_acqd_l(sim, time_t, feedstock)                    = 0;

$ifthen.two not "%two_stage%" == "true"
  v_k_fs_mined_m(time_t, k, feedstock)               = 0;
  v_k_min_acquisition_m(year, month, k, feedstock)   = 0;

  v_tailings_sum_m(time_t, k)                        = 0;
  v_sieve_sum_m(time_t, k)                           = 0;
  v_concentrate_sum_m(time_t, k)                     = 0;
  v_enrichment1_m(time_t, k, feedstock)              = 0;
  v_enrichment2_m(time_t, k, feedstock)              = 0;

  v_sales_marg(year, month, k, feedstock, t_mk)      = 0;
  v_sales_m_m(time_t, k, feedstock, t_mk)            = 0;
  v_k_compulsory_kkt_m(time_t)                       = 0;

  v_perm_mining2_m(year, month, k)                   = 0;
$ifthen.three "%fc%" == "true"
* v_k_closure_m
* v_k_closure_mining_m
* v_fc_load_m
* v_fc_maintenance_m
* v_fc_startup_m
* v_fc_overtime_m
$endif.three
  v_reserved_fuel_m(time_t, k, feedstock, l)         = 0;
$endif.two

v_mining_dist_m(sim, time_t, feedstock, k)           = 0;
v_max_loading_l_m(sim, time_t, l)                    = 0;
v_perm_mining1_m(sim, year, month, k, feedstock)     = 0;
v_el_position_m(sim, time_t, slot)                   = 0;
v_fc_load_m(sim, year, month, t_el)                  = 0;
v_k_fs_acquired_m(sim, time_t, feedstock)            = 0;
v_so_quota_m(sim, year)                              = 0;
v_em_lambda4_k_m(sim, time_t, slot, t_cl)            = 0;
v_em_lambda4_l_m(sim, time_t, slot, t_lime)          = 0;
v_stack_hours_m(sim, t_stack)                        = 0;
v_cooling_water_m(sim, time_t, slot)                 = 0;
v_co2_cert_usage_m(sim, serial)                      = 0;
v_max_storage_k_m(sim, time_t, s_k)                  = 0;
v_max_storage_t_m(sim, time_t, s_t)                  = 0;
v_min_storage_m(sim, time_t, storage)                = 0;
v_max_throughput_m(sim, time_t, l)                   = 0;
v_max_loading_k_m(sim, time_t, k)                    = 0;
v_max_loading_l_m(sim, time_t, l)                    = 0;
v_ht_delivery_ext_m(sim, time_t, slot)               = 0;
v_ht_delivery_int_m(sim, time_t, slot)               = 0;
v_max_load_el_m(sim, time_t, slot, t_el)             = 0;
v_max_load_pu_m(sim, time_t, slot, t_el)             = 0;
v_delta_up_el_m(sim, time_t, slot, t_el)             = 0;
v_delta_down_el_m(sim, time_t, slot, t_el)           = 0;
v_max_cap_oil_m(sim, time_t, t_ol)                   = 0;
v_min_production_el_m(sim, time_t, slot)             = 0;
v_permitted_use_m(sim, year, month, t, k, feedstock) = 0;




