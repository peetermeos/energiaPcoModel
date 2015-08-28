********************************************************************************
**                                                                             *
** Electricity and oil production constraints                                  *
**                                                                             *
** Peeter Meos, Taaniel Uleksin                                                *
********************************************************************************

Equations
*  v_lambda(time_t, slot, t_el)         "Piecewise linear approximation of efficiencies"
  v_load_balance(time_t, slot, t_el)   "Balance equation for heat transfer at production unit"
  v_max_load_el(time_t, slot, t_el)    "Maximum power generation load for given production unit"
  v_max_load_pu(time_t, slot, t_el)    "Maximum total load for given production unit"
  v_min_load_ht(time_t, slot, t_ht)    "Power load must exceed set minimum to produce heat"
  v_min_load_ht_M(time_t, slot, t_el)  "Positive heat load only when such decision has been taken"
  v_load_el(time_t, slot, t_el)        "Power generation load is a sum of piecewise linear lambdas"
  v_fs_mix(time_t, k, feedstock, t_el) "Production unit receives a mix of different feedstocks"
  v_fs_max_content(time_t, slot, k, feedstock, t_el) "Maximal allowed proportion of specific feedstock at gen unit"
  v_fs_max_content_oil(time_t, k, feedstock, t_ol)   "Maximal allowed proportion of specific feedstock at oil unit"
  v_min_cv(time_t, t)                  "Minimum calorific value of feedstock mix allowed"
  v_delta_up_el(time_t, slot, t_el)    "Ramp up rate constraint for power production"
  v_delta_down_el(time_t, slot, t_el)  "Ramp down rate constraint for power production"
  v_min_production_el(time_t, slot)    "Minimal required peak and off peak load for electricity production (MW)"
  v_permitted_use(year, month, t, k, feedstock) "Arbitrary limitations to feedstock use"

*  v_beta(time_t, slot, t_el, para_lk)  "Value of previous segment must be greater than current segment"

  v_unit_commitment(time_t, slot, t_el)"Unit commitment two component sum"

* Oil production
  v_oil(time_t, t_ol)                  "Oil production balance equation"
  v_max_cap_oil(time_t, t_ol)          "Oil production max capacity constraint"
  v_oil_el_prod(time_t, t_el)          "Oil and power co-production"

* Heat production
$ifthen.two "%ht%" == "true"
  v_ht_delivery_ext(time_t, slot)      "Compulsory heat delivery for external customers"
  v_ht_delivery_int(time_t, slot)      "Compulsory heat delivery for internal customers"
$endif.two

* Use crushed limestone and lime
$ifthen.two "%l_k_invoked%" == "true"
  v_cl_use(time_t, t_cl)               "Crushed limestone use constraint"
  v_lime_use(time_t, slot, t_lime)     "Lime use constraint in NID devices"
$endif.two

$ifthen.two "%oil%" == "true"
  v_max_rg(time_t)                     "Upper bound for retort gas in time unit"
$endif.two

  v_max_rg_el(time_t, slot, t_el)

$ifthen.two "%rg_division%" == "true"
  v_rg_division(time_t, slot, t_el)    "Retort gas even use in production units"
$endif.two

$ifthen.two "%fc%" == "true"
* v_pu_decom(year, t)                  "Decommissioned unit cannot be restarted"
* v_pu_decom_load(time_t, t)           "Production in decommissoned units not possible"
$endif.two

$ifthen.two "%mx_schedule%" == "true"
  v_mx_opt(time_t, t_el)               "No operation during maintenance"
  v_mx_s(t_el, year)                   "Only one maintenance in year"
  v_mx(t_el, year)                     "Given number of mx days in year"
  v_mx2(time_t, t_el)                  "After start the unit is down for maintenance given number of days"
$endif.two

* Boiler cleaning constraints
$ifthen.two "%cleanings%" == "true"
  v_cleaning1(time_t, t_el)            "One cleaning in two weeks"
  v_cleaning2(time_t, t_el)            "No arbitrary multiple-day cleaning periods"
  v_cleaning3(time_t, slot, t_el)      "Boiler is powered down when cleaning"
