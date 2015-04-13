********************************************************************************
**                                                                             *
**  See tükk koodi kirjeldab PCO sihifunktsiooni                               *
**  Sihifunktsioon koosneb muutuvtuludest (toodang * referentshinnad)          *
**  miinus muutuvkulud (heitmed, transa jne)                                   *
**                                                                             *
**  30. dets 2013                                                              *
**  Peeter Meos                                                                *
********************************************************************************

Equations  sihifunktsioon                    "Üldine sihifunktsioon (EUR)";

sihifunktsioon..
  kasum =e=  sum((opt_paev),
(

$libinclude pco_sihifun_elekter
$libinclude pco_sihifun_heitmed
$libinclude pco_sihifun_ket

$if "%kkul%"          == "true" $libinclude pco_sihifun_kaivitus
$if "%soojus%"        == "true" $libinclude pco_sihifun_soojus
$if "%myyk%"          == "true" $libinclude pco_sihifun_myyk
$if "%oli%"           == "true" $libinclude pco_sihifun_oli
$if "%laod%"          == "true" $libinclude pco_sihifun_laod
$if "%logistika%"     == "true" $libinclude pco_sihifun_logistika
$if "%kaevandused%"   == "true" $libinclude pco_sihifun_kaevandused
$if "%ost%"           == "true" $libinclude pco_sihifun_ostulepingud
)
$if "%diskonteerimine%" == "true" $libinclude pco_sihifun_diskonteerimine
)
$if "%laojaak%" == "true" $libinclude pco_sihifun_laojaak
$if "%pysikulud%" == "true" $libinclude pco_sihifun_pysikad
;
