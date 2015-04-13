********************************************************************************
** Value chain optimisation model                                              *
** Time resolution max 1 month to min 1 hour.                                  *
** Eesti Energia, Energiakaubandus, 2013, 2014, 2015                           *
**                                                                             *
** Peeter Meos                                                                 *
** Taaniel Uleksin                                                             *
** Allan Puusepp                                                               *
**                                                                             *
********************************************************************************
$libinclude pco_header
$eolcom //

$title Eesti Energia Production Chain Optimisation Model. ENK 2013, 2014, 2015

********************************************************************************
** For better readability, pretty much everything besides main configuration   *
** is in include files.                                                        *
**                                                                             *
** NB!  For manual configuration to work, please make sure that you have       *
**      following environment variable set in GAMS GUI (at the top)            *
**      --manual=true                                                          *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

**********************************************
** Calendar configuration (DDMMYYY)          *
**********************************************
$if set manual $set beg_date          01012015
$if set manual $set end_date          02012015
**********************************************

********************************************************************************
** General optimisation model logic                                            *
********************************************************************************
$if set manual $set slot                     T   // Resolution                 *
$if set manual $set mkul                 false   // Variable costs calculation *
$if set manual $set prc                  false   // Purchase contracts         *
$if set manual $set numsim                   1   // Number of stoc.realisations*
$if set manual $set two_stage            false   // One or two stages stoch    *
$if set manual $set ys                   false   // General scenaria           *
$if set manual $set hedge                false   // Hedging and fin. markets   *
********************************************************************************

**********************************************
** Include commit number from VCS            *
**********************************************
*$if not set manual $libinclude pco_version
**********************************************

********************************************************************************
** Other configuration that usually does not                                   *
** need to be changed.                                                         *
********************************************************************************
$set MT                 OP      // Model type
$set sc                 true    // Startup costs                               *
$set cleanings          true    // Boiler cleanings calculated                 *
$set ht                 true    // Heat production switched on                 *
$set sales              false   // Oil shale sales switched on                 *
$set logistics          false   // Logistic network switched on                *
$set storage            true    // Storage units allowed                       *
$set mine_storage       true    // Storage at mines allowed                    *
$set prod_storage       true    // Production units' storage allowed           *
$set rg_balance         true    // Retort gas balance enforced                 *
$set rg_division        false   // Retort gas use even across prod. units      *
$set discounting        false   // Future cash flows in present value          *
$set l_k_invoked        false   // Lime and crushed limestone use allowed      *
$set heat_free          false   // Heat delivery requirement not enforced      *
$set el_free            false   // Minimum power production not enforced       *
********************************************************************************

$libinclude pco_stochastics
$libinclude pco_cplex_parameters

$show
$offOrder

$GDXin _gams_net_gdb0.gdx
*$GDXin %in%.gdx
* All that following stuff lies in GAMS subfolder "inclib"
$libinclude pco_constants
$libinclude pco_calendar
$libinclude pco_macros
$libinclude pco_energy_primary
$libinclude pco_production
$libinclude pco_logistics
$libinclude pco_emissions
$libinclude pco_energy_secondary
$libinclude pco_contracts
$libinclude pco_hedge
$libinclude pco_op_planning
$libinclude pco_guss
$GDXin

$libinclude pco_variables

Equations  v_objective_function             "Overall objective function (EUR)";

v_objective_function..
  total_profit =e= sum(time_t$time_t_s(time_t),
(
  -sum((year, month, k, feedstock, t)$y_m_t,
      to_production(time_t, k, feedstock, t) * fs_vc(k, feedstock, year))
  +
$libinclude pco_obj_power
$libinclude pco_obj_emissions
$libinclude pco_obj_supply

$if "%sc%"            == "true" $libinclude pco_obj_startup
$if "%ht%"            == "true" $libinclude pco_obj_heat
)
)
$if "%hedge%"         == "true" $libinclude pco_obj_hedge
;

********************************************************************************
** Objective function has been described, now let's describe the constraints.  *
** Peeter Meos                                                                 *
********************************************************************************

* Production constraints
$libinclude pco_constraints_p

* Emissions constraints
$libinclude pco_constraints_e

* Hedging constraints
$libinclude pco_constraints_h

* Fuel request and delivery constraints (for short term planning model)
$libinclude pco_constraints_op

$libinclude pco_quality_check

********************************************************************************
* Describe the header and structure for post processing (ie. variables),       *
* the calculation may require multiple passes later.                           *
********************************************************************************

$set jareltootlus_m1  true
$libinclude pco_postprocessing
$set jareltootlus_m2  true

********************************************************************************
** All constraints and data have been described,                               *
** model ready to be sent to solver.                                           *
** Peeter Meos                                                                 *
********************************************************************************
$libinclude pco_deterministic

* The model has been solved and is ready for postprocessing
$libinclude pco_postprocessing

* Save the results in case of manual operation
execute_unload 'output.gdx';
