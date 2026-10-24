# GAUREX iOS - Cloud Build & IPA Generator
param (
    [string]$RepoUrl
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  GAUREX iOS Cloud Build Deployment (Apple Silicon Runner)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

if (-not $RepoUrl) {
    $existing = git remote get-url origin 2>$null
    if ($existing) {
        $RepoUrl = $existing
        Write-Host "Using configured remote: $RepoUrl" -ForegroundColor Green
    } else {
        $RepoUrl = Read-Host "Enter your GitHub repository URL (e.g., https://github.com/YOUR_USERNAME/gaurex-ios.git)"
        if (-not $RepoUrl) {
            Write-Host "Error: Repository URL is required." -ForegroundColor Red
            exit 1
        }
        git remote add origin $RepoUrl
    }
}

Write-Host "`n>>> Ensuring branch is 'main'..." -ForegroundColor Yellow
git branch -M main

Write-Host ">>> Pushing GAUREX codebase to GitHub..." -ForegroundColor Yellow
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n==========================================================" -ForegroundColor Green
    Write-Host "  SUCCESSFULLY PUSHED TO GITHUB!" -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host "Next Steps:" -ForegroundColor White
    Write-Host "1. Open your repository on GitHub in your browser." -ForegroundColor White
    Write-Host "2. Click 'Actions' > 'Build & Sign GAUREX iOS IPA'." -ForegroundColor White
    Write-Host "3. Click 'Run workflow'." -ForegroundColor White
    Write-Host "4. Download GAUREX.ipa under Artifacts and sideload with Sideloadly!" -ForegroundColor White
} else {
    Write-Host "`nError pushing to GitHub. Please verify credentials or run 'gh auth login'." -ForegroundColor Red
}
