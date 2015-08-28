********************************************************************************
**                                                                             *
** This file defines the parameters for emissions calculations.                *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

Scalars
 t_sg_m3      "Smoke gas coefficient (m3/MWh fuel)"      /1.3608/
;

Sets
  em          "Emission types"       /co, so, no, lt, jv, th, at/
  em_ol       "Oil emissions"
  t_jv(t)     "Production units that have cooling water constraint"
;

Parameter
  em_co2(feedstock)          "Specific emission of CO2"
  k_effect(k, feedstock, em) "Effect of crushed limestone on emissions"
/
Estonia.Energeetiline.so         0.02468
Estonia.Madal.so                 0.03062
Estonia.Kaevis.so                0.03062
Narva1.Energeetiline.so          0.03441
Narva1.Madal.so                  0.03441
Narva1.Kaevis.so                 0.03441
Narva2.Labindus.so               0.03441
Narva2.Kaevis.so                 0.03441
Viivikonna.Energeetiline.so      0.03441
Viivikonna.Madal.so              0.03441
Viivikonna.Kaevis.so             0.03441
KKT.Energeetiline.so             0.03441
Slantso.Energeetiline.so         0.03441
/
;

$loaddc em_ol=eh_ol em_co2=eh_co2
$loaddc t_jv

k_effect(k, feedstock, "co") = 0.01;

Set
    l_level       "Lime levels t(lime)/h"
         /0
$ifthen.two "%l_k_invoked%" == "true"
         , 1
$endif.two
/

    k_level       "Crushed limestone levels t(stone)/h"
         /0
$ifthen.two "%l_k_invoked%" == "true"
       ,20
$endif.two
         /
;

Parameters
    lime_level(l_level)
    /
0        0
$ifthen.two "%l_k_invoked%" == "true"
1        1
$endif.two
    /

    cl_level(k_level)
    /
0        0
$ifthen.two "%l_k_invoked%" == "true"
20       20
$endif.two
    /

;

Parameter
   uncertainty(em)                  "Measurement uncertainty for emissions"
   em_tariff(em, year)               "Emission tariffs from corp. accounting (EUR/t)"
   em_tariff_ol(t_ol, em_ol, year)   "Oil emission tariffs from corp. accounting (EUR/t)"
   em_quota(year, em)                "Emissions quota (t/year)"
   em_coefficients(em, t_el, k, feedstock, para_lk) "Specific emission regression coefs (t)"
   em_coefficients_ol(em_ol, t_ol)   "Oil specific emission coefs. Unit is t(emission)/t(feedstock)"
   hour_limit(t_stack)               "Limit of total number of operational hours (hours)"
   lime_price(year)                  "Lime price in year (EUR/t)"

* Specific emissions are given in secondary energy - for convenience's sake (a'la Molodtsov table)
   em_fa(k, feedstock, t_el)  "Specific emission of fly ash for power production units (kg/GWh el)"
   em_ba(k, feedstock, t_el)  "Specific emission of bottom ash for power production units  (kg/GWh el)"
   em_cw(k, feedstock, t_el)  "Specific emission of cooling water for power production units (m3/GWh el)"
   spent_sox(year)            "Already spent SOx quota (t) (needed mostly for the fist year)"
;
$load   uncertainty

$loaddc em_fa=eh_lt em_ba=eh_th em_cw=eh_jv lime_price=lubja_hind
$loaddc em_tariff=eh_tariif em_tariff_ol=eh_tariif_ol em_quota=eh_kvoot
$loaddc em_coefficients_ol=eh_koefitsendid_ol hour_limit=korstna_tundide_piirang spent_sox=kulutatud_sox

* Fly ash ash is given for t/MWh fuel, thus no need for conversion
em_coefficients("lt", t_el, k, feedstock, para_lk) = em_fa(k, feedstock, t_el);

* Bottom ash is given for t/MWh fuel, thus no need for conversion
em_coefficients("th", t_el, k, feedstock, para_lk) = em_ba(k, feedstock, t_el);

* Cooling water is given for m3/MWh power, thus no need for conversion
em_coefficients("jv", t_el, k, feedstock, para_lk) = em_cw(k, feedstock, t_el);

Parameter
  em_coef(em, t_el, k, feedstock, para_lk, k_level) "Recalculated emissions coefficients"
  retort_gas_coef(em)                               "Emissions coefficient for retort gas"
* Cooling water usage requirement for production units
  cw_usage(t, month)                                "Cooling water usage requirement for production units"
;

* Retort gas increases only SOx emissions by 22%
retort_gas_coef(em)   = 1;
retort_gas_coef("so") = 1.22;

em_coef(em, t_el, k, feedstock, para_lk, k_level)
   = em_coefficients(em, t_el, k, feedstock, para_lk);

$loaddc cw_usage=jahutusvee_kasutus

********************************************************************************
**                                                                             *
** Instataneous emission calculations                                          *
**                                                                             *
**  Peeter Meos                                                                *
********************************************************************************
Parameter
  hh_so(k, feedstock, para_lk, t_el)         "Concentration levels of SOx (mg/m3)"
  hh_no(k, feedstock, para_lk, t_el)         "Concentration levels of SOx (mg/m3)"
  hh_coef(em, t_el, k, feedstock, para_lk)   "Aggregated and converted concentrations (t/m3)"
  hh_q(t_el, para_lk)                        "Concentrations per entering feedstock (t/m3/MWh)"
  hh_limit(em, year, t_el)                   "Concentration limits for each year"
;

$loaddc hh_so hh_no
*$loaddc hh_limit

hh_coef("so", t_el, k, feedstock, para_lk) = hh_so(k, feedstock, para_lk, t_el) / (1000 * 1000 );
hh_coef("no", t_el, k, feedstock, para_lk) = hh_no(k, feedstock, para_lk, t_el) / (1000 * 1000 );

* Levels for instataneous emissions are 0, 40, 120, 145 (at MW net power)
hh_q(t_el, "1") = 0;
hh_q(t_el, "2") = eff_lookup(t_el, "3", "b") / eff_lookup(t_el, "3", "a")   * 40;
hh_q(t_el, "3") = (eff_lookup(t_el, "4", "b") + eff_lookup(t_el, "3", "b"))
                / (eff_lookup(t_el, "4", "a") + eff_lookup(t_el, "3", "a")) * 120;
hh_q(t_el, "4") = eff_lookup(t_el, "4", "b") / eff_lookup(t_el, "4", "a")   * efficiency(t_el, "4", "a");

* Since we don't have these yet, for sake of development and testing
* we are hardcoding 400 mg/m3 for SOx and NOx for years 2016 onwards

hh_limit(em, year, t_el) = 0;
*hh_limit("so", year, t_el)$(ord(year) > 3) = 400 / (1000 * 1000);
*hh_limit("no", year, t_el)$(ord(year) > 3) = 400 / (1000 * 1000);
