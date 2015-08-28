powershell .\Deploy-Versioning.ps1 > pco_version.gms
copy Library\*.gms \\pcotest\inclib
copy pco_version.gms \\pcotest\inclib
copy pco.gms \\pcotest\gamslib_ml
copy pco-op.gms \\pcotest\gamslib_ml
copy gamslib.glb \\pcotest\gamslib_ml
