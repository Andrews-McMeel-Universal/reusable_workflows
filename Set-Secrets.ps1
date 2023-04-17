param (
    [parameter(Mandatory = $false)]
    $KeyVaultRG = "AMU_KeyVaults_RG",
    [parameter(Mandatory = $false)]
    $File = "Secrets.json"
)

#Check to see if Az module is installed
if (!(Get-Module -ListAvailable Az)) {
    Write-Host "Installing Azure Powershell Module."
    Install-Module -Name Az -Confirm:$false -Force
}

Import-Module Az -ErrorAction SilentlyContinue

$RepositoryName = ((git remote get-url origin).Split("/")[-1].Replace(".git",""))

$keyVaults = (Get-Content -Path $File | ConvertFrom-Json).PSObject.Properties
$keyVaults | ForEach-Object {
    $KeyVaultName = $_.Name
    $Environment = $KeyVaultName.Split('-')[-1]
    $KeyVault = New-AzKeyVault -Name $KeyVaultName -ResourceGroupName "$KeyVaultRG" -Sku Standard -EnableRbacAuthorization -Location 'Central US' -Tag @{"environment"="$Environment";"repository-name"="$RepositoryName"} -ErrorAction SilentlyContinue
    if (!$KeyVault) {
        $KeyVault = Get-AzKeyVault -VaultName $KeyVaultName
        if ((! $KeyVault.Tags.environment -eq "$Environment") -or (! $KeyVault.Tags."repository-name" -eq "$RepositoryName")) {
            $KeyVault = $KeyVault | Update-AzKeyVault -Tags @{"environment"="$Environment";"repository-name"="$RepositoryName"}
            Write-Host "Updated tags on $KeyVaultName" -ForegroundColor Green
        }
        else {
            Write-Host "No changes to $KeyVaultName" -ForegroundColor DarkGray
        }
    }
    else {
        Write-Host "Created $KeyVaultName" -ForegroundColor Green
    }
    $secrets = $_.Value
    $secrets | ForEach-Object {
        $SecretName = $_.SecretName.ToLower().Replace("_", "-")
        $SecretValue = $_.SecretValue
        $ContentType = $_.ContentType
        $CurrentContentType = (Get-AzKeyVaultSecret -VaultName $KeyVaultName -SecretName "$SecretName").ContentType   
        $CurrentValue = (Get-AzKeyVaultSecret -VaultName $KeyVaultName -SecretName "$SecretName" -AsPlainText)
        if (($CurrentValue -ne $SecretValue) -or ($CurrentContentType -ne $ContentType)){
            $Secret = Set-AzKeyVaultSecret -VaultName $KeyVaultName -SecretName "$SecretName" -SecretValue ("$SecretValue" | ConvertTo-SecureString -AsPlainText -Force) -ContentType "$ContentType"
            Write-Host "[$KeyVaultName] Updated $($_.SecretName)" -ForegroundColor Green
        }
        else {
            Write-Host "[$KeyVaultName] No changes to $($_.SecretName)" -ForegroundColor DarkGray
        }
    }
}