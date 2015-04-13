$setglobal kompileeri
$setglobal UNIX

* Lülitame välja portsu listinguid ja valime solveriks CPLEXi
option
* Ei trüki välja optimeerimisülesande ridasid (piiranguid)
  limrow = 0,
* Ei trüki välja veerge (sihifunktsiooni)
  limcol = 0,
  solprint = off,
  sysout = off,

* Valime CPLEXi
    mip = cplex
  miqcp = cplex
;

$offlisting
$offsymlist
$offsymxref
$offuellist
$offuelxref
