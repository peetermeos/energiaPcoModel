********************************************************************************
**                                                                             *
** See fail sisaldab heitmetega seotud piiranguid.                             *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

Equations
$ifthen.two "%l_k_sees%" == "true"
  v_eh_lambda1_k(opt_paev_max, slott, k, primaarenergia, t_killustik, k_tase, l_tase)  "Esimene eriheitmete lähendamise võrrand killustikule"
  v_eh_lambda1_l(opt_paev_max, slott, k, primaarenergia, t_lubi, l_tase, k_tase)  "Esimene eriheitmete lähendamise võrrand lubjale"
  v_eh_lambda4_k(opt_paev_max, slott, t_killustik)
  v_eh_lambda4_l(opt_paev_max, slott, t_lubi)
$endif.two

  v_eh_lambda2(opt_paev_max, slott, t_el, k, primaarenergia)            "Teine eriheitmete lähendamise võrrand"
  v_eh_lambda5(opt_paev_max, slott, t_el, k, primaarenergia)

  v_emission_variable_replacement1(opt_paev_max, slott, t_el, k, primaarenergia, para_lk)
  v_emission_variable_replacement2(opt_paev_max, slott, t_el, k, primaarenergia, para_lk)

$ifthen.two "%tp%" == "true"
 v_korsten_aktiivne(opt_paev_max, slott, t_el)   "Korstna kasutamise binaar"
 v_korstna_tunnid(t_korstnad)                    "Korstna tundide piirang"
$endif.two

* SOx kvoodi piirang tootmisele
  v_so_kvoot(aasta)                              "SOx kvoodi piirang tootmisele"
* Jahutusvee piirang tootmisele
$ifthen.two "%jp%" == "true"
  v_jahutusvesi(opt_paev_max, slott)
$endif.two
;

  lambda_e.fx(opt_paev, slott, t_el, k, primaarenergia, k_tase, l_tase, para_lk)$(max_osakaal(k, primaarenergia, t_el) = 0)= 0;
  lambda_e.up(opt_paev, slott, t_killustik, k, primaarenergia, k_tase, "0", para_lk) = 1;
  lambda_e.up(opt_paev, slott, t_lubi, k, primaarenergia, "0", l_tase, para_lk)      = 1;
  lambda_e.fx(opt_paev, slott, t_el, k, primaarenergia, k_tase, l_tase, para_lk)$(not sameas(k_tase, "0") and not t_killustik(t_el)) = 0;
  lambda_e.fx(opt_paev, slott, t_el, k, primaarenergia, k_tase, l_tase, para_lk)$(not sameas(l_tase, "0") and not t_lubi(t_el))      = 0;
  lambda_e.up(opt_paev, slott, t_el, k, primaarenergia, k_tase, l_tase, para_lk)$(t_killustik(t_el) and t_lubi(t_el))      = 1;

  z_emission.up(opt_paev, slott, k, primaarenergia, t_el, "1") = 0;
  z_emission.up(opt_paev, slott, k, primaarenergia, t_el, "1")$(max_osakaal(k, primaarenergia, t_el) = 0)= 0;

********************************************************************************
** Korstnate kasutuse binaarmuutuja surutakse 1'ks siis kui vähemalt ühe       *
** vastava ploki koormus on nullist suurem                                     *
** Peeter Meos                                                                 *
********************************************************************************
$ifthen.two "%tp%" == "true"

kr_aktiivne.up(opt_paev, slott, t_korstnad) = 1;

v_korsten_aktiivne(opt_paev, slott, t_el)$(sum(t_korstnad$t_ploki_korsten(t_korstnad, t_el), 1) > 0)..
  koorm_el(opt_paev, slott, t_el)
  =l=
    sum(t_korstnad$t_ploki_korsten(t_korstnad, t_el), kr_aktiivne(opt_paev, slott, t_korstnad))
  * sum((aasta, kuu)$tee_paevaks, max_koormus_el(t_el, aasta, kuu))
;
********************************************************************************
** Korstna kasutamise tunnid peavad jääma ajaperioodil lubatud piiridesse      *
** Peeter Meos                                                                 *
********************************************************************************


v_korstna_tunnid(t_korstnad)$(korstna_tundide_piirang(t_korstnad) > 0)..
     sum((aasta, kuu, opt_paev, slott)$(tee_paevaks and tp_aasta(aasta)),
          kr_aktiivne(opt_paev, slott, t_korstnad)
       * sloti_pikkus_orig(slott)
    )
    =l= korstna_tundide_piirang(t_korstnad)
;
$endif.two

********************************************************************************
** SOx kvoodi aastane piirang                                                  *
** Peeter Meos                                                                 *
********************************************************************************
v_so_kvoot(aasta)..
$ifthen.two "%uus_logistika%" == "false"
  sum((opt_paev, kuu)$tee_paevaks,
      sum(t_el,
          sum(slott,
              sum((primaarenergia, k)$(max_osakaal(k, primaarenergia, t_el) > 0),
                       eh_tase_el(opt_paev, slott, "so", k, primaarenergia, t_el))
                      * sloti_pikkus(opt_paev, slott, t_el)
              )
          )
       )
* Siia on vaja juba esimesel aastal kulutatud kvoot juurde liita
  +
  kulutatud_sox(aasta)
$else.two
   0
$endif.two
   =l=
   eh_kvoot(aasta, "so")
;

