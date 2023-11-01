$apps = @(
    "Mozilla.Firefox.ESR",
    "TheDocumentFoundation.LibreOffice"
)

$ProgressPreference = "SilentlyContinue"
Set-Location -Path $ENV:USERPROFILE

try {Winget | Out-Null}
catch {
    Invoke-WebRequest -Uri "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -OutFile VCLibs.appx -UseBasicParsing; Add-AppxPackage -Path .\VCLibs.appx; Remove-Item -Path .\VCLibs.appx
    Invoke-WebRequest -Uri "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx" -OutFile Xaml.appx -UseBasicParsing; Add-AppxPackage -Path .\Xaml.appx; Remove-Item -Path .\Xaml.appx

    $assets = (Invoke-WebRequest -Uri "https://api.github.com/repos/microsoft/winget-cli/releases/latest" -UseBasicParsing).Content | ConvertFrom-Json | Select-Object -ExpandProperty "assets"

    $uri = $assets | Where-Object "browser_download_url" -Match '.msixbundle' | Select-Object -ExpandProperty "browser_download_url"; Invoke-WebRequest -Uri $uri -OutFile "Winget.msixbundle" -UseBasicParsing
    $uri = $assets | Where-Object "browser_download_url" -Match 'License1.xml' | Select-Object -ExpandProperty "browser_download_url"; Invoke-WebRequest -Uri $uri -OutFile "Winget_License.xml" -UseBasicParsing

    Add-AppxProvisionedPackage -Online -PackagePath .\Winget.msixbundle -LicensePath .\Winget_License.xml; Remove-Item -Path .\Winget.msixbundle; Remove-Item -Path .\Winget_License.xml
}

$installed = [String]::Join("",(Winget List --accept-source-agreements --accept-package-agreements))
$apps | ForEach-Object {if (!$installed.contains($_)) {winget install -e --silent --accept-source-agreements --accept-package-agreements --id $_}}  