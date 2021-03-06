********************************************************************************
**                                                                             *
** Production related data structures and elements.                            *
** Includes also some preprocessing for efficiencies and maintenance           *
** schedules.                                                                  *
**                                                                             *
**  Peeter Meos                                                                *
********************************************************************************

Sets
 t           "Production units"
 tech        "Production technology"
 boiler      "Boilers"
;
$loaddc t boiler=katel tech=tehnoloogia

Sets
 t_tech(tech, t)                 "Tuple connecting tehcnology and production unit"
 t_stack                         "Meie jaamade korstnad"
 t_unit_stack(t_stack, t)        "Which unit is connected to which smokestack"
 t_el(t)                         "Power production units"
 t_ol(t)                         "Oil production units"
 t_mk(t)                         "Points of sale"
;
$loaddc t_tech=t_tehnoloogia t_stack=t_korstnad t_unit_stack=t_ploki_korsten t_ol t_mk t_el

Sets t_ht(t_el)                  "Combined heat/power production units"
;

Set
  t_k_tase  "Levels of crushed limestone additive"
   /0
$ifthen.two "%l_k_invoked%" == "true"
   , 10, 15, 20
$endif.two
   /
  t_l_tase  "Levels of lime additive"
   /0
$ifthen.two "%l_k_invoked%" == "true"
   , 1, 2, 3
$endif.two
  /
;

Set
  t_boiler(t_el, boiler)  "Boiler count for each production unit"
  /
  (EEJ1*EEJ8) .(a,b)
  (BEJ9*BEJ12).(a,b)
  (AUVERE1)     .(a)
  /
;

Table max_q(t_el, boiler) "Max loads for boilers (MW)"
                         a    b
(EEJ1,EEJ2,EEJ7)       255  255
(EEJ3,EEJ4,EEJ5,EEJ6)  265  265
(BEJ9,BEJ10,BEJ12)     250  250
(BEJ11,EEJ8)           300  300
(AUVERE1)              900
;

Parameter
  kv_kt(t_el)          "Effect of calorific value to efficiency (%/(MJ/kg))"
  katelt_plokis(t_el)  "Mitmest katlast tootmisüksus koosneb";
;

$loaddc katelt_plokis t_ht=t_sj kv_kt

katelt_plokis(t_el)$(katelt_plokis(t_el) = 0) = 1;

Sets
  para_kt           "Piecewise linear efficiency approximation parameters"
  para_lk           "Piecewise linear efficiency approximation points"
  t_cl(t_el)        "Production units that use crushed limestone for emission reduction"
  t_lime(t_el)      "Production units that use lime for emission reduction"
  ol_product        "Shale oil products"
  r_kp              "Maintenance beginning and end date"
  r_num             "Maintenance serial number"

;
$loaddc para_lk para_kt t_cl=t_killustik t_lime=t_lubi

**********************************************************************************
**                                                                               *
** Define all parameters                                                         *
**                                                                               *
**********************************************************************************