$else.two
* If the cleaning constraints above are not in use, we have to correct the max hours
* accordingly. Check the constraint formulation for details.
* Peeter Meos (18.12.2013)
  v_cleaning4(time_t, slot, t_el)      "Cleaning of boilers when cleaning is not optimised"
$endif.two

  v_beta1(time_t, slot, t_el)          "Unit can be loaded only when committed"
  v_unit_status(time_t, t_el)          "Unit status balance equation"
  v_no_load(time_t, t_el)              "No fictional loadings when there are no production hours"
  v_lambda_z(time_t, slot, t_el, k, feedstock) "Coupling between unit commitment and emissions"
;


********************************************************************************
** For constraints that are not interesting enough to calculate shadow prices  *
** we are using upper and lower bounds instead.                                *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************
$ifthen.two "%oil%" == "false"
oil.up(time_t, t_ol) = 0;
$endif.two

load_el_u(sim, time_t, slot, t_el) = +INF;
load_el_u(sim, time_t, slot, t_el)
                    $(slot_length_s(sim, time_t, slot, t_el) = 0) = 0;

load_el.lo(time_t, slot, t_el) = 0;
load_ht.lo(time_t, slot, t_ht) = 0;
load_ht.lo(time_t, slot, t_el) = 0;

$ifthen.two "%ht%" == "true"
load_ht.up(time_t, slot, t_el) = max_load_ht(t_el);
$endif.two

********************************************************************************
** Provide some basic cuts for the solution space for Q, lime and crushed stone*
** Peeter Meos                                                                 *
********************************************************************************
v_max_rg_el(time_t, slot, t_el)$(time_t_s(time_t))..
sum(para_lk, z_emission(time_t, slot, "Hange", "Uttegaas", t_el, para_lk))
                                                 $(cv("Uttegaas", "Hange", "MWh") > 0)
     =l= sum((year, month)$y_m_t, t_rg(t_el, year, month))
                              * cv("Uttegaas", "Hange", "MWh")
;

$ifthen.two "%l_k_invoked%" == "true"
  add_k.up(time_t, slot, t_el, k_level)   = 0;
  add_l.up(time_t, slot, t_el, l_level)   = 0;
  add_k.up(time_t, slot, t_cl, k_level)   = 1;
  add_l.up(time_t, slot, t_lime, l_level) = 1;
$endif.two

********************************************************************************
** Maximum loads for power production (net power + heat)                       *
** Peeter Meos                                                                 *
********************************************************************************
$ifthen.op "%MT%" == "OP"
  v_max_load_el(time_t, slot, t_el)$(time_t_s(time_t)
                                           and ord(time_t) > card(paev))..
$else.op
  v_max_load_el(time_t, slot, t_el)$time_t_s(time_t)..
$endif.op
  load_el(time_t, slot, t_el)
  =l=
  sum((year, month), max_load_el(t_el, year, month)$y_m_t)
$ifthen.three "%mx_schedule%" == "true"
  * (1 - maint_opt(time_t, t_el))
$endif.three
;

$ifthen.op "%MT%" == "OP"
  v_max_load_pu(time_t, slot, t_el)$(time_t_s(time_t)
                                           and ord(time_t) > card(paev))..
$else.op
  v_max_load_pu(time_t, slot, t_el)$time_t_s(time_t)..
$endif.op
  load_el(time_t, slot, t_el) + load_ht(time_t, slot, t_el)
=l=
         sum((year,month), max_load_pu(t_el, year, month)$y_m_t)
$ifthen.three "%mx_schedule%" == "true"
 * (1 - maint_opt(time_t, t_el))
$endif.three
;

