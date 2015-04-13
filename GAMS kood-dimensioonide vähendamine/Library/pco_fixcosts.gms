********************************************************************************
**                                                                             *
** Definitions for fixed costs. Not currently used.                            *
**                                                                             *
** Taaniel Uleskin                                                             *
********************************************************************************

$ifthen.two "%fc%" == "true"

Parameter
  fc_ty(t, year)    "Production unit annual fixed costs €/year"
  fc_k(k, year)     "Fixed costs of mining €/year"
  fc_l(year)        "Fixed costs of logistics €/year"
;

*Scalar unit_count /1/;

*Set
*  plant "Set of production plants"
*     /
*      EEJ
*      BEJ
*    /
*;

*Set
*  t_plant(plant, t_el) "Tuple connecting production plant with its production units"
*  /
*  EEJ.(EEJ1*EEJ8)
*  BEJ.(BEJ9*BEJ12)
*  /
*;

*Parameters
*  ot_coef(year, month)                      "Maximal overtime allowed for maintenance team (0% - 100%)"
*  b_toojoukulu(year, month, plant)           "Kuine tööjõukulu brigaadi kohta jaamas (€/kuus)"
*  yletunni_tootasu_koefitsient(year, month) "Millega korrutatakse tööjõukulu kui on ületunnitöö?"
*  sundpuhkuse_koefitsient(year)             "Millega korrutatakse tööjõukulu kui on sundpuhkus?"
*
*  maint_cost(year, month, t_el)             "Kuine ploki hoolduskulu"
*  seisaku_lisahooldus_koefitsient(year)     "Ploki käivitades % hoolduskulust"
*  pl_toos(year, plant)                      "Mitu plokki töös on?"
*;

*ot_coef(year, month)                      = 0.15;
*b_toojoukulu(year, month, plant)           = 32000;
*yletunni_tootasu_koefitsient(year, month) = 1.8;
*sundpuhkuse_koefitsient(year)             = 0.5;
*maint_cost(year, month, t_el)             = 70000;
*seisaku_lisahooldus_koefitsient(year)     = 0.2;

fc_ty(t, year) = 120000;

*units_operational(year, plant) = sum(t_el$t_plant(plant, t_el), 1$(sum(month, max_load_el(t_el, year, month)) > 0));

*$load fc_ty=pysikulud_ty
*$load fc_k=pysikulud_k, fc_l=pysikulud_l
$endif.two
