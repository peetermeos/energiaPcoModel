********************************************************************************
**                                                                             *
**  See tükk koodi teeb avariilisuste ja hindade stohhastikat                  *
**  14. mai 2014                                                               *
**                                                                             *
**  Peeter Meos                                                                *
********************************************************************************

$GDXin _gams_net_gdb0.gdx
Set ajal_aasta, ajal_paev;
$load ajal_aasta ajal_paev

Parameter ajal_elekter(ajal_aasta, kuu, ajal_paev, opt_tund);
$load ajal_elekter
$GDXin

Set run       /1*1/;
Set av_para   /mtbf, mttr/

Parameter keskmine_ref(aasta), keskmine_ajal(ajal_aasta);

Parameter
  el(run, aasta, kuu, opt_paev_max, opt_tund)
  temp_aasta(kuu, ajal_paev, opt_tund)
  co(aasta, kuu)
  av(run, opt_paev, t_el)
  pe_marg(k, primaarenergia)
  pe_sum(t_el)
  pe_kasutus(k, primaarenergia, t_el)
  orig_kaeve(aasta, kuu, k, primaarenergia)
  h(run) model handles;
;

Scalar random_aasta, keskmine;

execseed = 1+gmillisec(jnow);

keskmine_ref(aasta) = sum((kuu, opt_paev, opt_tund)$tee_paevaks, elektri_referents(aasta, kuu, opt_paev, opt_tund))
                    / (sum((kuu, opt_paev, opt_tund)$tee_paevaks, 1)+1);

loop((run, aasta),
    random_aasta = round(uniform(1, card(ajal_aasta)));

    keskmine  = sum(ajal_aasta$(ord(ajal_aasta) = random_aasta),
                       sum((kuu, ajal_paev, opt_tund), ajal_elekter(ajal_aasta, kuu, ajal_paev, opt_tund))
                     / sum((kuu, ajal_paev, opt_tund), 1)
                   );

* Nüüd on aasta valitud, see tuleb elektri_referentsis ära asendada
    temp_aasta(kuu, ajal_paev, opt_tund) = sum(ajal_aasta$(ord(ajal_aasta) = random_aasta),
                                                   ajal_elekter(ajal_aasta, kuu, ajal_paev, opt_tund));

    loop((opt_paev, kuu, ajal_paev)$(
                 ord(ajal_paev) = gday(jdate(%aasta_1%, 1, 1) - 1 + ord(opt_paev))
                 and tee_paevaks
                 ),
         el(run, aasta, kuu, opt_paev, opt_tund) = temp_aasta(kuu, ajal_paev, opt_tund) + keskmine_ref(aasta) - keskmine
        );
    );

Table
 av_tabel(t_el, av_para)  "MTBF ja MTTR ajad plokkidele tundides"
               mtbf      mttr
EEJ1         210.73     35.88
EEJ2         210.73     39.98
EEJ3         311.48     56.31
EEJ4         311.48     63.34
EEJ5         311.48     40.07
EEJ6         311.48     53.96
EEJ7         210.73     35.53
EEJ8         334.86     17.74
BEJ9          61.83     55.33
BEJ10         61.83     55.33
BEJ11        334.86     16.72
BEJ12         61.83     67.26
AUVERE1      334.86      4.58
ENE1         334.86      4.58
ENE2         334.86      4.58
ENE3         334.86      4.58
Katlamaja      1E30      1E-6
;

Positive variable
  tulemused_marg(run, opt_paev, k, primaarenergia)
  tulemused_koorm(run, aasta, kuu, t_el)
  tulemused_mkas(run, aasta, kuu, t_el)
  tulemused_kaeve_mwh(run, aasta, kuu, k, primaarenergia)
  tulemused_kytuse_kasutus_mwh(run, aasta, kuu, t, k, primaarenergia)
;



Scalar loop_index;
Scalar max_run /7/;
Scalar status /0/;
Scalar amount /0/;
Scalar next_event /0/;
Scalar u /0/;
Scalar corr /0.8/;

alias(r2, run);
h(r2) = 0;

co(aasta, kuu) = co2_referents(aasta, kuu);

pco.solvelink = 3;

* Arvutame avariilisuste stsenaariumid
loop((run, t_el),
  next_event = -av_tabel(t_el, "mtbf") * log(uniform(0,1))/24;
  loop(opt_paev,
      av(run, opt_paev, t_el) = amount;
      if((ord(opt_paev) > round(next_event) and t_remondigraafik(opt_paev, t_el) = 0),
* Uus sündmus
         if(status = 0,
            status = 1;
            u = uniform(0, 1);
            if(u > 2/3, amount = 1);
            if(u <= 2/3, amount = 0.5);
            next_event = next_event - av_tabel(t_el, "mttr") * log(uniform(0,1))/24;
         else
            status = 0;
            amount = 0;
            next_event = next_event - av_tabel(t_el, "mtbf") * log(uniform(0,1))/24;
         );
      );
   );
);


* Lülitame standardse avariilisuse välja
avariilisus(t_el, aasta)$(not sameas(t_el, "BEJ11") and not sameas(t_el, "Katlamaja")) = 0;

loop(run,
  loop_index = max_run + 1;
  while(loop_index > max_run,
    loop_index = 0;
    display$sleep(10) 'sleep some time';
    loop_index = sum(r2$(handlestatus(h(r2)) = 1),1);
    );

  elektri_referents(aasta, kuu, opt_paev, opt_tund) = el(run, aasta, kuu, opt_paev, opt_tund);
  av_p(opt_paev, t_el) = av(run, opt_paev, t_el);

  Solve pco maximizing kasum using mip;
  h(run) = pco.handle;
);

Repeat
  loop(run,
    if(handlestatus(h(run)) = 2,
      pco.handle = h(run);
      execute_loadhandle pco;
  $$libinclude pco_jareltootlus2

* Arvutame marginaalid primaarenergia mitte massi kohta, jagame kütteväärtusega läbi
           tulemused_marg.l(run, opt_paev, k, primaarenergia)$(kyttevaartus(primaarenergia, k) > 0)
                 = v_k_paevane_kaeve.m(opt_paev, k, primaarenergia) / kyttevaartus(primaarenergia, k);

           tulemused_koorm.l(run, aasta, kuu, t_el) = ploki_koorm_ku.l(aasta, kuu, t_el);
           tulemused_kaeve_mwh.l(run, aasta, kuu, k, primaarenergia)= kaeve_kuus.l(aasta, kuu, k, primaarenergia, "mwh");
           tulemused_mkas.l(run, aasta, kuu, t_el)= t_mkas_kuu.l(aasta, kuu, t_el);
           tulemused_kytuse_kasutus_mwh.l(run, aasta, kuu, t, k, primaarenergia)
                                        = kytuse_kasutus_kuus_koik.l(aasta, kuu,  t, k, primaarenergia, "mwh");

     display$handledelete(h(run)) 'trouble deleting handles' ;
     h(run) = 0
    );
  );
  display$sleep(card(h) * 0.2) 'sleep some time';
until card(h) = 0 or timeelapsed > 7200;

