param(
    [string]$Image = $env:DOCKERHUB_USERNAME,
    [string]$Tag = 'latest'
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    if ([string]::IsNullOrWhiteSpace($Image) -or $Image -match '\s|^\-|@' -or ($Image.Split('/')[-1] -match ':') -or $Tag -cnotmatch '^[a-zA-Z0-9_][a-zA-Z0-9_.-]{0,127}$') {
        throw 'Supply a Docker Hub username or untagged image and an optional -Tag. Example: .\scripts\update-container.ps1 -Image yourname -Tag latest'
    }
    if (-not $Image.Contains('/')) { $Image = "$Image/workshop-app" }
    $reference = "${Image}:${Tag}"
    $name = 'workshop-app'
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { throw 'Install Docker Desktop first.' }
    docker info | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Start Docker Desktop and select Linux containers.' }

    $existing = docker container ls -a --filter "name=^/${name}$" --format '{{.Names}}'
    if ($LASTEXITCODE -ne 0) { throw 'Could not list containers.' }
    if ($existing) {
        # Parse JSON instead of passing nested template quotes through Windows shells.
        $details = docker inspect $name | ConvertFrom-Json
        if ($LASTEXITCODE -ne 0) { throw 'Could not inspect the previous container.' }
        $owner = $null
        if ($null -ne $details[0].Config.Labels) {
            $owner = $details[0].Config.Labels.PSObject.Properties['com.from-code-to-container.workshop']
        }
        if ($null -eq $owner -or $owner.Value -ne 'true') {
            throw "'$name' exists without the workshop label. Inspect it and remove or rename it yourself if appropriate."
        }
    }
    Write-Host "Pulling $reference before replacing the current container..."
    docker pull $reference
    if ($LASTEXITCODE -ne 0) { throw 'Pull failed; the previous container was kept. Check the public image name and tag.' }
    if ($existing) {
        docker stop $name
        if ($LASTEXITCODE -ne 0) { throw 'Could not stop the previous demo container.' }
        docker rm $name
        if ($LASTEXITCODE -ne 0) { throw 'Could not remove the previous demo container.' }
    }
    docker run -d --name $name --label 'com.from-code-to-container.workshop=true' -p '127.0.0.1:8080:80' $reference
    if ($LASTEXITCODE -ne 0) { throw 'Container could not start. Check whether port 8080 is in use.' }

    $ready = $false
    for ($attempt = 1; $attempt -le 30; $attempt++) {
        try {
            $response = Invoke-WebRequest -Uri 'http://localhost:8080' -UseBasicParsing -TimeoutSec 3
            if ($response.StatusCode -eq 200) { $ready = $true; break }
        } catch { Write-Host "Waiting for Nginx ($attempt/30)..." }
        Start-Sleep -Seconds 1
    }
    if (-not $ready -or $response.Content -notmatch '<h1>From Code to Container</h1>' -or $response.Content -notmatch 'id="app-version">Version [0-9]+</span>') {
        docker logs $name
        throw 'Container failed its HTTP readiness check. Inspect: docker logs workshop-app'
    }
    Write-Host "Running $reference at http://localhost:8080"
} catch {
    Write-Error $_ -ErrorAction Continue
    exit 1
}
