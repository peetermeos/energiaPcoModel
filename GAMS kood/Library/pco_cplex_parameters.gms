File C_OPT cplex option file  / cplex.opt /;
Put C_OPT;
Put      'barobjrng=1E75' /
         'names=no'/
         'heurfreq=100'/
         'lpmethod=4'/
         'memoryemphasis=0'/
         'parallelmode=1'/
         'aggind=20'/
         'prepass=50'/
         'startalg=4'/
         'subalg=4'/
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
         'feasoptmode=3'/
         'relaxfixedinfeas=1'/
         ;
Putclose C_OPT;
