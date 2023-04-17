param (
    [parameter(Mandatory = $false)]
    [string]$File = "Secrets.json",
    [parameter(Mandatory = $false)]
    [switch]$Encrypt,
    [parameter(Mandatory = $false)]
    [switch]$Decrypt
)

if ((!$Decrypt) -and (!$Encrypt)) {
    Write-Error "Please use either -Decrypt or -Encrypt when calling the script"
}

if ($File -match "\.gpg") {
    $File.Replace(".gpg", "")
}

if ($Encrypt) {
    Write-Output "Encrypting the $File file for this project. Please search 1Password for the secret passphrase under the name: '.env files encryption secret'!"
    gpg -c $File
}
elseif ($Decrypt) {
    Write-Output "Decrypting the $File file for this project. Please search 1Password for the secret passphrase under the name: '.env files encryption secret'!"
    gpg --output $File --decrypt $File".gpg"
}
