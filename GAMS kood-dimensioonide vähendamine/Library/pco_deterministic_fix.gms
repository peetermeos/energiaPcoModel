********************************************************************************
** Definition of PCO deterministic model                                       *
** And solving it...                                                           *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

Model pco_fix /all/;

* Configure CPLEX
pco_fix.OptFile = 1;
pco_fix.PriorOpt = 1;
pco_fix.HoldFixed = 1;
pco_fix.dictfile  = 0;

$ifthen.s "%numsim%" == "1"
Solve pco_fix maximizing total_profit using mip;
$else.s
  $$libinclude pco_guss_solve
*$if not "%two_stage" == "true" $if not "%num_sim%" == "1" modified_bender = 1;
  $$libinclude pco_guss_grid
$endif.s


$ifthen.s "%numsim%" == "1"
  fs_purchase_l(sim, serial, time_t, k, feedstock) = fs_purchase.l(serial, time_t, k, feedstock);

  storage_t_l(sim, time_t, s_t, k, feedstock) = storage_t.l(time_t, s_t, k, feedstock);
  storage_k_l(sim, time_t, s_k, k, feedstock) = storage_k.l(time_t, s_k, k, feedstock);

  logs_to_storage_l(sim, time_t, route, s_t, feedstock) = logs_to_storage.l(time_t, route, s_t, feedstock);
  storage_to_production_l(sim, time_t, s_t, t, k, feedstock) = storage_to_production.l(time_t, s_t, t, k, feedstock);
  mine_to_storage_l(sim, time_t, s_k, k, feedstock) = mine_to_storage.l(time_t, s_k, k, feedstock);
  storage_to_logs_l(sim, time_t, s_k, route, feedstock) = storage_to_logs.l(time_t, s_k, route, feedstock);
  storage_to_production_l(sim, time_t, s_t, t, k, feedstock) = storage_to_production.l(time_t, s_t, t, k, feedstock);
  logs_to_production_l(sim, time_t, route, t, feedstock) = logs_to_production.l(time_t, route, t, feedstock);
  mine_to_logs_l(sim, time_t, route, feedstock) = mine_to_logs.l(time_t, route, feedstock);

  load_ht_l(sim, time_t, slot, t_el) = load_ht.l(time_t, slot, t_el);
  load_el_l(sim, time_t, slot, t_el) = load_el.l(time_t, slot, t_el);
  oil_l(sim, time_t, t_ol) = oil.l(time_t, t_ol);
  t_cleaning_l(sim, time_t, t_el) = t_cleaning.l(time_t, t_el);

  z_emission_l(sim, time_t, slot, k, feedstock, t_el, para_lk) = z_emission.l(time_t, slot, k, feedstock, t_el, para_lk);

  co2_spot_market_l(sim, time_t) = co2_spot_market.l(time_t);
  co2_cert_usage_l(sim, serial, time_t) = co2_cert_usage.l(serial, time_t);
$endif.s
