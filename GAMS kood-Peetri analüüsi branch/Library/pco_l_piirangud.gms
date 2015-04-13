********************************************************************************
**                                                                             *
** See fail sisaldab laonduse ja logistikaga seotud piiranguid PCO mudelile    *
**                                                                             *
** Peeter Meos                                                                 *
********************************************************************************

Equations
* Laoseisude updated
  v_kaevanduse_laoseis(opt_paev_max, l_k, k, primaarenergia)
  v_kaevanduse_laoseis2(opt_paev_max, l_k, k, primaarenergia)
  v_kaevanduse_laoseis3(opt_paev_max, l_k)
  v_tootmisuksuse_laoseis(opt_paev_max, l_t, k, primaarenergia)
  v_tootmisuksuse_laoseis2(opt_paev_max, l_t, k, primaarenergia)
  v_tootmisuksuse_laoseis3(opt_paev_max, l_t)

* Ladude maksimumseisud
$ifthen.k "%kaevandused%" == "true"
  v_max_laoseis_k(opt_paev_max, l_k) "Ladude maksimumi piirang kaevandustes (t)"
$endif.k
  v_max_laoseis_t(opt_paev_max, l_t) "Ladude maksimumi piirang tootmisüksustes (t)"

* Ladude miinimumseisud
*  v_min_laoseis_k(opt_paev, l_k) "Ladude miinimumi piirang (t)"
  v_min_laoseis_t(opt_paev_max, l_t) "Ladude miinimumi piirang (t)"

* Logistika tasakaaluvõrrandid
  v_logistika(opt_paev_max, liinid, primaarenergia)  "Logistika tasakaaluvõrrand"

* Logistikaliinide maksimumvõimekused
  v_max_labilase(opt_paev_max, l)    "Logistikaliinide maksimumvõimekused (t/päevas)"
  v_max_laadimine_k(opt_paev_max, k) "Maksimum laadimisvõimekused kaevandustes"
  v_max_laadimine_l(opt_paev_max, l) "Maksimum laadimisvõimekused tootmisüksustes"

* Fuel reservation constraint for non-production fuel use
  v_reserved_fuel(aasta, kuu, k, primaarenergia, l) "Monthly non-production fuel consumption (t)"

* Maximum capacity constraints for loading distinct products
  v_loading_bin(opt_paev_max, liinid, primaarenergia) "Whether a product is being loaded at a given point"
  v_max_loading_cap(aasta, kuu, liinid)           "Maximum loading capacity at a given point"
;

* Algsed laoseisud
laoseis_t.fx("%esimene_paev%", l_t, k, primaarenergia) = alguse_laoseisud(l_t, k, primaarenergia);
laoseis_k.fx("%esimene_paev%", l_k, k, primaarenergia) = alguse_laoseisud(l_k, k, primaarenergia);

laoseis_k.up(opt_paev, l_k, k, primaarenergia)$(not primaar_k(k, primaarenergia)) = 0;
laoseis_t.up(opt_paev, l_t, k, primaarenergia)$(not primaar_k(k, primaarenergia)) = 0;
laoseis_k.up(opt_paev, "Estonia_Aher", k, primaarenergia) = 0;

laoseis_t.fx(opt_paev, l_t, k, primaarenergia)$(ladustamatu_primaarenergia(k, primaarenergia, l_t)) = 0;
laoseis_k.fx(opt_paev, l_k, k, primaarenergia)$(ladustamatu_primaarenergia(k, primaarenergia, l_k)) = 0;

kaevandusest_lattu.fx(opt_paev, l_k, k, primaarenergia)$(ladustamatu_primaarenergia(k, primaarenergia, l_k)) = 0;
liinilt_lattu.fx(opt_paev, liinid, l_t, primaarenergia)
     $(sum((k,l)$(liini_otsad(liinid, k, l) and ladustamatu_primaarenergia(k, primaarenergia, l_t)), 1) > 0) = 0;

$ifthen.fix set fix_ladu
Parameter fix_ladu(laod, k, primaarenergia);

$GDXin _gams_net_gdb0.gdx
$load fix_ladu
$GDXin

laoseis_t.fx("%fix_ladu%", l_t, k, primaarenergia)$(not sameas(k, "Hange")) = fix_ladu(l_t, k, primaarenergia);
laoseis_k.fx("%fix_ladu%", l_k, k, primaarenergia)$(not sameas(k, "Hange")) = fix_ladu(l_k, k, primaarenergia);

