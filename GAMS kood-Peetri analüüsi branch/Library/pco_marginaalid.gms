********************************************************************************
**                                                                             *
**  See tükk koodi arvutab pakkumistele marginaale                             *
**  30. dets 2013                                                              *
**  Ette on vaja anda ports keskkonnamuutujaid:                                *
**                                                                             *
**  $set max_marginaalid       30 (ehk mitme päeva marginaalid, harilikult kuu)*
**                                                                             *
**  Peeter Meos                                                                *
********************************************************************************

Set hinnad /
   lo, mid, up
          /;
Parameter
  h_nihe(hinnad) /
                  lo   0.9
                  mid  1.0
                  up   1.1
                 /
;

Positive variable
  tulemused(hinnad, t_el)
  tulemused_sox(hinnad, t_el)   "SOx marginaal per plokk (EUR/MWh)"
  tulemused_hind(hinnad, opt_paev_marg, slott, t_el)
  tulemused_kulu(hinnad, t_el)
  tulemused_marg(hinnad, opt_paev_marg, k, primaarenergia)
  tulemused_kaeve(hinnad, aasta, kuu, k, primaarenergia)
  tulemused_koorm(hinnad, opt_paev_marg, t_el)
;

Parameter
  el(aasta, kuu, opt_paev_max, opt_tund)
  pe_marg(k, primaarenergia)
  pe_sum(t_el)
  pe_kasutus(k, primaarenergia, t_el)
;

el(aasta, kuu, opt_paev_max, opt_tund) = elektri_referents(aasta, kuu, opt_paev_max, opt_tund);

loop(hinnad,
  elektri_referents(aasta, kuu, opt_paev_max, opt_tund) = el(aasta, kuu, opt_paev_max, opt_tund) * h_nihe(hinnad);
  Solve pco maximizing kasum using mip;

  $$libinclude pco_jareltootlus2

* Arvutame iga kaevandatud kütuse marginaali per primaarenergia MWh
  pe_marg(k, primaarenergia)$(kyttevaartus(primaarenergia, k) > 0)
  = sum(opt_paev_marg, v_k_paevane_kaeve.m(opt_paev_marg, k, primaarenergia) / kyttevaartus(primaarenergia, k)
    ) / card(opt_paev_marg);

* Arvutame kokku kasutatud primaarenergia koguse plokis
  pe_sum(t_el) = sum((aasta, kuu, paev, opt_paev_marg, k, primaarenergia, toode)$paev_kalendriks(opt_paev_marg, aasta, kuu),
                 kytuse_kasutus_paev.l(aasta, kuu, paev, opt_paev_marg, t_el, toode, k, primaarenergia, "mwh"));

* Arvutame kasutatud primaarenergia proportsiooni kütuse kaupa iga ploki jaoks
  pe_kasutus(k, primaarenergia, t_el)$(pe_sum(t_el) > 0)
  =
  sum((aasta, kuu, paev, toode, opt_paev_marg)$paev_kalendriks(opt_paev_marg, aasta, kuu),
   kytuse_kasutus_paev.l(aasta, kuu, paev, opt_paev_marg, t_el, toode, k, primaarenergia, "mwh")) / pe_sum(t_el);

  tulemused.l(hinnad, t_el) = sum((primaarenergia, k, p2)$(rikastuskoefitsent(primaarenergia, k, p2)),
                                   pe_kasutus(k, p2, t_el) * pe_marg(k, primaarenergia));

*  tulemused.l(hinnad, t_el) = smin((primaarenergia, k, p2)$(rikastuskoefitsent(primaarenergia, k, p2)
*                                          and pe_kasutus(k, p2, t_el) > 0), pe_marg(k, primaarenergia));

  tulemused_hind.l(hinnad, opt_paev_marg, slott, t_el)$(sloti_pikkus(opt_paev_marg, slott, t_el) > 0) =
      sum((aasta, kuu, opt_tund)$(sloti_tunnid(slott, opt_tund) and paev_kalendriks(opt_paev_marg, aasta, kuu) ),
          elektri_referents(aasta, kuu, opt_paev_marg, opt_tund)) / sloti_pikkus(opt_paev_marg, slott, t_el);

  tulemused_kulu.l(hinnad, t_el) =
      sum((opt_paev_marg, t, toode)$(t_el(t)), t_mkul_paev_EurPerToode.l(opt_paev_marg, t, toode, "kokku")) /
      (0.01+sum((opt_paev_marg, t, toode)$(t_el(t) and t_mkul_paev_EurPerToode.l(opt_paev_marg, t, toode, "kokku") >0), 1));

  tulemused_marg.l(hinnad, opt_paev_marg, k, primaarenergia) = v_k_paevane_kaeve.m(opt_paev_marg, k, primaarenergia);
  tulemused_koorm.l(hinnad, opt_paev_marg, t_el)             = t_toodang_paev.l(opt_paev_marg, t_el, "Elekter");

  tulemused_kaeve.l(hinnad, aasta, kuu, k, primaarenergia)= sum(kvartal$kvartali_kuud(kvartal, kuu),
                             kaeve_toodang_kuu.l(aasta, kvartal, kuu, k, primaarenergia, "mwh"));

* Arvutame SOx marginaali igale plokile sekundaarenergia peale (EUR/MWh)

  tulemused_sox.l(hinnad, t_el) = sum((opt_paev_marg, aasta, kuu)$paev_kalendriks(opt_paev_marg, aasta, kuu),
                                     v_so_kvoot.m(aasta)) / card(opt_paev_marg)
                                * sum((opt_paev_marg, aasta, kuu)$paev_kalendriks(opt_paev_marg, aasta, kuu),
                                     keskmine_eriheide_aasta.l(aasta, t_el, "so", "ELekter")) / card(opt_paev_marg)
                                + epsilon;

);

* Paneme algupärased hinnad tagasi
elektri_referents(aasta, kuu, opt_paev_max, opt_tund) = el(aasta, kuu, opt_paev_max, opt_tund);
