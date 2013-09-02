$path = Split-Path $MyInvocation.InvocationName

Import-Module $path\explain.psm1 -Force

explain gcm -Noun Module
explain gci *.txt -Path D:\
explain Get-ChildItem -rec -fo:$true -fi *.txt