const fs = require('fs');
const { execSync } = require('child_process');

const psCmd = `powershell -ExecutionPolicy Bypass -Command "& { Add-Type -AssemblyName System.IO.Compression.FileSystem; $z = [System.IO.Compression.ZipFile]::OpenRead('E:\\Gaurex\\ios\\GAUREX.ipa'); foreach ($e in $z.Entries) { Write-Output ($e.FullName + ' (' + $e.Length + ' bytes)') }; $z.Dispose() }"`;

const out = execSync(psCmd).toString();
console.log('--- IPA Entries ---');
console.log(out);
