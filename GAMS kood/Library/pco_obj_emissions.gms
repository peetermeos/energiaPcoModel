********************************************************************************
**                                                                             *
** Definition of emissions portion of the objective function.                  *
** it also includes CO2 certificates (both already present and CO2 spot market)*
**                                                                             *
**  Peeter Meos                                                                *
********************************************************************************

-
sum((year, month, slot, t_el)$y_m_t,

* Emission costs
        sum(em$(not sameas(em, "jv")), sum((feedstock, k)$(max_ratio(k, feedstock, t_el) > 0),
                        em_level_el(time_t, slot, em, k, feedstock, t_el) *
                        slot_length(time_t, slot, t_el)) *
                        em_tariff(em, year)
           )
)


* Use of lime
-
  sum((t_lime, slot),
         load_el(time_t, slot, t_lime)
       * slot_length(time_t, slot, t_lime)
       * lime_consumption(t_lime)
       * sum((year, month)$y_m_t, lime_price(year) / 1000)
      )

* CO2 from spot market and fwd market
- sum(serial$(sum(year, co2_certs(serial, year, "kogus")) > 0),
               co2_cert_usage(serial, time_t)
             * sum(year, co2_certs(serial, year, "hind")))

- co2_spot_market(time_t) * sum((year, month)$y_m_t, co2_price(year))

* Cooling water
-
sum((year, month, slot, t_el)$y_m_t,
   em_level_cw(time_t, slot, t_el)
    * slot_length(time_t, slot, t_el)
    * em_tariff("jv", year)
   )
