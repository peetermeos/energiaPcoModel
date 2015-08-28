********************************************************************************
**                                                                             *
** Constant definition for generating Bender's cuts                            *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

cutconst(b_iter) = cutconst(b_iter)

********************************************************************************
* Mining and primary energy acquisition constraints                            *
********************************************************************************
  - 1/%numsim% * sum((sim, time_t, feedstock),
                            -v_k_fs_acquired_m(sim, time_t, feedstock)
                          * sum((year, month)$y_m_t, max_mining_cap("Hange", feedstock, year, month)
                          / monthly_workdays(year, month, "Hange")))

********************************************************************************
* Emissions constraints                                                        *
********************************************************************************
  - 1/%numsim% * sum((sim, year),
                 -v_so_quota_m(sim, year)
               * (em_quota(year, "so") - spent_sox(year)))

$ifthen.c "%l_k_invoked%" == "true"
  - 1/%numsim% * sum((sim, time_t, slot, t_cl),
                 -v_em_lambda4_k_m(sim, time_t, slot, t_cl))

  - 1/%numsim% * sum((sim, time_t, slot, t_lime)$z_subset(sim),
                 -v_em_lambda4_l_m(sim, time_t, slot, t_lime))
$endif.c

$ifthen.c "%hr%" == "true"
  - 1/%numsim% * sum((sim, t_stack)),
                 -v_stack_hours_m(sim, t_stack)$(hour_limit(t_stack) > 0)
               * hour_limit(t_stack))
$endif.c

$ifthen.c "%cw%" == "true"
  - 1/%numsim% * sum((sim, time_t, slot),
                 -v_cooling_water_m(sim, time_t, slot)
               * sum((year, month)$y_m_t, em_quota(year, "jv")))
$endif.c
********************************************************************************
* Hedging constraints                                                          *
********************************************************************************
   - 1/%numsim% * sum((sim, serial, year),
                             -v_co2_cert_usage_m(sim, serial, year)
                            * co2_certs(serial, year, "kogus"))

********************************************************************************
* Logistics constraints                                                        *
********************************************************************************
*   + 1/%numsim% * sum((sim, time_t, s_k), -v_k_storage3.m(sim, time_t, s_k)$(ord(time_t) eq card(time_t)) * min_storage(s_k))
*   + 1/%numsim% * sum((sim, time_t, s_t), -v_t_storage3.m(sim, time_t, s_t)$(ord(time_t) eq card(time_t)) * min_storage(s_t))

   - 1/%numsim% * sum((sim, time_t, s_k), -v_max_storage_k_m(sim, time_t, s_k) * max_storage(s_k))

   - 1/%numsim% * sum((sim, time_t, s_t), -v_max_storage_t_m(sim, time_t, s_t) * max_storage(s_t))

   - 1/%numsim% * sum((sim, time_t, s_t), -v_min_storage_t_m(sim, time_t, s_t) * min_storage(s_t))

   - 1/%numsim% * sum((sim, time_t, l),
                             -v_max_throughput_m(sim, time_t, l)$(max_throughput(l) > 0)
                           * max_throughput(l) * days_in_t(time_t))

   - 1/%numsim% * sum((sim, time_t, k),
                             -v_max_loading_k_m(sim, time_t, k)
                           * sum((year, month)$y_m_t, max_loading_k(k, year)) * days_in_t(time_t))

   - 1/%numsim% * sum((sim, time_t, l),
                             -v_max_loading_l_m(sim, time_t, l)
                           * sum((year, month)$y_m_t, max_loading_l(l, year)) * days_in_t(time_t))

********************************************************************************
* Production constraints                                                       *
********************************************************************************
$ifthen.c "%ht%" == "true"
   - 1/%numsim% * sum((sim, time_t, slot),
                             -v_ht_delivery_ext_m(sim, time_t, slot)
                           * sum((year, month)$y_m_t, heat_delivery(year, month)
                                               / (days_in_month_l(year, month))
                                               / 24 * smax(t, slot_length_orig(time_t, slot, t))))

   - 1/%numsim% * sum((sim, time_t, slot),
                             -v_ht_delivery_int_m(sim, time_t, slot)
                           * sum((year, month)$y_m_t, internal_heat_delivery(year, month)
                                               / (days_in_month_l(year, month))
                                               / 24 * smax(t, slot_length_orig(time_t, slot, t))))
$endif.c

*$if "%l_k_invoked%" == "true"   v_cl_use
*$if "%l_k_invoked%" == "true"   v_lime_use,
*$if "%fc%" == "true"  v_pu_decom_load,
*$if not "%cleanings%" == "true" v_cleaning4,

  - 1/%numsim% * sum((sim, time_t, slot, t_el),
                            -v_max_load_el_m(sim, time_t, slot, t_el)
                          * sum((year,month), max_load_el_s(sim, t_el, year, month)$y_m_t))

  - 1/%numsim% * sum((sim, time_t, slot, t_el),
                            -v_max_load_pu_m(sim, time_t, slot, t_el)
                          * sum((year,month), max_load_pu(t_el, year, month)$y_m_t))

  - 1/%numsim% * sum((sim, time_t, slot, t_el),
                            -v_delta_up_el_m(sim, time_t, slot, t_el)$(not sameas(t_el, "Katlamaja")
                                                                      and delta_up(t_el) > 0
                                                                      and not (ord(time_t) eq 1
                                                                      and ord(slot) eq 1)
                                                                      and (not t_ol(t_el)))
                          * delta_up(t_el))

  - 1/%numsim% * sum((sim, time_t, slot, t_el),
                            -v_delta_down_el_m(sim, time_t, slot, t_el)$(not sameas(t_el, "Katlamaja")
                                                                       and delta_down(t_el) > 0
                                                                       and not (ord(time_t) eq 1
                                                                       and ord(slot) eq 1)
                                                                       and (not t_ol(t_el)))
                          * delta_down(t_el))

  - 1/%numsim% * sum((sim, time_t, slot, t_el),
                            -v_lambda_m(sim, time_t, slot, t_el)$(not t_ol(t_el)) * (card(para_lk) - 1))

  - 1/%numsim% * sum((sim, time_t, t_ol),
                            -v_max_cap_oil_m(sim, time_t, t_ol)
                          * sum((year, month)$y_m_t, max_load_ol_s(sim, t_ol, year, month)))

  - 1/%numsim% * sum((sim, time_t), -v_min_production_el_m(sim, time_t)$(day_type(time_t) = 0)
                * (  sum((year, month, cal_time_sub, weekday, time_hour)$(y_m_t
                                      and cal_t(time_t, cal_time_sub) and wkday_number_cal_sub(cal_time_sub) = ord(weekday)
                                      and (ord(time_hour) < 8 or ord(time_hour) > 20 or day_type(time_t) > 0)),
                  t_el_min_sum_offpeak(year, month))
           +
           sum((year, month, cal_time_sub, weekday, time_hour)$(y_m_t
                                      and cal_t(time_t, cal_time_sub) and wkday_number_cal_sub(cal_time_sub) = ord(weekday)
                                      and ord(time_hour) > 7 and ord(time_hour) < 21 and day_type(time_t) = 0),
                t_el_min_sum_peak(year, month))))

  - 1/%numsim% * sum((sim, year, month, t, k, feedstock),
                            -v_permitted_use_m(sim, year, month, t, k, feedstock)
                          * permitted_use(year, month, t, k, feedstock) * M * M)
       ;
