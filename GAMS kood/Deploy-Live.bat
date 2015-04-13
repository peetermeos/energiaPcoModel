powershell .\Deploy-Versioning.ps1 > pco_version.gms
copy Library\*.gms \\pcolive\inclib
copy pco_version.gms \\pcolive\inclib
copy pco.gms \\pcolive\gamslib_ml
copy pco-op.gms \\pcolive\gamslib_ml

copy gamslib.glb \\pcolive\gamslib_ml
