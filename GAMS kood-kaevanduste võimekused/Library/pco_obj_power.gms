********************************************************************************
**                                                                             *
** Power sales to spot market and other variable costs related to power        *
** production. Sales of forward contracts is covered in file                   *
** pco_obj_hedge                                                               *
**                                                                             *
** Macros used: y_m_t - connecting tuple between model time units and calendar *
** days and months                                                             *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

 sum(slot,
    el_spot_position(time_t, slot)
    * el_price_slot(time_t, slot)
 )

* Other variable costs
* Taaniel Uleksin
   -
  sum((slot, t_el),
   slot_length(time_t, slot, t_el)
   * sum((year, month)$y_m_t, el_other_vc(t_el, year))

* In order to cover minimum marginal required, we are substracting it.
* ie. treating as another component of variable costs.

$ifthen.marg "%m_marg%" == "true"
   - min_marginal(t_el)
$endif.marg

)



