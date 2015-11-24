********************************************************************************
**                                                                             *
** Primary energy related data structures and elements.                        *
** Includes also some preprocessing for calorific value (mind the units!)      *
**                                                                             *
**  Peeter Meos                                                                *
********************************************************************************

* These two are the main sets that define feedstock with its source
* used pretty much everywhere throughout the model

Sets
  k         "Sources of feedstock"
  feedstock "Feedstock used in production"
;

$loaddc k

Sets
 k_eek(k)   "Eesti Energia Kaevandused"
 /
 Estonia
 Narva1
 Narva2
 /
;
$loaddc feedstock=primaarenergia

alias(feedstock, p2);
alias(k, k2);

Sets
  k_mines(k, feedstock)    "The type of preprocessed material actually mined or acquired"
  fs_k(k, feedstock)       "Tuple to filter feasible feedstock-mine combinations, used extensively throughout"
  gas(feedstock)           "Gas subset"
  oilshale(feedstock)      "Subtypes of oilshale"
  /
  Energeetiline            "Standard oil shale (8.4 MJ/kg)"
  Madal                    "Low CV oil shale (7.5 MJ/kg)"
  Kaevis                   "Raw oil shale (7.0 MJ/kg)"
  Labindus                 "Raw oil shale (7.0 MJ/kg)"
  /
;
$loaddc gas=gaas fs_k=primaar_k k_mines=k_kaeve

********************************************************************************
**                                                                             *
** Now let's load some basic parameters for the mines and feedstock            *
**                                                                             *
********************************************************************************

Parameter
  max_mining_cap(k, feedstock, year, month) "Mining capacities (MWh/month)"
  fs_vc(k, feedstock, year)                 "Feedstock variable costs (ie. mining costs) (EUR/t)"
  enrichment_coef(feedstock, k, p2)         "Proportion of raw shale(material) converted into usable feedstock (%)"
  cv_mwh(feedstock, k)                      "Calorific values (MJ/kg)"
  cv(feedstock, k, unit)                    "Calorific values (MWh/t) or (MJ/kg)"

  fs_min_acq(k, feedstock, year, month)     "Minimal contractually allowed acquisition of feedstock (t)"
  perm_mining(year, month, k, feedstock)    "Permitted mining and enrichment at given mine"

  tailings_pct(k)                           "Percentage of tailings left over from raw shale (%)"
  sieve_pct(k)                              "Percentage of sieved oil shale in raw oil shale (%)"
  cont_pct(k)                               "Percentage of concentrated oil shale in raw oil shale (%)"
  k_workday(k, weekday)                     "Is the mine operation at a given weekday (0/1)?"

  sieve_cv(k)                               "Calorific value of sieved oil shale (MWh/t)"
  concentrate_price(year)                   "Price of concentrated oil shale for sale (EUR/t)"
;

$loaddc max_mining_cap=max_kaeve fs_vc=k_muutuvkulud enrichment_coef=rikastuskoefitsent cv_mwh=kyttevaartus fs_min_acq=prim_min_tarne perm_mining=lubatud_kaeve
$loaddc tailings_pct=aher_pct sieve_pct=soel_pct cont_pct=konts_pct k_workday=k_toopaev
$loaddc sieve_cv=soelise_kyttevaartus concentrate_price=kontsentraadi_hind

cv(feedstock, k, unit) = cv_mwh(feedstock, k);

* Bogus non-zero calorific value for lime
cv(feedstock, k, "MJ")$(sameas(feedstock, "Lubi") and sameas(k, "Hange")) = 0.0000000001;

* Convert MJ/kg to MWh/t
cv(feedstock, k, "MWh")$(not gas(feedstock))  = cv(feedstock, k, "MJ") / 3.6;



Set
  k_enrichment(k)               "Subset of mines with enrichment plants"
  k_works(time_t, weekday, k)   "Tuple indicating whether mine works at a particular day"
;
$loaddc k_enrichment=k_rikastus

k_works(time_t, weekday, k)$(day_type(time_t) = 0) = yes;

********************************************************************************
**                                                                             *
** Calculations:                                                               *
** 1) Conversion of calorific values                                           *
** 2) Estimation of mining variable costs by calorific values                  *
**                                                                             *
********************************************************************************

* Convert from MJ/kg to MWh/t
sieve_cv(k) = sieve_cv(k) / 3.6;

* Calculate variable costs for mines without enrichment plant
fs_vc(k, feedstock, year)$(not k_enrichment(k)
                                              and not sameas(k, "Hange")
                                              and fs_vc(k, feedstock, year) = 0
                                              and fs_k(k, feedstock)
                                              )
  = sum(p2$(k_mines(k, p2)
    and enrichment_coef(p2, k, feedstock) > 0), fs_vc(k, p2, year) / enrichment_coef(p2, k, feedstock));

* Calculate variable costs for mines with enrichment plant
* Input value is variable cost of standard oil shale which is then adjusted porportionally
* by respective calorific values to get variable costs of the remaining feedstock
* This calculation method is provided by Eesti Energia Kaevandused (mr. Meelis Goldberg)

fs_vc(k, feedstock, year)$(k_enrichment(k)
                                             and fs_k(k, feedstock)
                                             and fs_vc(k, feedstock, year) = 0
                                             and(cv("Energeetiline", k, "MWh") - cv("Aheraine", k, "MWh")) > 0)
  =
  fs_vc(k, "Energeetiline", year)
   * (1
      -
     (cv("Energeetiline", k, "MWh") - cv(feedstock, k, "MWh"))
      /
     (cv("Energeetiline", k, "MWh") - cv("Aheraine", k, "MWh"))
     );
