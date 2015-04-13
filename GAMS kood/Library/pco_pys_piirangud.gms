********************************************************************************
** Püsikuludele seatavad piirangud.                                            *
** Taaniel Uleksin                                                             *
********************************************************************************

Equations
   v_pys_koormus(time_t, t_el)         "Kui plokk ei ole töös, siis seda ei koormata."
   v_pys_hoolduskulu(aasta, kuu, t_el)   "Hoolduskulu sõltuvus eelmise ja järgmise kuu töös olemisest."
   v_pys_kaivitus(aasta, kuu, t_el)      "Ploki käimapanemine pärast konserveerimist."
   v_pys_yletunni_brig(aasta, kuu, jaam)       "Ületundide arvelt kasutatavate brigaadide arv"
*   v_pys_brigaadid(aasta, kuu)           "Brigaadide jaotus (töös, ületund, sundpuhkus)"
;

v_pys_koormus(time_t, t_el)..
   sum(slott, koorm_el(time_t, slott, t_el)) =l= sum((aasta, kuu)$tee_paevaks, p_work(aasta, kuu, t_el))*M
;

v_pys_hoolduskulu(aasta, kuu, t_el)..
* Antud piirangus teeme eelduse, et aasta tuple ei muutu s.t. 1. aasta on alati 2013.

   h_kulu(aasta, kuu, t_el)
   =g=
*p(t-1)
   p_work(aasta, kuu-1, t_el)$(ord(kuu) le %lopp_kuu% and (ord(aasta) + 2012 eq %lopp_aasta%))
   +
   p_work(aasta, kuu-1, t_el)$(ord(kuu) > 1 and (ord(aasta) + 2012 < %lopp_aasta%))
   +
   p_work(aasta-1, "12", t_el)$(ord(kuu) eq 1 and (ord(aasta) + 2012 le %lopp_aasta%))
*p(t+1)
   +
   p_work(aasta, kuu+1, t_el)$(ord(kuu) ge %algus_kuu% and (ord(aasta) + 2012 eq %algus_aasta%))
   +
   p_work(aasta, kuu+1, t_el)$(ord(kuu) < card(kuu) and (ord(aasta) + 2012 > %algus_aasta%))
   +
   p_work(aasta+1, "1", t_el)$(ord(kuu) eq card(kuu) and (ord(aasta) + 2012 ge %algus_aasta%))
*p(t)
   -
   2*p_work(aasta, kuu, t_el)
;

v_pys_kaivitus(aasta, kuu, t_el)..
   k_kulu(aasta, kuu, t_el)
   =g=
   p_work(aasta, kuu, t_el)
   -
   p_work(aasta, kuu-1, t_el)$(ord(kuu) > 1)
;

v_pys_yletunni_brig(aasta, kuu, jaam)..
   yt_brigaadid(aasta, kuu, jaam)
   =l=
   yletunni_koefitsient(aasta, kuu)*sum(t_el$t_jaam(jaam, t_el), p_work(aasta, kuu, t_el))
;

*v_pys_brigaadid(aasta, kuu)..

*;
