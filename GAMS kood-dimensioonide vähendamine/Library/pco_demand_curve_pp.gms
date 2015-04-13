      t_feedstock.l(sim, year, month, t)$(sum(time_t, 1$y_m_t) > 0)
                                 = sum((s_t, time_t)$y_m_t,
                          storage_to_production_l(sim, time_t, s_t, t, "%n_source%", "%nk%")
                          * cv("%nk%", "%n_source%", "MWh"))
                          +
                          sum((time_t, route, l)$(y_m_t and route_endpoint(route, "%n_source%", l) and t_dp_prod(l, t)),
                          logs_to_production_l(sim, time_t, route, t, "%nk%")
                          * cv("%nk%", "%n_source%", "MWh"))
;


      t_run.l(sim, year, month, "price")$(sum(time_t, 1$y_m_t) > 0) = h_run(sim);
      t_run.l(sim, year, month, "acq") = sum(t, t_feedstock.l(sim, year, month, t));

      t_run_total.l(sim, year, "price") = t_run.l(sim, year, "1", "price");
      t_run_total.l(sim, year, "acq") = sum(month, t_run.l(sim, year, month, "acq"));


