********************************************************************************
**                                                                             *
** Definitions of sets and parameters for hedging structures.                  *
**                                                                             *
**  27. Oct 2014                                                               *
**  Peeter Meos                                                                *
********************************************************************************

Set
  fwd_type "Delivery period for electricty forward"
  /
   year
   quarter
   month
  /
;

Parameter
   co2_certs(serial, year, contract_para)      "CO2 allowance amounts and prices for each year"
   el_fwd_price(serial, fwd_type, year, month) "Electricity forward delivery period, delivery date and price"
;
*$loaddc co2_certs el_fwd_price
*el_fwd_price(serial, fwd_type, year, month)$(el_fwd_price(serial, fwd_type, year, month) > 0)
*                      = el_fwd_price(serial, fwd_type, year, month)
*                        + 10;

el_fwd_price(serial, fwd_type, year, month)$(not sameas(fwd_type, "year")) = 0;
co2_certs(serial, year, contract_para) = 0;




