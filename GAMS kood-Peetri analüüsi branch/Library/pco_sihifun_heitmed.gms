
-
sum((aasta, kuu, slott, t_el) $tee_paevaks,

* Eriheitmete kulud
        sum(eh$(not sameas(eh, "jv")), sum((primaarenergia, k)$(max_osakaal(k, primaarenergia, t_el) > 0),
                        eh_tase_el(opt_paev, slott, eh, k, primaarenergia, t_el) *
                        sloti_pikkus(opt_paev, slott, t_el)) *
                        eh_tariif(eh, aasta)
           )
)


* Lubja mõju
* Eeldame, et lupja kulub 2.5 kg per toodetud elektri MWh
-
  sum((t_lubi, slott), koorm_el(opt_paev, slott, t_lubi) * sloti_pikkus(opt_paev, slott, t_lubi)
       * lime_consumption(t_lubi)
       * sum((aasta, kuu)$tee_paevaks, lubja_hind(aasta)/1000))

-
sum((aasta, kuu, slott, t_el) $tee_paevaks,
* CO2 ostmine turult
        sum((primaarenergia, k)$(max_osakaal(k, primaarenergia, t_el) > 0),
            eh_tase_co2(opt_paev, slott, k, primaarenergia, t_el) *
            sloti_pikkus(opt_paev, slott, t_el) * co2_referents(aasta))
)


