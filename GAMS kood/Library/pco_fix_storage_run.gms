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
fix_switch = 1;

* And now solve the model
$libinclude pco_deterministic_fix
$show

Parameter fix_storage_add(storage, k, feedstock);

$GDXin _gams_net_gdb0.gdx
$load fix_storage_add=fix_ladu
$GDXin

*fix_storage_add("EEJ_M", "Estonia", "Energeetiline") = 5000;

* Fix storage levels
storage_t.up(time_t, s_t, k, feedstock)$(ord(time_t)= %fix_date% + 1) = round(last_day_storage.l(s_t, k, feedstock)) + fix_storage_add(s_t, k, feedstock);
storage_k.up(time_t, s_k, k, feedstock)$(ord(time_t)= %fix_date% + 1) = round(last_day_storage.l(s_k, k, feedstock)) + fix_storage_add(s_k, k, feedstock);
*storage_to_production.fx(time_t, s_t, t, k, feedstock)$(ord(time_t) = card(time_t_s)) = storage_to_production.l(time_t, s_t, t, k, feedstock);

*storage_t.fx("%fix_date%", s_t, k, feedstock) = round(storage_t.l("%fix_date%", s_t, k, feedstock));
*storage_k.fx("%fix_date%", s_k, k, feedstock) = round(storage_k.l("%fix_date%", s_k, k, feedstock));

* Time settings for the second run
*time_t_s(time_t) = yes;

*time_t_s(time_t) = no;
*time_t_s(time_t)$(ord(time_t) > %fix_date%) = yes;
time_t_s(time_t) = yes;
*fix_switch = 0;

