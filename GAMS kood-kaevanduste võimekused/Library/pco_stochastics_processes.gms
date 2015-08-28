********************************************************************************
**                                                                             *
**  Stochastics for prices and reliability                                     *
**  14. mai 2014                                                               *
**                                                                             *
**  Peeter Meos                                                                *
********************************************************************************

Set
  hist_year  "Historical years"
  hist_day   "Historical days"
  rel_para   "Reliability parameters"
;

$load hist_year=ajal_aasta hist_day=ajal_paev rel_para=av_para

Parameter
  hist_el(hist_year, month, hist_day, time_hour)  "Historical electricity prices (EUR/MWh)"
  rel_table(t, rel_para)                          "MTBF and MTTR times for production units (hour)"
  keskmine_ref(year)                              "Average reference price for electircity (EUR/MWh)"
  keskmine_ajal(hist_year)                        "Average historical price for electiricity (EUR/MWh)"
  temp_aasta(month, hist_day, time_hour)          "Temporary year structure"
  co(year, month)                                 "CO2 price for each month (EUR/t)"
  rel_s(sim, cal_time, t)                         "Reliability for given day (%)"
  rel(cal_time, t)                                "Reliability for given day (%)"
;

$load hist_el=ajal_elekter rel_table=av_tabel


********************************************************************************
** Price realisations for electricity and CO2                                  *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************
Scalar random_aasta, keskmine;

execseed = 1 + gmillisec(jnow);

keskmine_ref(year) = sum((month, day, time_hour), elektri_referents(year, month, day, time_hour))
                    / (sum((month, day, time_hour)$(elektri_referents(year, month, day, time_hour) > 0), 1)+1);

loop((sim, year),
    random_aasta = round(uniform(1, card(hist_year)));

    keskmine  = sum(hist_year$(ord(hist_year) = random_aasta),
                       sum((month, hist_day, time_hour), hist_el(hist_year, month, hist_day, time_hour))
                     / sum((month, hist_day, time_hour), 1)
                   );

* Now random year is selected, lets adjust current years price curve to match historic shape
    temp_aasta(month, hist_day, time_hour) = sum(hist_year$(ord(hist_year) = random_aasta),
                                                   hist_el(hist_year, month, hist_day, time_hour));

    loop((time_t, month, hist_day)$(
                 ord(hist_day) = gday(jdate(%year_1%, 1, 1) - 1 + ord(time_t))
                 and y_m_t
                 ),
         el_price_slot_s(sim, time_t, slot) =
                    sum((day, weekday, time_hour)
                                      $(y_m_t
                                    and days
                                    and gdow(jdate(%year_1% + ord(year) - 1, ord(month), ord(day))) = ord(weekday)
                                    and slot_hours(slot, weekday, time_hour)
                                      ),  temp_aasta(month, hist_day, time_hour) / keskmine * keskmine_ref(year)
                                      )
                                      /
                    sum((day, weekday, time_hour)
                                      $(y_m_t
                                    and days
                                    and gdow(jdate(%year_1% + ord(year) - 1, ord(month), ord(day))) = ord(weekday)
                                    and slot_hours(slot, weekday, time_hour)
                                      ),  1
                                      );
        );
);

* This row is extremely slow to execute. Why?
el_price_slot_s(sim, time_t, slot) = el_price_slot_s(sim, time_t, slot)
                                  + normal(0, 0.1 * el_price_slot_s(sim, time_t, slot));

* CO2 and oil are just random as of now.
;
co2_price_s(sim, year)$(co2_price_s(sim, year) > 3) = co2_price_s(sim, year) + normal(0, 0.2 * co2_price_s(sim, year));

oil_price_s(sim, year, month)$(oil_price_s(sim, year, month) > 0) = oil_price_s(sim, year, month) + normal(0, 25);

********************************************************************************
** Calculation of maintenance scenaria                                         *
********************************************************************************

Parameter
  t_mx_schedule_s(sim, time_t, slot, t)
  mean_delay
;

