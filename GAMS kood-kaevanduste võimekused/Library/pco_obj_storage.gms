********************************************************************************
**                                                                             *
** This part of the objective function storage costs                           *
** The tuples and dollar conditions are here quite confusing, see pco_logistics*
** for explanation.                                                            *
**                                                                             *
** Macros used: y_m_t - tuple connecting calendar time to model time           *
**                                                                             *
********************************************************************************

* Storage costs at mines
$ifthen.two "%mine_storage%" == "true"
   -
sum((year, month, k, s_k, feedstock)$(
     y_m_t and mine_storage(k, s_k) and fs_k(k, feedstock)
     ),
     storage_vc(s_k) * mine_to_storage(time_t, s_k, k, feedstock))
   -
sum((year, month, s_k, route, k, feedstock)$(
         y_m_t
     and k_dp_storage(route, s_k)
     and mine_storage(k, s_k) and fs_k(k, feedstock)
     ),
     storage_vc(s_k) * storage_to_logs(time_t, s_k, route, feedstock))

$endif.two

* Storage costs at production units
$ifthen.two "%prod_storage%" == "true"
-
sum((year, month, route, s_t, l, k, feedstock)$(
         y_m_t
     and route_endpoint(route, k, l)
     and fs_k(k, feedstock) and t_dp_storage(l, s_t)
     ),
     storage_vc(s_t) * logs_to_storage(time_t, route, s_t, feedstock))
   -
sum((year, month, s_t, t, k, feedstock)$(
     y_m_t and fs_k(k, feedstock) and prod_storage(s_t, t)
     ),
     storage_vc(s_t) * storage_to_production(time_t, s_t, t, k, feedstock))
$endif.two



