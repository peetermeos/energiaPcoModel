********************************************************************************
**                                                                             *
**  See tükk koodi arvutab etteantud kütusele nõudluskõvera                    *
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

$eval n_hind_punktid ((%n_hind_2% - %n_hind_1%) / %n_hind_samm%) + 1
Set
  runnid /1*%n_hind_punktid%/
  tulem  /hind, hange, sisene, kasum/
;
$drop n_hind_punktid

Parameter  h_run(runnid);
h_run(runnid) = %n_hind_1% + (ord(runnid)-1) * %n_hind_samm%;


Variable
   t_run(runnid, aasta, kuu, tulem) "Mudeli tulem"
   t_kytus(runnid, aasta, kuu, t_el, k, primaarenergia) "Mudeli kütuse kasutus (MWh)"
;

Parameter h(runnid) model handles;
*pco.SolveLink = 3;
*pco.SolveLink = 2;

Parameter alg_kulud(aasta, k, primaarenergia);
Parameter alg_kaeve(aasta, kuu, k, primaarenergia);
Scalar loop_index;

alg_kulud(aasta, k, primaarenergia) =  k_muutuvkulud(aasta,  k, primaarenergia);
alg_kaeve(aasta, kuu, k, primaarenergia) = max_kaeve(aasta, kuu, k, primaarenergia);

alias(r2, runnid);
h(r2) = 0;

max_kaeve(aasta, kuu, k, primaarenergia)  = M;
max_kaeve(aasta, kuu, "Hange", primaarenergia) = 0;
max_kaeve(aasta, kuu, "Hange", "Killustik") = M;
max_kaeve(aasta, kuu, "Hange", "Lubi") = M;
max_kaeve(aasta, kuu, "Hange", "Maagaas") = M;
logistikakulu(aasta, kuu, liinid) = 0;


loop(runnid,
  loop((k, primaarenergia),
  k_muutuvkulud(aasta,  k, primaarenergia)$(not (sameas(primaarenergia, "Killustik")
                                              or sameas(primaarenergia, "Lubi")
                                              or sameas(primaarenergia, "Maagaas")))
               = h_run(runnid) * kyttevaartus(primaarenergia, k);
  );

$ontext
  loop_index = 5;
  while(loop_index > 3,
    loop_index = 0;
    display$sleep(card(h) * 1) 'sleep some time';

    loop(r2,
      if(handlestatus(h(r2)) = 1, loop_index = loop_index + 1);
    );
  );
$offtext

  Solve pco maximizing kasum using mip;
$ontext
  h(runnid) = pco.handle;
);

Repeat
  loop(runnid,
    if(handlestatus(h(runnid)) = 2,
      pco.handle = h(runnid);
      execute_loadhandle pco;
$offtext
      $$libinclude pco_jareltootlus2

      t_run.l(runnid, aasta, kuu, "hind")$(sum((time_t), 1$tee_paevaks) > 0)    = h_run(runnid);
      t_run.l(runnid, aasta, kuu, "hange")$(sum((time_t), 1$tee_paevaks) > 0)
                                 = sum((t_el, primaarenergia), kytuse_kasutus_kuus.l(aasta, kuu, t_el, "Hange", primaarenergia, "mwh"))
                                 + sum((t_ol, primaarenergia), kytuse_kasutus_kuus_ol.l(aasta, kuu, t_ol, "Hange", primaarenergia, "mwh"));
      t_run.l(runnid, aasta, kuu, "sisene")$(sum((time_t), 1$tee_paevaks) > 0)
                                 = sum((t_el, k, primaarenergia), kytuse_kasutus_kuus.l(aasta, kuu, t_el, k, primaarenergia, "mwh"))
                                 + sum((t_ol, k, primaarenergia), kytuse_kasutus_kuus_ol.l(aasta, kuu, t_ol, k, primaarenergia, "mwh"))
                                 - t_run.l(runnid, aasta, kuu, "hange");
      t_run.l(runnid, aasta, kuu, "kasum")$(sum((time_t), 1$tee_paevaks) > 0)
                                 = kasum.l;
      t_kytus.l(runnid, aasta, kuu, t_el, k, primaarenergia)$(sum((time_t), 1$tee_paevaks) > 0)
                                 = kytuse_kasutus_kuus.l(aasta, kuu, t_el, k, primaarenergia, "mwh");
$ontext
     display$handledelete(h(runnid)) 'trouble deleting handles' ;
     h(runnid) = 0
    )
$offtext
  );

*  display$sleep(card(h) * 0.2) 'sleep some time';
*until card(h) = 0 or timeelapsed > 7200;

k_muutuvkulud(aasta,  k, primaarenergia) = alg_kulud(aasta, k, primaarenergia);
max_kaeve(aasta, kuu, k, primaarenergia) = alg_kaeve(aasta, kuu, k, primaarenergia);

