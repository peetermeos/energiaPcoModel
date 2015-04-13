********************************************************************************
**                                                                             *
** This file contains all constraints related to emissions and the environment *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

Equations
  v_em_lambda2(time_t, slot, t_el, k, feedstock)"Piecewise linear approximation"
  v_em_lambda5(time_t, slot, t_el, k, feedstock)"Lambdas must sum to one"
  v_em_var_rep1(time_t, slot, t_el, k, feedstock, para_lk)  "Emission variable - replacement of binary component"
  v_em_var_rep2(time_t, slot, t_el, k, feedstock)           "Emission variable - replacement of continuous component"
  v_so_quota(year)                              "Annual SOx quota limit to production"
  v_hh_emissions(time_t, t_el, em)              "Emission concentration constraints"

$ifthen.two "%l_k_invoked%" == "true"
  v_em_lambda1_k(time_t, slot, t_cl, k_level)   "Use of crushed stone for emission reduction"
  v_em_lambda1_l(time_t, slot, t_lime, l_level) "Use of lime for emission reduction"
  v_em_lambda4_k(time_t, slot, t_cl)            "Crushed limestone use decisions must sum to one"
  v_em_lambda4_l(time_t, slot, t_lime)          "Lime use decisions must sum to one"
$endif.two

$ifthen.two "%hr%" == "true"
 v_stack_active(time_t, slot, t_stack)          "Binary for smokestack use (connects use and power load)"
 v_stack_hours(t_stack)                         "Upper limit for usage hours"
$endif.two

$ifthen.two "%cw%" == "true"
  v_cooling_water(time_t, slot)                 "Cooling constraint for electricity production"
$endif.two
;

********************************************************************************
** This ugliness cuts down solution space for piecewise linear emission        *
** approximation. We are trying to filter out already infeasible combinations  *
********************************************************************************
  lambda_e.fx(time_t, slot, t_el,
              k, feedstock, k_level, l_level, para_lk)
                                        $(fs_k(k, feedstock) and max_ratio(k, feedstock, t_el) = 0)= 0;

  lambda_e.up(time_t, slot, t_cl,
              k, feedstock, k_level, "0", para_lk)$(fs_k(k, feedstock) and max_ratio(k, feedstock, t_cl) > 0)   = 1;

  lambda_e.up(time_t, slot, t_lime,
              k, feedstock, "0", l_level, para_lk)$(fs_k(k, feedstock) and max_ratio(k, feedstock, t_lime) > 0) = 1;

  lambda_e.fx(time_t, slot, t_el,
              k, feedstock, k_level, l_level, para_lk)$(fs_k(k, feedstock) and  max_ratio(k, feedstock, t_el) > 0
                                                    and not sameas(k_level, "0")
                                                    and not t_cl(t_el))  = 0;

  lambda_e.fx(time_t, slot, t_el,
              k, feedstock, k_level, l_level, para_lk)$(fs_k(k, feedstock) and  max_ratio(k, feedstock, t_el) > 0
                                                    and not sameas(l_level, "0")
                                                    and not t_lime(t_el))= 0;

  lambda_e.up(time_t, slot, t_el,
              k, feedstock, k_level, l_level, para_lk)$(fs_k(k, feedstock) and  max_ratio(k, feedstock, t_el) > 0
                                                    and t_cl(t_el)
                                                    and t_lime(t_el)) = 1;

  z_emission.fx(time_t, slot, k, feedstock, t_el, "1") = 0;
  z_emission.fx(time_t, slot, k, feedstock, t_el, "1")
                                        $(max_ratio(k, feedstock, t_el) = 0)= 0;

********************************************************************************
** Binary variables and constraints for smokestack usage. Loading at connected *
** production unit forces smokestack use to one at this time slot.             *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************
$ifthen.two "%hr%" == "true"
v_stack_active(time_t, slot, t_stack)$time_t_s(time_t)..
  sum(t_el$t_unit_stack(t_stack, t_el),
       k_alpha(time_t, slot, t_el)
     )
  =l= st_active(time_t, slot, t_stack)
;

********************************************************************************
** Hours of smokestack used must be less than the imposed limit                *
** Peeter Meos                                                                 *
********************************************************************************

v_stack_hours(t_stack)$(hour_limit(t_stack) > 0)..
     sum((time_t, slot)$time_t_s(time_t),
          st_active(time_t, slot, t_stack)
        * smax(t$t_unit_stack(t_stack, t), slot_length_orig(time_t, slot, t))
    )
    =l= hour_limit(t_stack)
;
$endif.two

********************************************************************************
** SOx quota annual constraint                                                 *
** Peeter Meos                                                                 *
********************************************************************************
v_so_quota(year)..
  sum((time_t, month)$(time_t_s(time_t) and y_m_t),
      sum(t_el, sum(slot,
              sum((feedstock, k)$(max_ratio(k, feedstock, t_el) > 0),
                        em_level_el(time_t, slot, "so", k, feedstock, t_el))
                      * slot_length(time_t, slot, t_el)
              )
          ))
* Taking into account already spent quota
   =l=
   em_quota(year, "so") - spent_sox(year)
;

********************************************************************************
** Constraint for cooling water                                                *
** Taaniel Uleksin                                                             *
********************************************************************************
$ifthen.two "%cw%" == "true"
v_cooling_water(time_t, slot)$time_t_s(time_t)..
  sum(t_el, k_alpha(time_t, slot, t_el) *
    sum((year, month)$y_m_t, cw_usage(t_el, month)))
  =l=
  sum((year, month)$y_m_t, em_quota(year, "jv"))
