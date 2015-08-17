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




