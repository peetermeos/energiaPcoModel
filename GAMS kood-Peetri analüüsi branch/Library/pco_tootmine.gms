Sets
 t           "Tootmis�ksused"
 tehnoloogia "Tootmistehnoloogia"
 katel       "Katelde numeratsioon"
;
$loaddc t katel tehnoloogia

Sets
 t_tehnoloogia(tehnoloogia, t)   "Mis tehnoloogiat plokk kasutab"
 t_korstnad                      "Meie jaamade korstnad"
 t_ploki_korsten(t_korstnad, t)  "Mis ploki k�ljes mis korsten on"
 t_el(t)                         "Elektritootmise �ksused"
 t_ol(t)                         "�litootmise �ksused"
 t_mk(t)                         "Primaarenergia m��k"
;
$loaddc t_tehnoloogia t_korstnad t_ploki_korsten t_ol t_mk t_el

Sets t_sj(t_el)                  "Koostoomise �ksused"
;

Set
  t_k_tase  "Killustiku lisamise tasemed" /0, 10, 15, 20/
  t_l_tase  "Lubja lisamise tasemed"      /0, 1, 2, 3/
;

Set
  t_katel(t_el, katel)  "Mitmest katlast tootmis�ksus koosneb"
/
(EEJ1*EEJ8) .(a,b)
(BEJ9*BEJ12).(a,b)
(AUVERE1)     .(a)
/
;

Table max_q(t_el, katel) "Katelde maksimaalsed koormused (MW)"
                         a    b
(EEJ1,EEJ2,EEJ7)       255  255
(EEJ3,EEJ4,EEJ5,EEJ6)  265  265
(BEJ9,BEJ10,BEJ12)     250  250
(BEJ11,EEJ8)           300  300
(AUVERE1)              900
;

Parameter kv_kt(t_el)          "Primaarenergia k�ttev��rtuse m�ju kasutegurile (%/(MJ/kg))";
Parameter katelt_plokis(t_el)  "Mitmest katlast tootmis�ksus koosneb";

$loaddc katelt_plokis t_sj kv_kt

katelt_plokis(t_el)$(katelt_plokis(t_el) = 0) = 1;

Sets
  para_kt           "Kasutegurite l�hendusfunktsioonide parameetrid, lineaarsed"
  para_lk           "Kasutegurite l�hendamiseks on neli punkti"
  t_killustik(t_el) "Mis tootmis�ksustele killustik sobib"
  t_lubi(t_el)      "Mis tootmis�ksustele lubi sobib"
;
$loaddc para_lk para_kt t_killustik t_lubi

Parameters
  max_koormus_el(t_el, aasta, kuu) "Elektritoomis�ksuste maksimum elektri netokoormus (MW)"
  max_koormus_ty(t_el, aasta, kuu) "Elektritoomis�ksuste maksimum summaarne netokoormus (MW)"
  max_koormus_sj(t_el)             "Koostootmis�ksuste maksimum neto soojuskoormus (MW)"
  max_koormus_ol(t_ol, aasta, kuu) "Installeeritud netov�imsus t �li / p�evas (sisendis on pk. t / h)"
  tootlikkus_ol(t_ol, aasta)       "�litehaste tootlikkkus (%)"
  min_koormus_el(t_el)             "Elektritoomis�ksuste miinimum netokoormus (MW)"
  min_koormus_sj(t_el)             "Koostootmis�ksuste miinimumkoormus soojatootmiseks (MW)"
  kasutegur(t_el, para_lk, para_kt)"Kasutegurite arvutamise tabel (prim/sek)"
  valjund(t_el, para_lk, para_kt)  "Kasutegurite arvutamise tabel (sek/prim)"
  soojuse_kasutegur(t_el)          "Soojuse kasutegur tootmis�ksuste kaupa (MWh(sj)/MWh(k�t))"
  delta_yles(t_el)                 "Maksimaalse �leskoormamise kiirus (MW/h)"
  delta_alla(t_el)                 "Maksimaalne allakoormamise kiirus (MW/h)"
  kaivituskulu(t_el)               "Ploki k�lmk�ivituskulu (EUR)"
  auru_min_koormus(aasta)          "�litehaste jaoks vajalik auru miinimumkoormus (MW)"
  misc_lost_pwr(t_el, aasta ,kuu)  "Miscellaneous lost production capacities (MW)"
  lime_consumption(t_el)           "Lime consumption for NID units (kg/MWh)"
