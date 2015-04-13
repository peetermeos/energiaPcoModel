
  -
* Kütuse etteande muutuvkulud elektritootmisüksustes (KET kulud)
sum((aasta,kuu, t_el)$tee_paevaks,
   (sum((l_t, k, primaarenergia)
     $(tootmine_ja_laod(l_t, t_el) and
       (max_osakaal(k, primaarenergia, t_el) > 1)) ,
      laost_tootmisse(opt_paev, l_t, t_el, k, primaarenergia)$primaar_k(k, primaarenergia))
 +
 sum((l, k, liinid, primaarenergia)
      $(liini_otsad(liinid, k, l) and
       (max_osakaal(k, primaarenergia, t_el) > 1) and
       t_jp_tootmine(l, t_el)),
      liinilt_tootmisse(opt_paev, liinid, t_el, primaarenergia)$primaar_k(k, primaarenergia)
      ))*t_ket_kulu(aasta, kuu, t_el))


   -
* Kütuse etteande muutuvkulud õlitootmisüksustes (KET kulud)
sum((aasta,kuu, t_ol)$tee_paevaks,
   (sum((l_t, k, primaarenergia)
     $(tootmine_ja_laod(l_t, t_ol) and
       (max_osakaal(k, primaarenergia, t_ol) > 1)) ,
      laost_tootmisse(opt_paev, l_t, t_ol, k, primaarenergia)$primaar_k(k, primaarenergia))
 +
 sum((l, k, liinid, primaarenergia)
      $(liini_otsad(liinid, k, l) and
       (max_osakaal(k, primaarenergia, t_ol) > 1) and
       t_jp_tootmine(l, t_ol)),
      liinilt_tootmisse(opt_paev, liinid, t_ol, primaarenergia)$primaar_k(k, primaarenergia)
      ))*t_ket_kulu(aasta, kuu, t_ol))