********************************************************************************
** Tootmisüksuste sulgemise piirangud.                                         *
** Kõigepealt eeldame, et esimele aastal on meil kõik tootmisüksused töös.     *
**                                                                             *
** Esimene keelab järgnevatel aastate üksus taas töösse lülitada, kui eelmisel *
** aastal see juba sulgetud on                                                 *
**                                                                             *
** Teine ei luba toota sulgetud plokis                                         *
** Peeter Meos                                                                 *
** Taaniel Uleksin                                                             *
********************************************************************************
$ifthen.two "%fc%" == "true"
*v_pu_decom(year, month, t)..
*  p_active(t, year, month)$(ord(year) gt 1)
*  =l=
*  pu_active(t, year - 1)$(ord(year) gt 1)
*;
*
*v_pu_decom_load(z_subset, time_t, t)..
*  sum((slot, t_el)$sameas(t, t_el), load_el(z_subset, time_t, slot, t_el))
*  +
*  sum(t_ol$sameas(t, t_ol), oil(z_subset, time_t, t_ol))
*  =l=
*  sum((year, month), pu_active(t, year)$y_m_t * M)
*;
$endif.two

********************************************************************************
** Limit for production unit ramp up and ramp down rates                       *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************
v_delta_up_el(time_t, slot, t_el)$(time_t_s(time_t)
      and not sameas(t_el, "Katlamaja")
      and delta_up(t_el) > 0
      and not (ord(time_t) eq 1 and ord(slot) eq 1) and (not t_ol(t_el)))..

  q_out(time_t, slot, t_el) - delta_up(t_el)
                                     * slot_length(time_t, slot, t_el)
  =l=
  q_out(time_t, slot--1, t_el)$(ord(slot) gt 1)
  +
  q_out(time_t-1, slot--1, t_el)$(ord(slot) eq 1)
;

v_delta_down_el(time_t, slot, t_el)$(time_t_s(time_t)
           and not sameas(t_el, "Katlamaja")
           and delta_down(t_el) > 0
           and not (ord(time_t) eq 1 and ord(slot) eq 1) and (not t_ol(t_el)))..

  q_out(time_t, slot, t_el) + delta_down(t_el)
                                     * slot_length(time_t, slot, t_el)
  =g=
  q_out(time_t, slot--1, t_el)$(ord(slot) gt 1)
  +
  q_out(time_t-1, slot--1, t_el)$(ord(slot) eq 1)
;

********************************************************************************
** Efficiency approximation, piecewise linear. Power generation.               *
**                                                                             *
** Peeter Meos                                                                 *
** Taaniel Uleksin                                                             *
********************************************************************************
*v_lambda(time_t, slot, t_el)$(time_t_s(time_t) and not t_ol(t_el))..
*  sum(para_lk, lambda_p(time_t, slot, t_el, para_lk))
**  =e= 1
*  =l= card(para_lk) - 1;
*;

********************************************************************************
** Heat balance between boiler, heat production and power generation           *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************
v_load_balance(time_t, slot, t_el)$(time_t_s(time_t)
                                      and not t_ol(t_el))..
  q_in(time_t, slot, t_el)
  +
  load_ht(time_t, slot, t_el) / ht_efficiency(t_el)
  =e=
  q_out(time_t, slot, t_el)
;

********************************************************************************
** Retort gas can only be added, when other feedstock are in use               *
** Taaniel Uleksin                                                             *
** Peeter Meos                                                                 *
********************************************************************************
$ifthen.three "%oil%" == "true"
v_max_rg(time_t)$time_t_s(time_t)..
  sum((slot, t_el), q(time_t, slot, "Hange", "Uttegaas", t_el)
                  * slot_length(time_t, slot, t_el))

$ifthen.two "%rg_balance%" == "true"
  =e=
$else.two
  =l=
$endif.two

* See $ifthen jubin lülitab tootmisüksuste laodusid sisse välja
* Sisuliselt kui ladudest rongi peale toodet laadida ei saa,
* pole mõtet ka ladusid kasutada
* -Peeter Meos
  sum((k, feedstock, t_ol), to_production(time_t, k, feedstock, t_ol)
    * rg_yield(t_ol)
    * cv("Uttegaas", "Hange", "MWh"))
;
$endif.three

