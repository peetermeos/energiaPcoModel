********************************************************************************
**                                                                             *
** This file implements the piece of objective function involving              *
** variable costs of acquiring feedstock from supply contracts                 *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************
   -
  sum((serial, k, feedstock),
    fs_purchase(serial, time_t, k, feedstock)
    * sum((year, month)$y_m_t, contract(serial, year, month, k, feedstock, "hind"))
    * cv(feedstock, k, "MWh")
  )



