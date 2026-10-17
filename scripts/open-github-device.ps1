[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
param(
    [string]$ChromePath,
    [string]$VerificationUri = 'https://github.com/login/device',
    [switch]$PlanOnly
)
$ErrorActionPreference = 'Stop'
$uri = [Uri]$VerificationUri
if (-not $uri.IsAbsoluteUri -or $uri.Scheme -ne 'https' -or
    $uri.Host -ne 'github.com' -or $uri.Port -ne 443 -or
    $uri.AbsolutePath -ne '/login/device' -or $uri.UserInfo -or
    $uri.Query -or $uri.Fragment) {
    throw 'Only https://github.com/login/device is accepted. Do not put a device code in a URL.'
}
if ($ChromePath) {
    $candidates = @($ChromePath)
} else {
    $candidates = @()
    foreach ($rootPath in @($env:ProgramFiles, ${env:ProgramFiles(x86)}, $env:LOCALAPPDATA)) {
        if ($rootPath) { $candidates += Join-Path $rootPath 'Google\Chrome\Application\chrome.exe' }
    }
}
$chrome = $candidates | Where-Object {
    [IO.Path]::IsPathRooted($_) -and [IO.Path]::GetFileName($_) -ieq 'chrome.exe' -and
    (Test-Path -LiteralPath $_ -PathType Leaf)
} | Select-Object -First 1
if (-not $chrome) { throw 'Chrome was not found. Supply its existing absolute chrome.exe path; do not install or change browsers automatically.' }
$chrome = (Resolve-Path -LiteralPath $chrome).ProviderPath
$arguments = @('--new-window', $uri.AbsoluteUri)
if ($PlanOnly) {
    [pscustomobject]@{ ChromePath=$chrome; Arguments=$arguments; VerificationUri=$uri.AbsoluteUri; OpensBrowser=$false }
    return
}
if ($PSCmdlet.ShouldProcess($uri.AbsoluteUri, 'Open the official GitHub device page in Chrome')) {
    # Visible because this workflow explicitly asks the user to complete web authentication.
    $process = Start-Process -FilePath $chrome -ArgumentList $arguments -PassThru
    [pscustomobject]@{ ChromePath=$chrome; VerificationUri=$uri.AbsoluteUri; ProcessId=$process.Id; PageObserved=$false; AuthenticationVerified=$false }
}
