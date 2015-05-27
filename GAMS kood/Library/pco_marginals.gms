********************************************************************************
**                                                                             *
**  This piece of code calculates and prepares sales margins                   *
**  30. dets 2013                                                              *
**  Environment variables required:                                            *
**                                                                             *
**  $set m_marg      30 (marginals for how many time units?)                   *
**                                                                             *
**  Peeter Meos                                                                *
********************************************************************************

* In case of deterministic model we are using three price levels
* for stochastics this hack is not necessary, distribution is already
* provided naturally

Set prices /
$if     "%numsim%" == "1"    lo
                              mid
$if     "%numsim%" == "1"    up
          /;
Parameter
  h_nihe(prices) /
$if     "%numsim%" == "1"    lo   0.9
                              mid  1.0
$if     "%numsim%" == "1"    up   1.1
                 /
;

Positive variable
  margin_results(prices, sim, t_el)
  margin_results_sox(prices, sim, t_el)                       "SOx margin for each unit (EUR/MWh)"
  margin_results_price(prices, sim, time_t_marg, slot, t_el)  "Average sales price for each unit (EUR/MWh)"
  margin_results_varcost(prices, sim, t_el)                   "Average variable cost for each unit (EUR/MWh)"
  margin_results_marg(prices, time_t_marg, k, feedstock)      "Feedstock margin for each unit (EUR/MWh)"
  margin_results_mine(prices, sim, year, month, k, feedstock) "Feedstock mined (t)"
  margin_results_load(prices, sim, time_t_marg, t_el)         "Loading for each unit (MW)"
  margin_results_profit(prices)                               "Total profit for margin run (EUR)"
;

Parameter
  el(time_t, slot)
  pe_marg(k, feedstock)
  pe_sum(sim, t_el)
  pe_use(sim, k, feedstock, t_el)
;

el(time_t, slot) = el_price_slot(time_t, slot);

loop(prices,
  el_price_slot(time_t, slot) = el(time_t, slot) * h_nihe(prices);

* Solve the actual model. Different for deterministic and stochastic cases
$if not "%two_stage%" == "true"    Solve pco maximizing total_profit using mip;
$if     "%two_stage%" == "true"    $libinclude pco_bender

  margin_results_profit.l(prices) = total_profit.l;
* Now do postprocessing
  $$libinclude pco_postprocessing

* Calculate shadow prices for each mined feedstock
  pe_marg(k, feedstock)
  = (sum(time_t_marg, v_k_fs_mined.m(time_t_marg, k, feedstock) / cv(feedstock, k, "MWh"))$(cv(feedstock, k, "MWh") > 0)
     +
     sum(time_t_marg, v_k_fs_acquired.m(time_t_marg, feedstock) / cv(feedstock, "Hange", "MWh"))$(cv(feedstock, "Hange", "MWh") > 0 and sameas(k, "Hange"))
     )
    / card(time_t_marg);

$ifthen.b not "%numsim%" == "1"
  pe_marg(k, feedstock) = -pe_marg(k, feedstock)/%numsim%;
$endif.b

* Calculate amount of feedstock used in production unit
  pe_sum(sim, t_el) = sum((year, month, day, time_t_marg, k, feedstock)$(date_cal(time_t_marg, year, month)),
                 fuel_consumption_day.l(sim, year, month, day, time_t_marg, t_el, "Elekter", k, feedstock, "mwh"));

  pe_use(sim, k, feedstock, t_el)$(pe_sum(sim, t_el) > 0)
  =
  sum((year, month, day, time_t_marg)$date_cal(time_t_marg, year, month),
                 fuel_consumption_day.l(sim, year, month, day, time_t_marg, t_el, "Elekter", k, feedstock, "mwh")) / pe_sum(sim, t_el);

*  margin_results.l(prices, sim, t_el) = sum((feedstock, k, p2)$(enrichment_coef(feedstock, k, p2)),
*                                   pe_use(sim, k, p2, t_el) * pe_marg(k, feedstock));

* For all shadow prices for fuels, find smallest non-zero shadow price for fuel that is usable at this
* given production unit.

  margin_results.l(prices, sim, t_el) = smin((feedstock, k, p2)$(max_ratio(k, feedstock, t_el) > 0
* This is messes up marginals when no shortage exists        and pe_marg(k, p2) > 0
                                                             and enrichment_coef(p2, k, feedstock)),
                                                     pe_marg(k, p2)
                                               );


  margin_results_price.l(prices, sim, time_t_marg, slot, t_el)$(slot_length_s(sim, time_t_marg, slot, t_el) > 0) =
                                                                     el_price_slot(time_t_marg, slot);

  margin_results_varcost.l(prices, sim, t_el)
    $(sum(time_t_marg, t_varcost_perunit_day.l(sim, time_t_marg, t_el, "Elekter", "kokku")) > 0) =
      sum(time_t_marg, t_varcost_perunit_day.l(sim, time_t_marg, t_el, "Elekter", "kokku")) /
      (sum(time_t_marg$(t_varcost_perunit_day.l(sim, time_t_marg, t_el, "Elekter", "kokku") > 0), 1));

  margin_results_marg.l(prices, time_t_marg, k, feedstock)$(not sameas(k, "Hange"))
      = v_k_fs_mined.m(time_t_marg, k, feedstock);

  margin_results_marg.l(prices, time_t_marg, k, feedstock)$(sameas(k, "Hange"))
      = v_k_fs_acquired.m(time_t_marg, feedstock);

  margin_results_load.l(prices, sim, time_t_marg, t_el)
      = t_production_day.l(sim, time_t_marg, t_el, "Elekter");

  margin_results_mine.l(prices, sim, year, month, k, feedstock)
      = sum((quarter)$q_months(quarter, month),
         mine_production_month.l(sim, year, quarter, month, k, feedstock, "mwh"));

* Calculate SOx margin for each production unit and secondary energy (EUR/MWh)
  margin_results_sox.l(prices, sim, t_el) = sum((time_t_marg, year, month)$date_cal(time_t_marg, year, month),
                                     v_so_quota.m(year)) / card(time_t_marg)
                                * sum((time_t_marg, year, month)$date_cal(time_t_marg, year, month),
                                     avg_specific_emission_year.l(sim, year, t_el, "so", "Elekter")) / card(time_t_marg)
                                + epsilon
                                ;

);

* Restore the original price levels
el_price_slot(time_t, slot) = el(time_t, slot);

*$ifthen.b not "%numsim%" == "1"
*   tulemused_sox.l(prices, sim, t_el) = -tulemused_sox.l(prices, sim, t_el);
*   tulemused_marg.l(prices, time_t_marg, k, feedstock) =
*      -tulemused_marg.l(prices, time_t_marg, k, feedstock) / %numsim%;
*$endif.b