Parameters
  max_load_el_s(sim, t_el, year, month) "Maximum allowed power generation load (MW)"
  max_load_el(t_el, year, month) "Maximum allowed power generation load (MW)"

  max_load_pu(t_el, year, month)      "Maximum combined load (MW)"
  max_load_ht(t_el)                   "Maximum allowed head load (MW)"

  max_load_ol_s(sim, t_ol, year, month) "Installed net capacity oil / day (input is oil shale t/h)"
  max_load_ol(t_ol, year, month) "Installed net capacity oil / day (input is oil shale t/h)"

  max_load_ol_temp(t_ol, year, month) "Temporary placeholder for oil production capacity"
  max_load_el_temp(t_el, year, month) "Temporary placeholder for power production capacity"
  yield_oil(t_ol, year)               "Oil yield at production plant(%)"
  min_load_el(t_el)                   "Minimal allowed load for power generation (MW)"
  min_load_ht(t_el)                   "Minimal allowed load for heat production (MW)"
  efficiency(t_el, para_lk, para_kt)  "Efficiencies for production units. Piecewise linear. (prim/sec)"
  eff_lookup(t_el, para_lk, para_kt)  "Efficiency lookup table (prim/sec)"
  ht_efficiency(t_el)                 "Heat production efficiency (MWh(ht)/MWh(fuel))"
  delta_up(t_el)                      "Ramp up rate (MW/h)"
  delta_down(t_el)                    "Ramp down rate (MW/h)"
  misc_lost_pwr(t_el, year ,month)    "Miscellaneous lost production capacities (MW)"
  lime_consumption(t_lime)            "Lime consumption rate (kg/MWh)"
  t_rg(t_el, year, month)             "Utilisation capacity of retort gas (m3/h)"
  rg_yield(t_ol)                      "Oil plant retort gas yield (m3/t oil shale)"
  t_supply_vc(t, year)                "Feedstock supply variable cost (EUR/t)"
  t_supply_gr_vc(k, feedstock, t, year)           "Optional feedstock griding costs (EUR/t)"
  t_el_min_sum_peak(year, month)      "Minimaalne summaarne kuine elektrikoormus (MWh)"
  t_el_min_sum_offpeak(year, month)   "Minimaalne summaarne kuine elektrikoormus (MWh)"
  t_mx_schedule(time_t, slot, t)      "Production unit maintenance hours in time slot (h)"
  failure_rate(t, year)               "Production unit failure rate (proportion of monthly production capacity)"
  startup_vc(t_el)                    "Startup costs for cold start (EUR)"
  t_mx(t_el, year)                    "Maintenance period length (days)"
  p_days_month_oil(t_ol, year, month) "Oil plant maintenance days in month"
  r_days_month_oil(t_ol, year, month) "Oil plant cleaning days in month"
  el_other_vc(t_el, year)             "Other variable costs related to power production (€/MWh(el))"
  ht_other_vc(t_el, year)             "Other variable costs related to heat production (€/MWh(heat))"
  oil_other_vc(t_ol, year)            "Other variable costs related to oil production (€/t(oil))"
  permitted_use(year, month, t, k, feedstock) "Permitted use of feedstock in production"
  cv_min(t, year, month)              "Minimum allowed calorific value of feedstock"
  max_ratio(k, feedstock, t)          "Maximal ratio of feedstock entering the production unit (%)"
  t_rg_total(year, month)             "Total retort gas usage capacity (m3)"

  failure_s(sim, t, year)             "Adjusted failure rate"

  t_maintenance(t, r_num, r_kp)       "Maintenance scheduled"
  oil_prod_prop(t_ol, ol_product)      "Percentage of oil product from total produce (fuel oil / gasoline)"
;

**********************************************************************************
**                                                                               *
** And load them                                                                 *
**                                                                               *
**********************************************************************************
$loaddc max_load_el_temp=max_koormus_el max_load_pu=max_koormus_ty
$loaddc max_load_ht=max_koormus_sj max_load_ol_temp=max_koormus_ol
$loaddc yield_oil=tootlikkus_ol  min_load_ht=min_koormus_sj efficiency=kasutegur
$loaddc ht_efficiency=soojuse_kasutegur
$loaddc min_load_el=min_koormus_el
$load delta_up=delta_yles delta_down=delta_alla
$loaddc misc_lost_pwr
$loaddc lime_consumption
$loaddc t_rg=t_uttegaas t_supply_vc=t_ket_kulu t_el_min_sum_peak t_el_min_sum_offpeak
$loaddc failure_rate=avariilisus startup_vc=kulu_kylmkaivitus
$loaddc p_days_month_oil=p_paevi_kuus_ol r_days_month_oil=r_paevi_kuus_ol
$loaddc t_mx=TRemont
$loaddc rg_yield=uttegaasi_tootlikkus
$load el_other_vc=el_muud_kulud ht_other_vc=soojuse_muud_kulud oil_other_vc=oil_muud_kulud
$load max_ratio=max_osakaal cv_min=kyttevaartus_min permitted_use=lubatud_kasutus
$loaddc ol_product=oli_toode oil_prod_prop=oli_toote_osakaal
$loaddc r_kp r_num
$load t_supply_gr_vc=t_purustamiskulu

**********************************************************************************
**                                                                               *
** Some processings and conversions                                              *
**                                                                               *
**********************************************************************************
max_load_el_s(sim, t_el, year, month) = max_load_el_temp(t_el, year, month);
max_load_ol_s(sim, t_ol, year, month) = max_load_ol_temp(t_ol, year, month);

