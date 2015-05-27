   -
* Primaarenergia ostmine välistest allikatest lepingu kaupa
  sum((aasta, kuu, lepingu_nr, k, primaarenergia)$(tee_paevaks and primaar_k(k, primaarenergia)
       and ostuleping(lepingu_nr, aasta, kuu, k, primaarenergia, "kogus") > 0),
      kytuse_ost(lepingu_nr, opt_paev, k, primaarenergia)
    * ostuleping(lepingu_nr, aasta, kuu, k, primaarenergia, "hind")
    * kyttevaartus(primaarenergia, k)
  )



