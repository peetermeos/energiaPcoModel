********************************************************************************
**                                                                             *
** See fail sisaldab mudeli loetavamaks tegemiseks makrosid                    *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

$macro tee_paevaks paev_kalendriks(opt_paev, aasta, kuu)

$macro day day_cal(opt_paev, paev)

$macro paevi_kuus_l(aasta, kuu) (paevi_kuus(kuu) + liigaasta(aasta)$sameas(kuu, "2"))

$ifthen.three "%uus_logistika%" == "false"
$macro tootmisse(opt_paev, k, primaarenergia, t)                               \
  (sum(l_t$(tootmine_ja_laod(l_t, t)                                           \
       and (max_osakaal(k, primaarenergia, t) > 0)                             \
       and primaar_k(k, primaarenergia) ) ,                                    \
      laost_tootmisse(opt_paev, l_t, t, k, primaarenergia)                     \
      )                                                                        \
  +                                                                            \
  sum((l, liinid)                                                              \
      $(liini_otsad(liinid, k, l)                                              \
       and (max_osakaal(k, primaarenergia, t)>0)                               \
       and primaar_k(k, primaarenergia)                                        \
       and t_jp_tootmine(l, t)),                                               \
      liinilt_tootmisse(opt_paev, liinid, t, primaarenergia)                   \
      ))
$endif.three

$macro kaevandusest(k, primaarenergia)                                         \
   (sum((l_k)$(kaevandused_ja_laod(k, l_k)                                     \
         and primaar_k(k, primaarenergia)                                      \
         and not ladustamatu_primaarenergia(k, primaarenergia, l_k)),          \
         kaevandusest_lattu(opt_paev, l_k, k, primaarenergia))                 \
   +                                                                           \
   sum((liinid, l)                                                             \
      $(liini_otsad(liinid, k, l) and primaar_k(k, primaarenergia)             \
     ),                                                                        \
          kaevandusest_liinile(opt_paev, liinid, primaarenergia)))

********************************************************************************
*                                                                              *
* KASUTEGURITE ARVUTUS                                                         *
*                                                                              *
********************************************************************************

$macro parim_kasutegur(t_el)                                                    \
                              sum(para_lk$(ord(para_lk) = card(para_lk)),       \
                             kasutegur(t_el, para_lk, "b"))

$macro realiseerunud_kasutegur(opt_paev, slott, t_el)                           \
        (                                                                       \
        (sum(para_lk$(ord(para_lk) < card(para_lk)), lambda_p(opt_paev, slott, t_el, para_lk)\
            * (valjund(t_el, para_lk+1, "a") - valjund(t_el, para_lk, "a")))    \
        /                                                                       \
                                                                               \
        sum(para_lk$(ord(para_lk) < card(para_lk)), lambda_p(opt_paev, slott, t_el, para_lk)\
            * (valjund(t_el, para_lk+1, "b") - valjund(t_el, para_lk, "b"))))$  \
   (sum(para_lk$(ord(para_lk) < card(para_lk)), lambda_p(opt_paev, slott, t_el, para_lk)    \
       * (valjund(t_el, para_lk+1, "b") - valjund(t_el, para_lk, "b"))) > 0)    \
   +                                                                            \
   1$                                                                           \
   (sum(para_lk$(ord(para_lk) < card(para_lk)), lambda_p(opt_paev, slott, t_el, para_lk)    \
       * (valjund(t_el, para_lk+1, "b") - valjund(t_el, para_lk, "b"))) = 0)    \
   )

$macro kasutegur_paevas(opt_paev, t_el)                                         \
     sum(slott, realiseerunud_kasutegur(opt_paev, slott, t_el)                  \
              * sloti_pikkus(slott)) / 24

$macro kasutegur_kuus(aasta, kuu, t_el)                                         \
     (sum(opt_paev$(tee_paevaks and kasutegur_paevas(opt_paev, t_el) > 0),      \
         kasutegur_paevas(opt_paev, t_el))                                      \
     /sum(opt_paev$(tee_paevaks and kasutegur_paevas(opt_paev, t_el) > 0), 1))$ \
     (sum(opt_paev$(tee_paevaks and kasutegur_paevas(opt_paev, t_el) > 0), 1) > 0)

$macro kasutegur_aastas(aasta, t_el)                                            \
     (sum(kuu$(kasutegur_kuus(aasta, kuu, t_el) > 0),                           \
               kasutegur_kuus(aasta, kuu, t_el))                                \
     /sum(kuu$(kasutegur_kuus(aasta, kuu, t_el) > 0), 1))$(sum(kuu$(kasutegur_kuus(aasta, kuu, t_el) > 0), 1) > 0)


* Korrigeerime kütteväärtusega, selleks hetkeks on kütteväärtuste ühikuks MWh/t
* Väidetavalt alanevad plokkide kasutegurid koos madalama kütteväärtusega kivi kasutamisega
* Seega parandame siin sissemineva primaarenergia hulka vastavalt
* ehk siis katla kasutegur vastandina turbiini omale

$macro katla_kt(t_el, k, primaarenergia)                                        \
*                1-(8.4 - kyttevaartus(primaarenergia, k) * 3.6) * kv_kt(t_el)
                 1

