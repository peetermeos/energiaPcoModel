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
  c_s(sim, year)         "Concentrate price"
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
c_s(sim, year)$(sum((time_t, month)$y_m_t, 1) > 1)  = h_run(sim);

Variable
   t_run(sim, year, month, run_result)             "Resulting value"
   t_feedstock(sim, year, month, t)  "Feedstock use (MWh)"
;

Set dict
   /
     o.                     opt.                  ""
     sim_subset.            scenario.             ""
     concentrate_price.     param.                c_s
     total_profit.          level.                total_profit_s
     z_emission.            level.                z_emission_l
     load_ht.               level.                load_ht_l
     load_el.               level.                load_el_l
     storage_to_production. level.                storage_to_production_l
     logs_to_production.    level.                logs_to_production_l
   /;


* Actual solving takes place here, different setups for deterministic and stochastic
$if     "%numsim%" == "1" $libinclude pco_guss_grid
* Solve pco maximizing total_profit using mip scenario dict;

*$if not "%numsim%" == "1"    $libinclude pco_bender

* Save the run results (kytuse kasutus kuu = monthly feedstock usage)
* We must save the fuel use that we are plotting the curve for
* and also other fuels, in order to capture the replacement effect at
* low prices.

      t_feedstock.l(sim, year, month, t)$(sum(time_t, 1$y_m_t) > 0)
                                 =
                                (
                                 sum((s_t, time_t)$y_m_t, storage_to_production_l(sim, time_t, s_t, t, "%n_source%", "%pk%"))
                                 +
                                 sum((route, l, time_t)$(y_m_t and route_endpoint(route, "%n_source%", l)),
                                       logs_to_production_l(sim, time_t, route, t, "%pk%"))
                                )
                          * cv("%pk%", "%n_source%", "MWh");

      t_run.l(sim, year, month, "price")$(sum(time_t, 1$y_m_t) > 0) = h_run(sim);
      t_run.l(sim, year, month, "acq") = sum(t, t_feedstock.l(sim, year, month, t));
