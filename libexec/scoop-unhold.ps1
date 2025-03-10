# Usage: scoop unhold <app>
# Summary: Unhold an app to enable updates

. "$PSScriptRoot\..\lib\help.ps1"
. "$PSScriptRoot\..\lib\manifest.ps1"
. "$PSScriptRoot\..\lib\versions.ps1"

reset_aliases
$apps = $args

if(!$apps) {
    my_usage
    exit 1
}

$apps | ForEach-Object {
    $app = $_
    $global = installed $app $true

    if (!(installed $app)) {
        error "'$app' is not installed."
        return
    }

    if (get_config NO_JUNCTIONS) {
        $version = Select-CurrentVersion -App $app -Global:$global
    } else {
        $version = 'current'
    }
    $dir = versiondir $app $version $global
    $json = install_info $app $version $global
    $install = @{}
    $json | Get-Member -MemberType Properties | ForEach-Object { $install.Add($_.Name, $json.($_.Name))}
    $install.hold = $null
    save_install_info $install $dir
    success "$app is no longer held and can be updated again."
}

exit $exitcode
