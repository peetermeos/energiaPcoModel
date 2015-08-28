#Vıta versioonid
$version = &'C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\tf.exe' history * /noprompt /stopafter:1
#Kuva versioonid
#$version
#V‰‰rtused
$values = $version[2].Split(" ")
#Nimed
$names = $version[0].Split(" ")

$nl = [Environment]::NewLine

#V‰ljundfail
$conf = "Set VCS /Changeset/;" + $nl
$conf += "Variable vcs_changeset(VCS);" + $nl
$conf += "vcs_changeset.fx('Changeset') = " + $values[0] + ";" + $nl

$conf 
# out-file pco_version.gms