********************************************************************************
**                                                                             *
** Data structures and parameters for logistics and storage                    *
**                                                                             *
**  Peeter Meos                                                                *
********************************************************************************

Set
  storage                               "All storage units"
  storage_agg                           "Aggregated storage"
;
$loaddc storage=laod storage_agg=laod_kokku

Set
  storage_tuple(storage_agg, storage)   "Storage aggregation tuple for overall storage quantities"
  s_t(storage)                          "Storage at production units (subset)"
  s_k(storage)                          "Storage at mining units (subset)"
  route                                 "Logistics route from mine to production unit"
  l                                     "Route endpoints"
;

$loaddc storage_tuple=laod_tuple s_k=l_k s_t=l_t route=liinid l

Sets
  mine_storage(k, s_k)                  "Tuple connecting mines and respective storage"
  prod_storage(s_t, t)                  "Tuple connecting production units and respective storage"
  no_storage(k, feedstock, storage)     "Feedstock that cannot be stored"
  k_dp_storage(route, s_k)              "Loading point tuple for mine storage"
  route_endpoint(route, k, l)           "Beginning and enpoint of a given route"
  t_dp_prod(l, t)                       "Loading point tuple for production units"
  t_dp_storage(l, s_t)                  "Loading point tuple for production unit storage"
  log_f_constraint(route, feedstock)    "Allowed combinations of logistic lines and fuel types"
;

$loaddc mine_storage=kaevandused_ja_laod prod_storage=tootmine_ja_laod
$loaddc no_storage=ladustamatu_primaarenergia k_dp_storage=k_jp_ladu route_endpoint=liini_otsad
$loaddc t_dp_prod=t_jp_tootmine t_dp_storage=t_jp_ladu
$loaddc log_f_constraint

Parameter
* Storage capacities
  max_storage(storage)                  "Storage maximal capacity (t)"
  min_storage(storage)                  "Minimum allowed stock level (t)"

* Route and loading capacities
  max_throughput(l)                     "Maximal throughput for logistic routes (t/day)"
  max_loading_k(k, year)                "Maximal loading capacity at mines (t/day)"
  max_loading_l(l, year)                "Maximal loading capacity at route endpoints (t/day)"

* Variable costs
  storage_vc(storage)                   "Variable cost for storage (EUR/t)"
  log_vc(route, year)                   "Logistics variable cost by route (EUR/t)"

* Initial levels at storage
  initial_storage(storage, k, feedstock)"Initial storage levels (t)"
;

$loaddc max_storage=max_laomaht min_storage=min_laomaht storage_vc=laokulud
$loaddc max_throughput=max_labilase max_loading_k=max_laadimine_k max_loading_l=max_laadimine_l log_vc=logistikakulu
$loaddc initial_storage=alguse_laoseisud

no_storage("Hange", "Lubi", storage) = yes;


