* CO2 liigub 3 kuni 9 0.5 sammuga
* Elekter liigub 30 kuni 40 0.5 sammuga

Set run_co       /1 * 15/;
Set run_el       /1 * 30 /;
*Set sim          /1 * 161/;      // 7 * 23 = 161
Set sim_el_co(sim, run_el, run_co)  /#sim:(#run_el.#run_co)/;
Set sim_subset(sim);

sim_subset(sim) = yes;

Parameter o /
             UpdateType   2
             SkipBaseCase 0
             LogOption    1
             NoMatchLimit 500
            /
;

Parameter
  h_co(sim)
  h_el(sim)
  avg_el(year, month)
  v_sales_m2(sim, year, month, k, feedstock, t_mk)
  t_run(run_el, run_co, year, month)
  t_run_p(run_el, run_co, year, month, t_el)
  t_run_c(run_el, run_co, year, month, t_el)
  t_op_price(run_el, run_co, year, month)
;

h_co(sim) = sum((run_el, run_co)$sim_el_co(sim, run_el, run_co), 3  + (ord(run_co) - 1) * 0.5);
h_el(sim) = sum((run_el, run_co)$sim_el_co(sim, run_el, run_co), 30 + (ord(run_el) - 1) * 0.5);

avg_el(year, month)$(sum((time_t, slot)$y_m_t, 1) > 0)
     = sum((time_t, slot)$y_m_t, el_price_slot(time_t, slot)) / sum((time_t, slot)$y_m_t, 1);

co2_price_s(sim, year)$(sum((month, time_t)$y_m_t, 1) > 0) = h_co(sim);

el_price_slot_s(sim, time_t, slot)$(sum((year, month)$y_m_t, avg_el(year, month)) > 0)
         = el_price_slot(time_t, slot) / sum((year, month)$y_m_t, avg_el(year, month)) * h_el(sim);

concentrate_price(year) = 0;
fs_vc("Estonia", "Tykikivi", year) = 0;

Model pco /all/;

* Configure CPLEX
pco.OptFile   = 1;
pco.PriorOpt  = 1;
pco.HoldFixed = 1;
pco.dictfile  = 0;

Set dict /
     o.                     opt.                  ""
     sim_subset.            scenario.             ""
     el_price_slot.         param.                el_price_slot_s
     co2_price.             param.                co2_price_s
     v_sales.               marginal.             v_sales_m2
         /;

*Solve pco maximizing total_profit using mip scenario dict;
$libinclude pco_guss_grid

t_run(run_el, run_co, year, month) = -smax(sim$sim_el_co(sim, run_el, run_co), v_sales_m2(sim, year, month, "Estonia", "Tykikivi", "VKG"));

$ontext

Set dict /
     o.                     opt.                  ""
     sim_subset.            scenario.             ""
     el_price_slot.         param.                el_price_slot_s
     co2_price.             param.                co2_price_s
* Outputs

     fs_mined.              level.                fs_mined_l
     fs_acqd.               level.                fs_acqd_l
$ifthen.two "%prc%" == "true"
     fs_purchase.           level.                fs_purchase_l
     fs_purchase.           fixed.                fs_purchase_f
$endif.two

     mine_to_storage.       level.                mine_to_storage_l
     mine_to_logs.          level.                mine_to_logs_l
     storage_to_logs.       level.                storage_to_logs_l
     logs_to_storage.       level.                logs_to_storage_l
     logs_to_production.    level.                logs_to_production_l
     storage_to_production. level.                storage_to_production_l

     load_el.               level.                load_el_l
     load_ht.               level.                load_ht_l
     oil.                   level.                oil_l
     z_emission.            level.                z_emission_l
     storage_k.             level.                storage_k_l
     storage_t.             level.                storage_t_l

$ifthen.two "%cleanings%" == "true"
  t_cleaning.               level.                t_cleaning_l
$endif.two

    co2_cert_usage.         level.                co2_cert_usage_l
    co2_spot_market.        level.                co2_spot_market_l
         /;

*Solve pco maximizing total_profit using mip scenario dict;
$libinclude pco_guss_grid

$libinclude pco_postprocessing

  t_run_p(run_el, run_co, year, month, t_el) = sum((sim, quarter)$(q_months(quarter, month) and sim_el_co(sim, run_el, run_co)),
                                            t_production_month.l(sim, year, quarter, month, t_el, "Elekter"));

  t_run_c(run_el, run_co, year, month, t_el) = sum((sim, quarter)$(q_months(quarter, month) and sim_el_co(sim, run_el, run_co)),
                                            t_contribution_month.l(sim, year, quarter, month, t_el, "Elekter"));
* t_run(run_el, run_co, year, month) = -smax(sim$sim_el_co(sim, run_el, run_co), v_sales_m2(sim, year, month, "Estonia", "Tykikivi", "VKG"));

Parameter t_days(year, month);
t_days(year, month) = sum((time_t)$y_m_t, 1);

t_op_price(run_el, run_co, year, month)$(t_days(year, month) > 0)
               = sum((time_t, sim)$(y_m_t and sim_el_co(sim, run_el, run_co)), el_price_slot_s(sim, time_t, "1"))
                 /
                 t_days(year, month);

$offtext