********************************************************************************
** Use of retort gas forced to be proportional to power generations at         *
** production units                                                            *
**                                                                             *
** Macros: q - total heat (energetic quantity) of particular feedstock         *
**                                                                             *
** Taaniel Uleksin                                                             *
********************************************************************************
$ifthen.two "%rg_division%" == "true"
  v_rg_division(time_t, slot, t_el)$(time_t_s(time_t)
         and not t_ht(t_el)
         and (sum((year,month)$y_m_t, max_koormus_el(t_el, year, month)) > 0)
         and sum((year, month)$y_m_t, t_uttegaas_kokku(year, month)) > 0
         and cv("Uttegaas", "Hange", "MWh") > 0)..
    q(time_t, slot, "Hange", "Uttegaas", t_el) / cv("Uttegaas", "Hange", "MWh")
    =g=
    sum((year, month)$y_m_t, t_rg(year, month, t_el) / t_rg_total(year, month))
    *
    sum((t_ol,year,month)$(yield_oil(t_ol, year)>0),
             (
                 (max_load_ol(t_ol, year, month)/days_in_month(year, month))
             /yield_oil(t_ol, year))$y_m_t
    )
    * rg_yield(t_ol)
    / slot_length_orig(time_t, slot, t_ol)
    * load_el(time_t, slot, t_el)/
         sum((year,month)$y_m_t, max_load_el(time_t, t_el, year, month))
;
$endif.two

********************************************************************************
** Feedstock mixes for power production units                                  *
** Summation by calorific values and not by masses                             *
**                                                                             *
** Macros: to_production - summation of logistic flows from storage and rail   *
**         q - total heat (energetic quantity) of particular feedstock         *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************
z_emission.fx(time_t, slot, k, feedstock, t_el, para_lk)
                                      $(fs_k(k, feedstock)
                             and max_ratio(k, feedstock, t_el) eq 0) = 0;

v_fs_mix(time_t, k, feedstock, t_el)$((not t_ol(t_el))
                                        and not sameas(feedstock, "Uttegaas"))..
    to_production(time_t, k, feedstock, t_el)
  * cv(feedstock, k, "MWh")
  =e=
  sum((slot), q(time_t, slot, k, feedstock, t_el)
            * slot_length(time_t, slot, t_el))
;

********************************************************************************
** Feedstock mixes for power production units                                  *
** Maximal proportions of each feedstock must be followed                      *
**                                                                             *
** Macros: q - total heat (energetic quantity) of particular feedstock         *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************
v_fs_max_content(time_t, slot, k, feedstock, t_el)
                   $(time_t_s(time_t)
                             and fs_k(k, feedstock)
                             and max_ratio(k, feedstock, t_el) > 0)..
  q(time_t, slot, k, feedstock, t_el)$(max_ratio(k, feedstock, t_el) > 0)
  =l=
  sum((k2, p2)$(max_ratio(k2, p2, t_el) > 0),
     q(time_t, slot, k2, p2, t_el))
   * max_ratio(k, feedstock, t_el)
;

********************************************************************************
** Feedstock mixes for oil production units                                    *
** Summation by  by masses                                                     *
**                                                                             *
** Macros: to_production - summation of logistic flows from storage and rail   *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************
v_fs_max_content_oil(time_t, k, feedstock, t_ol)$
                                            (time_t_s(time_t)
                                         and (max_ratio(k, feedstock, t_ol) > 0)
                                         and fs_k(k, feedstock))..
    to_production(time_t, k, feedstock, t_ol)
 =l=
    max_ratio(k, feedstock, t_ol)
  * sum((k2, p2), to_production(time_t, k2, p2, t_ol))
;

********************************************************************************
** Minimal allowed calorific value constraint at units                         *
** The point of this constraint is to mix fuels that cannot be used            *
** at production units exclusively                                             *
**                                                                             *
** Macros used: y_m_t - connects calendar time to model time                   *
**                                                                             *
** Taaniel Uleksin                                                             *
********************************************************************************
v_min_cv(time_t, t)$(time_t_s(time_t) and sum((year, month)
                                $y_m_t, cv_min(t, year, month)) > 0)..
 sum((k, feedstock), to_production(time_t, k, feedstock, t) * cv(feedstock, k, "MWh"))
 +
