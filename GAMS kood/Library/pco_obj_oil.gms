********************************************************************************
**                                                                             *
** This part of the objective function manages oil revenue and                 *
** oil-related costs (emissions and other variable costs)                      *
**                                                                             *
**  Peeter Meos                                                                *
********************************************************************************

    +
* Oil production
   sum((year, month, t_ol) $y_m_t,
       oil(time_t, t_ol) *
       oil_price(year, month)
       )

-
* Oil environmental tariffs and polliution costs
* All feedstock entering production unit * specific emission * tariff

   sum((year, month, em_ol, t_ol, k, feedstock)$y_m_t,
       to_production(time_t, k, feedstock, t_ol)
     * em_coefficients_ol(em_ol, t_ol)
     * em_tariff_ol(t_ol, em_ol, year)
      )


* Other variable costs
-
sum((year, month, t_ol)$y_m_t,
    oil_other_vc(t_ol, year)
  * oil(time_t, t_ol))



