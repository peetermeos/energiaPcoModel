********************************************************************************
**                                                                             *
** Macro definitions. Dangerous and powerful stuff!                            *
**                                                                             *
**  Peeter Meos                                                                *
********************************************************************************

$macro y_m_t date_cal(time_t, year, month)
$macro y_m_t_s date_cal(time_t_s, year, month)
$macro days day_cal(time_t, day)

********************************************************************************
**                                                                             *
** Feedstock movement to production. Simplifies several production related     *
** constraints.                                                                *
**                                                                             *
********************************************************************************

$macro to_production(time_t, k, feedstock, t)                                  \
  (sum(s_t$(prod_storage(s_t, t)                                               \
       and (max_ratio(k, feedstock, t) > 0)                                    \
       and fs_k(k, feedstock) ) ,                                              \
      storage_to_production(time_t, s_t, t, k, feedstock)                      \
      )                                                                        \
  +                                                                            \
  sum((l, route)                                                               \
      $(route_endpoint(route, k, l)                                            \
       and (max_ratio(k, feedstock, t)>0)                                      \
       and fs_k(k, feedstock)                                                  \
       and t_dp_prod(l, t)),                                                   \
      logs_to_production(time_t, route, t, feedstock)                          \
      ))

$macro to_production_s(sim, time_t, k, feedstock, t)                           \
  (sum(s_t$(prod_storage(s_t, t)                                               \
       and (max_ratio(k, feedstock, t) > 0)                                    \
       and fs_k(k, feedstock) ) ,                                              \
      storage_to_production_l(sim, time_t, s_t, t, k, feedstock)               \
      )                                                                        \
  +                                                                            \
  sum((l, route)                                                               \
      $(route_endpoint(route, k, l)                                            \
       and (max_ratio(k, feedstock, t)>0)                                      \
       and fs_k(k, feedstock)                                                  \
       and t_dp_prod(l, t)),                                                   \
      logs_to_production_l(sim, time_t, route, t, feedstock)                   \
      ))                                                                       \

********************************************************************************
**                                                                             *
** Q variable replacement                                                      *
**                                                                             *
********************************************************************************
$macro   q(time_t, slott, k, feedstock, t_el)                                  \
    sum(para_lk, z_emission(time_t, slott, k, feedstock, t_el, para_lk))       \
    $(max_ratio(k, feedstock, t_el)>0)

$macro   q_s(sim, time_t, slott, k, feedstock, t_el)                           \
    sum(para_lk, z_emission_l(sim, time_t, slott, k, feedstock, t_el, para_lk))\
    $(max_ratio(k, feedstock, t_el)>0)

********************************************************************************
*                                                                              *
* Efficiencies                                                                 *
*                                                                              *
********************************************************************************

* The efficiency of a boiler can depend on the calorific value of entering
* feedstock.

$macro boiler_eff(t_el, k, feedstock)                                          \
                1-(8.4 - kyttevaartus(feedstock, k) * 3.6) * kv_kt(t_el)

* Amount of heat exiting a boiler
$macro q_out(time_t, slot, t_el)                                               \
          sum((k, feedstock)$(max_ratio(k, feedstock, t_el) > 0),              \
               q(time_t, slot, k, feedstock, t_el))

* Amount of heat entering a turbine
$macro q_in(time_t, slott, t_el)                                               \
            lambda_p(time_t, slott, t_el)                                      \
         * (eff_lookup(t_el, "4", "b"))

* Net power load of a turbine (ie output power)
$macro net_load_el(time_t, slot, t_el)                                         \
            lambda_p(time_t, slot, t_el)                                       \
         * (eff_lookup(t_el, "4", "a"))                                        \
          - k_alpha(time_t, t_el) * turbine_loss(t_el)

********************************************************************************
**                                                                             *
** SPECIFIC EMISSIONS                                                          *
**                                                                             *
********************************************************************************

* CO2 specific emission
$macro    em_level_co2(time_t, slot, k, feedstock, t_el)                       \
             (q(time_t, slot, k, feedstock, t_el)                              \
                $(max_ratio(k, feedstock, t_el) > 0)                           \
             * 3.6 / 1000 * em_co2(feedstock)                                  \
*             * (1 + k_moju(k, feedstock, "co") * kil_tase(k_tase)))           \
             * 0.999                                                           \
             * 44.01                                                           \
              / 12 )

