********************************************************************************
**                                                                             *
**  See t�kk koodi arvutab etteantud k�tusele n�udlusk�vera                    *
**  30. dets 2013                                                              *
**  Ette on vaja anda ports keskkonnamuutujaid:                                *
**                                                                             *
**  $set n_hind_1               6                                              *
**  $set n_hind_2              15                                              *
**  $set n_hind_samm          0.2                                              *
**  $set n_allikas          Hange                                              *
**  $set n_kytus           Turvas                                              *
**                                                                             *
**  Peeter Meos                                                                *
********************************************************************************


Set
  co2      /1 * 20/
  el       /1 * 20/

  tulem  /hind_co2, hind_bio, hange, sisene, kasum/
;
$drop n_hind_punktid

Parameters
  co2_hind(co2)
  el_hind(el)
;
co2_hind(co2) = 4  + 0.5  * (ord(co2) - 1);
el_hind(bio)  = 30 + 0.25  * (ord(el) - 1);


Variable
   t_run(co2, el, aasta, kuu, tulem) "Mudeli tulem"
   t_kytus(co2, el, aasta, kuu, t, k, primaarenergia) "Mudeli k�tuse kasutus (MWh)"
;

Model pco /all/;

* Konfigureerime CPLEXi
pco.OptFile = 1;
pco.PriorOpt = 1;
pco.SolveLink = 5;
$libinclude pco_cplex_parameetrid

max_kaeve(aasta, kuu, "Hange", "Biokytus")  = M * M;

loop((co2, el),
  k_muutuvkulud(aasta,  kuu, "Hange", "Biokytus") = bio_hind(bio) * kyttevaartus("Biokytus", "Hange");
  co2_referents(aasta)                            = co2_hind(co2);

  Solve pco maximizing total_profit using mip;

      $$libinclude pco_postprocessing

      t_run.l(co2, bio, aasta, kuu, "hind_bio")$(sum((time_t), 1$tee_paevaks) > 0)    = bio_hind(bio);
      t_run.l(co2, bio, aasta, kuu, "hind_co2")$(sum((time_t), 1$tee_paevaks) > 0)    = co2_hind(co2);

      t_run.l(co2, bio, aasta, kuu, "hange")$(sum((time_t), 1$tee_paevaks) > 0)
                                 = sum((sim, t, toode, kvartal)$kvartali_kuud(kvartal, kuu),
                         kytuse_kasutus_kuu.l(sim, aasta, kvartal, kuu, t, toode, "Hange", "Biokytus", "MWh"));

      t_run.l(co2, bio, aasta, kuu, "sisene")$(sum((time_t), 1$tee_paevaks) > 0)
                                 = sum((sim, t, toode, kvartal, k, primaarenergia)$kvartali_kuud(kvartal, kuu),
                         kytuse_kasutus_kuu.l(sim, aasta, kvartal, kuu, t, toode, k, primaarenergia, "MWh"))
                                 - t_run.l(co2, bio, aasta, kuu, "hange");

      t_run.l(co2, bio, aasta, kuu, "kasum")$(sum((time_t), 1$tee_paevaks) > 0)
                                 = total_profit.l;

      t_kytus.l(co2, bio, aasta, kuu, t, k, primaarenergia)$(sum((sim, time_t), 1$tee_paevaks) > 0)
                                 = sum((sim, toode, kvartal)$kvartali_kuud(kvartal, kuu),
                           kytuse_kasutus_kuu.l(sim, aasta, kvartal, kuu, t, toode, k, primaarenergia, "MWh"));
);