;

$loaddc max_koormus_el max_koormus_ty max_koormus_sj max_koormus_ol
$loaddc tootlikkus_ol  min_koormus_sj kasutegur soojuse_kasutegur
$loaddc min_koormus_el
$load delta_yles delta_alla
$loaddc auru_min_koormus misc_lost_pwr
$loaddc lime_consumption

* a v�ljund
* b sisend

min_koormus_el("BEJ11") = 40;

* Korrigeerime kasutegurite tabelit vastavalt miinimumkoormusele.

* kasutegur(t_el, "3", "a") = min_koormus_el(t_el);
kasutegur(t_el, "2", "a") = kasutegur(t_el, "3", "a") - 0.1;

valjund(t_el, para_lk, "a")$(kasutegur(t_el, para_lk, "b") > 0) = kasutegur(t_el, para_lk, "a");
valjund(t_el, para_lk, "b")
                        $(kasutegur(t_el, para_lk, "b") > 0
                      and kasutegur(t_el, para_lk, "a") > 0)
      = kasutegur(t_el, para_lk, "a") / kasutegur(t_el, para_lk, "b");

valjund(t_el, para_lk, "b")
                        $(kasutegur(t_el, para_lk, "b") = 0
                      and kasutegur(t_el, para_lk, "a") > 0)
      = valjund(t_el, para_lk+1, "b")-1;

soojuse_kasutegur(t_el)$(max_koormus_sj(t_el) = 0) = 1;

Parameter
  t_uttegaas(t_el, aasta, kuu)      "Mitu m3 tootmis�ksused uttegaasi tarbida suudavad"
  uttegaasi_tootlikkus(t_ol)        "�litehaste uttegaasi tootlikkus"
  uttegaasi_kyttevaartus(t_ol)      "�litehaste uttegaasi k�ttev��rtus (MWh/m3)"
  t_ket_kulu(aasta, kuu, t)         "K�tuse etteande muutuvkulu (EUR/t)"
  t_el_min_sum_peak(aasta, kuu)     "Minimaalne summaarne elektrikoormus peak (MWh)"
  t_el_min_sum_offpeak(aasta, kuu)  "Minimaalne summaarne elektrikoormus peak (MWh)"
  t_remondigraafik(opt_paev_max, t) "Tootmis�ksuste remondigraafik (0/1)"
  avariilisus(t, aasta)             "Tootmis�ksuste avariilisus (proportsioon kuisest tootmisv�imekusest)"
  puhastus(opt_paev_max, t)             "Tootmis�ksuste puhastusp�evade graafik (0/1)"
  kulu_kylmkaivitus(t_el)           "K�ivituskulud k�lmal k�ivitusel (EUR)"
  oli_kulu_kylmkaivitus(t_el)       "�li kulu k�lmk�ivitusel (t)"
  TRemont(t_el, aasta)              "Ploki remondip�evade arv aastas (p�eva)"

  p_paevi_kuus_ol(t_ol, aasta, kuu)  "�litehaste remondip�evade arv kuus"
  r_paevi_kuus_ol(t_ol, aasta, kuu)  "�litehaste puhastusp�evade arv kuus"
;
$loaddc t_uttegaas t_ket_kulu t_el_min_sum_peak t_el_min_sum_offpeak
$loaddc avariilisus kulu_kylmkaivitus oli_kulu_kylmkaivitus
$loaddc p_paevi_kuus_ol r_paevi_kuus_ol
*puhastus
$loaddc TRemont
$loaddc uttegaasi_tootlikkus uttegaasi_kyttevaartus

Parameter sloti_pikkus(opt_paev_max, slott, t);
sloti_pikkus(opt_paev_max, slott, t) = sloti_pikkus_orig(slott);

sloti_pikkus(opt_paev, slott, t)$(sum((aasta, kuu)$paev_kalendriks(opt_paev, aasta, kuu), avariilisus(t, aasta)) > 0)
    = sloti_pikkus_orig(slott)
     * sum((aasta, kuu)$paev_kalendriks(opt_paev, aasta, kuu), (1-avariilisus(t, aasta)));

Parameter t_uttegaasi_kokku(aasta, kuu);
t_uttegaasi_kokku(aasta, kuu) = sum(t_el, t_uttegaas(t_el, aasta, kuu));

*Muud muutuvkulud

