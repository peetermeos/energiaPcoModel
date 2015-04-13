********************************************************
* Operatiivne tootmise planeerimise mudel              *
* Rakendatakse peale seda, kui turud on realiseerunud  *
* Ajahorisont: 1 p�ev                                  *
* Allan Puusepp                                        *
********************************************************

Sets
  toode "Toode, mida kontsern toodab"
  /
  elekter       "Elekter"
  oli           "�li"
  /
;

$ifthen %MT% == "OP"
Sets
  t_toode(t, toode) "Tootmisjaamade toodetavad tooted"
;

$load t_toode

*Scalars
*min_kaigusolek "Minimaalne tootmisjaama k�igusoleku aeg kahe peatamise vahel [slott]" /20/
*min_maasolek "Minimaalne tootmisjaama maasoleku aeg kahe peatamise vahel [slott]" /20/

Parameter
  turu_kogus_el(opt_tund) "Elektriturul (NordPool) realiseerunud aggregeeritud elektrienergia kogus [MWh]"
  tootmisjaamade_hetkevoimsus_el(t_el) "Tootmisjaamade hetkelised v�imsused enne optimeerimise algust [MWh]"
*Hetkel eeldatakse, et tootmisjaamade v�imsuse �les- ja allakoormamise maksimaalsed m��rad on s�mmeetrilised s.t. v�rdsed ning aditiivsed
  delta_el(t_el) "Tootmisjaamade koormuse muutumise maksimaalne m��r"
;

$loaddc tootmisjaamade_hetkevoimsus_el turu_kogus_el delta_el
$endif
