Set h solution headers / modelstat, solvestat, objval /;
Parameter o /
             UpdateType   2
             SkipBaseCase 0
             LogOption    1
             NoMatchLimit 500
            /
          r_s(sim ,h) Solution status report;
;

Set sim_subset(sim);
sim_subset(sim) = yes;

Set dict
   /
     o.                     opt.                  r_s
     sim_subset.            scenario.             ""

$ifthen.two not "%two_stage%" == "true"
*  fs_mined.                 level.                fs_mined_l
*  raw_shale.                level.                raw_shale_l
*  cont_p.                   level.                cont_p_l
*  tailings_p.               level.                tailings_p_l
*  sieve_p_l.                level.                sieve_p_l
*  daily_res_f.              level.                daily_res_f_l
*  feedstock_choice.         level.                feedstock_choice_l
*  sales.                    level.                sales_l
$endif.two

     fs_acqd.               level.                fs_acqd_l
$ifthen.two "%prc%" == "true"
     fs_purchase.           level.                fs_purchase_l
     fs_purchase.           fixed.                fs_purchase_f
$endif.two

  storage_k.                level.                storage_k_l
  storage_t.                level.                storage_t_l

* Logistic flows
  mine_to_storage.          level.                mine_to_storage_l
  mine_to_logs.             level.                mine_to_logs_l
  storage_to_logs.          level.                storage_to_logs_l
  logs_to_storage.          level.                logs_to_storage_l
  logs_to_production.       level.                logs_to_production_l
*  logs_to_production.       fixed.                logs_to_production_f
  storage_to_production.    level.                storage_to_production_l
*  storage_to_production.    fixed.                storage_to_production_f

********************************************************************************
** Continuous decision variables describing production                         *
** Peeter Meos                                                                 *
********************************************************************************
  load_el.                  level.                load_el_l
  load_el.                  upper.                load_el_u
  load_ht.                  level.                load_ht_l
  ht_active.                level.                ht_active_l
  oil.                      level.                oil_l
  k_alpha.                  level.                k_alpha_l
  lambda_p.                 level.                lambda_p_l

$ifthen.two "%cleanings%" == "true"
  t_cleaning.               level.                t_cleaning_l
$endif.two

* These penalty variables are for Bender's decomposition to avoid infeasibilities
  heat_penalty.             level.                heat_penalty_l
  heat_penalty_internal.    level.                heat_penalty_internal_l
  el_penalty.               level.                el_penalty_l

$ifthen.two "%MT%" == "OP"
  load_el_op.               level.                load_el_op_l
$endif.two

********************************************************************************
** Decision variables for emissions                                            *
**                                                                             *
** Note that q macro used widely in production is actually sum of z_emissons   *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************
  lambda_e.                 level.                lambda_e_l
  z_emission.               level.                z_emission_l

$ifthen.two "%l_k_invoked%" == "true"
  add_k.                    level.                add_k_l
  add_l.                    level.                add_l_l
$endif.two

********************************************************************************
** Decision variables for unit startups                                        *
** Peeter Meos                                                                 *
********************************************************************************
  t_startup.                level.                t_startup_l
  t_stop.                   level.                t_stop_l

********************************************************************************
** Decision variables for hedging and energy trading                           *
** Peeter Meos                                                                 *
********************************************************************************
* CO2 emissions related variables
  co2_cert_usage.            level.                co2_cert_usage_l
  co2_spot_market.           level.                co2_spot_market_l

* Electricity hedging related variables, we are allowing both long and short positions
  el_spot_position.          level.                el_spot_position_l

