********************************************************************************
**                                                                             *
** Definition of Bender's decomposition's subproblem's objective function      *
**                                                                             *
**  Peeter Meos                                                                *
********************************************************************************

Free variable  zsub  "Objective variable of subproblem";
Equations    subobj  "Subproblem objective function";

subobj..
   zsub =e= -sum((sim, time_t),
                                         $$libinclude pco_obj_power
                                         $$libinclude pco_obj_emissions
                                         $$libinclude pco_obj_supply
                                         $$libinclude pco_obj_acquisitions
                                         $$libinclude pco_obj_penalty
*        $$if "%sc%"            == "true" $libinclude pco_obj_startup
                                         $$libinclude pco_obj_startup
         $$if "%ht%"            == "true" $libinclude pco_obj_heat
         $$if "%oil%"           == "true" $libinclude pco_obj_oil
         $$if "%storage%"       == "true" $libinclude pco_obj_storage
         $$if "%logistics%"     == "true" $libinclude pco_obj_logistics
         $$if "%prc%"           == "true" $libinclude pco_obj_contracts
                ) / %numsim%
$ifthen.h "%hedge%" == "true"
         -(0
         $$libinclude pco_obj_hedge
         )
$endif.h
$ifthen.h "%fc%" == "true"
        -(0
        $$libinclude pco_obj_fixcosts
        )
$endif.h
;
