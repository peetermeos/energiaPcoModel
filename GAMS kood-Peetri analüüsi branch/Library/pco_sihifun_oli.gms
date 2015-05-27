    +
* Õli tootmine
   sum((aasta, kuu, t_ol) $tee_paevaks,
       oli(opt_paev, t_ol) *
       oli_referents(aasta, kuu)
       )

$ifthen.two "%uus_logistika%" == "false"
-

* Õli keskkonnamaksud ja saastetasud
* Kogu kivi mis läheb õlitehasesse * eriheide * keskkonnatariif

   sum((aasta,kuu,eh_ol, t_ol)$tee_paevaks,
   (sum((l_t, k, primaarenergia)
     $(tootmine_ja_laod(l_t, t_ol) and
      (max_osakaal(k, primaarenergia, t_ol) > 1) ) ,
      laost_tootmisse(opt_paev, l_t, t_ol, k, primaarenergia)$primaar_k(k, primaarenergia))
 +
 sum((l, k, liinid, primaarenergia)
      $(liini_otsad(liinid, k, l) and
       (max_osakaal(k, primaarenergia, t_ol) > 1) and
       t_jp_tootmine(l, t_ol)),
      liinilt_tootmisse(opt_paev, liinid, t_ol, primaarenergia)$primaar_k(k, primaarenergia)
      ))*eh_koefitsendid_ol(eh_ol, t_ol)*eh_tariif_ol(t_ol, eh_ol, aasta))

    -
*CO2
sum((aasta,kuu, t_ol)$tee_paevaks,
    (
sum((l_t, k, primaarenergia)
     $(tootmine_ja_laod(l_t, t_ol) and
       (max_osakaal(k, primaarenergia, t_ol) > 1)) ,
      laost_tootmisse(opt_paev, l_t, t_ol, k, primaarenergia)$primaar_k(k, primaarenergia))
 +
 sum((l, k, liinid, primaarenergia)
      $(liini_otsad(liinid, k, l) and
      (max_osakaal(k, primaarenergia, t_ol) > 1) and
       t_jp_tootmine(l, t_ol)),
      liinilt_tootmisse(opt_paev, liinid, t_ol, primaarenergia)$primaar_k(k, primaarenergia))

      )
      *eh_koefitsendid_ol("co", t_ol)*co2_referents(aasta))

$else.two
-

* Õli keskkonnamaksud ja saastetasud
* Kogu kivi mis läheb õlitehasesse * eriheide * keskkonnatariif

   sum((aasta,kuu,eh_ol, t_ol)$tee_paevaks,

        sum((l_n, slott, k, primaarenergia)$(t_log(t_ol, l_n)
                             and  (max_osakaal(k, primaarenergia, t_ol) > 1)),
        tootmisse(opt_paev, slott, l_n, t_ol, k, primaarenergia))

   *eh_koefitsendid_ol(eh_ol, t_ol)*eh_tariif_ol(t_ol, eh_ol, aasta))

-
*CO2
sum((aasta,kuu, t_ol)$tee_paevaks,

    sum((l_n, slott, k, primaarenergia)$(t_log(t_ol, l_n)
                             and  (max_osakaal(k, primaarenergia, t_ol) > 1)),
        tootmisse(opt_paev, slott, l_n, t_ol, k, primaarenergia))

      * eh_koefitsendid_ol("co", t_ol)
      * co2_referents(aasta, kuu))
$endif.two

* Muud muutuvkulud
-
sum((aasta,kuu, t_ol)$tee_paevaks,
oil_muud_kulud(aasta, kuu, t_ol) * oli(opt_paev, t_ol))

*Õli riigimaks - kui kui õli müügihind ületab 350 €/t, siis vahe pealt maksame 25% riigile.
$ifthen.two "%oli_riigimaks%" == "true"
-sum(t_ol,
 sum((aasta, kuu)$(tee_paevaks and oli_referents(aasta, kuu) ge 350),
         (oli_referents(aasta, kuu) - 350)*0.25
 )*oli(opt_paev, t_ol))
$endif.two

