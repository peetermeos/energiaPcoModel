$setglobal kompileeri
$setglobal UNIX

* L�litame v�lja portsu listinguid ja valime solveriks CPLEXi
option
* Ei tr�ki v�lja optimeerimis�lesande ridasid (piiranguid)
  limrow = 0,
* Ei tr�ki v�lja veerge (sihifunktsiooni)
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
