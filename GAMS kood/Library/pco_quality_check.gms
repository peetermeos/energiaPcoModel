********************************************************************************
**                                                                             *
** Pre-solve quality check for the model. Hopefully we can weed out            *
** infeasibilities.                                                            *
**                                                                             *
**  2. Oct 2014                                                                *
**  Peeter Meos                                                                *
********************************************************************************

* Minimum stock levels

loop(storage$(min_storage(storage) > 0),
  if(sum((k , feedstock), initial_storage(storage, k, feedstock)) < min_storage(storage),
    abort "Minimum levels of stock not met!"
  );
);

* Calorific values - check for zeroes in legit fuels

if(sum((k, feedstock)$(cv(feedstock, k, "MWh") = 0
                   and fs_k(k, feedstock)), 1 ) > 0,
  abort "At least one feedstock has calorific fuel equal to zero!"
);
