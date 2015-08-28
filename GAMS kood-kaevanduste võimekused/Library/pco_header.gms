********************************************************************************
**                                                                             *
** Generic GAMS settings for the model                                         *
**                                                                             *
**  31. Oct 2014                                                               *
**  Peeter Meos                                                                *
********************************************************************************

* Let's switch off bunch of listings and select CPLEX for solver
option
* Will not print out rows (constraints)
  limrow = 0,
* Will not print out columns (objective function)
  limcol = 0,
  solprint = off,
  sysout = off,

* Select CPLEX
    mip = cplex
   rmip = cplex
  miqcp = cplex
 reslim = 1e8
;

$offsymlist
$offsymxref
$offuellist
$offuelxref
$offinclude
$oneolcom

*option
*  Optcr=0.00
*;
*option dmpsym;



