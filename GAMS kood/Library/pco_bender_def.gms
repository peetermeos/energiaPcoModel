********************************************************************************
**                                                                             *
** This file implements Bender's Decomposition algorithm for PCO               *
** We are using it to separate deterministic equivalent of stochastic          *
** variant of PCO into manageable pieces.                                      *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

********************************************************************************
* Form the Benders master problem                                              *
********************************************************************************

Set
   b_iter          "Max Benders iterations"                 /iter1 * iter50/
   dyniter(b_iter) "Dynamic subset of Benders iterations"
   result                                                   /lower, upper, delta/
;

Parameters
  i_bounds(b_iter, result)                               "Upper and lower bounds for iterations"
  cutconst(b_iter)                                       "Constants in optimality cuts"
  c_mining_dist(b_iter, time_t, feedstock, k)            "Coefficients in optimality cuts"
  c_max_loading(b_iter, time_t, l)                       "Coefficients in optimality cuts"
  c_perm_mining1(b_iter, year, month, k, feedstock)      "Coefficients in optimality cuts"
  c_el_position(b_iter, time_t, slot)                    "Coefficients in optimality cuts"
  c_fc_load(b_iter, year, month, t_el)                   "Coefficients in optimality cuts"
  objsub(sim)                                            "Subobjective value"
;

Scalar
  iteration
  done           /0/
  lowerbound     /-INF/
  upperbound     /INF/
  objmaster
;

Free variables
   zmaster         "Objective variable of master problem"
   theta           "Extra term in master objective function"
;

Equations
   masterobj       "Master problem objective function"
   optcut(b_iter)  "Benders optimality cuts"
;

masterobj..
    zmaster =e=  -(sum(time_t$time_t_s(time_t), 0
                      $$libinclude pco_obj_mining
                      $$libinclude pco_obj_sales
                      )
                   )
                 + theta;

fs_mined.up(time_t, p2, feedstock, k) = 10000000;
fs_mined.up(time_t, p2, feedstock, k)$(sameas(k, "Hange")) = 0;

optcut(dyniter)..  theta =g=
        cutconst(dyniter)
        -
        sum((time_t, k, feedstock, p2)$(time_t_s(time_t) and k_mines(k, p2)),
             c_mining_dist(dyniter, time_t, feedstock, k)
           * fs_mined(time_t, p2, feedstock, k)
           * enrichment_coef(p2, k, feedstock)
           )
         -
         sum((time_t, l)$time_t_s(time_t),
           c_max_loading(dyniter, time_t, l)
           *  sum((route, k, feedstock)$(route_endpoint(route, k, l)
                                           and fs_k(k, feedstock)
                                           and not gas(feedstock)
                                           and sum((year, month)$y_m_t,
                                              reserved_fuel(year, month, k, feedstock, l)) > 0
                                               ),
             daily_res_f(time_t, k, feedstock, l))
           )
         -
         sum((year, month, k, feedstock),
           c_perm_mining1(dyniter, year, month, k, feedstock)
           * feedstock_choice(year, month, k, feedstock) * M * M
           )
$ifthen.c "%hedge%" == "true"
         -
         sum((time_t, slot)$time_t_s(time_t),
           c_el_position(dyniter, time_t, slot)
           * (
              sum((serial, fwd_type, y2, month2)$(el_fwd_price(serial, fwd_type, y2, month2) > 0),
**** Yearly forward must be spread evenly across the year
                  (el_fwd_position(serial, fwd_type, y2, month2)$(sum((year, month)$(y_m_t
                      and sameas(year, y2)), 1))
                   / hours_in_year(y2) * sum(t$(ord(t) = 1), slot_length_orig(time_t, slot, t))
                  )$(sameas(fwd_type, "year"))
                  +
**** Quarterly forward must be spread evenly across the quarter
                 (el_fwd_position(serial, fwd_type, y2, month2)$(sum((year, quarter, month)$(y_m_t
                     and sameas(year, y2) and q_months(quarter, month) and q_months(quarter, month2)), 1))
                   / sum((month, quarter)$(q_months(quarter, month2) and q_months(quarter, month)), hours_in_month(y2, month))
                   * sum(t$(ord(t) = 1), slot_length_orig(time_t, slot, t))
                  )$(sameas(fwd_type, "quarter"))
                  +
**** Monthly forward must be spread evenly across the month
                 (el_fwd_position(serial, fwd_type, y2, month2)$(sum((year, month)$(y_m_t
                     and sameas(year, y2) and sameas(month, month2)), 1))
                   / hours_in_month(y2, month2) * sum(t$(ord(t) = 1), slot_length_orig(time_t, slot, t))
                  )$(sameas(fwd_type, "month"))
                 )
             )
            )
$endif.c

$ifthen.c "%fc%" == "true"
        -
        sum((year, month, t_el),
          c_fc_load(dyniter, year, month, t_el)
          * (p_work(year, month, t_el) * M * 100)
           )
$endif.c
;

$libinclude pco_benders_masterproblem

********************************************************************************
** Form the Benders' subproblem                                                *
** Notice in mining logistics we use the level value kaeve.l, i.e.             *
** this is a constant                                                          *
********************************************************************************
$libinclude pco_benders_subobjective
$libinclude pco_benders_subproblem

********************************************************************************
** Solver options                                                              *
********************************************************************************
$libinclude pco_benders_solver
$libinclude pco_guss_solve



