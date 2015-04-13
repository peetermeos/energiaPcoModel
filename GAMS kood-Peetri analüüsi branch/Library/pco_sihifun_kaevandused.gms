
  -
* Kaevanduste muutuvkulud

sum((aasta, kuu, primaarenergia, k, p2)$(tee_paevaks and primaar_k(k, primaarenergia) and k_kaeve(k, p2)),
        kaeve(opt_paev, p2, primaarenergia, k)
      * rikastuskoefitsent(p2, k, primaarenergia)
      * k_muutuvkulud(aasta, kuu, k, primaarenergia) )