* a output
* b inout

min_load_el("BEJ11") = 40;

Parameter turbine_loss(t_el)  "Static power loss in turbines (MW)"
/
  (EEJ1,EEJ2,EEJ7)        8
  (EEJ3,EEJ4)             6
  (EEJ5,EEJ6)             6
  (EEJ8)                  6
  (BEJ11)                 3
  (AUVERE1)              10
  (BEJ12)                 3
/;

efficiency(t_el, para_lk, "b")$(efficiency(t_el, para_lk, "b") > 0) = efficiency(t_el, para_lk, "b") + 0.01;

* Correct efficiencies according to minimum loads
* efficiency(t_el, "3", "a") = min_koormus_el(t_el);
efficiency(t_el, "2", "a") = efficiency(t_el, "3", "a") - 0.1;

eff_lookup(t_el, para_lk, "a")$(efficiency(t_el, para_lk, "b") > 0) = efficiency(t_el, para_lk, "a");
eff_lookup(t_el, para_lk, "b")
                        $(efficiency(t_el, para_lk, "b") > 0
                      and efficiency(t_el, para_lk, "a") > 0)
      = efficiency(t_el, para_lk, "a") / efficiency(t_el, para_lk, "b");

eff_lookup(t_el, para_lk, "b")
                        $(efficiency(t_el, para_lk, "b") = 0
                      and efficiency(t_el, para_lk, "a") > 0)
      = eff_lookup(t_el, para_lk+1, "b")-1;

ht_efficiency(t_el)$(max_load_ht(t_el) = 0) = 1;

t_rg_total(year, month) = sum(t_el, t_rg(t_el, year, month));
failure_s(sim, t, year)  = failure_rate(t, year);

* Convert MJ/kg to MWh/t
cv_min(t, year, month) = cv_min(t, year, month) / 3.6;


**********************************************************************************
**                                                                               *
** Slots can be defined only when production units have been defined.            *
**********************************************************************************

$libinclude pco_calendar_slots

**********************************************************************************
**                                                                               *
** Use date pairs that define maintenance schedule and create 0/1 maintenance    *
** schedule. Input is dates in format DDMMYY.                                    *
**                                                                               *
** Peeter Meos                                                                   *
**********************************************************************************
$loaddc t_maintenance=t_remondid
t_mx_schedule(time_t, slot, t) = 0;
Scalar
  r_day, r_month, r_year, r_beg, r_end
;

loop(r_num,
  loop(t,
* Calculate day numbers for maintenance days
      if ((t_maintenance(t, r_num, 'algus') > 0 and t_maintenance(t, r_num, 'lopp') > 0),
          r_day  = trunc(t_maintenance(t, r_num, 'algus') / 1E4);
          r_month   = trunc((t_maintenance(t, r_num, 'algus') - (r_day * 1E4)) / 1E2);
          r_year = 2000 + t_maintenance(t, r_num, 'algus') - (r_day * 1E4) - (r_month * 1E2);

          r_beg = jdate(r_year, r_month, r_day) - jdate(%year_1%, 1, 1) + 1;

          r_day  = trunc(t_maintenance(t, r_num, 'lopp') / 1E4);
          r_month   = trunc((t_maintenance(t, r_num, 'lopp') - (r_day * 1E4)) / 1E2);
          r_year = 2000 + t_maintenance(t, r_num, 'lopp') - (r_day * 1E4) - (r_month * 1E2);

          r_end = jdate(r_year, r_month, r_day) - jdate(%year_1%, 1, 1) + 1;

          t_mx_schedule(time_t, slot, t) = t_mx_schedule(time_t, slot, t) +
                                             sum((cal_time, weekday, time_hour)$(
                                            (ord(cal_time) ge r_beg)
                                        and (ord(cal_time) le r_end)
                                        and cal_t(time_t, cal_time)
                                        and slot_hours(slot, weekday, time_hour)
                                        and wkday_number_cal(cal_time) = ord(weekday)
                                                    ), 1);
         );
      );
    );

