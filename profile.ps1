Set-ExecutionPolicy -ex RemoteSigned -s CurrentUser;

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
        $piper = if ($FilePattern -and -not $Input) { ls $FilePattern -Recurse:$Recurse } elseif ($TextPattern -and -not $Input) { ls -Recurse:$Recurse } else { $Input }
        $selected = $piper | sls $TextPattern | select Path,LineNumber,Line
        $wanted = if ($Unique) { $selected | Unique-Property Path } else { $selected }
        $wanted | %{
            Write-Host "$($_.Path):$($_.LineNumber)" -ForegroundColor Yellow -NoNewline
            Write-Host "`t$($_.Line)" -ForegroundColor Green
        }
    }
}


function part {
    [CmdletBinding()]
    Param(
    [Parameter(ValueFromPipeline)] $Input,
    [Parameter(Position = 1)] $Pattern,
    [Parameter(Position = 2)] $Part,
    [Parameter(Position = 3)] $Idx,
    [switch] $All)
    process {
        $str = $Input | Out-String -Stream
        $matches = ([regex]$Pattern).Matches($str)
        if($All) {
            $mc = 0
            Write-Host "Found $($matches.Count) match(es)"
            $matches.ForEach({
                Write-Host "> Index $mc`: $_"
                for($i = 0; $i -lt $_.Groups.Count; $i++) {
                    Write-Host "-- Group $($_.Groups[$i].Name): $($_.Groups[$i].Value)"
                }
                $mc++
            })
            return
        }
        if($matches.Count -gt 0) {
            if($Part) {
                if($Idx -is [int]) {
                    return $matches[$Idx].Groups[$Part].Value
                } else {
                    return $matches[0].Groups[$Part].Value
                }
            } elseif ($Idx -is [int]) {
                $num = if($Idx) { $Idx } else { 0 }
                return $matches[$num].Groups[1].Value
            } else {
                return $matches
            }
        } else {
            Write-Host "No matches"
        }
    }
}
