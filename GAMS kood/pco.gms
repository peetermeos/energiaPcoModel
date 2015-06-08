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
$if set manual $set beg_date          01052015
$if set manual $set end_date          31122015
**********************************************

********************************************************************************
** General optimisation model logic                                            *
********************************************************************************
$if set manual $set slot                    PK   // Resolution                 *
$if set manual $set fc                   false   // Fixed costs                *
*$if set manual $set fix_st            31122015  // Fixed storage at given time*
$if set manual $set hr                   false   // Hour limits for smokestacks*
$if set manual $set cw                   false   // Cooling water constraints  *
$if set manual $set mkul                 false   // Variable costs calculation *
$if set manual $set prc                   true   // Purchase contracts         *
$if set manual $set numsim                   1   // Number of stoc.realisations*
$if set manual $set two_stage            false   // One or two stages stoch    *
$if set manual $set ys                   false   // General scenaria           *
              $$set hedge                false   // Hedging and fin. markets   *
********************************************************************************

**********************************************
** Include commit number from VCS            *
**********************************************
*$if not set manual $libinclude pco_version
**********************************************

*$eval ny gyear(jstart)
*$eval nm gmonth(jstart)
*$eval nd gday(jstart)
*$if not "%scen%" == "true" Singleton set run_desc /DTG%ny%%nm%%nd% "%numsim% realisations with %slot% time resolution without scenarios."/;
*$if     "%scen%" == "true" Singleton set run_desc /DTG%ny%%nm%%nd% "%numsim% realisations with %slot% time resolution with scenarios."/;
*$drop ny
*$drop nm
*$drop nd

********************************************************************************
** Model type                                                                  *
** Operational model requires hourly                                           *
** resolution                                                                  *
**                                                                             *
** Choices: ST or OP                                                           *
********************************************************************************
$if set manual $set MT                      ST

********************************************************************************
* Configuration for marginal profits                                           *
********************************************************************************
$if set manual $set n_max_marg                71  // Time units for marginals  *
$if set manual $set nm_marg              false  // Minimum margins enforced    *
********************************************************************************

********************************************************************************
* Configuration for demand curve calculation                                   *
********************************************************************************
$if set manual $set n_price_1                0  // Min price for demand curve  *
$if set manual $set n_price_2               20  // Max price for demand curve  *
$if set manual $set n_price_step           0.1  // Demand curve step size      *
$if set manual $set n_source            Estonia  // Feedstock source            *
*$if set manual $set nk                Energeetiline  // Feedstock type        *
*$if set manual $set nkl                Energeetiline  // Feedstock type        *
*$if set manual $set pk                Tykikivi  // Feedstock type             *
*$if set manual $set hm
*$if set manual $set hm_vkg                                                    *
********************************************************************************

********************************************************************************
** Other configuration that usually does not                                   *
** need to be changed.                                                         *
********************************************************************************
$set sc                 true    // Startup costs                               *
$set inventory          false   // End of period inventory value               *
$set cleanings          true    // Boiler cleanings calculated                 *
$set oil                true    // Oil production switched on                  *
$set ht                 true    // Heat production switched on                 *
$set sales              true    // Oil shale sales switched on                 *
$set logistics          true    // Logistic network switched on                *
$set storage            true    // Storage units allowed                       *
$set mine_storage       true    // Storage at mines allowed                    *
$set prod_storage       true    // Production units' storage allowed           *
$set mines              true    // Mines and acq. sources switched on          *
$set rg_balance         true    // Retort gas balance enforced                 *
$set rg_division        false   // Retort gas use even across prod. units      *
$set mx_schedule        false   // Maintenance schedule optimisation           *
$set discounting        false   // Future cash flows in present value          *
$set l_k_invoked        false   // Lime and crushed limestone use allowed      *
$set heat_free          false   // Heat delivery requirement not enforced      *
$set kkt_free           false   // External feedstock acq contr not enforced   *
$set el_free            false   // Minimum power production not enforced       *
$set scen               false   // Scenarios?                                  *
********************************************************************************

$libinclude pco_stochastics
$libinclude pco_cplex_parameters

$ifthen.d set nk
$  set sales                                true
$  set heat_free                           false
$  set kkt_free                            false
$  set el_free                             false
$  set max_cpu                                 5
$endif.d

$ifthen.d set nkl
$  set logistics                           false
$  set mines                               false
$  set sales                               false
$  set nk                                "%nkl%"
$  set heat_free                            true
$  set kkt_free                             true
$  set el_free                              true
$  set max_cpu                                 5
$endif.d

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
$libinclude pco_fixcosts
$libinclude pco_op_planning
$libinclude pco_guss

max_ratio(k, "Madal", t) = 0;
max_ratio(k, "Kaevis", t) = 0;

* In case of multiple iterations, add stochastic elements to the model
$if not "%numsim%" == "1"                        $libinclude pco_stochastics_processes
$if not "%numsim%" == "1" $if "%scen%" == "true" $libinclude pco_stochastics_scenaria
$GDXin

$libinclude pco_variables

$if set nkl $libinclude pco_demand_curve_var_reset
$if not "%two_stage%" == "true" $libinclude pco_obj

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

* Primary energy mining and acquisition constraints (underground and open pit mines)
$if "%mines%" == "true"     $if not set nkl $libinclude pco_constraints_s

* Logistics and storage constraints
$if "%logistics%" == "true" $if not set nkl $libinclude pco_constraints_l

* Fixed cost constraints
$if "%fc%" == "true"           $libinclude pco_constraints_f

* Fuel request and delivery constraints (for short term planning model)
$if "%MT%" == "OP"             $libinclude pco_constraints_op

$libinclude pco_quality_check

********************************************************************************
* Describe the header and structure for post processing (ie. variables),       *
* the calculation may require multiple passes later.                           *
********************************************************************************

$set jareltootlus_m1  true
$libinclude pco_postprocessing
$set jareltootlus_m2  true

********************************************************************************
** For two stage optimisation we need to solve first period, then fix storage  *
** and do the longer run.                                                      *
********************************************************************************
$if set fix_st $if not "%two_stage%" == "true" $libinclude pco_fix_storage_run

********************************************************************************
** All constraints and data have been described,                               *
** model ready to be sent to solver.                                           *
** Peeter Meos                                                                 *
********************************************************************************
$if not set nk $if not set hm $if not set hm_vkg $if not "%two_stage%" == "true"  $libinclude pco_deterministic
*$if not set nk $if     "%two_stage%" == "true"  $libinclude pco_bender_def
*$if not set nk $if     "%two_stage%" == "true"  $libinclude pco_bender

* On top the of the regular production planning, do we want minimum margins for
* sales and demand curves
$if set nk  $if not set nkl                     $libinclude pco_demand_curve
$if set nkl                                     $libinclude pco_demand_curve_long
$if set pk                                      $libinclude pco_supply_curve
$if set max_marg                                $libinclude pco_marginals
$if set hm                                      $libinclude pco_supply_heatmap
$if set hm_vkg                                  $libinclude pco_supply_heatmap_vkg

* The model has been solved and is ready for postprocessing
$if not set nk $if not set pk $if not set hm $if not set hm_vkg $libinclude pco_postprocessing

* Save the results in case of manual operation
*execute_unload '%out%.gdx';

$if set manual $if not set nk $if not set nkl execute_unload 'output.gdx';
$if set manual $if     set nk  execute_unload '%n_source% %nk% %beg_year% %end_year% noudluskover.gdx';
$if set manual $if     set nkl execute_unload '%n_source% %nk% %beg_year% %end_year% noudluskover.gdx';
