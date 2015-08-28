********************************************************************************
**                                                                             *
**  This piece of code generates reference prices based on generic scenaria    *
**  by JAR                                                                     *
**                                                                             *
**  Peeter Meos                                                                *
********************************************************************************

* �htsete stsenaariumite jaoks on meil vaja arvutada normaliseeritud hinnakurvi iga kuu jaoks aastas.
* V�tame aasta, arvutame selle pealt kuu keskmised
* Siis normaliseerime kuu kurvi

* K�igepealt otsime viimase aasta, kus meil hinnad on
Scalar viimane_aasta;
Parameter kuu_keskmine_ref(kuu);
Parameter hinnakover(kuu, paev, time_hour);

viimane_aasta = smax(aasta$(sum((kuu, paev, time_hour), elektri_referents(aasta, kuu, paev, time_hour)  > 0)), ord(aasta));

kuu_keskmine_ref(kuu) = sum((aasta, paev, time_hour)$(ord(aasta) = viimane_aasta),
                                   elektri_referents(aasta, kuu, paev, time_hour))
                     / (sum((aasta, paev, time_hour)$(ord(aasta) = viimane_aasta
                                                 and elektri_referents(aasta, kuu, paev, time_hour) > 0), 1)+1);

hinnakover(kuu, paev, time_hour) = sum(aasta$(ord(aasta) = viimane_aasta),
                                         elektri_referents(aasta, kuu, paev, time_hour))
                                       / kuu_keskmine_ref(kuu);

* N��d on kurvid ja keskmised olemas, v�tame �hised stsenaariumid ja teeme nende pealt elektri_referentsi

elektri_referents(aasta, kuu, paev, time_hour) = hinnakover(kuu, paev, time_hour) * ys_elekter(aasta, kuu);