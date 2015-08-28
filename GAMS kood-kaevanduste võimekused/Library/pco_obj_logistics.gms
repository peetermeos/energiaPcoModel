********************************************************************************
**                                                                             *
** This part of the objective function handles logistics related variable      *
** costs. Note, that supply costs at production units and at storage are       *
** handled separately.                                                         *
**                                                                             *
** Macros used: y_m_t - tuple connecting calendar time to model time           *
**                                                                             *
********************************************************************************

-
sum((year, month, route, feedstock, k,l)$(
         y_m_t
     and route_endpoint(route, k, l)
     and fs_k(k, feedstock)
     ),
     log_vc(route, year) *
     mine_to_logs(time_t, route, feedstock))

$ifthen.two "%mine_storage%" == "true"
   -
sum((year, month, route, feedstock, s_k, k)$(
         y_m_t
     and k_dp_storage(route, s_k)
     and mine_storage(k, s_k)
     and fs_k(k, feedstock)
     ),
     log_vc(route, year) *
     storage_to_logs(time_t, s_k, route, feedstock)
     )
$endif.two




