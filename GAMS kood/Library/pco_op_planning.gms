**************************************************************
* Operatiivne tootmise planeerimise mudel.                   *
* Rakendatakse peale seda, kui elektriturg on realiseerunud. *
* Ajahorisont: 1 p�ev, tunni t�psusega                       *
* Peeter Meos                                                *
**************************************************************

$ifthen "%MT%" == "OP"

Set   paev  /1*31/;

Parameter
  op_real_koorm(paev, time_hour)           "Turul realiseerunud kogused"
  op_min_koorm(paev, time_hour, t_el)      "L�hikese ajaperioodi miinimumkoormused"
  op_max_koorm(paev, time_hour, t_el)      "L�hikese ajaperioosi maksimumkoormused"
  op_max_tarne(l, k, feedstock, paev)      "P�evane maksimaalne tarnev�imekus (t)"
  op_max_uttegaas(paev)                    "Maksimaalne uttegaasi tarnev�imekus (MWh)"
  op_soojus(paev)                          "P�evane soojatarne t�psemal kujul (MWh)"
;


*op_real_koorm(paev, time_hour) = 900;
$ontext
op_min_koorm(paev, time_hour, t_el) = 0;

op_max_koorm(paev, time_hour, t_el)
   = sum((time_t, aasta, kuu)$(tee_paevaks
                             and ord(time_t) = ord(paev)),
                      max_koormus_el(t_el, aasta, kuu));

op_max_tarne(paev, l, k, primaarenergia) = M;
op_max_uttegaas(paev) = M;
op_soojus(paev) = 40;
$offtext

$loaddc op_real_koorm
$loaddc op_min_koorm op_max_koorm op_max_tarne op_max_uttegaas
$loaddc op_soojus

$endif
