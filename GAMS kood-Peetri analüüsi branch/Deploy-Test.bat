powershell .\Deploy-Versioning.ps1 > pco_version.gms
copy Library\*.gms \\enkdevapp3\inclib
copy pco_version.gms \\enkdevapp3\inclib
copy pco.gms \\enkdevapp3\gamslib_ml
