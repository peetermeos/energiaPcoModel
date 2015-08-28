********************************************************************************
**                                                                             *
** Definition of hedging part of the objective function. Note that we are      *
** keeping hedging strategy deterministic, ie. same for all realisations of    *
** market and production conditions.                                           *
**                                                                             *
**  27. Oct 2014                                                               *
**  Peeter Meos                                                                *
********************************************************************************

+

sum((serial, fwd_type, year, month),
   el_fwd_position(serial, fwd_type, year, month)
 * el_fwd_price(serial, fwd_type, year, month)
)
