******************************************
**
** Sisendandmete kvaliteedikontroll
**
** Peeter Meos
**
******************************************

* Laojäägid - kontrollime, kas miinimum laojääk on perioodi alguses tagatud

loop(laod$(min_laomaht(laod) > 0),
  if(sum((k , primaarenergia), alguse_laoseisud(laod, k, primaarenergia)) < min_laomaht(laod),
    abort "Miinimum laojääk ei ole perioodi alguses tagatud!"
  );
);

* Kui on ladu fikseeritud, kontrollime, kas annab miinimumi kokku
$ifthen.fix set fix_ladu

loop(laod$(min_laomaht(laod) > 0),
  if(sum((k , primaarenergia), fix_ladu(laod, k, primaarenergia)) < min_laomaht(laod),
    abort "Miinimum laojääk ei ole vaheperioodi alguses tagatud!"
  );
);


$endif.fix


* Kütteväärtused, kontrollime kas on null kütteväärtusega
* legaalseid kütuseid

if(sum((k, primaarenergia)$(kyttevaartus(primaarenergia, k) = 0
                        and primaar_k(k, primaarenergia)), 1 ) > 0,
  abort "Vähemalt ühe lubatud kütuse kütteväärtus on null!"
);


* Max_koorm_ty peab olema suurem kui max_koorm_el ja max_koorm_sj

*loop(t_el,
*  loop((aasta, kuu),
*    abort$(max_koormus_el(t_el, aasta, kuu) > max_koormus_ty(t_el, aasta, kuu))
*                 "Tootmisüksuse elektritootmisvõimekus on suurem kui koguvõimekus!";
*  )
*);
