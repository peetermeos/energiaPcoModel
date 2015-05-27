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
    sum((year, month)$y_m_t,
      fs_mined(time_t, "%nk%", "%nk%", "%n_source%")
    * fs_vc("%n_source%", "%nk%", year)
       )

