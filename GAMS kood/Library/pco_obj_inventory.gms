********************************************************************************
**                                                                             *
** Objective function component for value of final inventory at storage sites  *
** We assume general value of 4 EUR/MWh                                        *
**                                                                             *
**  Peeter Meos                                                                *
********************************************************************************

$ifthen.two "%mine_storage%" == "true"
  +
  sum((time_t, s_k, k, feedstock)$
      (ord(time_t) = card(time_t)),
                           last_day_storage(s_k, k, feedstock) *
                           cv(feedstock, k, "MWh") *
                           4)
$endif.two


$ifthen.two "%prod_storage%" == "true"
  +
  sum((time_t, s_t, k, feedstock)$
      (ord(time_t) = card(time_t)),
                           last_day_storage(s_t, k, feedstock) *
                           cv(feedstock, k, "MWh") *
                           4)
$endif.two
