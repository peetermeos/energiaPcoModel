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
**  $set nnk               Turvas                                              *
**                                                                             *
**  Peeter Meos                                                                *
**                                                                             *
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
pco.SolveLink = 3;
*pco.SolveLink = 2;

Parameter alg_kulud(aasta, kuu);
Parameter alg_kaeve(aasta, kuu);
Scalar loop_index;

alg_kulud(aasta, kuu) =  k_muutuvkulud(aasta,  kuu, "%n_allikas%", "%nk%");
alg_kaeve(aasta, kuu) = max_kaeve(aasta, kuu, "%n_allikas%", "%nk%");

alias(r2, runnid);
h(r2) = 0;

loop(runnid,
  k_muutuvkulud(aasta,  kuu, "%n_allikas%", "%nk%")  = h_run(runnid)*kyttevaartus("%nk%", "%n_allikas%");
  max_kaeve(aasta, kuu, "%n_allikas%", "%nk%")  = 120000000000;

  loop_index = 5;
  while(loop_index > 3,
    loop_index = 0;
    display$sleep(card(h) * 1) 'sleep some time';
    loop(r2,
      if(handlestatus(h(r2)) = 1, loop_index = loop_index + 1);
    );
  );

  Solve pco maximizing kasum using mip;
  h(runnid) = pco.handle;
);

Repeat
  loop(runnid,
    if(handlestatus(h(runnid)) = 2,
      pco.handle = h(runnid);
      execute_loadhandle pco;

      $$libinclude pco_jareltootlus2

      t_run.l(runnid, aasta, kuu, "hind")$(sum((opt_paev), 1$paev_kalendriks(opt_paev, aasta, kuu)) > 0)    = h_run(runnid);
      t_run.l(runnid, aasta, kuu, "hange")$(sum((opt_paev), 1$paev_kalendriks(opt_paev, aasta, kuu)) > 0)
                                 = sum((kvartal, t, toode)$(kvartali_kuud(kvartal, kuu)), kytuse_kasutus_kuu.l(aasta, kvartal, kuu, t, toode, "%n_allikas%", "%nk%", "mwh"))
                                  ;
      t_run.l(runnid, aasta, kuu, "sisene")$(sum((opt_paev), 1$paev_kalendriks(opt_paev, aasta, kuu)) > 0)
                                 = sum((kvartal, t, toode, k, primaarenergia)$(kvartali_kuud(kvartal, kuu)), kytuse_kasutus_kuu.l(aasta, kvartal, kuu, t, toode, k, primaarenergia, "mwh"))
                                 - t_run.l(runnid, aasta, kuu, "hange");
      t_run.l(runnid, aasta, kuu, "kasum")$(sum((opt_paev), 1$paev_kalendriks(opt_paev, aasta, kuu)) > 0)
                                 = kasum.l;
      t_kytus.l(runnid, aasta, kuu, t_el, k, primaarenergia)$(sum((opt_paev), 1$paev_kalendriks(opt_paev, aasta, kuu)) > 0)
                                 = sum((kvartal, t, toode)$(kvartali_kuud(kvartal, kuu)), kytuse_kasutus_kuu.l(aasta, kvartal, kuu, t, toode, "%n_allikas%", "%nk%", "mwh"))
                                 ;
     display$handledelete(h(runnid)) 'trouble deleting handles' ;
     h(runnid) = 0
    )
  );
  display$sleep(card(h) * 0.2) 'sleep some time';
until card(h) = 0 or timeelapsed > 7200;

k_muutuvkulud(aasta,  kuu, "%n_allikas%", "%nk%") = alg_kulud(aasta, kuu);
max_kaeve(aasta, kuu, "%n_allikas%", "%nk%") = alg_kaeve(aasta, kuu);

pco.SolveLink = 0;

execute_unload '%n_allikas% %nk% noudluskover.gdx', t_run, t_kytus;