Scalars
 t_sg_m3 "Suitsugaaside koefitsent (m3/MWh kütust)"      /1.3451/
;

Set
    eh          "Eriheitmed"
/
co
so
no
lt
jv
th
at
/;

Set    eh_ol(eh)       "Õli Eriheitmed"
/
co
jv
th
at
/;

Parameter   eh_co2(primaarenergia);
$loaddc eh_co2

Parameter
  k_moju(k, primaarenergia, eh)
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

k_moju(k, primaarenergia, "co") = 0.01;

Set
    l_tase       "Lubja tasemed t(lubi)/h"            /0
$ifthen.two "%l_k_sees%" == "true"
                                                       *1
$endif.two
                                                       /
    k_tase       "Killustiku tasemed t(killustik)/h"  /0
$ifthen.two "%l_k_sees%" == "true"
                                                       ,20
$endif.two
                                                      /
;

Parameters
    lub_tase(l_tase)
    /
0        0
$ifthen.two "%l_k_sees%" == "true"
1        1
$endif.two
    /

    kil_tase(k_tase)
    /
0        0
$ifthen.two "%l_k_sees%" == "true"
20       20
$endif.two
    /
;

Parameter
    eh_tariif(eh, aasta)  "Eriheitmete tariifid juhtimisarvestuselt (EUR/t)"
    eh_tariif_ol(t_ol, eh_ol, aasta)  "Õli eriheitmete tariifid juhtimisarvestuselt (EUR/t)"
    eh_kvoot(aasta, eh) "Eriheitmete kvoot(t/aasta)"
    eh_koefitsendid(eh, t_el, k, primaarenergia, para_lk) "Eriheitmete regressioonikoefitsendid. (t)"
    eh_koefitsendid_ol(eh_ol, t_ol) "Õli eriheitmete koefitsendid. Ühik on t(heide)/t(põlevkivi)"
    korstna_tundide_piirang(t_korstnad) "Mitu tundi korsten aktiivne olla tohib (tunnid)"
    lubja_hind(aasta) "Lubja hind aastas (EUR/t)"

* Eriheitmete mugavamaks sisestamiseks võtame nad sekundaarenergias antuna (a'la Molodtsovi tabel)
   eh_lt(k, primaarenergia, t_el)  "Elektritootmisplokkide lendtuha eriheitmed vastava kütusega (kg/GWh el)"
   eh_th(k, primaarenergia, t_el)  "Elektritootmisplokkide ladestatud tuha eriheitmed vastava kütusega (kg/GWh el)"
   eh_jv(k, primaarenergia, t_el)  "Elektritootmisplokkide jahutusvee eriheitmed vastava kütusega (kg/GWh el)"

   kulutatud_sox(aasta)            "Juba kulutatud SOx kvoot (t) (vajalik esimese aasta jaoks)"
;

Set tp_aasta(aasta)   "Töötundide piirangu aastad";
$loaddc tp_aasta

$loaddc eh_lt eh_th eh_jv lubja_hind
$loaddc eh_tariif eh_tariif_ol eh_kvoot
$loaddc eh_koefitsendid_ol korstna_tundide_piirang kulutatud_sox

* JARi tabelist, MWh kütuse kohta
eh_koefitsendid("lt", t_el, k, primaarenergia, para_lk) = eh_lt(k, primaarenergia, t_el);

* Ladestatud tuhk on ette antud t/MWh kütuse kohta, seega edasi töödelda pole vaja
eh_koefitsendid("th", t_el, k, primaarenergia, para_lk) = eh_th(k, primaarenergia, t_el);

* Jahutusvesi on antud m3/MWh elektri peale ja läheb ka sihifunktsiooni sellisena
eh_koefitsendid("jv", t_el, k, primaarenergia, para_lk) = eh_jv(k, primaarenergia, t_el);

Set t_jv(t)  "Jahutusvee piiranguga tootmisüksused";
$loaddc t_jv

Parameter eh_koef(eh, t_el, k, primaarenergia, para_lk, k_tase);
Parameter eh_korr(eh, t_el, k, primaarenergia, para_lk, k_tase);
Parameter retort_gas_coef(eh)  "Emissions coefficient for retort gas";

* Retort gas increases only SOx emissions by 22%
retort_gas_coef(eh)   = 1;
retort_gas_coef("so") = 1.22;

eh_koef(eh, t_el, k, primaarenergia, para_lk, k_tase)
   = eh_koefitsendid(eh, t_el, k, primaarenergia, para_lk);

*Jahutusvee hulk
Parameter jahutusvee_kasutus(t, kuu);

$loaddc jahutusvee_kasutus

*****************************************************************************************************
Parameter hh_so(k, primaarenergia, para_lk, t_el);
Parameter hh_no(k, primaarenergia, para_lk, t_el);
$loaddc hh_so hh_no

Parameter hh_koef(eh, t_el, k, primaarenergia, para_lk);
hh_koef("so", t_el, k, primaarenergia, para_lk) = hh_so(k, primaarenergia, para_lk, t_el) / (1000 * 1000 ) * 0.47;
hh_koef("no", t_el, k, primaarenergia, para_lk) = hh_no(k, primaarenergia, para_lk, t_el) / (1000 * 1000 ) * 0.47;

Parameter hh_q(t_el, para_lk);
* 0, 40, 120, 145
hh_q(t_el, "1") = 0;
hh_q(t_el, "2") = valjund(t_el, "3", "b") / valjund(t_el, "3", "a")   * 40;
hh_q(t_el, "3") = (valjund(t_el, "4", "b") + valjund(t_el, "3", "b"))
                / (valjund(t_el, "4", "a") + valjund(t_el, "3", "a")) * 120;
hh_q(t_el, "4") = valjund(t_el, "4", "b") / valjund(t_el, "4", "a")   * kasutegur(t_el, "4", "a");
*****************************************************************************************************
