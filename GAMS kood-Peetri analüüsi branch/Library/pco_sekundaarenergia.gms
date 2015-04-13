
Parameter
  elektri_referents(aasta, kuu, opt_paev_max, opt_tund) "Elektri referentshind (EUR/MWh)"
  co2_referents(aasta )                                 "CO2 referentshind (EUR/t)"
  oli_referents(aasta, kuu)                             "Põlevkiviõli referentshind (EUR/t)"
  soojuse_referents(aasta, kuu)                         "Soojuse referentshind (EUR/MWh)"
  myygileping(aasta, kuu, t_mk, k, primaarenergia)      "Primaarenergia müügilepingu mahud (t/kuus)"
  soojatarne(aasta, kuu)                                "Soojatarne MWh neto kuus"
  sisemine_soojatarne(aasta, kuu)                       "Kontserni sisene soojatarne MWh neto kuus"
  min_marginaal(t_el)                                   "Minimaalne müügimarginaal (EUR/MWh)"
  reserved_fuel(aasta, kuu, k, primaarenergia, l)       "Fuel not used in production but reserver for other uses (t)"
;
$loaddc elektri_referents co2_referents oli_referents
$loaddc soojuse_referents myygileping soojatarne sisemine_soojatarne
$loaddc min_marginaal
$loaddc reserved_fuel

Set t_aur(t_el) "Auru plokid Eesti Elektrijaamas";
$loaddc t_aur
