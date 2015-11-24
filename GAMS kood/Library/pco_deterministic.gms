********************************************************************************
** Definition of PCO deterministic model                                       *
** And solving it...                                                           *
**                                                                             *
** 30. dets 2013                                                               *
** Peeter Meos                                                                 *
********************************************************************************

Model pco /all/;

* Configure CPLEX
pco.OptFile   = 1;
pco.PriorOpt  = 1;
pco.HoldFixed = 1;
$ifthen.two "%debug%" = "true"
pco.dictfile  = 1;
$else.two
pco.dictfile  = 0;
$endif.two
pco.scaleopt  = 1 ;

$ifthen.s "%numsim%" == "1"
  pco.SolveLink = 0;
  Solve pco maximizing total_profit using mip;
$else.s
  $$libinclude pco_guss_solve
**$  if not "%two_stage" == "true" $if not "%num_sim%" == "1" modified_bender = 1;
  $$libinclude pco_guss_grid
* Solve pco maximizing total_profit using mip scenario dict;
$endif.s


$ifthen.s "%numsim%" == "1"
$ifthen.two "%prc%" == "true"
  fs_purchase_l(sim, serial, time_t, k, feedstock) = fs_purchase.l(serial, time_t, k, feedstock);
$endif.two

$ifthen.l "%logistics%" == "true"
  storage_t_l(sim, time_t, s_t, k, feedstock) = storage_t.l(time_t, s_t, k, feedstock);
  storage_k_l(sim, time_t, s_k, k, feedstock) = storage_k.l(time_t, s_k, k, feedstock);
  mine_to_logs_l(sim, time_t, route, feedstock) = mine_to_logs.l(time_t, route, feedstock);
$endif.l

$ifthen.l not "%MT%" == "OP"
  logs_to_storage_l(sim, time_t, route, s_t, feedstock) = logs_to_storage.l(time_t, route, s_t, feedstock);
  mine_to_storage_l(sim, time_t, s_k, k, feedstock) = mine_to_storage.l(time_t, s_k, k, feedstock);
  storage_to_production_l(sim, time_t, s_t, t, k, feedstock) = storage_to_production.l(time_t, s_t, t, k, feedstock);
  storage_to_logs_l(sim, time_t, s_k, route, feedstock) = storage_to_logs.l(time_t, s_k, route, feedstock);
$endif.l

  storage_to_production_l(sim, time_t, s_t, t, k, feedstock) = storage_to_production.l(time_t, s_t, t, k, feedstock);
  logs_to_production_l(sim, time_t, route, t, feedstock) = logs_to_production.l(time_t, route, t, feedstock);


  load_ht_l(sim, time_t, slot, t_el) = load_ht.l(time_t, slot, t_el);
  load_el_l(sim, time_t, slot, t_el) = load_el.l(time_t, slot, t_el);
  oil_l(sim, time_t, t_ol) = oil.l(time_t, t_ol);
  t_cleaning_l(sim, time_t, t_el) = t_cleaning.l(time_t, t_el);

  z_emission_l(sim, time_t, slot, k, feedstock, t_el, para_lk) = z_emission.l(time_t, slot, k, feedstock, t_el, para_lk);

  co2_spot_market_l(sim, time_t) = co2_spot_market.l(time_t);
  co2_cert_usage_l(sim, serial, time_t) = co2_cert_usage.l(serial, time_t);
$endif.s
