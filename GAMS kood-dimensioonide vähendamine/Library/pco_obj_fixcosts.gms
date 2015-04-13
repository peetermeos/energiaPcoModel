********************************************************************************
** Fixed costs for mines and production units                                  *
**                                                                             *
** Taaniel Uleksin                                                             *
********************************************************************************

* Tootmisüksused

** Jaama tööjõukulud
*- sum((year, month, plant),
*        (sum(t_el$(t_jaam(plant, t_el)),
*          p_work(year, month, t_el))
*           - yt_brigaadid(year, month, plant))
*         * b_toojoukulu(year, month, plant
*        )
*     )

** Ületunni brigaadid
*- sum((year, month, plant),
*     yt_brigaadid(year, month, plant)
*   * b_toojoukulu(year, month, plant)
*   * yletunni_tootasu_koefitsient(year, month)
*     )

** Sundpuhkus
*- sum((year, month, plant),
*        (pl_toos(year, plant)
*       - yt_brigaadid(year, month, plant)
*       - sum(t_el$t_jaam(plant, t_el),
*                p_work(year, month, t_el))
*             )
*           * sundpuhkuse_koefitsient(year)
*           * b_toojoukulu(year, month, plant)
*     )

** Ploki hoolduskulud
*- sum((year, month, t_el),
*            h_kulu(year, month, t_el)
*          * hoolduskulu(year, t_el)
*          * 0.25
*     )

- sum((year, month, t)$t_el(t),
            p_work(year, month, t)
          * fc_ty(t, year)
     )

** Käivitamine pärast seisakut
*- sum((year, month, t_el),
*            k_kulu(year, month, t_el)
*          * seisaku_lisahooldus_koefitsient(year)
*          * hoolduskulu(year, t_el)
*     )

*- sum((t, year), ty_aktiivne(t, year) * pysikulud_ty(t, year))

*Kaevandused
*- sum((k, year), k_aktiivne(k, year)
*               * pysikulud_k(k, year)
*     )
*
**Logistika
*- sum(year, pysikulud_l(year))
