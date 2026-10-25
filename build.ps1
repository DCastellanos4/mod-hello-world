# build.ps1 - Compila HolaMundo Mod para Fabric 1.21.10
$ErrorActionPreference = "Stop"

$projectRoot = $PSScriptRoot
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host " Compilando HolaMundo Fabric Mod (1.21.10)..." -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# 1. Localizar Java 21
$javaCandidates = @(
    "C:\Users\David\AppData\Local\Packages\Microsoft.4297127D64EC6_8wekyb3d8bbwe\LocalCache\Local\runtime\java-runtime-delta\windows-x64\java-runtime-delta\bin",
    "$env:JAVA_HOME\bin"
)

$javaBin = $null
foreach ($cand in $javaCandidates) {
    if ($cand -and (Test-Path "$cand\javac.exe") -and (Test-Path "$cand\jar.exe")) {
        $javaBin = $cand
        break
    }
}

if (-not $javaBin) {
    $javacCmd = Get-Command javac -ErrorAction SilentlyContinue
    if ($javacCmd) {
        $javaBin = Split-Path $javacCmd.Source
    }
}

if (-not $javaBin) {
    Write-Error "No se pudo encontrar un JDK con javac.exe y jar.exe."
}

Write-Host "-> Usando JDK en: $javaBin" -ForegroundColor Gray

# 2. Localizar librerías de Fabric y Brigadier
$librariesRoot = "$env:APPDATA\.minecraft\libraries"
$fabricLoaderJar = Get-ChildItem -Path "$librariesRoot\net\fabricmc\fabric-loader" -Recurse -Filter "fabric-loader-0.17.3.jar" | Select-Object -First 1 -ExpandProperty FullName
if (-not $fabricLoaderJar) {
    $fabricLoaderJar = Get-ChildItem -Path "$librariesRoot\net\fabricmc\fabric-loader" -Recurse -Filter "*.jar" | Select-Object -First 1 -ExpandProperty FullName
}

$brigadierJar = Get-ChildItem -Path "$librariesRoot\com\mojang\brigadier" -Recurse -Filter "*.jar" | Select-Object -Last 1 -ExpandProperty FullName

$fabricApiMod = "$env:APPDATA\.minecraft\essential_mod\fabric\1.21.10\mods\fabric-api-0.138.0+1.21.10.jar"
$tempApiDir = "$env:TEMP\fabric_api_extracted"
if (-not (Test-Path "$tempApiDir\META-INF\jars\fabric-command-api-v2-*.jar")) {
    Write-Host "-> Extrayendo sub-librerias de Fabric API..." -ForegroundColor Gray
    New-Item -ItemType Directory -Path $tempApiDir -Force | Out-Null
    tar -xf $fabricApiMod -C $tempApiDir
}

$fabricCmdJar = Get-ChildItem -Path "$tempApiDir\META-INF\jars" -Filter "fabric-command-api-v2-*.jar" | Select-Object -First 1 -ExpandProperty FullName
$fabricBaseJar = Get-ChildItem -Path "$tempApiDir\META-INF\jars" -Filter "fabric-api-base-*.jar" | Select-Object -First 1 -ExpandProperty FullName

$classpath = @(
    $fabricLoaderJar,
    $brigadierJar,
    $fabricCmdJar,
    $fabricBaseJar
) -join ";"

# 3. Directorios de compilación
$buildDir = "$projectRoot\build"
$classesDir = "$buildDir\classes"
$packageDir = "$buildDir\package"
$libsDir = "$buildDir\libs"

Remove-Item -Path $classesDir, $packageDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $classesDir -Force | Out-Null
New-Item -ItemType Directory -Path $packageDir -Force | Out-Null
New-Item -ItemType Directory -Path $libsDir -Force | Out-Null

# 4. Compilar fuentes Java (incluyendo stubs de net.minecraft)
$srcFiles = @()
$srcFiles += (Get-ChildItem -Path "$projectRoot\src\main\java" -Recurse -Filter "*.java").FullName
$srcFiles += (Get-ChildItem -Path "$projectRoot\stubs" -Recurse -Filter "*.java").FullName

Write-Host "-> Compilando clases Java con javac..." -ForegroundColor Yellow
& "$javaBin\javac.exe" -encoding UTF-8 -cp $classpath -d $classesDir $srcFiles

# 5. Preparar contenido del JAR (solo com/ y resources, sin stubs)
Copy-Item -Path "$classesDir\com" -Destination "$packageDir\com" -Recurse -Force
Copy-Item -Path "$projectRoot\src\main\resources\*" -Destination $packageDir -Recurse -Force

# 6. Empaquetar JAR
$jarName = "holamundo-1.0.0.jar"
$outJarPath = "$libsDir\$jarName"
Write-Host "-> Empaquetando $jarName con jar.exe..." -ForegroundColor Yellow
& "$javaBin\jar.exe" -cvf $outJarPath -C $packageDir . | Out-Null

Write-Host "[OK] Mod compilado exitosamente: $outJarPath" -ForegroundColor Green

# 7. Copiar a carpetas de mods de Minecraft
$destMods1 = "C:\Users\David\AppData\Roaming\.minecraft\essential_mod\fabric\1.21.10\mods"
$destMods2 = "C:\Users\David\AppData\Roaming\.minecraft\mods"

if (Test-Path $destMods1) {
    Copy-Item -Path $outJarPath -Destination "$destMods1\$jarName" -Force
    Write-Host "-> Copiado a: $destMods1\$jarName" -ForegroundColor Cyan
}

if (Test-Path $destMods2) {
    Copy-Item -Path $outJarPath -Destination "$destMods2\$jarName" -Force
    Write-Host "-> Copiado a: $destMods2\$jarName" -ForegroundColor Cyan
}

Write-Host "`nListo para jugar! Inicia Minecraft Fabric 1.21.10 y escribe /hola en el chat." -ForegroundColor Green
