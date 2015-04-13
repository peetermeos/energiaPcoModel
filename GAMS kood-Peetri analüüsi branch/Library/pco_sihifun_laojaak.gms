$ifthen.two "%kaevanduste_laod%" == "true"
  +
* Viimasel päeval laos oleva kütuse tulevikuväärtus
* (kui temast toota elektrit 20EUR MWh kasumiga)
  sum((opt_paev, l_k, primaarenergia)$
      (ord(opt_paev) = card(opt_paev)),
                           laoseis_k(opt_paev, l_k, primaarenergia) *
                           kyttevaartus(primaarenergia,k) *
                           4)
$endif.two


$ifthen.two "%tootmise_laod%" == "true"
  +
* Viimasel päeval laos oleva kütuse tulevikuväärtus
* (kui temast toota elektrit 20EUR MWh kasumiga)
  sum((opt_paev, k, l_t, primaarenergia)$
      (ord(opt_paev) = card(opt_paev)),
                           laoseis_t(opt_paev, l_t, k, primaarenergia) *
                           kyttevaartus(primaarenergia,k) *
                           4)
$endif.two
