powershell .\Deploy-Versioning.ps1 > pco_version.gms
copy Library\*.gms \\pcodevapp2\inclib
copy pco_version.gms \\pcodevapp2\inclib
copy pco.gms \\pcodevapp2\gamslib_ml