********************************************************************************
** Jahutusvee kasutuse piirang                                                 *
** Taaniel Uleksin                                                             *
********************************************************************************
$ifthen.two "%jp%" == "true"
v_jahutusvesi(opt_paev, slott)..
sum(t_el, pl_aktiivne(opt_paev, slott, t_el)*
 sum((aasta,kuu)$tee_paevaks, jahutusvee_kasutus(t_el, kuu))
) =l= sum((aasta, kuu)$tee_paevaks, eh_kvoot(aasta, "jv"))

$ontext
*Jahutusvee kasutus elektritootmisüksustel
  sum((t_el, t_jv)$sameas(t_el, t_jv),eh_tase_jv(opt_paev, slott, t_el) *
                     sloti_pikkus(slott))
*Jahutusvee kasutus õlitehastes
+
*$ifthen.two "%uus_logistika%" == "true"
  sum((l_n, k, primaarenergia), tootmisse(opt_paev, slott, l_n, t_ol, k, primaarenergia)$primaar_k(k, primaarenergia)*sloti_pikkus(slott))*eh_koefitsendid_ol("jv", t_ol)
*$else.two
sum((t_ol, t_jv)$sameas(t_ol, t_jv),
   (
sum((l_t, k, primaarenergia)
     $(tootmine_ja_laod(l_t, t_ol) and
       (max_osakaal(k, primaarenergia, t_ol) > 0)) ,
      laost_tootmisse(opt_paev, l_t, t_ol, k, primaarenergia)$primaar_k(k, primaarenergia))
 +

 sum((l, k, liinid, primaarenergia)
      $(liini_otsad(liinid, k, l) and
       (max_osakaal(k, primaarenergia, t_ol) > 0) and
       t_jp_tootmine(l, t_ol)),
      liinilt_tootmisse(opt_paev, liinid, t_ol, primaarenergia)$primaar_k(k, primaarenergia)
       ))*eh_koefitsendid_ol("jv", t_ol)
)
*$endif.two
=l=
*Jahutusvee võimalik kasutus (~60m^3/s)
  sum((aasta, kuu)$tee_paevaks, eh_kvoot(aasta, "jv")*60*60*sloti_pikkus(slott))
$offtext
;
$endif.two

$ifthen.two "%l_k_sees%" == "true"
v_eh_lambda1_k(opt_paev, slott, k, primaarenergia, t_killustik, k_tase, l_tase)..
  sum((para_lk)$(
*   ord(para_lk) > 1 and
   max_osakaal(k, primaarenergia, t_killustik) > 0),
       lambda_e(opt_paev, slott, t_killustik, k, primaarenergia, k_tase, l_tase, para_lk))
  =l=
  s_k(opt_paev, slott, t_killustik, k_tase)
;

v_eh_lambda1_l(opt_paev, slott, k, primaarenergia, t_lubi, l_tase, k_tase)..
  sum((para_lk)$(
       ord(para_lk) > 1 and
       max_osakaal(k, primaarenergia, t_lubi) > 0),
       lambda_e(opt_paev, slott, t_lubi, k, primaarenergia, k_tase, l_tase, para_lk))
  =l=
  s_l(opt_paev, slott, t_lubi, l_tase)
;

v_eh_lambda4_k(opt_paev, slott, t_killustik)..
sum(k_tase, s_k(opt_paev, slott, t_killustik, k_tase))
  =l=
  1
;

v_eh_lambda4_l(opt_paev, slott, t_lubi)..
  sum(l_tase, s_l(opt_paev, slott, t_lubi, l_tase))
  =l=
  1
;
$endif.two

v_eh_lambda2(opt_paev, slott, t_el, k, primaarenergia)$((not sameas(t_el, "Katlamaja") )
                                                         and max_osakaal(k, primaarenergia, t_el) > 0
                                                        )..
 sum((k_tase, l_tase, para_lk),
   lambda_e(opt_paev, slott, t_el, k, primaarenergia, k_tase, l_tase, para_lk)
   * hh_q(t_el, para_lk))
  =g=
  sum((k2, p2), q(opt_paev, slott, k2, p2, t_el))
  -
  koorm_sj(opt_paev, slott, t_el) / soojuse_kasutegur(t_el)
;


v_eh_lambda5(opt_paev, slott, t_el, k, primaarenergia)$(not sameas(t_el, "Katlamaja")
                                                                    and max_osakaal(k, primaarenergia, t_el)>0
                                                                    )..
  sum((para_lk, k_tase, l_tase), lambda_e(opt_paev, slott, t_el, k, primaarenergia, k_tase, l_tase, para_lk))
  =e=
  1
;

v_emission_variable_replacement1(opt_paev, slott, t_el, k, primaarenergia, para_lk)$(
                                                 max_osakaal(k, primaarenergia, t_el)>0
                                             and ord(para_lk) > 1)..
  z_emission(opt_paev, slott, k, primaarenergia, t_el, para_lk)
  =g=
  sum((k_tase, l_tase), lambda_e(opt_paev, slott, t_el, k, primaarenergia, k_tase, l_tase, para_lk))
;

v_emission_variable_replacement2(opt_paev, slott, t_el, k, primaarenergia, para_lk)$(
                                                 max_osakaal(k, primaarenergia, t_el)>0
                                             and ord(para_lk) > 1)..
  z_emission(opt_paev, slott, k, primaarenergia, t_el, para_lk)
  =g=
  q(opt_paev, slott, k, primaarenergia, t_el)
;
