********************************************************************************
**                                                                             *
** Generic constants and data structures for the model                         *
**                                                                             *
**  31. Oct 2014                                                               *
**  Peeter Meos                                                                *
********************************************************************************

Scalars
  first_year    "First year of the model"                             /2013/
  first_month   "First month of the model"                            /1/
  M             "Very big number"                                     /100000/
*  uncertainty   "Measurement uncertainty for emissions"               /1/
  epsilon       "Very small number"                                   /0.0000001/
  st_oil_cv     "Standardised shale oil calorific value (MWh/t)"      /2.2777778/
  efficiency_shift "Efficiency shift for non-linear approximation"    /0.01/

;

Set
  unit    "Set of units used"
                 /
                  t     "Ton"
                  MWh   "MWh feedstock"
                  MJ    "MJ feedstock"
                  Toode "MWh of electricity, heat või t oil"
                  m3    "m3 of gas"
                  EUR   "EUR"
                 /

  serial         "Serial number in a set"   /1*100/
;

Parameter clean_span;
clean_span = 7;

Parameter fix_switch;
fix_switch=0;

