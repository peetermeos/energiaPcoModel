**************************************************************
* Operatiivne tootmise planeerimise mudel.                   *
* Rakendatakse peale seda, kui elektriturg on realiseerunud. *
* Ajahorisont: 1 p�ev, tunni t�psusega                       *
* Peeter Meos                                                *
**************************************************************

$ifthen "%MT%" == "OP"

Set   o_paev  /1*31/;

Semicont variable koorm_el_op(o_paev, slott, t_el) "Elektrikoormuse poolpidev muutuja t�pseks koormamiseks";


Parameter
  op_real_koorm(o_paev, opt_tund)            "Turul realiseerunud kogused"
  op_min_koorm(o_paev, opt_tund, t_el)       "L�hikese ajaperioodi miinimumkoormused"
  op_max_koorm(o_paev, opt_tund, t_el)       "L�hikese ajaperioosi maksimumkoormused"
  op_max_tarne(o_paev, l, k, primaarenergia) "P�evane maksimaalne tarnev�imekus (t)"
  op_max_uttegaas(o_paev)                    "Maksimaalne uttegaasi tarnev�imekus (MWh)"
  op_soojus(o_paev)                          "P�evane soojatarne t�psemal kujul (MWh)"
;


*op_real_koorm(paev, opt_tund) = 900;
$ontext
op_min_koorm(paev, opt_tund, t_el) = 0;

op_max_koorm(paev, opt_tund, t_el)
   = sum((opt_paev, aasta, kuu)$(paev_kalendriks(opt_paev, aasta, kuu)
                             and ord(opt_paev) = ord(paev)),
                      max_koormus_el(t_el, aasta, kuu));

op_max_tarne(paev, l, k, primaarenergia) = M;
op_max_uttegaas(paev) = M;
op_soojus(paev) = 40;
$offtext

$loaddc op_real_koorm
$loaddc op_min_koorm op_max_koorm op_max_tarne op_max_uttegaas
$loaddc op_soojus

$endif