laoseis_t.lo("%fix_ladu%", l_t, k, primaarenergia)$(sameas(k, "Hange")) = fix_ladu(l_t, k, primaarenergia);
laoseis_k.lo("%fix_ladu%", l_k, k, primaarenergia)$(sameas(k, "Hange")) = fix_ladu(l_k, k, primaarenergia);
$endif.fix

********************************************************************************
** Logistika lollikindlus: ei tarni kütust tootmisüksusesse, kus toota ei saa. *
** Antud piirang välistab kütuse laost ära viskamise.                          *
** Taaniel Uleksin                                                             *
********************************************************************************

laost_tootmisse.up(opt_paev, l_t, t, k, primaarenergia)$(
  (sum((aasta, kuu, t_ol)$sameas(t, t_ol), max_koormus_ol(t_ol, aasta, kuu)$tee_paevaks) = 0
and
  sum((aasta, kuu, t_el)$sameas(t, t_el), max_koormus_ty(t_el, aasta, kuu)$tee_paevaks) = 0
and
  sum((aasta, kuu, t_mk)$sameas(t, t_mk), myygileping(aasta, kuu, t_mk, k, primaarenergia)$tee_paevaks) = 0)
or
  t_remondigraafik(opt_paev, t) = 1
) = 0;

liinilt_tootmisse.up(opt_paev, liinid, t, primaarenergia)$(
  (sum((aasta, kuu, t_ol)$sameas(t, t_ol), max_koormus_ol(t_ol, aasta, kuu)$tee_paevaks) = 0
and
  sum((aasta, kuu, t_el)$sameas(t, t_el), max_koormus_ty(t_el, aasta, kuu)$tee_paevaks) = 0
and
  sum((aasta, kuu, t_mk, k)$sameas(t, t_mk), myygileping(aasta, kuu, t_mk, k, primaarenergia)$tee_paevaks) = 0)
or
  t_remondigraafik(opt_paev, t) = 1
) = 0;

********************************************************************************
** Laomahud peavad olema väiksemad kui max laomahud kaevandustes               *
** ja tootmisüksustes                                                          *
** Peeter Meos                                                                 *
********************************************************************************
$ifthen.k "%kaevandused%" == "true"
v_max_laoseis_k(opt_paev, l_k)..
   sum((primaarenergia, k), laoseis_k(opt_paev, l_k, k, primaarenergia))
   =l=
$ifthen.two "%kaevanduse_laod%" == "false"
   1000
$else.two
   max_laomaht(l_k)
$endif.two
;
$endif.k

v_max_laoseis_t(opt_paev, l_t)..
   sum((primaarenergia, k), laoseis_t(opt_paev, l_t, k, primaarenergia)) =l= max_laomaht(l_t);


********************************************************************************
** Laomahud peavad olema suuremad kui min laomahud kaevandustes                *
** ja tootmisüksustes                                                          *
** Taaniel Uleksin                                                             *
********************************************************************************
$ontext
v_min_laoseis_k(opt_paev, l_k)..
   sum((primaarenergia), laoseis_k(opt_paev, l_k, primaarenergia))
   =g=
   min_laomaht(l_k);
$offtext

*$ifthen.four not "%spot_hinnad%" == "true"
v_min_laoseis_t(opt_paev, l_t)..
   sum((primaarenergia, k), laoseis_t(opt_paev, l_t, k, primaarenergia))
   =g= min_laomaht(l_t);
*$endif.four


********************************************************************************
** Kaevanduse laoseisude päevane update ja järgmise päeva laoseisu arvutamine  *
** Kaevanduse lao laoseis on eelmise päeva laoseis miinus rongile laaditud kivi*
** pluss kaevandusest lisaks toodud kivi                                       *
** laoseis = eilne laoseis + kaevandusest_lattu - laost_rongile                *
** Peeter Meos                                                                 *
********************************************************************************

v_kaevanduse_laoseis(opt_paev, l_k, k, primaarenergia)
                     $(not (ord(opt_paev) eq card(opt_paev)) and (primaar_k(k, primaarenergia)))..
* Järgmise päeva laoseis hommikul
   laoseis_k(opt_paev + 1, l_k, k ,primaarenergia)
   =e=
