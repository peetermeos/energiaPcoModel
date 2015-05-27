  +
* Soojatoodang, pole vaja netosse konverteerida, on kohe netos
  sum((aasta, kuu, slott, t_sj) $tee_paevaks,
         koorm_sj(opt_paev, slott, t_sj) * sloti_pikkus(opt_paev, slott, t_sj) *
         soojuse_referents(aasta, kuu)
      )
  -
  sum((aasta, kuu, slott, t_sj) $tee_paevaks,
         koorm_sj(opt_paev, slott, t_sj) * sloti_pikkus(opt_paev, slott, t_sj) *
         soojuse_muud_kulud(aasta, kuu, t_sj)
     )

