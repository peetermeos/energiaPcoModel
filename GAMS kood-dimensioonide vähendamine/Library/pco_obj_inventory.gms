********************************************************************************
**                                                                             *
** Objective function component for value of final inventory at storage sites  *
** We assume general value of 4 EUR/MWh                                        *
**                                                                             *
**  Peeter Meos                                                                *
********************************************************************************

$ifthen.two "%mine_storage%" == "true"
  +
  sum((time_t, l_k, feedstock)$
      (ord(time_t) = card(time_t)),
                           storage_k(time_t, l_k, feedstock) *
                           cv(feedstock, k, "MWh") *
                           4)
$endif.two


$ifthen.two "%prod_storage%" == "true"
  +
  sum((time_t, k, s_t, feedstock)$
      (ord(time_t) = card(time_t)),
                           laoseis_t(time_t, s_t, k, feedstock) *
                           cv(feedstock, k, "MWh") *
                           4)
$endif.two
