********************************************************************************
**                                                                             *
** This file implements Bender's Decomposition algorithm for PCO               *
** We are using it to separate deterministic equivalent of stochastic          *
** variant of PCO into manageable pieces.                                      *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

********************************************************************************
** Bender's algorithm                                                          *
********************************************************************************

********************************************************************************
* Step 1: solve master without cuts                                            *
********************************************************************************

display "*****************************************************************",
        "* Master without cuts                                           *",
        "*****************************************************************";

dyniter(b_iter)  = NO;
cutconst(b_iter) = 0;
done = 0;

c_mining_dist(dyniter, time_t, feedstock, k)        = 0;
c_max_loading(dyniter, time_t, l)                   = 0;
c_perm_mining1(dyniter, year, month, k, feedstock)  = 0;
c_el_position(dyniter, time_t, slot)                = 0;
c_fc_load(dyniter, year, month, t_el)               = 0;

theta.fx = 0;
solve masterproblem minimizing zmaster using mip;
display zmaster.l;

********************************************************************************
** Repair bounds                                                               *
********************************************************************************

theta.lo = -INF;
theta.up = INF;

objmaster = zmaster.l;

Parameter
 p_work_temp(b_iter, year, month, t_el)
* el_fwd_position_temp(b_iter, serial, fwd_type, year, month)
;

loop(b_iter$(not done),

   iteration = ord(b_iter);
   display "*****************************************************************",
           iteration,
           "*****************************************************************";

********************************************************************************
** Step 2: Solve subproblems                                                   *
********************************************************************************
   dyniter(b_iter) = yes;

$if "%fc%" == "true"    p_work_temp(b_iter, year, month, t_el) = p_work.l(year, month, t_el);
*$if "%hedge%" == "true" el_fwd_position_temp(b_iter, serial, fwd_type, year, month) = el_fwd_position.l(serial, fwd_type, year, month);

       if(ord(b_iter) < 3,
          solve subproblem minimizing zsub using rmip scenario dict;
       else
          solve subproblem minimizing zsub using mip scenario dict;
       );
       display oil_l;

$libinclude pco_bender_cutconst

* Check infeasibilities and solve alternative model
        display subproblem.modelstat;
        if((sum(sim$(r_s(sim, "ModelStat") = 10), 1) > 0 or  sum(sim$(r_s(sim, "ModelStat") = 4), 1) > 0) ,
           display 'Infeasibility, going for plan B';
           display subproblem.modelstat;
           modified_bender = 1;
           solve subproblem minimizing zsub using rmip scenario dict;
           modified_bender = 0;
        );

        objsub(sim) = r_s(sim, "objval");

        $$libinclude pco_bender_cutconst

        c_mining_dist(b_iter, time_t, feedstock, k) =
            c_mining_dist(b_iter, time_t, feedstock, k)
*            c_mining_dist("iter1", time_t, feedstock, k)
            - sum(sim, 1/%numsim%
              * (v_mining_dist_m(sim, time_t, feedstock, k)))
            ;

        c_max_loading(b_iter, time_t, l) =
            c_max_loading(b_iter, time_t, l)
*            c_max_loading("iter1", time_t, l)
            - sum(sim, 1/%numsim%
              * (v_max_loading_l_m(sim, time_t, l)))
            ;

        c_perm_mining1(b_iter, year, month, k, feedstock) =
            c_perm_mining1(b_iter, year, month, k, feedstock)
*            c_perm_mining1("iter1", year, month, k, feedstock)
            - sum(sim, 1/%numsim%
              * (v_perm_mining1_m(sim, year, month, k, feedstock)))
            ;

$ifthen.c "%hedge%" == "true"
        c_el_position(b_iter, time_t, slot) =
            c_el_position(b_iter, time_t, slot)
*            c_el_position("iter1", time_t, slot)
            - sum(sim, 1/%numsim%
              * (v_el_position_m(sim, time_t, slot)))
            ;
$endif.c

$ifthen.c "%fc%" == "true"
        c_fc_load(b_iter, year, month, t_el) =
            c_fc_load(b_iter, year, month, t_el)
            - sum(sim, 1/%numsim%
              * (v_fc_load_m(sim, year, month, t_el)))
            ;
$endif.c

   upperbound = min(upperbound, objmaster + sum(sim, objsub(sim)) / %numsim% );
********************************************************************************
** Step 3: Convergence test                                                    *
********************************************************************************

   i_bounds(b_iter, "upper") = upperbound;
   i_bounds(b_iter, "lower") = lowerbound;
   i_bounds(b_iter, "delta") = upperbound - lowerbound;

   display lowerbound, upperbound;
   if (ord(b_iter) > 2 and abs(i_bounds(b_iter, "delta") - i_bounds(b_iter-1, "delta"))
                                              < 0.0005 * abs(i_bounds(b_iter, "delta")),
*   if(abs(upperbound - lowerbound) < 0.001 * (1 + abs(lowerbound)),

      display  "Converged";
      done = 1;

   else

********************************************************************************
** Step 4: Solve masterproblem                                                 *
********************************************************************************
      Solve masterproblem minimizing zmaster using mip;
        if((masterproblem.modelstat = 10
         or masterproblem.modelstat = 14
         or masterproblem.modelstat = 9
         or masterproblem.modelstat = 4),
           display 'Infeasibility, going for plan B';
           display masterproblem.modelstat;
           solve subproblem minimizing zsub using rmip;
        );

      lowerbound = zmaster.l;
      objmaster = zmaster.l - theta.l;
      total_profit.l = abs(objmaster + sum(sim, objsub(sim)) / %numsim% );
      display objmaster;
  );
);