* Maintenance can stretch mean number of days
mean_delay = 3;
r_end_time(sim, t, r_num)$(t_maintenance(t, r_num, 'lopp')  > 0)
  = r_end_time("1", t, r_num) + floor(-mean_delay * log(uniform(0,1)));

* Calculate day numbers for maintenance days
t_mx_schedule_s(sim, time_t, slot, t) = sum((r_num, cal_time)$(
                                            (ord(cal_time) ge r_beg_time(t, r_num))
                                        and (ord(cal_time) le r_end_time(sim, t, r_num))
                                        and cal_t(time_t, cal_time)),
                                          sum((weekday, time_hour)$(
                                              slot_hours(slot, weekday, time_hour)
                                          and wkday_number_cal(cal_time) = ord(weekday)
                                                    ), 1));

t_mx_schedule(time_t, slot, t) = sum(sim$(ord(sim) = 1), t_mx_schedule_s(sim, time_t, slot, t));

********************************************************************************
** Calculation of reliability scenaria                                         *
** Originally MTBF and MTTR times are given in hours.                          *
** status = 0 - unit is operational                                            *
** status = 1 - unit is down                                                   *
********************************************************************************

Scalars
 status     /0/
 amount     /0/
 next_event "Exponential RV" /0/
 corr       "Correlation"    /0.8/
 u1         "Uniform RV"
;

rel_table(t, "mtbf") =  rel_table(t, "mtbf") * 1.10;

loop((sim, t)$(rel_table(t, "mtbf") > 0 and not sameas(t, "Katlamaja")),
* Next event is in days (ie. note division by 24)
  next_event = -rel_table(t, "mtbf") * log(uniform(0,1))/24;

  loop(cal_time_sub,
      if((ord(cal_time_sub) > next_event),
         rel_s(sim, cal_time_sub-1, t) = amount - amount * (ord(cal_time_sub) - next_event)$((ord(cal_time_sub) - next_event) < 1);
* New event
         status = 1 - status;
         u1$(status = 1) = uniform(0, 1);
         amount$(status = 1 and t_el(t)) = 1$(u1 > 2/3) + 0.5$(u1 <= 2/3);
         amount$(status = 1 and not t_el(t)) = 1;
         amount$(status = 0) = 0;
         next_event$(status = 0) = next_event - rel_table(t, "mtbf") * log(uniform(0,1))/24;
         next_event$(status = 1) = next_event - rel_table(t, "mttr") * log(uniform(0,1))/24;
      );
      rel_s(sim, cal_time_sub, t) = amount;
    );
);

* Now when we have the data for reliability, we need to recalculate time slots
  slot_length_s(sim, time_t, slot, t) = slot_length_orig(time_t, slot, t)
                                          - t_mx_schedule_s(sim, time_t, slot, t)$t_el(t)
                                          - sum((cal_time_sub, weekday, time_hour)$(cal_t(time_t, cal_time_sub)
                                                              and wkday_number_cal_sub(cal_time_sub) = ord(weekday)
                                                              and slot_hours(slot, weekday, time_hour)),
                                            rel_s(sim, cal_time_sub, t));

slot_length_s(sim, time_t, slot, t)$(slot_length_s(sim, time_t, slot, t) < 0) = 0;

* The ***** at oil plants are calling unscheduled maintenance as "cleaning"
* Thus we need to ignore cleaning days and only account for maintenance

max_load_ol_s(sim, t_ol, year, month)$(sum((time_t, slot)$y_m_t, slot_length_orig(time_t, slot, t_ol)) >0) =
* Tons of oilshale in day
   max_load_ol_temp(t_ol, year, month) * 24
* Tons of oil in day
   * yield_oil(t_ol, year)
* Correct with days of maintenace
   * (days_in_month_l(year, month)
      - r_days_month_oil(t_ol, year, month)
      )
   / days_in_month_l(year, month)
* Correct with stochastich reliability
   * sum((time_t, slot)$y_m_t, slot_length_s(sim, time_t, slot, t_ol))
   / sum((time_t, slot)$y_m_t, slot_length_orig(time_t, slot, t_ol))
;



