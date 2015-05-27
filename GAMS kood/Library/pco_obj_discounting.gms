********************************************************************************
**                                                                             *
** Discounting element for the objective function. The idea is to bring        *
** future revenue and costs into present value figures.                        *
**                                                                             *
**  31. Oct 2014                                                               *
**  Peeter Meos                                                                *
********************************************************************************

    / prod((time_t2, year, month)$(y_m_t and date_cal(time_t2, year, month)
                                    and ord(time_t2) le ord(time_t)),
           (1 + wacc(year) / disc_periods))