* Tänane laoseis hommikul
   laoseis_k(opt_paev, l_k, k, primaarenergia)
   +
* Kaevandusest lattu tulnud kivi
  kaevandusest_lattu(opt_paev, l_k, k, primaarenergia)$(kaevandused_ja_laod(k, l_k) and primaar_k(k, primaarenergia))

   -
* Laost rongi peale läinud kivi, kõigile liinidele per ladu
  sum((liinid, l)$(liini_otsad(liinid, k, l)
               and kaevandused_ja_laod(k, l_k)
               and primaar_k(k, primaarenergia)),
        laost_liinile(opt_paev, l_k, liinid, primaarenergia)
        )
;

********************************************************************************
** Viimase päeva lao kasutus peab olema võetud laost ning ei tohi ületada      *
** miinimum-laojääki kaevandustes                                              *
** Taaniel Uleksin                                                             *
********************************************************************************

v_kaevanduse_laoseis2(opt_paev, l_k, k, primaarenergia)
                     $(ord(opt_paev) eq card(opt_paev))..
  sum((liinid, l)$(liini_otsad(liinid, k, l)
               and kaevandused_ja_laod(k, l_k)
               and primaar_k(k, primaarenergia)),
        laost_liinile(opt_paev, l_k, liinid, primaarenergia)
        )
=l=
  laoseis_k(opt_paev, l_k, k ,primaarenergia)
;

v_kaevanduse_laoseis3(opt_paev, l_k)
                     $(ord(opt_paev) eq card(opt_paev))..
  sum((k, primaarenergia), sum((liinid, l)$(liini_otsad(liinid, k, l)
               and kaevandused_ja_laod(k, l_k)
               and primaar_k(k, primaarenergia)),
        laost_liinile(opt_paev, l_k, liinid, primaarenergia)
        ))
=l=
  sum((k, primaarenergia), laoseis_k(opt_paev, l_k, k ,primaarenergia))
  -
  min_laomaht(l_k)
;

********************************************************************************
** Tootmisüksuse laoseisude päevane update ja järgmise päeva lao arvutamine    *
** Tootmisüksuse lao laoseis on eelmise päeva ladu miinus tootmisse läinud kivi*
** pluss logistikaga lisaks toodud kivi                                        *
** laoseis = eilne laoseis + liinilt_lattu - laost_tootmisse                   *
** Peeter Meos                                                                 *
********************************************************************************
laoseis_t.up(opt_paev, l_t, k, primaarenergia)$(ladustamatu_primaarenergia(k, primaarenergia, l_t)) = 0;

v_tootmisuksuse_laoseis(opt_paev, l_t, k, primaarenergia)
                        $(not (ord(opt_paev) eq card(opt_paev)))..

* Järgmise päeva laoseis
  laoseis_t(opt_paev+1, l_t, k, primaarenergia)$(primaar_k(k, primaarenergia))
=e=
* Tänane laoseis
  laoseis_t(opt_paev, l_t, k, primaarenergia)$(primaar_k(k, primaarenergia))
  +
* Rongilt lattu tulnud kivi
  sum((liinid, l)$liini_otsad(liinid, k, l),
       liinilt_lattu(opt_paev, liinid, l_t, primaarenergia)
       $t_jp_ladu(l, l_t)
       )
  -
* Laost tootmisüksusesse läinud kivi
  sum(t, laost_tootmisse(opt_paev, l_t, t, k, primaarenergia)
      $(tootmine_ja_laod(l_t, t) and primaar_k(k, primaarenergia)))
;

********************************************************************************
** Viimase päeva lao kasutus peab olema võetud laost ning ei tohi ületada      *
** miinimum-laojääki tootmisüksustes                                           *
** Taaniel Uleksin                                                             *
********************************************************************************

v_tootmisuksuse_laoseis2(opt_paev, l_t, k, primaarenergia)
                        $(ord(opt_paev) eq card(opt_paev))..
  sum(t, laost_tootmisse(opt_paev, l_t, t, k, primaarenergia)
      $(tootmine_ja_laod(l_t, t) and primaar_k(k, primaarenergia)))
=l=
  laoseis_t(opt_paev, l_t, k, primaarenergia)$(primaar_k(k, primaarenergia))
;

