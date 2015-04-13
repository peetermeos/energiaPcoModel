$ifthen.two "%pysikulud%" == "true"

*Parameter pysikulud_ty(t, aasta) "Plokkide p�sikulud �/aastas";
Parameter pysikulud_k(k, aasta) "Kaevanduste p�sikulud �/aastas";
Parameter pysikulud_l(aasta) "Logistika p�sikulud �/aastas";

Scalar plokkide_arv /1/;

Set
jaam
/
  EEJ
  BEJ
/
;

Set
t_jaam(jaam, t_el)
/
  EEJ.(EEJ1*EEJ8)
  BEJ.(BEJ9*BEJ12)
/
;

Parameters
         yletunni_koefitsient(aasta, kuu) "Maksimaalne �letunnit�� brigaadi kohta (0% - 100%)"
         b_toojoukulu(aasta, kuu, jaam) "Kuine t��j�ukulu brigaadi kohta jaamas (�/kuus)"
         yletunni_tootasu_koefitsient(aasta, kuu) "Millega korrutatakse t��j�ukulu kui on �letunnit��?"
         sundpuhkuse_koefitsient(aasta) "Millega korrutatakse t��j�ukulu kui on sundpuhkus?"

         hoolduskulu(aasta, t_el) "Kuine ploki hoolduskulu"
         seisaku_lisahooldus_koefitsient(aasta) "Ploki k�ivitades % hoolduskulust"
         pl_toos(aasta, jaam)  "Mitu plokki t��s on?"
;

yletunni_koefitsient(aasta, kuu) = 0.15;
b_toojoukulu(aasta, kuu, jaam) = 32000;
yletunni_tootasu_koefitsient(aasta, kuu) = 1.8;
sundpuhkuse_koefitsient(aasta) = 0.5;

hoolduskulu(aasta, t_el) = 70000;
seisaku_lisahooldus_koefitsient(aasta) = 0.2;
pl_toos(aasta, jaam) = sum(t_el$t_jaam(jaam, t_el), 1$(sum(kuu, max_koormus_el(t_el, aasta, kuu)) > 0));

*$load pysikulud_ty, pysikulud_k, pysikulud_l
$load pysikulud_k, pysikulud_l

$endif.two
