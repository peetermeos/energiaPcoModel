Set num_scen /1*20/;

Parameter
  scenario(sim)     "Scenario description"
  u(sim, num_scen)  "Uniformly distributed RV"
  val
;

* Seed the generator
execseed = 1 + gmillisec(jnow);

u(sim, num_scen) = uniform(0, 1);

* Reset scenarios
scenario(sim) = 0;

$ontext
********************************************************************
* Elektri stsenaariumid                                            *
********************************************************************
* Auvere ehitus venib kolm kuud, 30% tõenäosus
  val = 0.3;
  scenario(sim)$(u(sim, "1") < val) = scenario(sim) + 2 ** 1;
  max_load_el_s(sim, "AUVERE1", year, month)$(u(sim, "1") < val and
           ord(month) > 4) = max_load_el_temp("AUVERE1", year,   month--4);
  max_load_el_s(sim, "AUVERE1", year, month)$(u(sim, "1") < val and
           not ord(month) > 4) = max_load_el_temp("AUVERE1", year-1, month--4);

* Auvere ehitus saab varem valmis, 20% tõenäosus
  val = 0.8;
  scenario(sim)$(u(sim, "1") > val) = scenario(sim) + 2 ** 2;
  max_load_el_s(sim, "AUVERE1", year, month)$(u(sim, "1") > val and
      ord(month) < 10) = max_load_el_temp("AUVERE1", year,   month++3);
  max_load_el_s(sim, "AUVERE1", year, month)$(u(sim, "1") > val and
  not ord(month) < 10) = max_load_el_temp("AUVERE1", year+1, month++3);

********************************************************************
* Õli stsenaariumid                                                *
********************************************************************
* Enefit ei lähe korralikult tööle, töötab poole koormusega, 50% tõenäosus
  val = 0.5;
  scenario(sim)$(u(sim, "3") < val) = scenario(sim) + 2 ** 3;
  max_load_ol_s(sim, "ENE1", year, month)$(u(sim, "3") < val)
     = max_load_ol_s(sim, "ENE1", year, month) * 0.5;

********************************************************************
* Transpordirisk üle piiri                                         *
********************************************************************
* Kivisüsi tuleb tuua laevaga, P(x)~0.5, muutuvkulud  +2 EUR/MWh
  val = 0.5;
  scenario(sim)$(u(sim, "4") < val) = scenario(sim) + 2 ** 4;
  contract_s(sim, serial, year, month, "Hange", "Kivisysi", "hind")
    $(u(sim, "4") < val
  and contract_s(sim, serial, year, month, "Hange", "Kivisysi", "hind") > 0)
  = contract_s(sim, serial, year, month, "Hange", "Kivisysi", "hind") + 2;

  val = 0.3;
* Põlevkivi toomine osutub võimatuks P(x)~0.3
  scenario(sim)$(u(sim, "5") < val) = scenario(sim) + 2 ** 5;
  contract_s(sim, serial, year, month, "Hange", "Energeetiline", "kogus")
    $(u(sim, "5") < val) = 0;

********************************************************************
* Põlevkivi counterparty risk                                      *
********************************************************************
  val = 0.2;
  scenario(sim)$(u(sim, "6") < val) = scenario(sim) + 2 ** 6;
  contract_s(sim, serial, "2015", month, "Hange", "Energeetiline", "kogus")
     $(u(sim, "6") < val and ord(month) < 3) = 0;

  val = 0.5;
  scenario(sim)$(u(sim, "6") < val) = scenario(sim) + 2 ** 7;
  contract_s(sim, serial, "2015", month, "Hange", "Energeetiline", "kogus")
     $(u(sim, "6") < val and ord(month) < 7) = 0;

********************************************************************
* Keskkonnaload                                                    *
********************************************************************
* Keskkonnalubade pärast kivisütt enne Q3 ei saa

  val = 0.5;
  scenario(sim)$(u(sim, "8") < val) = scenario(sim) + 2 ** 8;
  contract_s(sim, serial, "2015", month, "Hange", "Kivisysi", "kogus")
     $(u(sim, "8") < val and ord(month) < 3) = 0;

  val = 0.2;
  scenario(sim)$(u(sim, "8") < val) = scenario(sim) + 2 ** 9;
  contract_s(sim, serial, "2015", month, "Hange", "Kivisysi", "kogus")
     $(u(sim, "8") < val and ord(month) < 7) = 0;

