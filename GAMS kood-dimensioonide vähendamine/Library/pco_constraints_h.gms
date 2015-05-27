********************************************************************************
**                                                                             *
** Hedging and finance related constraints                                     *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************


Equation
  v_co2_cert_usage(serial, year)   "Upper bound for CO2 allowance for each year"
  v_co2_emission(time_t)           "CO2 emission balance equation, split between present quotas and spot market"
  v_el_position(time_t, slot)      "Total electicity sales, split spot market and forwards' market"
;

********************************************************************************
** Use of CO2 emission quota. We cannot use CO2 certificate more than          *
** its quantity allows.                                                        *
**                                                                             *
** Macros used: none                                                           *
** Peeter Meos                                                                 *
********************************************************************************

v_co2_cert_usage(serial, year)..
  sum((month, time_t)$(time_t_s(time_t) and y_m_t),
                                       co2_cert_usage(serial, time_t))
  =l=
  co2_certs(serial, year, "kogus");
;

********************************************************************************
** Use of CO2 emission quota Split between:                                    *
** 1) Already present CO2 certificates                                         *
** 2) Spot market                                                              *
**                                                                             *
** Macros used: y_m_t                                                          *
** Peeter Meos                                                                 *
********************************************************************************

v_co2_emission(time_t)$time_t_s(time_t)..
  sum((feedstock, k, t_el, slot)$(max_ratio(k, feedstock, t_el) > 0),
            em_level_co2(time_t, slot, k, feedstock, t_el) *
            slot_length(time_t, slot, t_el))
  =e=
* CO2 from certs from current year and previous years.
* The use of future certs is not allowed
  sum((year, y2, month, serial)$(y_m_t
             and co2_certs(serial, y2, "kogus") > 0
             and ord(y2) le ord(year)), co2_cert_usage(serial, time_t))
* CO2 from market
  + co2_spot_market(time_t)
;

********************************************************************************
** Power production and sales. Split between:                                  *
** 1) Monthly, quarterly and yearly forwards                                   *
** 2) Spot market                                                              *
**                                                                             *
** Macros used: y_m_t                                                          *
** Peeter Meos                                                                 *
********************************************************************************

el_fwd_position.up(serial, fwd_type, y2, month2)
    $(el_fwd_price(serial, fwd_type, y2, month2) > 0 and sameas(fwd_type, "year")) = 12000e3;
* 12000e3;

el_fwd_position.up(serial, fwd_type, y2, month2)
    $(el_fwd_price(serial, fwd_type, y2, month2) > 0 and sameas(fwd_type, "quarter")) =  4000e3;

el_fwd_position.up(serial, fwd_type, y2, month2)
    $(el_fwd_price(serial, fwd_type, y2, month2) > 0 and sameas(fwd_type, "month")) =  1000e3;


v_el_position(time_t, slot)$time_t_s(time_t)..
  sum(t_el, load_el(time_t, slot, t_el)
          * slot_length(time_t, slot, t_el))
  =e=
  el_spot_position(time_t, slot)
  +
** Use .l levels instead of variables for Bender's decomposition
* With Bender's decomposition
  (bender) * (
  sum((serial, fwd_type, y2, month2)$(el_fwd_price(serial, fwd_type, y2, month2) > 0),
**** Yearly forward must be spread evenly across the year
    (el_fwd_position.l(serial, fwd_type, y2, month2)$(sum((year, month)$(y_m_t
                                              and sameas(year, y2)), 1))
     / hours_in_year(y2) * sum(t$(ord(t) = 1), slot_length_orig(time_t, slot, t))
    )$(sameas(fwd_type, "year"))
    +
**** Quarterly forward must be spread evenly across the quarter
    (el_fwd_position.l(serial, fwd_type, y2, month2)$(sum((year, quarter, month)$(y_m_t
   and sameas(year, y2) and q_months(quarter, month) and q_months(quarter, month2)), 1))

     / sum((month, quarter)$(q_months(quarter, month2) and q_months(quarter, month)), hours_in_month(y2, month))
                  * sum(t$(ord(t) = 1), slot_length_orig(time_t, slot, t))
    )$(sameas(fwd_type, "quarter"))
    +
**** Monthly forward must be spread evenly across the month
    (el_fwd_position.l(serial, fwd_type, y2, month2)$(sum((year, month)$(y_m_t
   and sameas(year, y2) and sameas(month, month2)), 1))

     / hours_in_month(y2, month2) * sum(t$(ord(t) = 1), slot_length_orig(time_t, slot, t))
    )$(sameas(fwd_type, "month"))
   )
   ) +
* Without Bender's decomposition
  (1 - bender) * (
  sum((serial, fwd_type, y2, month2)$(el_fwd_price(serial, fwd_type, y2, month2) > 0),
**** Yearly forward must be spread evenly across the year
    (el_fwd_position(serial, fwd_type, y2, month2)$(sum((year, month)$(y_m_t
                                              and sameas(year, y2)), 1))
     / hours_in_year(y2)
     * sum(t$(ord(t) = 1), slot_length_orig(time_t, slot, t))
    )$(sameas(fwd_type, "year"))
    +
***** Quarterly forward must be spread evenly across the quarter
    (el_fwd_position(serial, fwd_type, y2, month2)$(sum((year, quarter, month)$(y_m_t
                                              and sameas(year, y2)
                                              and q_months(quarter, month)
                                              and q_months(quarter, month2)), 1))
     / sum((month, quarter)$(q_months(quarter, month2) and q_months(quarter, month)), hours_in_month(y2, month))
                  * sum(t$(ord(t) = 1), slot_length_orig(time_t, slot, t))
    )$(sameas(fwd_type, "quarter"))
    +
***** Monthly forward must be spread evenly across the month
    (el_fwd_position(serial, fwd_type, y2, month2)$(sum((year, month)$(y_m_t
                                              and sameas(year, y2)
                                              and sameas(month, month2)), 1))
     / hours_in_month(y2, month2) * sum(t$(ord(t) = 1), slot_length_orig(time_t, slot, t))
    )$(sameas(fwd_type, "month"))
   )
)
;

$ifthen.h not "%hedge%" == "true"
  el_fwd_position.up(serial, fwd_type, year, month) = 0;
$endif.h
