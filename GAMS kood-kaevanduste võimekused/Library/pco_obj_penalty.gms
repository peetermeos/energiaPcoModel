********************************************************************************
** This part of the objective function introduces penalties for violating      *
** euqality constraints. This is needed for avoiding infeasibilities while     *
** solving Bender's decomposition's subproblems.                               *
**                                                                             *
********************************************************************************

  -
  sum(slot, heat_penalty_internal(time_t, slot)) * 1000

  -
  sum(slot, heat_penalty(time_t, slot)) * 100

  -
  el_penalty(time_t) * 10

  -
  sum(t_ol, oil_penalty(time_t, t_ol)) * 1000000

* This mining penalty is written to ensure that all mining capacity
* at Estonia is utilised.
* Peeter Meos, 28.08.2015
  -
  sum((k, feedstock)$(not sameas(k, "Hange")
                      and k_mines(k, feedstock)
                      and k_mines(k, "Kaevis")
                      and (day_type(time_t) = 0
                        or k_workday(k, "6") = 1
                        or k_workday(k, "7") = 1)),
            mining_penalty(time_t, k, feedstock)
       ) * 10

  -
  sum(k$(not sameas(k, "Hange")
                     and k_mines(k, "Kaevis")
                     and (day_type(time_t) = 0
                       or k_workday(k, "6") = 1
                       or k_workday(k, "7") = 1)),
                     cont_penalty(time_t, k) + sieve_penalty(time_t, k)
        ) * 100





