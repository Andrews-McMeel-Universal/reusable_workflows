param (
    [string]$KeyVaultName,
    [string]$File = '.env',
    [string]$RepositoryName = ((git remote get-url origin).Split("/")[-1].Replace(".git","")),
    [string]$Environment = "development"
)

#Check to see if Az module is installed
if (!(Get-Module -ListAvailable Az)) {
    Write-Host "Installing Azure Powershell Module."
    Install-Module -Name Az -Confirm:$false
}

Import-Module Az -ErrorAction SilentlyContinue
Clear-Content -Path $File -ErrorAction SilentlyContinue

if (!"$KeyVaultName") {
    if (!$PSBoundParameters.ContainsKey('Environment')) {
        Write-Host "Environment missing. Defaulting to development." -ForegroundColor DarkGray
    }

    Write-Host "Searching for Key Vault..." -ForegroundColor DarkGray
    $KeyVaultName = (Get-AzKeyVault -Tag @{"environment" = "$Environment" } | Get-AzKeyVault -Tag @{"repository-name" = "$RepositoryName" }).VaultName
    Write-Host "Key Vault found: $KeyVaultName" -ForegroundColor DarkGray
}

$Secrets = (Get-AzKeyVaultSecret -VaultName $KeyVaultName).Name
if ($Secrets) {
    Write-Host "Retrieving Secrets..." -ForegroundColor DarkGray
}
$Secrets | ForEach-Object {
    $SecretName = $_.ToUpper().Replace("-", "_").Replace("`"", "")
    $SecretValue = (Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $_).SecretValue | ConvertFrom-SecureString -AsPlainText
    $Secret = $SecretName + "=" + $SecretValue
    Add-Content -Path $File -Value $Secret
}

Write-Host "Environment file $File generated.  Content is:" -ForegroundColor Green
Get-Content $File