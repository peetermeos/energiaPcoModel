********************************************************************************
**                                                                             *
**  This piece of code calculates demand curve for a given feedstock           *
**  30. dec 2013                                                               *
**  Required environment variables are:                                        *
**                                                                             *
**  $set n_price_1              6   Lower limit for price                      *
**  $set n_price_2             15   Price upper limit                          *
**  $set n_price_step         0.2   Step amount for the price                  *
**  $set n_source           Hange   Feedstock source (ie. mine)                *
**  $set nk                Turvas   Feedstock type (eg. peat)                  *
**                                                                             *
**  Peeter Meos                                                                *
**                                                                             *
********************************************************************************

Set
  run_result  "Attributes for run points"    /acq, price, internal, profit/
;

$drop n_price_points

Set sim_subset(sim);
sim_subset(sim) = yes;

Parameter
  init_cost(year, month) "Initial variable costs for mining"
  init_cap(year, month)  "Initial mining capacity"
  h_run(sim)
  fs_vc_s(sim, k, feedstock, year)     "Mining variable costs set"
  total_profit_s(sim)
;

Parameter o /
             UpdateType   2
             SkipBaseCase 0
             LogOption    1
             NoMatchLimit 500
            /
;

h_run(sim) = %n_price_1% + (ord(sim)-1) * %n_price_step%;

Variable
   t_run(sim, year, month, run_result)             "Resulting value"
   t_run_total(sim, year, run_result)              "Resulting value"
   t_feedstock(sim, year, month, t)                "Feedstock use (MWh)"
   t_production(sim, year, month, t, product)      "Production amount (MWh)"
;

Set dict
   /
     o.                     opt.                  ""
     sim_subset.            scenario.             ""
     fs_vc.                 param.                fs_vc_s
     total_profit.          level.                total_profit_s
     z_emission.            level.                z_emission_l
     load_ht.               level.                load_ht_l
     load_el.               level.                load_el_l
     oil.                   level.                oil_l     
     storage_to_production. level.                storage_to_production_l
     logs_to_production.    level.                logs_to_production_l
   /;

Equation v_mining_shorthand(time_t);

v_mining_shorthand(time_t)..
  sum((t, s_t), storage_to_production(time_t, s_t, t, "%n_source%", "%nk%"))
  =e=
$ifthen.s "%n_source%" == "Hange"
  fs_acqd(time_t, "%nk%")
$else.s
  fs_mined(time_t, "%nk%", "%nk%", "%n_source%")
$endif.s
;

* Set capacity to only one fuel
fs_vc_s(sim, "%n_source%", "%nk%", year)$(sum((month, time_t)$y_m_t, 1) > 0) = h_run(sim) * cv("%nk%", "%n_source%", "MWh");

********************************************************************************
** Constraints for oil shale sale contracts to external customers.             *
**                                                                             *
** Macros used: y_m_t - tuple connecting calendar time to model time           *
** Peeter Meos                                                                 *
********************************************************************************
Equations
  v_sales(year, month, k, feedstock, t_mk)
  v_sales_m(time_t, k, feedstock, t_mk)
;
v_sales(year, month, "%n_source%", "%nk%", t_mk)$(sum(time_t$(time_t_s(time_t)
                                                  and y_m_t), 1) > 0)..
  sum(time_t$(time_t_s(time_t) and y_m_t), sales(time_t, "%n_source%", "%nk%", t_mk))
  =l=
  sum(time_t$(time_t_s(time_t) and y_m_t),
    sale_contract(t_mk, "Estonia", "Tykikivi", year, month))
  / days_in_month_m(year, month)
;

v_sales_m(time_t, "%n_source%", "%nk%", t_mk)$(time_t_s(time_t))..
  sum(s_t, storage_to_production(time_t, s_t, t_mk, "%n_source%", "%nk%"))
  =e=
  sales(time_t, "%n_source%", "%nk%", t_mk)
;

Model pco /all/;

* Configure CPLEX
pco.OptFile   = 1;
pco.PriorOpt  = 1;
pco.HoldFixed = 1;
pco.dictfile  = 0;

* Actual solving takes place here, different setups for deterministic and stochastic
$if     "%numsim%" == "1" $libinclude pco_guss_grid
* Solve pco maximizing total_profit using mip scenario dict;

*$if not "%numsim%" == "1"    $libinclude pco_bender

* Save the run results (kytuse kasutus kuu = monthly feedstock usage)
* We must save the fuel use that we are plotting the curve for
* and also other fuels, in order to capture the replacement effect at
* low prices.

$libinclude pco_demand_curve_pp