* Jäätmete lakkamise määrus
* P(x) ~10% Q1
* Kõik on ok

* P(x) ~50% Q3
  val = 0.1;
  scenario(sim)$(u(sim, "10") > val and u(sim, "10") < 0.6)
        = scenario(sim) + 2 ** 10;
  contract_s(sim, serial, "2015", month, "Hange", "LCV", "kogus")
      $(u(sim, "10") > val and u(sim, "10") < 0.6 and ord(month) < 7) = 0;

* P(x) ~40% ei juhtu üldse
  val = 0.6;
  scenario(sim)$(u(sim, "10") > val) = scenario(sim) + 2 ** 11;
  contract_s(sim, serial, "2015", month, "Hange", "LCV", "kogus")
     $(u(sim, "10") > val) = 0;


********************************************************************
* Narva karjääride turvas                                          *
********************************************************************
* Algandmetes hakkab tarne Q3 pihta
* Turvas kaevandatav Q2
  val = 0.2;
  scenario(sim)$(u(sim, "12") < val) = scenario(sim) + 2 ** 12;
  contract_s(sim, serial, "2015", month, "Hange", "Turvas", "kogus")
     $(u(sim, "12") < val and ord(month) > 3)
     = contract_s(sim, serial, "2015", "7", "Hange", "Turvas", "kogus");

* Turvas kaevandatav Q4+
  val = 0.8;
  scenario(sim)$(u(sim, "12") > val) = scenario(sim) + 2 ** 13;
  contract_s(sim, serial, "2015", month, "Hange", "Turvas", "kogus")
     $(u(sim, "12") > val and ord(month) > 9)
     = contract_s(sim, serial, "2015", "7", "Hange", "Turvas", "kogus");
  contract_s(sim, serial, "2015", month, "Hange", "Turvas", "kogus")
     $(u(sim, "12") > val and ord(month) le 9) = 0;

********************************************************************
* VKG tükikivi müük - 50%/50% meil uut lepingut ei tule.           *
********************************************************************
  val = 0.5;
  scenario(sim)$(u(sim, "13") < val) = scenario(sim) + 2 ** 14;
  sale_contract_s(sim, t_mk, k, feedstock, year, month)$(sum(time_t$y_m_t, 1) > 0
      and u(sim, "13") < val)
     = 0;

********************************************************************
* EEJ127 tolmufiltritele ei ole tehnilist lahendust.               *
********************************************************************
  val = 0.3;
  scenario(sim)$(u(sim, "14") < val) = scenario(sim) + 2 ** 15;
  max_load_el_s(sim, t_el, "2015", month)
     $(u(sim, "14") < val
    and (sameas(t_el, "EEJ1") or sameas(t_el, "EEJ2") or sameas(t_el, "EEJ7")))
     = max_load_el_s(sim, t_el, "2015", month) * 0.8;

********************************************************************
* EEJ8 ja BEJ11 tolmufiltritele ei ole tehnilist lahendust.        *
********************************************************************
  val = 0.3;
  scenario(sim)$(u(sim, "15") < val) = scenario(sim) + 2 ** 16;
  max_load_el_s(sim, t_el, "2015", month)
     $(u(sim, "15") < val
    and (sameas(t_el, "EEJ8") or sameas(t_el, "BEJ11")))
     = max_load_el_s(sim, t_el, "2015", month) * 0.8;

********************************************************************
* Pooltes variantides on BEJ12 kinni                               *
********************************************************************

  val = 0.5;
  scenario(sim)$(u(sim, "16") < val) = scenario(sim) + 2 ** 17;
  max_load_el_s(sim, "BEJ12", year, month)$(u(sim, "16") < val) = 0;

$offtext
********************************************************************
* Uttegaasi upgraded                                               *
********************************************************************

  val = 0.3333;
  scenario(sim)$(u(sim, "17") < val) = scenario(sim) + 2 ** 18;
  t_rg_s(sim, "EEJ8", year, month)$(u(sim, "17") < val and sum(time_t$y_m_t, 1) > 0) = 50000;

  val = 0.66666;
  scenario(sim)$(u(sim, "17") > val) = scenario(sim) + 2 ** 19;
  t_rg_s(sim, "EEJ3", year, month)$(u(sim, "17") > val and sum(time_t$y_m_t, 1) > 0) = 50000;
