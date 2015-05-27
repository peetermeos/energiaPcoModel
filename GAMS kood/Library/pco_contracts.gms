********************************************************************************
** Definition of acquisition contract related parameters and structures.       *
**                                                                             *
** 31. Oct 2014                                                                *
** Peeter Meos                                                                 *
********************************************************************************

Set
  contract_para  "Contract parameters"
                 /hind         "Contract price in EUR/MWh"
                  kogus        "Contract quantity in MWh"
                  kyttevaartus "Calorific value of the feedstock"
                 /
;

alias(serial2, serial);

Parameter
  contract_s(sim, serial, year, month, k, feedstock, contract_para) "Acquisition contract"
  contract(serial, year, month, k, feedstock, contract_para) "Acquisition contract"

  contr_quantity(serial, feedstock, unit, year, month)             "Contract amount"
  contr_cv     (serial, feedstock, year, month)                    "Contract calorific value"
  contr_wo_logs     (serial, feedstock, year, month)               "Contract price without logistics"
  contr_logs_EEJ (serial, feedstock, year, month)                  "Contract price with logistics to EEJ"
  contr_logs_BEJ (serial, feedstock, year, month)                  "Contract price with logistics to BEJ"
;

$ifthen.two "%prc%" == "true"
$load contr_quantity=ost_kogus contr_cv=ost_kyttevaartus contr_logs_EEJ=ost_transpordiga_EEJ contr_logs_BEJ=ost_transpordiga_BEJ contr_wo_logs=ost_transpordita

* Convert into tons
contr_quantity(serial, feedstock, "MWh", year, month)$(fs_k("Hange", feedstock) and contr_cv(serial, feedstock, year, month) > 0)
         = contr_quantity(serial, feedstock, "MWh", year, month)
         / contr_cv(serial, feedstock, year, month);

* And now take max of the quants (in case amounts are given both in t and MWh)
contract_s(sim, serial, year, month, "Hange", feedstock, "kogus")$(fs_k("Hange", feedstock))
         = smax(unit, contr_quantity(serial, feedstock, unit, year, month));

* Set price
contract_s(sim, serial, year, month, "Hange", feedstock, "hind")
           $(fs_k("Hange", feedstock) and contr_wo_logs(serial, feedstock, year, month) > 0)
         = contr_wo_logs(serial, feedstock, year, month);

* Set calorific value
contract_s(sim, serial, year, month, "Hange", feedstock, "kyttevaartus")
           $(fs_k("Hange", feedstock) and contr_cv(serial, feedstock, year, month) > 0)
         = contr_cv(serial, feedstock, year, month);

contract_s(sim, serial, year, month, "Hange", feedstock, contract_para)
           $(fs_k("Hange", feedstock) and sum(time_t$y_m_t, 1) = 0) = 0;
contract(serial, year, month, "Hange", feedstock, contract_para)
         $fs_k("Hange", feedstock)
       = contract_s("1", serial, year, month, "Hange", feedstock, contract_para);

Parameter contract_s1(sim, serial, year, month, k, feedstock, contract_para);
contract_s1(sim, serial, year, month, "Hange", feedstock, contract_para)
            $(fs_k("Hange", feedstock) and not sameas(contract_para, "Kyttevaartus"))
          = contract_s(sim, serial, year, month, "Hange", feedstock, contract_para);
$endif.two