* For power production we need to add gas
 sum((slot, t_el, k, feedstock)$(gas(feedstock)   // Only for gases
                             and not t_ol(t_el)   // So it doesn't apply for ENEFIT
                             and sameas(t, t_el)
                             and max_ratio(k, feedstock, t_el) > 0),
      q(time_t, slot, k, feedstock, t_el))
=g=
   sum((k, feedstock), to_production(time_t, k, feedstock, t))
 * sum((year, month)$y_m_t, cv_min(t, year, month))
;

********************************************************************************
** Use of crushed limestone. Accuracy one time unit                            *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************
$ifthen.two "%l_k_invoked%" == "true"
v_cl_use(time_t, t_cl)$time_t_s(time_t)..
M
=g=
* Ma eeldan siin, et killustiku tasemed on antud per katel mitte per plokk.
 sum((slot, k_level), add_k(time_t, slot, t_cl, k_level)
             * slot_length(time_t, slot, t_cl) * cl_level(k_level))
;


********************************************************************************
** Use of lime, accuracy - one time slot.                                      *
**                                                                             *
** Macros used: none                                                           *
** Peeter Meos                                                                 *
********************************************************************************
v_lime_use(time_t, slot, t_lime)$time_t_s(time_t)..
  sum(l_level, add_l(time_t, slot, t_lime, l_level))
  =l=
  load_el(time_t, slot, t_lime) * M ;
$endif.two

********************************************************************************
** Production unit electric load must not exceed allowable maximum net load    *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************
v_load_el(time_t, slot, t_el)$(time_t_s(time_t) and not t_ol(t_el))..
  load_el(time_t, slot, t_el)
  =e=
  net_load_el(time_t, slot, t_el)
;

********************************************************************************
** Oil production - rather simplistic multiplication by productivity coef      *
**                                                                             *
** Macros used: y_m_t - connects calendar time to model time                   *
** Peeter Meos                                                                 *
********************************************************************************

v_oil(time_t, t_ol)$time_t_s(time_t)..
  sum((k, feedstock), to_production(time_t, k, feedstock, t_ol)
  * sum((year, month)$y_m_t,  adj_yield_oil(t_ol, year, k, feedstock)))
  =e=
  oil(time_t, t_ol)
;

********************************************************************************
** Oil production - must not exceed maximal production capacity                *
**                                                                             *
** Macros used: none                                                           *
** Peeter Meos                                                                 *
********************************************************************************

v_max_cap_oil(time_t, t_ol)$time_t_s(time_t)..
  oil(time_t, t_ol)
*   + oil_penalty(time_t, t_ol)
  =l=
  sum((year, month)$y_m_t, max_load_ol(t_ol, year, month))
;

********************************************************************************
**  Oil and electricity coproduction constraint for ENEFIT plants              *
**                                                                             *
** Taaniel Uleksin                                                             *
********************************************************************************
v_oil_el_prod(time_t, t_el)$(time_t_s(time_t) and t_ol(t_el))..
  sum(slot, load_el(time_t, slot, t_el))
  =l=
  sum(t_ol$sameas(t_el, t_ol), oil(time_t, t_ol))
;

********************************************************************************
** Cannot produce heat when total load is under set minimum for heat           *
** production                                                                  *
********************************************************************************
ht_active.up(time_t, t_el) = 1;

v_min_load_ht(time_t, slot, t_ht)$(time_t_s(time_t)
*                   and sum((year, month),
*                       max_load_el(t_el, year, month)$y_m_t) > 0
                   )..
  load_el(time_t, slot, t_ht)
  =g=
   min_load_ht(t_ht)
 * ht_active(time_t, t_ht)
;

********************************************************************************
** Production units can only produce heat when such decision has been taken    *
** Taaniel Uleksin & Peeter Meos                                               *
********************************************************************************

v_min_load_ht_M(time_t, slot, t_el)$(time_t_s(time_t)
*                   and sum((year,month),
*                       max_load_el(t_el, year, month)$y_m_t) > 0
                   )..
  load_ht(time_t, slot, t_el)
  =l=
  ht_active(time_t, t_el) * M
