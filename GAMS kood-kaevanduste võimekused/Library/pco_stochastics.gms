********************************************************************************
**  General stochastics setup                                                  *
**                                                                             *
**  Peeter Meos                                                                *
********************************************************************************

Parameter
  bender
  modified_bender
;

* We use this 0/1 parameter to switch of slack variables in
* equality constraints. This allows to solve relaxed versions
* of Bender's subproblems to get away with first (otherwise infeasible)
* iteration.

modified_bender = 0;

$if     "%two_stage%" == "true" bender = 1
$if not "%two_stage%" == "true" bender = 0

$evalglobal numstep_b    min(10, %numsim%)
*$setglobal  numstep_b                   20
$setglobal   max_cpu                     10


$ifthen.s  not "%numsim%" == "1"
  Set sim /1 * %numsim%/;
  Parameter shift(sim)  "Random value shift";

$elseif.s  set nk
  $$eval n_price_points ((%n_price_2% - %n_price_1%) / %n_price_step%) + 1
  Set sim /1 * %n_price_points%/;
  $$drop n_price_points

$elseif.s  set nkl
  $$eval n_price_points ((%n_price_2% - %n_price_1%) / %n_price_step%) + 1
  Set sim /1 * %n_price_points%/;
  $$drop n_price_points

$elseif.s  set pk
  $$eval n_price_points ((%n_price_2% - %n_price_1%) / %n_price_step%) + 1
  Set sim /1 * %n_price_points%/;
  $$drop n_price_points

$elseif.s  set hm
  Set sim /1 * 450/;

$elseif.s  set hm_vkg
  Set sim /1 * 900/;
$else.s

  Set sim /1/;
$endif.s