$macro    em_level_co2_s(sim, time_t, slot, k, feedstock, t_el)                \
             (q_s(sim, time_t, slot, k, feedstock, t_el)                       \
                $(max_ratio(k, feedstock, t_el) > 0)                           \
             * 3.6 / 1000 * em_co2(feedstock)                                  \
*             * (1 + k_moju(k, feedstock, "co") * kil_tase(k_tase)))           \
             * 0.999                                                           \
             * 44.01                                                           \
              / 12 )

* Remaining specific emissions (t/h)
$macro  em_level_el(time_t, slott, em, k, feedstock, t_el)                     \
   (sum(para_lk,                                                               \
                 t_sg_m3                                                       \
               * hh_coef(em, t_el, k, feedstock, para_lk)                      \
               * z_emission(time_t, slott, k, feedstock, t_el, para_lk)        \
             )$(sameas(em, "so") or sameas(em, "no"))                          \
    +                                                                          \
             (                                                                 \
                q(time_t, slott, k, feedstock, t_el)                           \
                  $(max_ratio(k, feedstock, t_el) > 0)                         \
                * sum(para_lk$(ord(para_lk) = card(para_lk)),                  \
                       em_coef(em, t_el, k, feedstock, para_lk, "0"))          \
             )$(not sameas(em, "so") and not sameas(em, "no"))                 \
        ) * (1 - uncertainty(em))

$macro  em_level_el_s(sim, time_t, slott, em, k, feedstock, t_el)              \
   (sum(para_lk,                                                               \
                 t_sg_m3                                                       \
               * hh_coef(em, t_el, k, feedstock, para_lk)                      \
               * z_emission_l(sim, time_t, slott, k, feedstock, t_el, para_lk) \
             )$(sameas(em, "so") or sameas(em, "no"))                          \
    +                                                                          \
             (                                                                 \
                q_s(sim, time_t, slott, k, feedstock, t_el)                    \
                  $(max_ratio(k, feedstock, t_el) > 0)                         \
                * sum(para_lk$(ord(para_lk) = card(para_lk)),                  \
                       em_coef(em, t_el, k, feedstock, para_lk, "0"))          \
             )$(not sameas(em, "so") and not sameas(em, "no"))                 \
        ) * (1 - uncertainty(em))

$macro em_level_cw(time_t, slott,  t_el)                                       \
             sum(para_lk$(ord(para_lk) = card(para_lk)),                       \
              em_coefficients("jv", t_el, "Estonia", "Energeetiline", para_lk))\
            * load_el(time_t, slot, t_el)

$macro em_level_cw_s(sim, time_t, slott,  t_el)                                \
             sum(para_lk$(ord(para_lk) = card(para_lk)),                       \
              em_coefficients("jv", t_el, "Estonia", "Energeetiline", para_lk))\
            * load_el_l(sim, time_t, slot, t_el)

********************************************************************************
*                                                                              *
* TOTAL CO2 USAGE IN TONS IN TIME UNIT, INCLUDE BOTH SPOT MARKET CO2           *
* AND PRESENT CERTIFICATES                                                     *
*                                                                              *
********************************************************************************

$macro co2_usage(time_t) (co2_spot_market(time_t)                              \
                       + sum(serial2, co2_cert_usage(serial2, time_t)))

$macro co2_usage_s(sim, time_t) (co2_spot_market_l(sim, time_t)                \
                       + sum(serial2, co2_cert_usage_l(sim, serial2, time_t)))

********************************************************************************
*                                                                              *
* ÕLITEHASTE SAAGISE SÕLTUVUS KÜTTEVÄÄRTUSEST, SAAGIS ON ANTUD 8.2 MJ/KG KOHTA *
* Andrejevi valemite järgi.                                                    *
*                                                                              *
********************************************************************************

$macro adj_yield_oil(t_ol, year, k, feedstock)   (yield_oil(t_ol, year)        \
   / (1-cv(feedstock, k, "MWh") / st_oil_cv + 1 ))

