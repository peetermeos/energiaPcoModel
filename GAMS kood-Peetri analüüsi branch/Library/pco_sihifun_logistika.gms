$ifthen.three "%uus_logistika%" == "false"

-
* Logistika kulud (kaevandusest liinile ja laost liinile)
sum((aasta, kuu, liinid, primaarenergia, k,l)$(
         tee_paevaks
     and liini_otsad(liinid, k, l)
     and primaar_k(k, primaarenergia)
     ),
     logistikakulu(aasta, kuu, liinid) *
     kaevandusest_liinile(opt_paev, liinid, primaarenergia))

$ifthen.two "%kaevanduse_laod%" == "true"
   -
sum((aasta, kuu, liinid, primaarenergia, l_k, k)$(
         tee_paevaks
     and k_jp_ladu(liinid, l_k)
     and kaevandused_ja_laod(k, l_k)
     and primaar_k(k, primaarenergia)
     ),
     logistikakulu(aasta, kuu, liinid) *
     laost_liinile(opt_paev, l_k, liinid, primaarenergia)
     )
$endif.two

$else.three

-
* Logistika kulud (ladude ja liinide kulud)
sum((aasta, kuu, l_vah, l_n, l_n1, primaarenergia, k)$tee_paevaks,
     l_tk_kulu(aasta, l_vah) * l_pikkus(l_n, l_n1) *
     l_voog(opt_paev, primaarenergia, k, l_vah, l_n1, l_n)$l_e(l_vah, l_n, l_n1)
)

$endif.three