;
********************************************************************************
** Heat delivery for internal and external customers (MWh)                     *
**                                                                             *
** Macros used: y_m_t - connection between calendar and model time             *
**                                                                             *
** Peeter Meos & Taaniel Uleksin                                               *
** Operational model has its own more precise heat delivery                    *
** Taaniel Uleksin                                                             *
********************************************************************************
$ifthen.two "%ht%" == "true"
v_ht_delivery_ext(time_t, slot)$time_t_s(time_t)..
 sum((t_ht), load_ht(time_t, slot, t_ht)
           * slot_length(time_t, slot, t_ht))
 +
* Penalty is needed for Bender's decomposition, switch off if subproblem is infeasible
* and calculate extreme ray
 heat_penalty(time_t, slot) * modified_bender
$ifthen.three "%heat_free%" == "true"
 =l=
$else.three
 =e=
$endif.three
 sum((year, month)$y_m_t, heat_delivery(year, month)
 / hours_in_month(year, month))
 * smax(t, slot_length_orig(time_t, slot, t))
;

v_ht_delivery_int(time_t, slot)$time_t_s(time_t)..
 sum(t_el$(not t_ht(t_el)), load_ht(time_t, slot, t_el)
                          * slot_length(time_t, slot, t_el))
 +
* Penalty is needed for Bender's decomposition, switch off if subproblem is infeasible
* and calculate extreme ray
 heat_penalty_internal(time_t, slot)
* modified_bender
$ifthen.three "%heat_free%" == "true"
 =l=
$else.three
 =e=
$endif.three
 sum((year, month)$y_m_t, internal_heat_delivery(year, month)
 / hours_in_month(year, month))
 * smax(t, slot_length_orig(time_t, slot, t));

;
$endif.two

********************************************************************************
**                                                                             *
** Minimum required peak load constraint for power production.                 *
**                                                                             *
** Description: For peak periods (weekday 0800 - 2000 hrs) we are given        *
** minimum power load in order to guarantee that cross border price            *
** from the South will not make the price in Estonia. The loads are given      *
** for every month.                                                            *
**                                                                             *
** Macros used: y_m_t - couples year, month and a model day                    *
** Notes: For lower resolution models, the loading needs to be normalised      *
** across the slots. Ie. the average load for the whole day needs to be        *
** proportionally lower than the peak load.                                    *
**                                                                             *
********************************************************************************
v_min_production_el(time_t, slot)$(time_t_s(time_t)
*                                   and day_type(time_t) = 0
                                   )..
     sum((year, month, t_el)$y_m_t,
         load_el(time_t, slot, t_el)
       * slot_length(time_t, slot, t_el)
        )
  +
* Penalty is needed for Bender's decomposition, switch off if subproblem is infeasible
* and calculate extreme ray
  el_penalty(time_t) * modified_bender
  =g=

* For some specific model setups, such as demand curve calculations, this constraint
* needs to be turned off

$ifthen.el "%el_free%" == "true"
  0
$else.el
* Kalvi defines peak periods from 7am to 8pm (weekdays)
* therefore production needs to be greater than
* total minimum load across these hours.
  min_production(time_t, slot)
$endif.el
;

********************************************************************************
** Optimisation of the maintenance overhaul strategy                           *
**                                                                             *
** Macros used: y_m_t - connection between calendar and model time             *
**                                                                             *
** Taaniel Uleksin                                                             *
********************************************************************************
$ifthen.two "%mx_schedule%" == "true"

* Remont alaku esmaspäeviti
maint_start.up(time_t, t_el)$(not gdow(jdate(beg_year, beg_month, 1)
                                  + ord(time_t) - 1) eq 1) = 0;

* No operation during maintenance
v_mx_opt(time_t, t_el)$time_t_s(time_t)..
  sum(slot, load_el(time_t, slot, t_el))
  =l=
  (1 - maint_opt(time_t, t_el)) * M
;

* Only one maintenance in year
v_mx_s(t_el, year)$(time_t_s(time_t) and TRemont(t_el, year) > 0)..
  sum((time_t, month), maint_start(time_t, t_el)$y_m_t)
  =e=
  1
;

