
Set-Location -Path $ENV:USERPROFILE

try {Winget | Out-Null}
catch {
    Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile VCLibs.appx; Add-AppxPackage -Path .\VCLibs.appx
    Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx -OutFile Xaml.appx; Add-AppxPackage -Path .\Xaml.appx

    $assets = (Invoke-WebRequest -Uri "https://api.github.com/repos/microsoft/winget-cli/releases/latest").Content | ConvertFrom-Json | Select-Object -ExpandProperty "assets"

    $uri = $assets | Where-Object "browser_download_url" -Match '.msixbundle' | Select-Object -ExpandProperty "browser_download_url"; Invoke-WebRequest -Uri $uri -OutFile "Winget.msixbundle" -UseBasicParsing
    $uri = $assets | Where-Object "browser_download_url" -Match 'License\d.xml' | Select-Object -ExpandProperty "browser_download_url"; Invoke-WebRequest -Uri $uri -OutFile "Winget_License.xml" -UseBasicParsing

    Add-AppxProvisionedPackage -Online -PackagePath .\Winget.msixbundle -LicensePath .\Winget_License.xml
}

