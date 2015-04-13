******************************************
**
** Sisendandmete kvaliteedikontroll
**
** Peeter Meos
**
******************************************

* Laoj��gid - kontrollime, kas miinimum laoj��k on perioodi alguses tagatud

loop(laod$(min_laomaht(laod) > 0),
  if(sum((k , primaarenergia), alguse_laoseisud(laod, k, primaarenergia)) < min_laomaht(laod),
    abort "Miinimum laoj��k ei ole perioodi alguses tagatud!"
  );
);

* Kui on ladu fikseeritud, kontrollime, kas annab miinimumi kokku
$ifthen.fix set fix_ladu

loop(laod$(min_laomaht(laod) > 0),
  if(sum((k , primaarenergia), fix_ladu(laod, k, primaarenergia)) < min_laomaht(laod),
    abort "Miinimum laoj��k ei ole vaheperioodi alguses tagatud!"
  );
);


$endif.fix


* K�ttev��rtused, kontrollime kas on null k�ttev��rtusega
* legaalseid k�tuseid

if(sum((k, primaarenergia)$(kyttevaartus(primaarenergia, k) = 0
                        and primaar_k(k, primaarenergia)), 1 ) > 0,
  abort "V�hemalt �he lubatud k�tuse k�ttev��rtus on null!"
);


* Max_koorm_ty peab olema suurem kui max_koorm_el ja max_koorm_sj

*loop(t_el,
*  loop((aasta, kuu),
*    abort$(max_koormus_el(t_el, aasta, kuu) > max_koormus_ty(t_el, aasta, kuu))
*                 "Tootmis�ksuse elektritootmisv�imekus on suurem kui koguv�imekus!";
*  )
*);
