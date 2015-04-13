logs_to_production.fx(time_t, route, t, feedstock) = 0;
storage_to_production.fx(time_t, s_t, t, k, feedstock) = 0;
storage_to_production.up(time_t, s_t, t, "%n_source%", "%nk%") = +INF;
storage_to_production.fx(time_t, s_t, t_ol, "%n_source%", "%nk%")$(sameas(t_ol, "ENE2") or sameas(t_ol, "ENE3")) = 0;

* Still allow retort gas and natural gas
max_ratio(k, feedstock, t)$(not sameas(feedstock, "Uttegaas")) = 0;
max_ratio("%n_source%", "%nk%", t) = 1;
permitted_use(year, month, t, k, feedstock) = 0;

cv_min(t, year, month)$(not sameas(t, "Katlamaja")) = cv("%nk%", "%n_source%", "MWh");

* Adjust concentrate sales.
sale_contract(t_mk, "Estonia", "Tykikivi", year, month)
     = sale_contract(t_mk, "Estonia", "Tykikivi", year, month)
       * cv("Tykikivi", "Estonia", "MWh") / cv("%nk%", "%n_source%", "MWh");

concentrate_price(year) =  concentrate_price(year) / cv("Tykikivi", "Estonia", "MWh") * cv("%nk%", "%n_source%", "MWh");

********************************************************************************
** This ugliness cuts down solution space for piecewise linear emission        *
** approximation. We are trying to filter out already infeasible combinations  *
********************************************************************************
lambda_e.up(time_t, slot, t_el, k, feedstock, k_level, l_level, para_lk) = +INF;
lambda_e.lo(time_t, slot, t_el, k, feedstock, k_level, l_level, para_lk) = 0;
z_emission.up(time_t, slot, k, feedstock, t_el, para_lk) = +INF;
z_emission.lo(time_t, slot, k, feedstock, t_el, para_lk) = 0;

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

z_emission.fx(time_t, slot, k, feedstock, t_el, para_lk)
                                      $(time_t_s(time_t)
                             and fs_k(k, feedstock)
                             and max_ratio(k, feedstock, t_el) eq 0) = 0;
