File C_OPT cplex option file  / cplex.opt /;
Put C_OPT;
Put      'barobjrng=1E75' /
*         'bardisplay=1'/
*         'mipdisplay=2'/
         'names=no'/
         'heurfreq=100'/
         'lpmethod=4'/
         'memoryemphasis=0'/
         'parallelmode=-1'/
         'aggind=20'/
         'prepass=50'/
*         'nodefileind=2'/
*** Eksperimentaalne MIP kiirendamine ******
*         'prepass=20'/
*         'perind=1'/
*         'epper=0.0001'/
*         'cuts=-1'/
*         'implbd=2'/
*         'ppriind=1'/
*         'varsel=3'/
*         'epint=0.001'/
*         'nodesel=0'/
********************************************
         'startalg=4'/
         'subalg=4'/
*         'baralg=2' /
*         'barorder=3' /
*         'barstartalg=4'/
$if not "%numsim%" == "1"   'barcrossalg=-1'/
$if     "%numsim%" == "1"   'barcrossalg=-1'/
$ifthen.pq "%nk%" == "true"
         'threads=8'/
         'mipstart=1'/
         'advind=1'/
*         'barcrossalg=-1'/
$elseif.pq "%nkl%" == "true"
         'threads=8'/
$else.pq
         'threads=-1'/
$endif.pq

$if     set max_marg 'solvefinal=1'/
$if not set max_marg 'solvefinal=1'/

         'tilim=1E75'/
*         'depind=3'/
         'feasoptmode=3'/
         'relaxfixedinfeas=1'/
*         'advind=0'/

*         'indic v_cleaning1(time_t, t_el)$k_alpha(time_t, t_el) 1'/
         ;
Putclose C_OPT;
