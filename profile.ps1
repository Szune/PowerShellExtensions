function grep($text, $filePattern) {
    ls $filePattern -R | sls $text | select Path,LineNumber,Line | %{"$($_.Path):$($_.LineNumber) $($_.Line)"}
}