v_tootmisuksuse_laoseis3(opt_paev, l_t)
                        $(ord(opt_paev) eq card(opt_paev))..
  sum((k, primaarenergia),
         sum(t, laost_tootmisse(opt_paev, l_t, t, k, primaarenergia)
               $(tootmine_ja_laod(l_t, t) and primaar_k(k, primaarenergia)))
  )
=l=
  sum((k, primaarenergia), laoseis_t(opt_paev, l_t, k, primaarenergia)$(primaar_k(k, primaarenergia)))
  -
  min_laomaht(l_t)
;

********************************************************************************
** Rongide tasakaaluvõrrand - rongi peale saabuv kivi =e=  sealt väljuvaga     *
** kaevandusest rongile + laost rongile = rongilt lattu + rongilt tootmisse    *
** Peeter Meos                                                                 *
********************************************************************************

v_logistika(opt_paev, liinid, primaarenergia)..
* Kaevandusest rongile
   sum((k, l)$(liini_otsad(liinid, k, l) and primaar_k(k, primaarenergia)
* If the tuple allows to use this combination of fuel and logistics line
        and (log_f_constraint(liinid, primaarenergia)
* .. or the tuple is not defined at all for given logistics line
          or sum(p2$log_f_constraint(liinid, p2), 1) = 0)
     ),
      kaevandusest_liinile(opt_paev, liinid, primaarenergia))

   +
* Ladudest rongile
    sum((k, l_k, l)$(liini_otsad(liinid, k, l)
* If the tuple allows to use this combination of fuel and logistics line
        and (log_f_constraint(liinid, primaarenergia)
* .. or the tuple is not defined at all for given logistics line
          or sum(p2$log_f_constraint(liinid, p2), 1) = 0)
        ),
        laost_liinile(opt_paev, l_k, liinid, primaarenergia)
        $(kaevandused_ja_laod(k, l_k) and primaar_k(k, primaarenergia)))

   =e=
* See $ifthen jubin lülitab tootmisüksuste laodusid sisse välja
* Sisuliselt kui ladudest rongi peale toodet laadida ei saa,
* pole mõtet ka ladusid kasutada
* -Peeter Meos

* Rongilt lattu tulnud kivi
  sum((k, l_t, l)$liini_otsad(liinid, k, l),
       liinilt_lattu(opt_paev, liinid, l_t, primaarenergia)
       $(t_jp_ladu(l, l_t) and primaar_k(k, primaarenergia)))
  +
* Rongilt otse tootmisse viidud kivi
  sum((k, l, t)$liini_otsad(liinid, k, l),
      liinilt_tootmisse(opt_paev, liinid, t, primaarenergia)
      $(t_jp_tootmine(l, t)
      and primaar_k(k, primaarenergia)
      )
  )
  +
* Fuel reserved for non-production uses (such as testing and commissioning)
   sum((k, l)$(liini_otsad(liinid, k, l)
          and primaar_k(k, primaarenergia)
          and sum((aasta, kuu)$tee_paevaks, reserved_fuel(aasta, kuu, k, primaarenergia, l)) > 0),
     daily_res_f(opt_paev, k, primaarenergia, l)
   )
;


********************************************************************************
** Logistika maksimaalse läbilaskevõime piirang. Kuna VKG on logistikute       *
** maatriksis mainimata, siis eeldame, et see on piiramatu                     *
** Peeter Meos                                                                 *
********************************************************************************

v_max_labilase(opt_paev, l)$(max_labilase(l) > 0)..
  sum((l_t, liinid, k, primaarenergia)$(liini_otsad(liinid, k, l)),
       liinilt_lattu(opt_paev, liinid, l_t, primaarenergia)
       $(t_jp_ladu(l, l_t) and
         primaar_k(k, primaarenergia)))
  +
* Rongilt otse tootmisse viidud kivi
  sum((liinid, k, t, primaarenergia)$(liini_otsad(liinid, k, l)),
      liinilt_tootmisse(opt_paev, liinid, t, primaarenergia)
      $(t_jp_tootmine(l, t) and primaar_k(k, primaarenergia)))
  +
* Fuel reserved for non-production uses (such as testing and commissioning)
  sum((k, primaarenergia),
    daily_res_f(opt_paev, k, primaarenergia, l)$(primaar_k(k, primaarenergia)
                        and sum((aasta, kuu)$tee_paevaks, reserved_fuel(aasta, kuu, k, primaarenergia, l)) > 0)
     )
 =l=
