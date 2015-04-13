********************************************************************************
**                                                                             *
** Unit startup costs for the electricity production unit                      *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

-
sum((slot,t_el), t_startup(time_t, t_el) * startup_vc(t_el))