Parameter
  el_muud_kulud(aasta, kuu, t_el)       "Elektritootmise muud muutuvkulud (�/MWh(el))"
  soojuse_muud_kulud(aasta, kuu, t_el)  "Soojatootmise muud muutuvkulud (�/MWh(soojus))"
  oil_muud_kulud(aasta, kuu, t_ol)      "�li muud muutuvkulud (�/t(�li))"
  lubatud_kasutus(aasta, kuu, t, k, primaarenergia) "Primaarenergia lubatud kasutus plokis"

  kyttevaartus_min(t, aasta, kuu)
  max_osakaal(k, primaarenergia, t)
;
$load el_muud_kulud soojuse_muud_kulud oil_muud_kulud
$load max_osakaal kyttevaartus_min lubatud_kasutus

kyttevaartus_min(t, aasta, kuu) = kyttevaartus_min(t, aasta, kuu)/3.6;

Parameter max_toetuse_kogus(aasta);
max_toetuse_kogus(aasta) = 365000;

Set
oli_toode   "V�imalikud �li tooted"
;

Parameter
oli_toote_osakaal(t_ol, oli_toode)  "Mitu % �litehase kogutoodangust on bensiin/kesk�li"
;

$loaddc oli_toode oli_toote_osakaal

Set
 r_kp    "Remondi algus ja l�pukuup�evad"
 r_num   "Remondi j�rjekorranumbrid"
;
$loaddc r_kp r_num

Parameter  t_remondid(t, r_num, r_kp);

**********************************************************************************
*                                                                                *
* Teeme kuup�evapaarides antud remondigraafikust optimeerija 0/1 remondigraafiku *
* Interfacest tulevad kuup�evad formaadis DDMMYY                                 *
*                                                                                *
* Peeter Meos                                                                    *
**********************************************************************************
$loaddc t_remondid
t_remondigraafik(opt_paev_max, t) = 0;

Scalar r_paev, r_kuu, r_aasta;
Scalar r_algus, r_lopp;

loop(r_num,
  loop(t,
* Arvutame remondipaeva p�evanumbrid
      if (t_remondid(t, r_num, 'algus') > 0 and t_remondid(t, r_num, 'lopp') > 0,
          r_paev  = trunc(t_remondid(t, r_num, 'algus') / 1E4);
          r_kuu   = trunc((t_remondid(t, r_num, 'algus') - (r_paev * 1E4)) / 1E2);
          r_aasta = 2000 + t_remondid(t, r_num, 'algus') - (r_paev * 1E4) - (r_kuu * 1E2);

          r_algus = jdate(r_aasta, r_kuu, r_paev) - jdate(%aasta_1%, 1, 1) + 1;

          r_paev  = trunc(t_remondid(t, r_num, 'lopp') / 1E4);
          r_kuu   = trunc((t_remondid(t, r_num, 'lopp') - (r_paev * 1E4)) / 1E2);
          r_aasta = 2000 + t_remondid(t, r_num, 'lopp') - (r_paev * 1E4) - (r_kuu * 1E2);

          r_lopp = jdate(r_aasta, r_kuu, r_paev) - jdate(%aasta_1%, 1, 1) + 1;

          t_remondigraafik(opt_paev_max, t)$(ord(opt_paev_max) ge r_algus and ord(opt_paev_max) le r_lopp) = 1;
         );
      );
    );


********************************************************************************
**                                                                             *
** Max net power production capacity adjustment                                *
**                                                                             *
** Description: Net production capacity that should remain standard across     *
** times, need to be adjusted for various reasons from month to month          *
** misc_lost_pwr implements it. The values will be deducted from net capacity. *
**                                                                             *
** Macros used: None                                                           *
** Notes: None                                                                 *
**                                                                             *
********************************************************************************

max_koormus_ty(t_el, aasta, kuu) = max_koormus_ty(t_el, aasta, kuu)
  - misc_lost_pwr(t_el, aasta ,kuu)
;
max_koormus_ty(t_el, aasta, kuu)$(max_koormus_ty(t_el, aasta, kuu) < 0) = 0;

max_koormus_el(t_el, aasta, kuu) = max_koormus_el(t_el, aasta, kuu)
  - misc_lost_pwr(t_el, aasta ,kuu)
;
max_koormus_el(t_el, aasta, kuu)$(max_koormus_el(t_el, aasta, kuu) < 0) = 0;