max_labilase(l)
;


v_max_laadimine_k(opt_paev, k)..
  sum((liinid, primaarenergia, l)$(liini_otsad(liinid, k, l)),
        kaevandusest_liinile(opt_paev, liinid, primaarenergia))
  +
  sum((liinid, l_k, primaarenergia)$(kaevandused_ja_laod(k, l_k) and primaar_k(k, primaarenergia)
      ),
      laost_liinile(opt_paev, l_k, liinid, primaarenergia)
     )
  =l=
  sum((aasta, kuu)$tee_paevaks, max_laadimine_k(k, aasta))
;

v_max_laadimine_l(opt_paev, l)..
  sum((l_t, liinid, k, primaarenergia)$(liini_otsad(liinid, k, l)),
       liinilt_lattu(opt_paev, liinid, l_t, primaarenergia)
       $(t_jp_ladu(l, l_t) and
         primaar_k(k, primaarenergia)))
  +
  sum((liinid, k, t, primaarenergia)$(liini_otsad(liinid, k, l)),
      liinilt_tootmisse(opt_paev, liinid, t, primaarenergia)
      $(t_jp_tootmine(l, t) and primaar_k(k, primaarenergia)))
  +
* Fuel reserved for non-production uses (such as testing and commissioning)
   sum((liinid, k, primaarenergia)$(liini_otsad(liinid, k, l) and primaar_k(k, primaarenergia)
          and sum((aasta, kuu)$tee_paevaks, reserved_fuel(aasta, kuu, k, primaarenergia, l)) > 0
       ),
     daily_res_f(opt_paev, k, primaarenergia, l)
   )
  =l=
  sum((aasta, kuu)$tee_paevaks, max_laadimine_l(l, aasta))
;

********************************************************************************
**                                                                             *
** Constraint for monthly fuel reservations for non-production use             *
**                                                                             *
** Description: Every month the value chain consumes a set amount of           *
** primary energy for non production use, such as testing, commissioning       *
** etc. Since this use is not reflected in revenue and thus absent from        *
** objective function it needs to be modelled as a separate constraint.        *
**                                                                             *
** Macros used: tee_paevaks - couples model day with cal month and year        *
** Notes: None                                                                 *
**                                                                             *
********************************************************************************

v_reserved_fuel(aasta, kuu, k, primaarenergia, l)$(reserved_fuel(aasta, kuu, k, primaarenergia, l) > 0
                                                 )..
  sum(opt_paev$tee_paevaks, daily_res_f(opt_paev, k, primaarenergia, l))
  =e=
  reserved_fuel(aasta, kuu, k, primaarenergia, l)
;

********************************************************************************
**                                                                             *
** Constraints modeling loading limits of distinct products at production pts  *
**                                                                             *
** Description: The essence is that for some log lines, the loading capacity   *
** for distinct products is limited. For instance at Narva, it is possible     *
** to load to products to rail and the third one needs to be transported by    *
** truck.
**                                                                             *
** Macros used: tee_paevaks - couples model day with cal month and year        *
** Notes: None                                                                 *
**                                                                             *
********************************************************************************

prod_load.up(aasta, kuu, k, primaarenergia)$(not primaar_k(k, primaarenergia)) = 0;

v_loading_bin(opt_paev, liinid, primaarenergia)$(max_sim_load_cap(liinid) > 0)..
  sum((k, l)$(liini_otsad(liinid, k, l) and primaar_k(k, primaarenergia)),
        kaevandusest_liinile(opt_paev, liinid, primaarenergia))
  +
  sum((k, l_k)$(kaevandused_ja_laod(k, l_k) and primaar_k(k, primaarenergia)),
        laost_liinile(opt_paev, l_k, liinid, primaarenergia))
  =l=
  sum((aasta, kuu, k, l)$(tee_paevaks and liini_otsad(liinid, k, l)), prod_load(aasta, kuu, k, primaarenergia)) * M
;

v_max_loading_cap(aasta, kuu, liinid)$(max_sim_load_cap(liinid) > 0)..
  sum((l, k, primaarenergia)$(liini_otsad(liinid, k, l) and primaar_k(k, primaarenergia)),
       prod_load(aasta, kuu, k, primaarenergia)
     )
  =l=
  max_sim_load_cap(liinid)
;
