Sets
*  tooraine "Mudelis kasutatavad toorained"
  k "Primaarenergia allikad"
;

$loaddc k
alias(k, k2);

Sets
 k_eek(k) "Eesti Energia kaevandused"
 /
 Estonia
 Narva1
 Narva2
 /
;


Sets
  primaarenergia "Tootmises kasutatav primaarenergia"
;
$loaddc primaarenergia
alias(primaarenergia, p2);

Sets
  k_kaeve(k, primaarenergia)    "Mida kaevandus tegelikult kaevandab"
  primaar_k(k, primaarenergia)  "Tootmiseks kasutatava primaarenergia allikad"

  polevkivi(primaarenergia)     "Põlevkivi sordid"
  /
  Energeetiline
  Madal
  Kaevis
  Labindus
  /

  gaas(primaarenergia)          "Gases"
;
$loaddc primaar_k k_kaeve gaas

Parameter
  max_kaeve(aasta, kuu, k, primaarenergia)        "Mäemassi kaevevõimekused kuude ja kaevanduste lõikes (MWh/päevas)"
  k_muutuvkulud(aasta, kuu, k, primaarenergia)    "Variable costs of mining (EUR/t) or (EUR/m3)"
  rikastuskoefitsent(primaarenergia, k, p2)       "Proportsionaalselt kui palju me kaevisest toodet teha suudame (%)"
  kyttevaartus(primaarenergia, k)                 "Kütuste kütteväärtused (MJ/kg)"
  prim_min_tarne(aasta, kuu, k, primaarenergia)
  lubatud_kaeve(aasta, kuu, k, primaarenergia)    "Primaarenergia lubatud kaeve kaevanduses"
;
$loaddc max_kaeve k_muutuvkulud rikastuskoefitsent kyttevaartus prim_min_tarne lubatud_kaeve

* Arvutame MJ/kg pealt MWh/t peale
kyttevaartus(primaarenergia, k)$(not gaas(primaarenergia)) = kyttevaartus(primaarenergia, k) / 3.6;
loop((primaarenergia, k)$(sameas(primaarenergia, "Lubi") and sameas(k, "Hange")),
    kyttevaartus(primaarenergia, k) = 0.0000000001;
);

Set
  k_rikastus(k)  "Kaevandused, millel on rikastusvabrik"
;

$loaddc k_rikastus

Parameter
  aher_pct(k)    "Mäemassist tehtava aheraine protsent"
  soel_pct(k)    "Mäemassist tehtava sõelise protsent"
  konts_pct(k)   "Mäemassist tehtava kontsentraadi protsent"
;
$loaddc aher_pct soel_pct konts_pct

Set
  nad_paev       "Nädalapäev 1 - 7 == Esmaspäev kuni Pühapäev"
;
$loaddc nad_paev

Parameter
  k_toopaev(k,nad_paev) "Kas kaevandus töötab antud nädalapäeval (0/1)?"
;
$loaddc k_toopaev

Set k_tootab(opt_paev_max, nad_paev, k);

k_tootab(opt_paev, nad_paev, k)$(gdow(jdate(esimene_aasta, esimene_kuu, 1)
                                       + ord(opt_paev)-1 + %esimene_paev%) eq
                                       ord(nad_paev)$(k_toopaev(k,nad_paev) eq 1))
= yes;

Parameter soelise_kyttevaartus(k) "Sõelise kütteväärtused kaevanduste kaupa";
$loaddc soelise_kyttevaartus

* Arvutame MJ/kg pealt MWh/t peale
soelise_kyttevaartus(k) = soelise_kyttevaartus(k) / 3.6;

Parameter kontsentraadi_hind(aasta) "Kontsentraadi hind";
$loaddc kontsentraadi_hind

* Arvutame kaeve muutuvkulud primaarenergia allikatele, mis ei oma rikastusvabrikut
k_muutuvkulud(aasta, kuu, k, primaarenergia)$(not k_rikastus(k)
                                              and not sameas(k, "Hange")
                                              and primaar_k(k, primaarenergia)
                                              )
  = sum(p2$(k_kaeve(k, p2)
    and rikastuskoefitsent(p2, k, primaarenergia) > 0), k_muutuvkulud(aasta, kuu, k, p2) / rikastuskoefitsent(p2, k, primaarenergia));

* Arvutame kaeve muutuvkulud primaarenergia allikatele, milledel on rikastusvabrik
* arvutus käib energeetilise kivi kaudu (st. ette on antud energeetilise kivi hind)
k_muutuvkulud(aasta, kuu, k, primaarenergia)$(k_rikastus(k)
                                             and primaar_k(k, primaarenergia)
                                             and k_muutuvkulud(aasta, kuu, k, primaarenergia) = 0
                                             and(kyttevaartus("Energeetiline", k) - kyttevaartus("Aheraine", k)) > 0)
  =
  k_muutuvkulud(aasta, kuu, k, "Energeetiline")
   * (1
      -
     (kyttevaartus("Energeetiline", k) - kyttevaartus(primaarenergia, k))
      /
     (kyttevaartus("Energeetiline", k) - kyttevaartus("Aheraine", k))
     );


