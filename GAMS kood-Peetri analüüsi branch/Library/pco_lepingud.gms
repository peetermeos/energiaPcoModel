* Kontserniv�lise k�tuse hankelepingud lepingud

Set
  lepingu_nr     /1*100/
  lepingu_para   /hind         "Lepingu MWh hind Eurodes"
                  kogus        "Lepingu maht MWh"
                  kyttevaartus "Lepingus hangitava k�tuse k�ttev��rtus"
                 /

  yhik           /
                  m3     "Kuupmeeter"
                  t      "Tonn"
                  MWh    "MWh k�tus"
                  Toode  "�hik toodet"
                  EUR    "Euro"
                 /
;

Parameter
  ostuleping(lepingu_nr, aasta, kuu, k, primaarenergia, lepingu_para)

  ost_kogus            (lepingu_nr, primaarenergia, yhik, aasta, kuu)
  ost_kyttevaartus     (lepingu_nr, primaarenergia, aasta, kuu)
  ost_transpordita(lepingu_nr, primaarenergia, aasta, kuu)
  ost_transpordiga_EEJ(lepingu_nr, primaarenergia, aasta, kuu)
  ost_transpordiga_BEJ(lepingu_nr, primaarenergia, aasta, kuu)
;

$ifthen.two "%ost%" == "true"
$load ost_kogus ost_kyttevaartus ost_transpordiga_EEJ ost_transpordiga_BEJ ost_transpordita

* Teeme tonnideks �mber
ost_kogus(lepingu_nr, primaarenergia, "MWh", aasta, kuu)$(ost_kyttevaartus(lepingu_nr, primaarenergia, aasta, kuu) > 0)
         = ost_kogus(lepingu_nr, primaarenergia, "MWh", aasta, kuu)
         / ost_kyttevaartus(lepingu_nr, primaarenergia, aasta, kuu);

* Ja n��d v�tame kogustest (k�ik tonnides juba) maksimaalse ja kirjutame sisendiks
ostuleping(lepingu_nr, aasta, kuu, "Hange", primaarenergia, "kogus")
         = smax(yhik, ost_kogus(lepingu_nr, primaarenergia, yhik, aasta, kuu));

* Hind on antud EUR/MWh kohta
ostuleping(lepingu_nr, aasta, kuu, "Hange", primaarenergia, "hind")
         = ost_transpordita(lepingu_nr, primaarenergia, aasta, kuu);

ostuleping(lepingu_nr, aasta, kuu, "Hange", primaarenergia, "kyttevaartus")
         = ost_kyttevaartus(lepingu_nr, primaarenergia, aasta, kuu);
$endif.two






