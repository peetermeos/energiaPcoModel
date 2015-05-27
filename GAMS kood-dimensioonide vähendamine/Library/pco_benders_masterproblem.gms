********************************************************************************
** Master problem definition for Bender's decomposition                        *
** Equations contain non-stochastic elements (ie. mining)                      *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

Model masterproblem
     /masterobj,
      v_open_pit_combo,
      v_k_fs_mined, v_k_compulsory_kkt, v_k_min_acquisition,
      v_tailings_sum, v_sieve_sum, v_concentrate_sum,
      v_enrichment1, v_enrichment2,
      v_perm_mining2
      v_sales, v_sales_m,
$ifthen.two "%fc%" == "true"
*     v_k_closure, v_k_closure_mining,
*     v_fc_load,
*      v_fc_maintenance,
*      v_fc_startup,
*      v_fc_overtime
$endif.two
      v_reserved_fuel,
      optcut
     /;
