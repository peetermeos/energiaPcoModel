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
  run_result  "Attributes for run points"    /price, acq, internal, profit/
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
     storage_to_production. level.                storage_to_production_l
     logs_to_production.    level.                logs_to_production_l
   /;


init_cost(year, month) = fs_vc("%n_source%", "%nk%", year);
init_cap(year, month)  = max_mining_cap("%n_source%", "%nk%", year, month);

fs_vc_s(sim, "%n_source%", "%nk%", year)$(sum((month, time_t)$y_m_t, 1) > 0) = h_run(sim) * cv("%nk%", "%n_source%", "MWh");
max_mining_cap("%n_source%", "%nk%", year, month) = 120000000000;
contract(serial, year, month, "%n_source%", "%nk%", "kogus") = 0;

* Actual solving takes place here, different setups for deterministic and stochastic
Model pco /all/;

* Configure CPLEX
pco.OptFile   = 1;
pco.PriorOpt  = 1;
pco.HoldFixed = 1;
pco.dictfile  = 1;

$if     "%numsim%" == "1" $libinclude pco_guss_grid
*Solve pco maximizing total_profit using mip scenario dict;
*$if not "%numsim%" == "1"    $libinclude pco_bender

* Save the run results (kytuse kasutus kuu = monthly feedstock usage)
* We must save the fuel use that we are plotting the curve for
* and also other fuels, in order to capture the replacement effect at
* low prices.

$libinclude pco_demand_curve_pp


