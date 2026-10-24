param (
    [string]$SourceDir,
    [string]$ZipPath
)

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

if (Test-Path $ZipPath) {
    Remove-Item $ZipPath -Force
}

$zip = [System.IO.Compression.ZipFile]::Open($ZipPath, [System.IO.Compression.ZipArchiveMode]::Create)

$files = Get-ChildItem -Path $SourceDir -Recurse -File
foreach ($file in $files) {
    # Get relative path with forward slashes
    $rel = $file.FullName.Substring($SourceDir.Length).TrimStart('\', '/')
    $rel = $rel.Replace('\', '/')
    
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $file.FullName, $rel, [System.IO.Compression.CompressionLevel]::Optimal)
}

$zip.Dispose()
Write-Output ">>> Created zip with forward slashes: $ZipPath"
