function Unique-Property([Parameter(ValueFromPipeline)] $Input, [Parameter(Position = 1)] $property) {
    $Input | Group-Object $property | %{ $_.Group | Select *  -First 1 }
}

function grep {
    [CmdletBinding()]
    Param(
    [Parameter(ValueFromPipeline)] $Input,
    [Parameter(Position = 1)] $TextPattern,
    [Parameter(Position = 2)] $FilePattern,
    [switch] $Recurse,
    [switch] $Unique)

    process {
        if(-not $FilePattern -and -not $TextPattern -and -not $Input) {
            throw "Nothing to grep on, pipe something or use a file pattern, e.g.`ngrep test *.txt`nls *.txt | grep test"
        }
        $piper = if ($FilePattern -and -not $Input) { ls $FilePattern -Recurse:$Recurse } else { $Input }
        $selected = $piper | sls $TextPattern | select Path,LineNumber,Line
        $wanted = if ($Unique) { $selected | Unique-Property Path } else { $selected }
        $wanted | %{
            Write-Host "$($_.Path):$($_.LineNumber)" -ForegroundColor Yellow -NoNewline
            Write-Host "`t$($_.Line)" -ForegroundColor Green
        }
    }
}