* Kateldest väljuv soojushulk
$macro q_out(opt_paev, slott, t_el)                                             \
          sum((k, primaarenergia)$(max_osakaal(k, primaarenergia, t_el) > 0),   \
               q(opt_paev, slott, k, primaarenergia, t_el))
*            * (1 - (8.4 - kyttevaartus(primaarenergia, k) * 3.6) * kv_kt(t_el)))

* Turbiini sisenev soojushulk
$macro q_in(opt_paev, slott, t_el)                                             \
         sum(para_lk$(ord(para_lk) < card(para_lk)), lambda_p(opt_paev, slott, t_el, para_lk)\
         * (valjund(t_el, para_lk+1, "b") - valjund(t_el, para_lk, "b")))

* Arvutab tootmisüksusest väljuvat energiat (st. turbiinist väljuvat)
$macro s_brutovoimsus_el(opt_paev, slott, t_el)                                  \
         sum(para_lk$(ord(para_lk) < card(para_lk)), lambda_p(opt_paev, slott, t_el, para_lk)\
         * (valjund(t_el, para_lk+1, "a") - valjund(t_el, para_lk, "a")))

$macro el_osakaal(opt_paev, slott, t_el) (q_in(opt_paev, slott, t_el) / q_out(opt_paev, slott, t_el))$(q_out(opt_paev, slott, t_el) > 0)
********************************************************************************
*                                                                              *
* ERIHEITMETE ARVUTUS                                                          *
*                                                                              *
********************************************************************************

* CO2 eriheide
* Arvutatud eraldi valemi järgi
$macro    eh_tase_co2(opt_paev, slott, k, primaarenergia, t_el)                \
             (q(opt_paev, slott, k, primaarenergia, t_el)$(max_osakaal(k, primaarenergia, t_el) > 0)   \
             * 3.6 / 1000 * eh_co2(primaarenergia)                             \
*             * (1 + k_moju(k, primaarenergia, "co") * kil_tase(k_tase)))       \
             * 0.999 * 44.01 / 12 )

* Eriheitmed.

$macro  eh_tase_el(opt_paev, slott, eh, k, primaarenergia, t_el)                               \
   (sum(para_lk,                                                                               \
                 t_sg_m3                                                                       \
               * hh_koef(eh, t_el, k, primaarenergia, para_lk)                                 \
               * z_emission(opt_paev, slott, k, primaarenergia, t_el, para_lk)                 \
             )$(sameas(eh, "so") or sameas(eh, "no"))                                          \
    +                                                                                          \
             (                                                                                 \
                q(opt_paev, slott, k, primaarenergia, t_el)$(max_osakaal(k, primaarenergia, t_el) > 0) \
                * sum(para_lk$(ord(para_lk) = card(para_lk)), eh_koef(eh, t_el, k, primaarenergia, para_lk, "0"))    \
             )$(not sameas(eh, "so") and not sameas(eh, "no")) \
        ) * mootemaaramatus

$macro eh_tase_jv(opt_paev, slott,  t_el)                                            \
             sum(para_lk$(ord(para_lk) = card(para_lk)),                             \
              eh_koefitsendid("jv", t_el, "Estonia", "Energeetiline", para_lk))      \
              *                                                                      \
              koorm_el(opt_paev, slott, t_el)


$macro eh_tase_jv_marg(opt_paev_marg, slott,  t_el)                                  \
             sum(para_lk$(ord(para_lk) = card(para_lk)),                             \
              eh_koefitsendid("jv", t_el, "Estonia", "Energeetiline", para_lk))      \
              *                                                                      \
              koorm_el_marg(opt_paev_marg, slott, t_el)

********************************************************************************
*                                                                              *
* KOORMAMATA PÕHJUSTE MAKROD                                                   *
*                                                                              *
********************************************************************************


*SPOT marginaali koormamata MWh(el)
$macro koormamata_el(opt_paev, slott,  t_el)                                 \
         max_koormus_el(t_el)                                                \
*         $ifthen.two "%remondigraafikud%" == "true"                         \
*                 *(1 - remondi_opt(opt_paev, t_el))                         \
*         $else.two                                                          \
                 *(1 - t_remondigraafik(opt_paev, t_el))                     \
*         $endif.two                                                         \
         -koorm_el(opt_paev, slott, t_el)

$macro koormamata_el_p(opt_paev, slott, t_el)                                \
         max_koormus_ty(t_el)                                                \
*                 *(1 - remondi_opt.l(opt_paev, t_el))                       \
                 *(1 - t_remondigraafik(opt_paev, t_el))                     \
         -koorm_el.l(opt_paev, slott, t_el)

********************************************************************************
*                                                                              *
* ÕLITEHASTE SAAGISE SÕLTUVUS KÜTTEVÄÄRTUSEST, SAAGIS ON ANTUD 8.2 MJ/KG KOHTA *
* Andrejevi valemite järgi.                                                    *
*                                                                              *
********************************************************************************

$macro saagis_ol(t_ol, aasta, k, primaarenergia)    (tootlikkus_ol(t_ol, aasta) \
   / (1 - kyttevaartus(primaarenergia, k) / kv_oli_std + 1))
