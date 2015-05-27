 sum((aasta, kuu, slott, t_el)$tee_paevaks,

  koorm_el(opt_paev, slott, t_el)
  * sum(opt_tund, (elektri_referents(aasta, kuu, opt_paev, opt_tund))$sloti_tunnid(slott, opt_tund))
  * (1 - avariilisus(t_el, aasta))

*Muud muutuvkulud
*Taaniel Uleksin
   -
   koorm_el(opt_paev, slott, t_el) * sloti_pikkus(opt_paev, slott, t_el) * el_muud_kulud(aasta, kuu, t_el)

* Miinimum-marginaali arvestamiseks võtame selle maha kui muutuvkulu
$ifthen.marg "%m_marg%" == "true"
   -
   koorm_el(opt_paev, slott, t_el) * min_marginaal(t_el)
$endif.marg

)

