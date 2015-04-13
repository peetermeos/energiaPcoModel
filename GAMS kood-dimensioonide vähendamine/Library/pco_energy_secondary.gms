********************************************************************************
**                                                                             *
** Everything related to secondary energy, ie. the stuff that we actually sell *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

Parameter
  elektri_referents(year, month, day, time_hour)    "Electricity reference price (EUR/MWh)"
  co2_reference(year)                               "CO2 reference price (EUR/t)"
  oil_reference(year, month)                        "Shale oil reference price (EUR/t)"
* ys_elekter(year, month)                           "Ühtsete stsenaariumite elektri kuised hinnatasemed EUR/MWh)"
* ys_co2(year)                                      "Ühtsete stsenaariumite CO2 kuised hinnatasemed EUR/MWh)"
* ys_oli(year)                                      "Ühtsete stsenaariumite õli kuised hinnatasemed EUR/MWh)"
  heat_reference(year, month)                       "Heat reference price (EUR/MWh)"
  sale_contract(t_mk, k, feedstock, year, month)    "Sales requirement for processed shale (t/month)"
  heat_delivery(year, month)                        "Heat delivery in month (MWh/month)"
  internal_heat_delivery(year, month)               "Internal heat delivery in month (MWh/month)"
  min_marginal(t_el)                                "Minimum sales margin (EUR/MWh el)"
  reserved_fuel(year, month, k, feedstock, l)       "Fuel not used in production but reserved for other uses (t/month)"
;


$loaddc elektri_referents
*ys_elekter
$loaddc co2_reference=co2_referents oil_reference=oli_referents
$loaddc heat_reference=soojuse_referents sale_contract=myygileping heat_delivery=soojatarne internal_heat_delivery=sisemine_soojatarne
$loaddc min_marginal=min_marginaal
$loaddc reserved_fuel

* These parameters are simply an expansion of the prices above to cover all iterations
* This later allows us to calculate different realisation paths for stochastics.

Parameter
  el_price_slot_s(sim, time_t, slot)                        "Electricity reference price in slot (EUR/MWh)"
  co2_price_s(sim, year)                                    "CO2 referentshind (EUR/t)"
  oil_price_s(sim, year, month)                             "Põlevkiviõli referentshind (EUR/t)"
  heat_price_s(sim, year, month)                            "Soojuse referentshind (EUR/MWh)"
  sale_contract_s(sim, t_mk, k, feedstock, year, month)     "Sales requirement for processed shale (t/month)"

  el_price_slot(time_t, slot)                        "Electricity reference price in slot (EUR/MWh)"
  co2_price(year)                                    "CO2 referentshind (EUR/t)"
  oil_price(year, month)                             "Põlevkiviõli referentshind (EUR/t)"
  heat_price(year, month)                            "Soojuse referentshind (EUR/MWh)"
;

************************************************************************************************************************
* Elektri hind tuleb kokku panna komponentidest:                                                                       *
* 1) Juhul kui olemas on hinnakõver, siis kasutada seda                                                                *
* 2) Kui on olemas ÜS hinnad, siis kasutada neid ja keskmist vastava month hinnakõverat                                  *
************************************************************************************************************************

$ifthen.ys "%ys%" == "true"
$libinclude pco_energy_gen_scenario
$endif.ys

************************************************************************
* Oil, CO2 and heat reference prices for all simations of the model   *
* If needed, we will be adding stochasticity later                     *
************************************************************************

oil_price_s(sim, year, month)$(sum(time_t$y_m_t, 1) > 0)  = oil_reference(year, month);
co2_price_s(sim, year)$(sum((month, time_t)$y_m_t, 1) > 0)= co2_reference(year);
heat_price_s(sim, year, month)$(sum(time_t$y_m_t, 1) > 0) = heat_reference(year, month);
sale_contract(t_mk, k, feedstock, year, month) = sale_contract(t_mk, k, feedstock, year, month);  

el_price_slot_s(sim, time_t, slot) =
sum((year, month, day, weekday, time_hour)
                                      $(y_m_t
                                    and days
                                    and gdow(jdate(%year_1% + ord(year) - 1, ord(month), ord(day))) = ord(weekday)
                                    and slot_hours(slot, weekday, time_hour)
                                      ),  elektri_referents(year, month, day, time_hour)
)
/
sum((year, month, day, weekday, time_hour)
                                      $(y_m_t
                                    and days
                                    and gdow(jdate(%year_1% + ord(year) - 1, ord(month), ord(day))) = ord(weekday)
                                    and slot_hours(slot, weekday, time_hour)
                                    and elektri_referents(year, month, day, time_hour) > 0
                                      ),  1
)
;

el_price_slot(time_t, slot) = el_price_slot_s("1", time_t, slot);
co2_price(year)             = co2_price_s("1", year);
oil_price(year, month)      = oil_price_s("1", year, month);
heat_price(year, month)     = heat_price_s("1", year, month);





