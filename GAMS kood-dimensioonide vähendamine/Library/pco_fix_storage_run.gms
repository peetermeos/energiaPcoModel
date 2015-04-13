********************************************************************************
** This file contains setup for two stage optimisation.                        *
** First we do a shorter run, fix the storage state and then we are ready      *
** for longer run                                                              *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

********************************************************************************
** If we need to fix a storage level at a given day, then this bit needs to be *
** switched on this is needed for isolating one time period (ie. we need to    *
** retain separately optimised first year.                                     *
********************************************************************************

* Time settings for the first run
time_t_s(time_t) = no;
time_t_s(time_t)$(ord(time_t) le %fix_date%) = yes;

* And now solve the model
$libinclude pco_deterministic_fix
$show
* Fix storage levels
storage_t.fx("%fix_date%", s_t, k, feedstock)$(not sameas(k, "Hange"))
   = storage_t.l("%fix_date%", s_t, k, feedstock);
storage_k.fx("%fix_date%", s_k, k, feedstock)$(not sameas(k, "Hange"))
   = storage_k.l("%fix_date%", s_k, k, feedstock);

* Time settings for the second run
time_t_s(time_t) = yes;