* Given number of mx days in year
v_mx(t_el, year)$(time_t_s(time_t) and TRemont(t_el, year) > 0)..
  sum((time_t, month), maint_opt(time_t, t_el)$y_m_t)
  =e=
  t_mx(t_el, year)
;

maint_opt.up(time_t, t_el) = 1;

* After start the unit is down for maintenance given number of days
v_mx2(time_t, t_el)$(time_t_s(time_t)
                      and sum((year, month), t_mx(t_el, year)) > 0)..
  maint_opt(time_t, t_el)
  =e=
  sum(time_t2,
         maint_start(time_t2, t_el)$
         (
                 (ord(time_t2) le ord(time_t))
                 and
                 (ord(time_t2) ge (ord(time_t) - sum((year, month),
                       t_mx(t_el, year)$y_m_t)+1))
         )
  )
;
$endif.two

********************************************************************************
** Optimisation of routine boiler cleanings                                    *
**                                                                             *
** Macros used: cleaning_bound                                                 *
** Peeter Meos                                                                 *
********************************************************************************

$ifthen.two "%cleanings%" == "true"

t_cleaning.lo(time_t, t_el) = period_switch;
t_cleaning.up(time_t, t_el) = 1;
t_cleaning.up(time_t, t_el)$(t_tech("CFB", t_el)) = 0;

* Ühe nädala sisse peab jääma vähemalt üks katla puhastus
* See peaks tekitama iga 7 tööpäeva sisse ühe puhastuspäeva
* iga puhastus annab meile 6 tööpäeva
alias(slot2, slot);

********************************************************************************
** Boiler is cleaned once in two weeks. If we have two boiler units, then      *
** one cleaning for a boiler is necessary each weekend .                       *
** I know it's confusing to read, but the idea is that in every 7 day          *
** timespan there must be one cleaning day. One cleaning day means cleaning    *
** for one boiler.                                                             *
**                                                                             *
** Macros used: num_days                                                       *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

$macro num_days(days, time_t, t_el) trunc(days * 24 / sum(slot2, slot_length_orig(time_t, slot2, t_el)))

t_cleaning_s.up(time_t, t_el) = clean_span;

v_cleaning1(time_t, t_el)$(time_t_s(time_t)
$ifthen.op "%MT%" == "OP"
                       and ord(time_t) > card(paev)
$endif.op
                       and ord(time_t) > 1
                       and not t_tech("CFB", t_el) and not t_ol(t_el)
*                       and sum(slot, t_mx_schedule(time_t, slot, t_el)) = 0
                          )..
  t_cleaning_s(time_t, t_el)
  =g=
  (1 - period_switch) *
* For monthly resolution, the following needs to be switched off
  (
    t_cleaning_s(time_t-1, t_el)
    + k_alpha(time_t, t_el)
    - t_cleaning(time_t, t_el) * round(num_days(clean_span, time_t, t_el))
   )
;

v_cleaning2(time_t, t_el)$(time_t_s(time_t)
$ifthen.op "%MT%" == "OP"
                       and ord(time_t) > card(paev)
$endif.op
                       and ord(time_t) > 1
                       and not t_tech("CFB", t_el) and not t_ol(t_el))..
  t_cleaning(time_t, t_el) * (num_days(clean_span, time_t, t_el) - 1)
  =l=
  t_cleaning_s(time_t-1, t_el)
;

Equation v_cleaning2a(time_t, t_el);

v_cleaning2a(time_t, t_el)$(time_t_s(time_t)
$ifthen.op "%MT%" == "OP"
                       and ord(time_t) > card(paev)
$endif.op
                       and ord(time_t) > 1
                       and not t_tech("CFB", t_el) and not t_ol(t_el))..
  t_cleaning(time_t, t_el)
  =g=
  (1 - period_switch) *
  (
    t_cleaning_s(time_t-1, t_el) - (num_days(clean_span, time_t, t_el) - 1)
  )
;


********************************************************************************
** Boiler is powered down at cleaning day                                      *
**                                                                             *
** Macros used: cleaning coeff                                                 *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

