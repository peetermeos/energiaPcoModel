**************************************************************
* Operatiivne tootmise planeerimise mudel.                   *
* Rakendatakse peale seda, kui elektriturg on realiseerunud  *
* või ka pikema ajahorisondi koormamise arvutamiseks.        *
* Granulaarsus: tunni täpsusega                              *
* Allan Puusepp, Peeter Meos                                 *
**************************************************************

$ifthen %MT% == "OP"

Equations
  v_op_tootmispiirang(opt_paev_max, slott)              "Turul realiseerunud koguse tuleb aggregeeritult toota"
  v_op_max_koormus(opt_paev_max, slott, t_el)           "Tootmisüksuse lühikese perspektiivi maksimumkoormus"
  v_op_max_tarne(opt_paev_max, l, k, primaarenergia)    "Maksimaalne deklareeritud tarnevõimekus päevas"
  v_op_max_uttegaas(opt_paev_max)                       "Maksimaalne uttegaasi tarnevõimekus päevas "
  v_op_koormus(o_paev, slott, t_el)                   "Unit commmitment koormamised op mudeli ajaaknas"
;

v_op_tootmispiirang(opt_paev, slott)$
       (sum((o_paev, opt_tund)$(ord(opt_paev) = ord(o_paev)
   and sloti_tunnid(slott, opt_tund)), op_real_koorm(o_paev, opt_tund)) > 0)..
  sum(t_el, koorm_el(opt_paev, slott, t_el) * sloti_pikkus_orig(slott))
  =e=
  sum((o_paev, opt_tund)$(ord(opt_paev) = ord(o_paev) and sloti_tunnid(slott, opt_tund)),
  op_real_koorm(o_paev, opt_tund)) / sloti_pikkus_orig(slott)
;

********************************************************
* Operatiivmudeli piirtingimused.                      *
* Allan Puusepp, Peeter Meos                           *
********************************************************

v_op_koormus(o_paev, slott, t_el)$(sum(opt_tund$sloti_tunnid(slott, opt_tund), op_max_koorm(o_paev, opt_tund, t_el))> 0)..
  sum(opt_paev$(ord(opt_paev) = ord(o_paev)),  koorm_el(opt_paev, slott, t_el))
  =e=
  koorm_el_op(o_paev, slott, t_el)
;

koorm_el_op.lo(o_paev, slott, t_el)$(sum(opt_tund$sloti_tunnid(slott, opt_tund),
  op_min_koorm(o_paev, opt_tund, t_el) > 0 and op_max_koorm(o_paev, opt_tund, t_el) > 0
  ))
  =
  sum(opt_tund$sloti_tunnid(slott, opt_tund),
    op_min_koorm(o_paev, opt_tund, t_el)) / sloti_pikkus_orig(slott)
;

v_op_max_koormus(opt_paev, slott, t_el)$
  (sum((o_paev, opt_tund)$(ord(opt_paev) = ord(o_paev)
                    and sloti_tunnid(slott, opt_tund)),
  op_max_koorm(o_paev, opt_tund, t_el))> 0)..
  koorm_el(opt_paev, slott, t_el)
  =l=
  sum((o_paev, opt_tund)$(ord(opt_paev) = ord(o_paev)
                    and sloti_tunnid(slott, opt_tund)),
   op_max_koorm(o_paev, opt_tund, t_el)) / sloti_pikkus_orig(slott)
;

v_op_max_tarne(opt_paev, l, k, primaarenergia)$
  (sum(o_paev$(ord(opt_paev) = ord(o_paev)), op_max_tarne(o_paev, l, k, primaarenergia)) > 0)..
  (sum((l_t, t)$(tootmine_ja_laod(l_t, t)
       and (max_osakaal(k, primaarenergia, t) > 0)
       and primaar_k(k, primaarenergia) ) ,
      laost_tootmisse(opt_paev, l_t, t, k, primaarenergia)
      )
  +
  sum((t, liinid)
      $(liini_otsad(liinid, k, l)
       and (max_osakaal(k, primaarenergia, t)>0)
       and primaar_k(k, primaarenergia)
       and t_jp_tootmine(l, t)),
      liinilt_tootmisse(opt_paev, liinid, t, primaarenergia)
      ))
  =l=
  sum(o_paev$(ord(opt_paev) = ord(o_paev)), op_max_tarne(o_paev, l, k, primaarenergia))
;

v_op_max_uttegaas(opt_paev)$
  (sum(o_paev$(ord(opt_paev) = ord(o_paev)), op_max_uttegaas(o_paev)) > 0)..
  sum((slott, t_el), q(opt_paev, slott, "Hange", "Uttegaas", t_el) *
                     sloti_pikkus_orig(slott))
  =l=
  sum(o_paev$(ord(opt_paev) = ord(o_paev)), op_max_uttegaas(o_paev))
;

* Soojuse piirang on pco_t_piirangutes!!

$endif
