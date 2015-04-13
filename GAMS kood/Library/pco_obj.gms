********************************************************************************
**                                                                             *
**  This piece of code describes the main objective function for               *
**  deterministic model configuration. Consists of revenue (sales) and         *
**  variable costs (mining, emissions, logistics etc)                          *
**  Please note that due to Bender's decomposition, stochastic version of      *
**  the objective function is defined separately in two pieces: master problem *
**  and subproblem.                                                            *
**                                                                             *
**  30. dets 2013                                                              *
**  Peeter Meos                                                                *
********************************************************************************

Equations  v_objective_function                    "Overall objective function (EUR)";

v_objective_function..
  total_profit =e= sum(time_t$time_t_s(time_t),
(


$libinclude pco_obj_power
$libinclude pco_obj_emissions
$libinclude pco_obj_supply
$libinclude pco_obj_acquisitions

$if not "%two_stage" == "true" $if not "%num_sim%" == "1" $libinclude pco_obj_penalty

$if "%sc%"            == "true" $libinclude pco_obj_startup
$if "%ht%"            == "true" $libinclude pco_obj_heat
                               $$libinclude pco_obj_sales
$if "%oil%"           == "true" $libinclude pco_obj_oil
$if "%storage%"       == "true" $libinclude pco_obj_storage
$if "%logistics%"     == "true" $libinclude pco_obj_logistics
$if "%prc%"           == "true" $libinclude pco_obj_contracts


$if "%mines%"         == "true" $libinclude pco_obj_mining
$if set nkl                     $libinclude pco_obj_mining_nkl
)
$if "%discounting%"   == "true" $libinclude pco_obj_discounting
)
$if "%hedge%"         == "true" $libinclude pco_obj_hedge
$if "%inventory%"     == "true" $libinclude pco_obj_inventory
$if "%fc%"            == "true" $libinclude pco_obj_fixcosts
;
