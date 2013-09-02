#requires -Version 2

function Get-CommandExplanation {
    $cmdline = $args -join ' '
    $tokens = [System.Management.Automation.PSParser]::Tokenize($cmdline, [ref]$null)

    # Assume the first token is a command or alias
    $command = Get-Command $tokens[0].Content -ErrorAction Stop
    if ($command.CommandType -eq 'Alias') {
        $command = $command.ReferencedCommand
    }
    # Retain only the arguments
    $tokens = $tokens | Select-Object -Skip 1
    "Command: $command"

    # Group parameters and arguments (when applicable)
    $parameters =
        $tokens |
        ForEach-Object {
            $currentParameter = $null
            $currentPosition = 0
        } {
            if ($_.Type -eq 'CommandParameter') {
                # First figure out the parameter
                $paramString = $_.Content -replace '^-'
                if ($paramString.EndsWith(':')) {
                    $switchParamWithArgument = $true
                    $paramString = $paramString -replace ':^'
                }
                $param = $command.ResolveParameter($paramString)
                if ($param.SwitchParameter -and !$switchParamWithArgument) {
                    New-Object PSObject -Property @{
                        Type = 'Switch'
                        Name = $param.Name
                        Value = $true
                        Position = -1
                    } | Select-Object Type,Name,Position,Value
                } else {
                    $currentParameter = New-Object PSObject -Property @{
                        Type = 'Named'
                        Name = $param.Name
                        Value = $null
                        Position = -1
                    } | Select-Object Type,Name,Position,Value
                }
            }
            if ($_.Type -eq 'CommandArgument') {
                if (!$currentParameter) {
                    # This would be a positional parameter
                    New-Object PSObject -Property @{
                        Type = 'Positional'
                        Name = $null
                        Position = $currentPosition
                        Value = $_.Content
                    } | Select-Object Type,Name,Position,Value
                    $currentPosition++
                } else {
                    $currentParameter.Value = $_.Content
                    $currentParameter
                    $currentParameter = $null
                }
            }
        }

    $parameters
}

New-Alias explain Get-CommandExplanation
New-Alias Explain-Command Get-CommandExplanation

Export-ModuleMember -Alias explain,Explain-Command -Function Get-CommandExplanation