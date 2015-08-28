********************************************************************************
**                                                                             *
** This file implements the piece of objective function involving              *
** profit from sales of processed oil shale                                    *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

   +
   sum((year, month, k, feedstock, t_mk)$
       (y_m_t and (max_ratio(k, feedstock, t_mk) > 0)),
       sales(time_t, k, feedstock, t_mk) * concentrate_price(year)
       )
