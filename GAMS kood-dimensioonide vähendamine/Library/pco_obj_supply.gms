********************************************************************************
**                                                                             *
** Objective function elements for fuel supply costs.                          *
** This does not include logistics such as rail or dump truck transport        *
** between mines and production units.                                         *
**                                                                             *
** Macros used: to_production                                                  *
**                                                                             *
**  Peeter Meos                                                                *
********************************************************************************

  -
sum((year, month, t, k, feedstock)$(y_m_t and max_ratio(k, feedstock, t) > 1),
    to_production(time_t, k, feedstock, t)
  * t_supply_vc(t, year)
    )

* Optional grinding costs
  -
sum((year, month, t, k, feedstock)$(y_m_t and max_ratio(k, feedstock, t) > 1),
    to_production(time_t, k, feedstock, t)
  * t_supply_gr_vc(k, feedstock, t, year)
    )



