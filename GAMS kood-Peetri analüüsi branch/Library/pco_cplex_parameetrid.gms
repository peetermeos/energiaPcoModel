File C_OPT cplex option file  / cplex.opt /;
Put C_OPT;
Put      'barobjrng=1E75' /
         'names=no'/
         'heurfreq=100'/
         'lpmethod=4'/
         'memoryemphasis=0'/
         'parallelmode=-1'/
*** Eksperimentaalne MIP kiirendamine ******
         'prepass=20'/
         'perind=1'/
         'epper=0.0001'/
         'cuts=2'/
         'implbd=2'/
         'ppriind=1'/
         'varsel=3'/
         'epint=0.001'/
         'epagap=1000'/
         'varsel=3'/
         'nodesel=0'/
         'mipdisplay=4'/
*** NB!
         'barcrossalg=-1'/
********************************************
         'startalg=4'/
         'subalg=4'/
         'baralg=2' /
         'barorder=3' /
         'barstartalg=4'/
$ifthen.pq "%noudluskover%" == "true"
         'threads=8'/
         'mipstart=1'/
         'advind=1'/
         'barcrossalg=-1'/
$elseif.pq "%noudluskover_suur%" == "true"
         'threads=8'/
$else.pq
         'threads=-1'/
$endif.pq

$if     set max_marg 'solvefinal=1'/
$if not set max_marg 'solvefinal=0'/

         'tilim=1E75'/
         'depind=3'/
         'feasoptmode=3'/
         'relaxfixedinfeas=1'/
         'advind=0'/
$ifthen "%debug%" == "1"
         'feasOpt=true'/
         'refineConflict=true'/
$endif
         ;
Putclose C_OPT;
