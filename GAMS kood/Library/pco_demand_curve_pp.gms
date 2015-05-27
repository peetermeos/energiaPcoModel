      t_feedstock.l(sim, year, month, t)$(sum(time_t, 1$y_m_t) > 0)
                                 = sum((s_t, time_t)$y_m_t,
                          storage_to_production_l(sim, time_t, s_t, t, "%n_source%", "%nk%")
                          * cv("%nk%", "%n_source%", "MWh"))
                          +
                          sum((time_t, route, l)$(y_m_t and route_endpoint(route, "%n_source%", l) and t_dp_prod(l, t)),
                          logs_to_production_l(sim, time_t, route, t, "%nk%")
                          * cv("%nk%", "%n_source%", "MWh"))
                          +
                          sum((t_el, time_t, slot)$(y_m_t and sameas(t, t_el)), q_s(sim, time_t, slot, "Hange", "Uttegaas", t_el))
;


      t_run.l(sim, year, month, "price")$(sum(time_t, 1$y_m_t) > 0) = h_run(sim);
      t_run.l(sim, year, month, "acq") = sum(t, t_feedstock.l(sim, year, month, t));

      t_run_total.l(sim, year, "price") = smax(month, t_run.l(sim, year, month, "price"));
      t_run_total.l(sim, year, "acq") = sum(month, t_run.l(sim, year, month, "acq"));


t_production.l(sim, year, month, t, product)
=
 sum((time_t, slot)$y_m_t,
 sum(t_el$sameas(t_el, t), load_el_l(sim, time_t, slot, t_el) * slot_length_s(sim, time_t, slot, t))$sameas(product, "Elekter")
 +
 sum(t_el$(sameas(t_el, t)),
         load_ht_l(sim, time_t, slot, t_el)$(sameas(product, "Soojus") and t_ht(t_el))
 +
         load_ht_l(sim, time_t, slot, t_el)$(sameas(product, "SisemineSoojus") and not t_ht(t_el))
 ) * slot_length_s(sim, time_t, slot, t)
 +
 (
 sum(t_ol$sameas(t_ol, t), oil_l(sim, time_t, t_ol))
         * slot_length_s(sim, time_t, slot, t)
         / (1$(slot_length_s(sim, time_t, slot, t) = 0)
            + sum(slott2$(slot_length_s(sim, time_t, slott2, t) > 0), slot_length_s(sim, time_t, slott2, t)))
 )$sameas(product, "oil")
 )
;
