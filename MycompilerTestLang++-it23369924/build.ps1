<#
  Tiny build helper for TestLang++ (PowerShell)
  - Fix accidental file-at-path collisions
  - Regenerate lexer (JFlex) and parser (CUP)
  - Compile classes into bin/
#>

$ErrorActionPreference = 'Stop'

Write-Host "[build] Checking path collisions..."
if (Test-Path 'src/parser' -PathType Leaf) {
  Write-Host "[build] Found file at 'src/parser'. Removing to allow directory creation."
  Remove-Item 'src/parser' -Force
}

Write-Host "[build] Ensuring directories exist..."
New-Item -ItemType Directory -Force -Path 'src/parser' | Out-Null
New-Item -ItemType Directory -Force -Path 'bin' | Out-Null

Write-Host "[build] Removing old generated files in src/ (if any)..."
foreach ($p in @('src/Parser.java','src/sym.java')) { if (Test-Path $p) { Remove-Item $p -Force } }

Write-Host "[build] Regenerating lexer (JFlex)..."
& java -jar 'lib\jflex-full-1.9.1.jar' 'src\lexer\lexer.flex' -d 'src\lexer'

Write-Host "[build] Regenerating parser (CUP)..."
& java -jar 'lib\java-cup-11b.jar' -parser Parser -symbols sym -destdir 'src\parser' -locations -progress 'parser\parser.cup'

Write-Host "[build] Compiling sources..."
$cp = ".;lib\java-cup-11b-runtime.jar;lib\java-cup-11b.jar"
& javac -cp $cp -d bin @('src\*.java','src\lexer\Yylex.java','src\parser\*.java')

Write-Host "[build] Packaging runnable jar..."
& jar cfm app.jar manifest.mf -C bin .

Write-Host "[build] Done. Run either:"
Write-Host "       java -cp \"bin;lib\java-cup-11b-runtime.jar;lib\java-cup-11b.jar\" Main examples\sample.test"
Write-Host "   or  java -jar app.jar examples\sample.test"
