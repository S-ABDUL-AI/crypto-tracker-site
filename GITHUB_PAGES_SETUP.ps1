# Creates https://github.com/S-ABDUL-AI/S-ABDUL-AI.github.io (if missing) and pushes this site to main.
# Option A: Set a classic PAT with "repo" scope, then run:
#   $env:GITHUB_TOKEN = "ghp_xxxxxxxx"
#   .\GITHUB_PAGES_SETUP.ps1
# Option B: Create an empty public repo named S-ABDUL-AI.github.io at https://github.com/new (no README),
#   then run: git push -u origin main

$ErrorActionPreference = "Stop"
$repo = "S-ABDUL-AI.github.io"
$owner = "S-ABDUL-AI"
Set-Location $PSScriptRoot

if ($env:GITHUB_TOKEN) {
  $headers = @{
    Authorization = "Bearer $($env:GITHUB_TOKEN)"
    Accept        = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
  }
  $exists = $false
  try {
    Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo" -Headers $headers -Method Get | Out-Null
    $exists = $true
  } catch { }
  if (-not $exists) {
    $body = @{
      name        = $repo
      description = "Personal site / GitHub Pages user site"
      homepage    = "https://$($owner.ToLower()).github.io/"
      private     = $false
      auto_init   = $false
    } | ConvertTo-Json
    Write-Host "Creating repo $owner/$repo ..."
    Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Headers $headers -Method Post -Body $body -ContentType "application/json" | Out-Null
    Write-Host "Repository created."
    Start-Sleep -Seconds 2
  } else {
    Write-Host "Repository already exists."
  }
} else {
  Write-Host "GITHUB_TOKEN not set - skipping API create. Create $repo at https://github.com/new if needed."
}

git remote remove origin 2>$null
git remote add origin "https://github.com/$owner/$repo.git"
git branch -M main
Write-Host "Pushing to origin main ..."
git push -u origin main
if ($LASTEXITCODE -ne 0) {
  Write-Host ""
  Write-Host "Push failed. Either:"
  Write-Host "  1. Create empty public repo $repo at https://github.com/new (no README, no .gitignore), then run this script again, OR"
  Write-Host "  2. Set `$env:GITHUB_TOKEN` to a classic PAT with repo scope and run again (repo will be created via API)."
  exit 1
}
Write-Host "Done. In the repo: Settings - Pages - Build from branch main, folder / (root)."
Write-Host "Site URL: https://$($owner.ToLower()).github.io/"