* Calculate correct number of hours in slot adjusted by maintenance days
slot_length_s(sim, time_t, slot, t) = slot_length_orig(time_t, slot, t) - t_mx_schedule(time_t, slot, t);
slot_length_s(sim, time_t, slot, t) = slot_length_s(sim, time_t, slot, t) * (1 -  sum((year, month)$y_m_t, failure_rate(t, year)));
slot_length_s(sim, time_t, slot, t)$(slot_length_s(sim, time_t, slot, t) < 0) = 0;

*slot_length_s(sim, time_t, slot, t_el)$(sum((year, month)$y_m_t, max_load_pu(t_el, year, month)) = 0) = 0;
slot_length(time_t, slot, t_el) = sum(sim$(ord(sim) = 1), slot_length_s(sim, time_t, slot, t_el));

**********************************************************************************
*                                                                                *
* Calculation of true capacities of oil plants (t oil / day)                     *
*                                                                                *
* Peeter Meos, 4. september 2014                                                 *
**********************************************************************************

max_load_ol_s(sim, t_ol, year, month)$(sum((time_t)$y_m_t, 1) > 0) =
* Tons of oilshale in day
   max_load_ol_temp(t_ol, year, month)
   * sum((time_t, slot)$y_m_t, slot_length_orig(time_t, slot, t_ol))
   / sum((time_t)$y_m_t, 1)
* Tons of oil in day
   * yield_oil(t_ol, year)
* Correct with days of maintenace and cleanings
   * ((days_in_month(month) + gleap(jdate(first_year + ord(year) - 1, ord(month), 1)))
      - p_days_month_oil(t_ol, year, month)
      - r_days_month_oil(t_ol, year, month)
      )
   / (days_in_month(month) + gleap(jdate(%year_1% + ord(year) - 1, ord(month), 1)))
;

********************************************************************************
**                                                                             *
** Max net power production capacity adjustment                                *
**                                                                             *
** Description: Net production capacity that should remain standard across     *
** times, need to be adjusted for various reasons from month to month          *
** misc_lost_pwr implements it. The values will be deducted from net capacity. *
**                                                                             *
** Macros used: None                                                           *
** Notes: None                                                                 *
**                                                                             *
********************************************************************************

max_load_pu(t_el, year, month) = max_load_pu(t_el, year, month)
  - misc_lost_pwr(t_el, year, month);

max_load_el_s(sim, t_el, year, month) = max_load_el_s(sim, t_el, year, month)
  - misc_lost_pwr(t_el, year ,month);

* Correction for oil plant elecritity production
max_load_el_s(sim, t_el, year, month)$t_ol(t_el) = max_load_el_s(sim, t_el, year, month)
  * ((days_in_month(month) + gleap(jdate(first_year + ord(year) - 1, ord(month), 1)))
        - sum(t_ol$sameas(t_ol, t_el), p_days_month_oil(t_ol, year, month) + r_days_month_oil(t_ol, year, month))
        )
     / (days_in_month(month) + gleap(jdate(%year_1% + ord(year) - 1, ord(month), 1)));

max_load_el(t_el, year, month) = max_load_el_s("1", t_el, year, month);
max_load_ol(t_ol, year, month) = max_load_ol_s("1", t_ol, year, month);

********************************************************************************
**                                                                             *
** Min required production (daily)                                             *
**                                                                             *
** Macros used: y_m_t                                                          *
** Notes: None                                                                 *
**                                                                             *
********************************************************************************
Parameter min_production(time_t);

min_production(time_t) =
  sum((year, month, cal_time_sub, weekday, time_hour)$(y_m_t
                             and cal_t(time_t, cal_time_sub)
                             and wkday_number_cal_sub(cal_time_sub) = ord(weekday)
                             and (   ord(time_hour) < 8
                                  or ord(time_hour) > 20
                                  or day_type(time_t) > 0)
                              ),
         t_el_min_sum_offpeak(year, month))
  +
  sum((year, month, cal_time_sub, weekday, time_hour)$(y_m_t
                             and cal_t(time_t, cal_time_sub)
                             and wkday_number_cal_sub(cal_time_sub) = ord(weekday)
                             and ord(time_hour) > 7
                             and ord(time_hour) < 21
                             and day_type(time_t) = 0
                             ),
       t_el_min_sum_peak(year, month))
;
