#Requires -Version 5.1

param (
    [Parameter(HelpMessage = "profiles")]
    [string[]]$Profiles
)

# check if config.json exists
$configFile = "$HOME/.win-setup/config.json"
if (-not (Test-Path $configFile)) {
    # create configFile with $schema and echo "hello world" action
    $config = @{
        "$schema" = "https://raw.githubusercontent.com/cethien/win-setup/main/schemas/config.schema.json"
        actions   = @(
            @{
                script = "echo `"Hello World! please edit $HOME/.win-setup/config.json`""
            }
        )
    } | ConvertTo-Json -Depth 10 | Set-Content $configFile
    exit
}

$config = Get-Content "$HOME/.win-setup/config.json" | ConvertFrom-Json

$config.actions | ForEach-Object {
    $_.prepare_script | ForEach-Object { Invoke-Expression $_ }

    Invoke-Expression $_.script

    $_.winget_packages | ForEach-Object {
        $cmd = "winget install --accept-source-agreements --accept-package-agreements --source winget --Id $($_.id) $($_.install_flags -join " ")"
        $cmd | Invoke-Expression

        if ($_.exclude_from_updatefile -ne $true) {
            Add-Content $env:USERPROFILE/.wingetupdate "$($_.id)`n"
        }
    }

    $_.pwsh_modules | ForEach-Object {
        Install-Module $_
    }

    Invoke-Expression $_.post_install_script
}