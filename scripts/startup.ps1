Set-ExecutionPolicy Bypass -Scope Process -Force;
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco feature enable -n allowGlobalConfirmation

choco install git -y

choco install choco install visualstudio2019buildtools -y

choco install azure-cli -y

write-output "finished installing chocolatey";

$path = "c:\actions-runner"
if(!(test-path $path))
{
    New-Item -ItemType Directory -Force -Path $path
}

Set-Location $path

$version = "2.283.3"
Invoke-WebRequest -Uri "https://github.com/actions/runner/releases/download/v$version/actions-runner-win-x64-$version.zip" -OutFile actions-runner-win-x64.zip

Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/actions-runner-win-x64.zip", "$PWD")

#./config.cmd remove

./config.cmd --url "${runner_url}" --token "${runner_token}" `
    --windowslogonaccount "${user}" --windowslogonpassword "${password}" `
    --labels "${labels}" `
    --runasservice --unattended --replace