;
$endif.two

********************************************************************************
** Constraints specific for crushed limestone and lime                         *
** Peeter Meos                                                                 *
********************************************************************************

$ifthen.two "%l_k_invoked%" == "true"
v_em_lambda1_k(time_t, slot, t_cl, k_level)$time_t_s(time_t)..
  sum((k, feedstock, l_level, para_lk)$(ord(para_lk) > 1
                                    and max_ratio(k, feedstock, t_cl) > 0),
       lambda_e(time_t, slot, t_cl, k,
                feedstock, k_level, l_level, para_lk))
  =l=
  add_k(time_t, slot, t_cl, k_level)
;

v_em_lambda1_l(time_t, slot, t_lime, l_level)$time_t_s(time_t)..
  sum((k, feedstock, k_level, para_lk)$(ord(para_lk) > 1
                                    and max_ratio(k, feedstock, t_lime) > 0),
       lambda_e(time_t, slot, t_lime,
                k, feedstock, k_level, l_level, para_lk))
  =l=
  add_l(time_t, slot, t_lime, l_level)
;

v_em_lambda4_k(time_t, slot, t_cl)$time_t_s(time_t)..
  sum(k_level, add_k(time_t, slot, t_cl, k_level))
  =e= 1
;

v_em_lambda4_l(time_t, slot, t_lime)$time_t_s(time_t)..
  sum(l_level, add_l(time_t,  slot, t_lime, l_level))
  =l= 1
;
$endif.two

********************************************************************************
** Piecewise linear approximation of instataneous emissions                    *
** Peeter Meos                                                                 *
********************************************************************************
v_em_lambda2(time_t, slot, t_el, k, feedstock)$((time_t_s(time_t)
                                          and not sameas(t_el, "Katlamaja") )
                                          and max_ratio(k, feedstock, t_el) > 0
                                                        )..
 sum((k_level, l_level, para_lk),
     lambda_e(time_t, slot, t_el,
              k, feedstock, k_level, l_level, para_lk)
   * hh_q(t_el, para_lk))
  =g=
  sum((k2, p2)$(max_ratio(k2, p2, t_el) > 0), q(time_t, slot, k2, p2, t_el))
  -
  load_ht(time_t, slot, t_el) / ht_efficiency(t_el)
;

v_em_lambda5(time_t, slot, t_el, k, feedstock)$(time_t_s(time_t)
                                                  and not sameas(t_el, "Katlamaja")
                                                                    and max_ratio(k, feedstock, t_el)>0
                                                                    )..
  sum((para_lk, k_level, l_level), lambda_e(time_t, slot, t_el,
                                            k, feedstock, k_level, l_level, para_lk))
  =e=
  1
;

********************************************************************************
** Variable replacement to get rid of multiplication of binary and continuous  *
** Peeter Meos                                                                 *
********************************************************************************
v_em_var_rep1(time_t, slot, t_el, k, feedstock, para_lk)$(
                                                 time_t_s(time_t)
                                             and max_ratio(k, feedstock, t_el) > 0
                                             and ord(para_lk) > 1)..
  z_emission(time_t, slot, k, feedstock, t_el, para_lk)
  =l=
  sum((k_level, l_level),
      lambda_e(time_t, slot, t_el,
               k, feedstock, k_level, l_level, para_lk))
  * hh_q(t_el, para_lk)
;

********************************************************************************
** Variable replacement to get rid of multiplication of binary and continuous  *
**                                                                             *
** Macros used: q - sum of z_emissions                                         *
** Peeter Meos                                                                 *
********************************************************************************
v_em_var_rep2(time_t, slot, t_el, k, feedstock)$(
                                               time_t_s(time_t)
                                           and max_ratio(k, feedstock, t_el) > 0
*                                             and ord(para_lk) > 1
                                             )..
  sum(para_lk, z_emission(time_t, slot, k, feedstock, t_el, para_lk) )
  =g=
  q(time_t, slot, k, feedstock, t_el)
;

********************************************************************************
** Concentrations of instataneous emissions must be within limits              *
**                                                                             *
** Description: we are calculating average concentration across all entering   *
**              feedstock limiting it with an upper bound. This applies        *
**              only to the production units that have no operating            *
**              hourly limits.  t_unit_stack defines the production units      *
**              that have operating hour limits imposed.                       *
**                                                                             *
** Macros: y_m_t - tuple for connecting calendar time and model time           *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************
v_hh_emissions(time_t, t_el, em)$(time_t_s(time_t)
 and sum((year, month)$y_m_t, hh_limit(em, year)) > 0
 and sum((k, feedstock, para_lk), hh_coef(em, t_el, k, feedstock, para_lk)) > 0
                          and sum(t_stack$t_unit_stack(t_stack, t_el), 1) = 0)..

  sum((slot, k, feedstock, para_lk),
      hh_coef(em, t_el, k, feedstock, para_lk)
    * sum((k_level, l_level), lambda_e(time_t, slot, t_el,
                                       k, feedstock, k_level, l_level, para_lk))
     )
  =l=
  sum((slot, k, feedstock, para_lk),
      sum((year, month)$y_m_t, hh_limit(em, year))
    * sum((k_level, l_level), lambda_e(time_t, slot, t_el,
                                       k, feedstock, k_level, l_level, para_lk))
     )
;
