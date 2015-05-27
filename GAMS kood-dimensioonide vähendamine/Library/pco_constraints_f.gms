********************************************************************************
**                                                                             *
** Constraints describing the effect of fixed costs                            *
**                                                                             *
** Taaniel Uleksin                                                             *
********************************************************************************

Equations
   v_fc_load(year, month, t_el)   "Can produce only in operational production unit"
*   v_fc_maintenance(year, month, t_el) "Maintenance costs depend on operational status in preceding and following months"
*   v_fc_startup(year, month, t_el)     "Unit startup costs bringing it back from conserved status"
*   v_fc_overtime(year, month, jaam)    "Maintenance teams working overtime"
;

*ot_teams.lo(year, month, plant) = 0;
*ot_teams.up(year, month, plant) = 12;

********************************************************************************
**                                                                             *
** Unit can produce only if operational                                        *
**                                                                             *
** Taaniel Uleksin                                                             *
********************************************************************************
v_fc_load(year, month, t_el)..
   sum((time_t, slot)$(time_t_s(time_t) and y_m_t), load_el(time_t, slot, t_el))
   =l=
$ifthen.b not "%numsim%" == "1"
   p_work.l(year, month, t_el) * M * 100
$else.b
   p_work(year, month, t_el) * M * 100
$endif.b
;

********************************************************************************
**                                                                             *
** Maintenance overhaul depends whether unit has been operation or will be     *
** operational                                                                 *
**                                                                             *
** Taaniel Uleksin                                                             *
********************************************************************************
$ontext
v_fc_maintenance(year, month, t_el)..
   maint_cost(year, month, t_el)
   =g=
*p(t-1)
   p_work(year, month-1, t_el)$(ord(month) le %end_month%
                           and (ord(year) + year_1 - 1 eq %end_year%))
   +
   p_work(year, month-1, t_el)$(ord(month) > 1
                           and (ord(year) + year_1 - 1 < %end_year%))
   +
   p_work(year-1, "12", t_el)$(ord(month) eq 1
                          and (ord(year) + year_1 - 1 le %end_year%))
*p(t+1)
   +
   p_work(year, month+1, t_el)$(ord(month) ge %beg_month%
                           and (ord(year) + year_1 - 1 eq %beg_year%))
   +
   p_work(year, month+1, t_el)$(ord(month) < card(month)
                           and (ord(year) + year_1 - 1 > %beg_year%))
   +
   p_work(year+1, "1", t_el)$(ord(month) eq card(month)
                         and (ord(year) + year_1 - 1 ge %beg_year%))
*p(t)
   -
   2* p_work(year, month, t_el)
;

********************************************************************************
**                                                                             *
** Fixed startup costs when taking unit out of conserved status                *
**                                                                             *
** Taaniel Uleksin                                                             *
********************************************************************************
v_fc_startup(year, month, t_el)..
   st_cost(year, month, t_el)
   =g=
   p_work(year, month, t_el)
   -
   p_work(year, month-1, t_el)$(ord(month) > 1)
;

********************************************************************************
**                                                                             *
** Overtime working teams get overtime pay                                     *
**                                                                             *
** Taaniel Uleksin                                                             *
********************************************************************************
v_fc_overtime(year, month, plant)..
   ot_teams(year, month, plant)
   =l=
   ot_coef(year, month)*sum(t_el$t_plant(plant, t_el), p_work(year, month, t_el))
;
$offtext
