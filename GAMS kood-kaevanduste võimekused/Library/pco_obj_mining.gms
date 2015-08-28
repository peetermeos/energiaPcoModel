********************************************************************************
**                                                                             *
** This file implements the piece of objective function involving              *
** variable costs of mining from internal sources.                             *
**                                                                             *
** Note: Supply contracts are covered in different file: pco_obj_contracts     *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

  -

sum((year, month, feedstock, k)$(y_m_t
*                             and fs_k(k, feedstock)
*                             and not sameas(k, "Hange")
                                 ),
     sum(p2$(enrichment_coef(p2, k, feedstock) > 0) ,
      fs_mined(time_t, p2, feedstock, k)
    * enrichment_coef(p2, k, feedstock))
    * fs_vc(k, feedstock, year)
    )

