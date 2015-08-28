********************************************************************************
**                                                                             *
**  See tükk koodi teeb avariilisuste ja hindade stohhastikat                  *
**  14. mai 2014                                                               *
**                                                                             *
**  Peeter Meos                                                                *
********************************************************************************

Set ajal_aasta, ajal_paev, av_para;
$load ajal_aasta ajal_paev av_para

Parameter  ajal_elekter(ajal_aasta, kuu, ajal_paev, time_hour);
Parameter  av_tabel(t_el, av_para)  "MTBF ja MTTR ajad plokkidele tundides";

$load ajal_elekter av_tabel

Parameter keskmine_ref(aasta), keskmine_ajal(ajal_aasta);

Parameter
  temp_aasta(kuu, ajal_paev, time_hour)
  co(aasta, kuu)
  av(sim, cal_time, t_el)
;

Scalar random_aasta, keskmine;

execseed = 1 + gmillisec(jnow);

keskmine_ref(aasta) = sum((kuu, paev, time_hour), elektri_referents(aasta, kuu, paev, time_hour))
                    / (sum((kuu, paev, time_hour)$(elektri_referents(aasta, kuu, paev, time_hour) > 0), 1)+1);

loop((sim, aasta),
    random_aasta = round(uniform(1, card(ajal_aasta)));

    keskmine  = sum(ajal_aasta$(ord(ajal_aasta) = random_aasta),
                       sum((kuu, ajal_paev, time_hour), ajal_elekter(ajal_aasta, kuu, ajal_paev, time_hour))
                     / sum((kuu, ajal_paev, time_hour), 1)
                   );

* Nüüd on aasta valitud, see tuleb elektri_referentsis ära asendada
    temp_aasta(kuu, ajal_paev, time_hour) = sum(ajal_aasta$(ord(ajal_aasta) = random_aasta),
                                                   ajal_elekter(ajal_aasta, kuu, ajal_paev, time_hour));

    loop((time_t, kuu, ajal_paev)$(
                 ord(ajal_paev) = gday(jdate(%aasta_1%, 1, 1) - 1 + ord(time_t))
                 and tee_paevaks
                 ),
         el_price_slot(sim, time_t, slott) =
                    sum((paev, weekday, time_hour)
                                      $(tee_paevaks
                                    and day
                                    and gdow(jdate(%aasta_1% + ord(aasta) - 1, ord(kuu), ord(paev))) = ord(weekday)
                                    and slot_hours(slott, weekday, time_hour)
                                      ),  temp_aasta(kuu, ajal_paev, time_hour) / keskmine * keskmine_ref(aasta)
                                      )
                                      /
                    sum((paev, weekday, time_hour)
                                      $(tee_paevaks
                                    and day
                                    and gdow(jdate(%aasta_1% + ord(aasta) - 1, ord(kuu), ord(paev))) = ord(weekday)
                                    and slot_hours(slott, weekday, time_hour)
                                      ),  1
                                      );
        );
);

nihe(sim) = normal(0, 0.5);
co2_price(sim, aasta) = co2_price(sim, aasta) + nihe(sim);

nihe(sim) = normal(0, 10);
oil_price(sim, aasta, kuu) = oil_price(sim, aasta, kuu) + nihe(sim);

Scalar status /0/;
Scalar amount /0/;
Scalar next_event /0/;
Scalar corr /0.8/;
Scalar u1;

* Arvutame avariilisuste stsenaariumid
* status = 0 - plokk on töökorras
* status = 1 - plokk on avariis

loop((sim, t_el)$(not sameas(t_el, "Katlamaja")),
* Next event on päevades (st vaata see 24 jagamine)
  next_event = -av_tabel(t_el, "mtbf") * log(uniform(0,1))/24;

  loop(cal_time_sub,
      av(sim, cal_time_sub, t_el) = amount;
      if((ord(cal_time_sub) > round(next_event)),
* Uus sündmus
         status = 1 - status;
         u1$(status = 1) = uniform(0, 1);
         amount$(status = 1) = 1$(u1 < 0.3469) + 0.5$(u1 >= 0.3469);
         amount$(status = 0) = 0;
         next_event$(status = 0) = next_event - av_tabel(t_el, "mtbf") * log(uniform(0,1))/24;
         next_event$(status = 1) = next_event - av_tabel(t_el, "mttr") * log(uniform(0,1))/24;
      );
   );

* Nüüd on av valmis tehtud, nüüd saab sloti tunnid vastavalt ümber arvutada.

  slot_length(sim, time_t, slott, t_el) = slot_length_orig(time_t, slott, t_el)
                                          - t_remondigraafik(time_t, slott, t_el)
                                          - sum((cal_time_sub, weekday, time_hour)$(cal_t(time_t, cal_time_sub)
                                                              and wkday_number_cal_sub(cal_time_sub) = ord(weekday)
                                                              and slot_hours(slott, weekday, time_hour)),
                                            av(sim, cal_time_sub, t_el));

  slot_length(sim, time_t, slott, t_el)$(slot_length(sim, time_t, slott, t_el) < 0) = 0;
);

