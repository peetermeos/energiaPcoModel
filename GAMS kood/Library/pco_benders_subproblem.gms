********************************************************************************
**                                                                             *
** Subproblem definition for Bender's decomposition                            *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

model subproblem /subobj,
********************************************************************************
* Mining and primary energy acquisition constraints                            *
********************************************************************************
  v_k_fs_acquired,
  v_mining_dist,
  v_perm_mining1,
  v_aquisition_dist,
$ifthen.c "%prc%" == "true"
  v_fs_purchase,
$endif.c

********************************************************************************
* Emissions constraints                                                        *
********************************************************************************
  v_em_lambda2,
  v_em_lambda5,
  v_so_quota,
$if "%l_k_invoked%" == "true"  v_em_lambda1_k, v_em_lambda1_l,
$if "%l_k_invoked%" == "true"  v_em_lambda4_k, v_em_lambda4_l,
$if "%hr%" == "true"           v_stack_active, v_stack_hours,
$if "%cw%" == "true"           v_cooling_water,

  v_em_var_rep1,
  v_em_var_rep2,
  v_hh_emissions,

********************************************************************************
* Hedging constraints                                                          *
********************************************************************************
  v_co2_cert_usage,
  v_co2_emission,
  v_el_position,

********************************************************************************
* Logistics constraints                                                        *
********************************************************************************
  v_k_storage,
  v_k_storage2,
  v_k_storage3,

  v_t_storage,
  v_t_storage2,
  v_t_storage3,

  v_max_storage_k,
  v_max_storage_t,
  v_min_storage_t,

  v_logistics,

  v_max_throughput,
  v_max_loading_k,
  v_max_loading_l,

********************************************************************************
* Production constraints                                                       *
********************************************************************************
$if "%ht%" == "true"                v_ht_delivery_ext, v_ht_delivery_int,
$if "%l_k_invoked%" == "true"       v_cl_use, v_lime_use,
$if "%oil%" == "true"               v_max_rg,
$if "%rg_division%" == "true"       v_rg_division,
$if "%mx_schedule%" == "true"       v_mx_opt, v_mx_s, v_mx, v_mx2,
$if "%cleanings%" == "true"         v_cleaning1, 
$if not "%cleanings%" == "true"     v_cleaning4,
*$if "%sc%" == "true"                v_unit_status
  v_unit_status

  v_max_load_el,
  v_max_load_pu,
  v_min_load_ht,
  v_min_load_ht_M,

  v_fs_mix,
  v_fs_max_content,
  v_fs_max_content_oil,
  v_min_cv,
  v_delta_up_el,
  v_delta_down_el,

  v_load_el,
  v_lambda,
  v_load_balance,

  v_oil,
  v_max_cap_oil,
  v_oil_el_prod,
  v_min_production_el,

  v_beta,

  v_permitted_use,

  v_unit_commitment,
  v_unit_beta

********************************************************************************
* Fixed costs                                                                  *
********************************************************************************
$ifthen.two "%fc%" == "true"
  v_fc_load
$endif.two

 /;
