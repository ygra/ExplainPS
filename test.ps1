$path = Split-Path $MyInvocation.InvocationName

Import-Module $path\explain.psm1 -Force

explain gcm -Noun Module
explain Get-ChildItem -rec -fo:$true -fi *.txt