v_cleaning3(time_t, slot, t_el)$(time_t_s(time_t)
                                       and not t_tech("CFB", t_el)
                                       and not t_ol(t_el)
$ifthen.op "%MT%" == "OP"
                                       and ord(time_t) > card(paev)
$endif.op
)..
  load_el(time_t, slot, t_el)
  =l= sum((year, month)$y_m_t, max_load_el(t_el, year, month))
$ifthen.four "%mx_schedule%" == "true"
      * (1 - maint_opt(time_t, t_el))
$endif.four
      * (1 - t_cleaning(time_t, t_el) * cleaning_coeff)
;

$else.two
  v_cleaning4(time_t, slot, t_el)$(time_t_s(time_t)
                                     and not t_tehnoloogia("CFB", t_el))..
 load_el(sim, time_t, slot, t_el)
 =l=
 sum((year, month), max_load_el(t_el, year, month)$y_m_t)
      * (1 - sum((year, month)$y_m_t, failure_rate(t_el, year)))
$ifthen.three "%mx_schedule%" == "true"
      * (1 - maint_opt(time_t, t_el))
$endif.three
;
$endif.two

********************************************************************************
**                                                                             *
**  Arbitrary enforcement of selected feedstock at given unit and time         *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

v_permitted_use(year, month, t, k, feedstock)$(sum((k2, p2),
                                 permitted_use(year, month, t, k2, p2)) > 0)..
 sum(time_t$(y_m_t
         and time_t_s(time_t)), to_production(time_t, k, feedstock, t))
 =l=
 permitted_use(year, month, t, k, feedstock) * M * M
;

********************************************************************************
**                                                                             *
**  Two component unit commitment with startup costs                           *
**                                                                             *
** Peeter Meos, 22. august 2014                                                *
********************************************************************************

lambda_p.up(time_t, slot, t_el) = 1;
k_alpha.up(time_t, t_el) = 1;

v_beta1(time_t, slot, t_el)$(time_t_s(time_t)
$ifthen.op "%MT%" == "OP"
                       and ord(time_t) > card(paev)
$endif.op
)..
  load_el(time_t, slot, t_el)
  =l=
  k_alpha(time_t, t_el) * sum((year, month)$y_m_t, max_load_el(t_el, year, month))
;

v_unit_commitment(time_t, slot, t_el)$(time_t_s(time_t))..
  load_el(time_t, slot, t_el)
  =g=
  k_alpha(time_t, t_el) * min_load_el(t_el)
;

********************************************************************************
**                                                                             *
**  The other option for unit status constraint is to model it as equality     *
**  with unit stop status as another variable, but since there are no costs    *
** involved with stopping unit, this would add unnecessary variables and       *
** increase solution time.                                                     *
**                                                                             *
** Peeter Meos, 29. January 2015                                               *
********************************************************************************


v_unit_status(time_t, t_el)$(time_t_s(time_t) and ord(time_t) > 1)..
  k_alpha(time_t, t_el)
  =l=
  t_startup(time_t, t_el)
  +
  k_alpha(time_t--1, t_el)
;

********************************************************************************
**                                                                             *
**  We are not allowing fictional loads when there are no hours for production.*
**  For clarity's sake.                                                        *
**                                                                             *
** Peeter Meos, 29. January 2015                                               *
********************************************************************************

v_no_load(time_t, t_el)$(time_t_s(time_t))..
  k_alpha(time_t, t_el)
  =l=
  sum(slot, slot_length(time_t, slot, t_el))
;

********************************************************************************
**                                                                             *
**  Coupling between unit commitment variable and emissions piecewise linear   *
**  variables. This cuts solution space and yields tighter formulation.        *
**                                                                             *
** Peeter Meos, 29. January 2015                                               *
********************************************************************************

v_lambda_z(time_t, slot, t_el, k, feedstock)$(time_t_s(time_t)
                                                  and not sameas(t_el, "Katlamaja")
                                                                    and max_ratio(k, feedstock, t_el)>0
                                                                    )..
  sum((para_lk, k_level, l_level)$(ord(para_lk) > 1), lambda_e(time_t, slot, t_el,
                                            k, feedstock, k_level, l_level, para_lk))
  =e=
  k_alpha(time_t, t_el)
;




