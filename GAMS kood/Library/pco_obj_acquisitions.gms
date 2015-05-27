********************************************************************************
**                                                                             *
** This file implements the piece of objective function involving              *
** supply external feedstock sources. The reason for this separation is        *
** stochasticity, we are considering internal acquisition non-stochastic       *
** and external stochastic.                                                    *
**                                                                             *
** Note: Supply contracts are covered in different file: pco_obj_contracts     *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

  -

sum((year, month, feedstock)$(y_m_t and fs_k("Hange", feedstock)),
     fs_acqd(time_t, feedstock) * fs_vc("Hange", feedstock, year))