******** SHADOW PRICES
$ifthen.two not "%two_stage%" == "true"
*  v_k_fs_mined.              marginal.            v_k_fs_mined_m
*  v_k_compulsory_kkt.        marginal.            v_k_compulsory_kkt_m
*  v_k_min_acquisition.       marginal.            v_k_min_acquisition_m
*  v_tailings_sum.            marginal.            v_tailings_sum_m
*  v_sieve_sum.               marginal.            v_sieve_sum_m
*  v_concentrate_sum.         marginal.            v_concentrate_sum_m
*  v_enrichment1.             marginal.            v_enrichment1_m
*  v_enrichment2.             marginal.            v_enrichment2_m
*  v_perm_mining2.            marginal.            v_perm_mining2_m
*  v_sales.                   marginal.            v_sales_marg
*  v_sales_m.                 marginal.            v_sales_m_m
$ifthen.three "%fc%" == "true"
** v_k_closure.               marginal.            v_k_closure_m
** v_k_closure_mining.        marginal.            v_k_closure_mining_m
** v_fc_load.                 marginal.            v_fc_load_m
** v_fc_maintenance.          marginal.            v_fc_maintenance_m
** v_fc_startup.              marginal.            v_fc_startup_m
** v_fc_overtime.             marginal.            v_fc_overtime_m
$endif.three
*  v_reserved_fuel.           marginal.            v_reserved_fuel_m
$endif.two

  v_mining_dist.             marginal.            v_mining_dist_m
  v_perm_mining1.            marginal.            v_perm_mining1_m
  v_el_position.             marginal.            v_el_position_m

$ifthen.two "%fc%" == "true"
  v_fc_load.                 marginal.            v_fc_load_m
$endif.two

  v_k_fs_acquired.           marginal.            v_k_fs_acquired_m
  v_so_quota.                marginal.            v_so_quota_m

$ifthen.two "%l_k_invoked%" == "true"
  v_em_lambda4_k.            marginal.            v_em_lambda4_k_m
  v_em_lambda4_l.            marginal.            v_em_lambda4_l_m
$endif.two

$ifthen.two "%hr%" == "true"
  v_stack_hours.             marginal.            v_stack_hours_m
$endif.two

$ifthen.two "%cw%" == "true"
  v_cooling_water.           marginal.            v_cooling_water_m
$endif.two

  v_co2_cert_usage.          marginal.            v_co2_cert_usage_m
  v_max_storage_k.           marginal.            v_max_storage_k_m
  v_max_storage_t.           marginal.            v_max_storage_t_m
  v_min_storage_t.           marginal.            v_min_storage_t_m
  v_max_throughput.          marginal.            v_max_throughput_m
  v_max_loading_k.           marginal.            v_max_loading_k_m
  v_max_loading_l.           marginal.            v_max_loading_l_m
  v_ht_delivery_ext.         marginal.            v_ht_delivery_ext_m
  v_ht_delivery_int.         marginal.            v_ht_delivery_int_m
  v_max_load_el.             marginal.            v_max_load_el_m
  v_max_load_pu.             marginal.            v_max_load_pu_m
  v_delta_up_el.             marginal.            v_delta_up_el_m
  v_delta_down_el.           marginal.            v_delta_down_el_m
  v_max_cap_oil.             marginal.            v_max_cap_oil_m
  v_min_production_el.       marginal.            v_min_production_el_m
  v_permitted_use.           marginal.            v_permitted_use_m

**** PARAMETERS
  max_load_el.               param.               max_load_el_s
  max_load_ol.               param.               max_load_ol_s
  slot_length.               param.               slot_length_s1
  el_price_slot.             param.               el_price_slot_s
  co2_price.                 param.               co2_price_s
  oil_price.                 param.               oil_price_s
  heat_price.                param.               heat_price_s
$ifthen.two "%prc%" == "true"
  contract.                  param.               contract_s1
$endif.two
  sale_contract.             param.               sale_contract_s
  /
;

max_load_ol_s(sim, t_ol, year, month) = max_load_ol_s(sim, t_ol, year, month)$(sum(time_t$y_m_t, 1) > 0);
max_load_el_s(sim, t_el, year, month) = max_load_el_s(sim, t_el, year, month)$(sum(time_t$y_m_t, 1) > 0);

Parameter slot_length_s1(sim, time_t, slot, t);

slot_length_s1(sim, time_t, slot, t) = slot_length_s(sim, time_t, slot, t);
slot_length_s1(sim, time_t, slot, t)$(sameas(t, "VKG"))  = 0;
slot_length_s1(sim, time_t, slot, t)$(sameas(t, "TSK1")) = 0;
slot_length_s1(sim, time_t, slot, t)$(sameas(t, "TSK2")) = 0;



