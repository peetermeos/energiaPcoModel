$ifthen.three "%uus_logistika%" == "false"

$ifthen.two "%kaevanduste_laod%" == "true"
   -
sum((aasta, kuu, k, l_k, primaarenergia)$(
         tee_paevaks
     and kaevandused_ja_laod(k, l_k) and primaar_k(k, primaarenergia)
     ),
     laokulud(l_k) *
     kaevandusest_lattu(opt_paev, l_k, k, primaarenergia))
   -
sum((aasta, kuu, l_k, liinid, k, primaarenergia)$(
         tee_paevaks
     and k_jp_ladu(liinid, l_k)
     and kaevandused_ja_laod(k, l_k) and primaar_k(k, primaarenergia)
     ),
     laokulud(l_k) * laost_liinile(opt_paev, l_k, liinid, primaarenergia))

$endif.two

* Ladustamise kulud tootmisüksustes
$ifthen.two "%tootmise_laod%" == "true"
-
sum((aasta, kuu, liinid, l_t, l, k, primaarenergia)$(
         tee_paevaks
     and liini_otsad(liinid, k, l)
     and primaar_k(k, primaarenergia) and t_jp_ladu(l, l_t)
     ),
     laokulud(l_t) *
     liinilt_lattu(opt_paev, liinid, l_t, primaarenergia))
   -
sum((aasta, kuu, l_t, t, k, primaarenergia)$(
         tee_paevaks
     and primaar_k(k, primaarenergia) and tootmine_ja_laod(l_t, t)
     ),
     laokulud(l_t) * laost_tootmisse(opt_paev, l_t, t, k, primaarenergia))
$endif.two

$else.three

*Lattu laadimise ja laost võtmise kulud
-
sum((l_n, lao_laiendus),lattu_kulu(opt_paev, l_n, lao_laiendus) + laost_kulu(opt_paev, l_n, lao_laiendus))
$endif.three

