param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Args
)

$target = Join-Path $PSScriptRoot "devcontainer-preflight.ps1"
& $target @Args
exit $LASTEXITCODE
