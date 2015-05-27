   +
* Kivi müük (VKGle ja potentsiaalselt teistele)
   sum((aasta, kuu, k, primaarenergia, t_mk)$
       (tee_paevaks
        and primaar_k(k, primaarenergia)
        and (max_osakaal(k, primaarenergia, t_mk) > 0)
       ),

       myyk(opt_paev, k, primaarenergia, t_mk) * kontsentraadi_hind(aasta)
       )
