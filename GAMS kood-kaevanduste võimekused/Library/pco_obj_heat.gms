********************************************************************************
**                                                                             *
** Objective function. Heat production revenue and heat production variable    *
** cost. True costs (ie. emissions and fuel) is covered under                  *
** pco_obj_emissions and pco_obj_mining                                        *
**                                                                             *
** Macros used: y_m_t - tuple connecting model time with cal month and year    *
**                                                                             *
**  31. Oct 2014                                                               *
**  Peeter Meos                                                                *
********************************************************************************

  +

  sum((year, month, slot, t_ht) $y_m_t,
         load_ht(time_t, slot, t_ht)
       * slot_length(time_t, slot, t_ht)
       * heat_price(year, month)
      )
  -
  sum((year, month, slot, t_el) $y_m_t,
         load_ht(time_t, slot, t_el)
       * slot_length(time_t, slot, t_el)
       * ht_other_vc(t_el, year)
     )



