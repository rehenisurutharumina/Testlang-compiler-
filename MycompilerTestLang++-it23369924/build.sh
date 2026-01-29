#!/usr/bin/env bash
set -euo pipefail

# Tiny build helper for TestLang++ (Git Bash/Unix shells)
# - Fixes accidental file-at-path collisions
# - Regenerates lexer (JFlex) and parser (CUP)
# - Compiles classes into bin/

ROOT_DIR=$(pwd)

echo "[build] Checking path collisions..."
if [ -f src/parser ]; then
  echo "[build] Found file at 'src/parser'. Removing to allow directory creation."
  rm -f src/parser
fi

echo "[build] Ensuring directories exist..."
mkdir -p src/parser
mkdir -p bin

echo "[build] Removing old generated files in src/ (if any)..."
rm -f src/Parser.java src/sym.java || true

echo "[build] Regenerating lexer (JFlex)..."
java -jar lib/jflex-full-1.9.1.jar src/lexer/lexer.flex -d src/lexer

echo "[build] Regenerating parser (CUP)..."
java -jar lib/java-cup-11b.jar -parser Parser -symbols sym -destdir src/parser -locations -progress parser/parser.cup

echo "[build] Compiling sources..."
CP=".;lib/java-cup-11b-runtime.jar;lib/java-cup-11b.jar"
javac -cp "$CP" -d bin src/*.java src/lexer/Yylex.java src/parser/*.java

echo "[build] Packaging runnable jar..."
jar cfm app.jar manifest.mf -C bin .

echo "[build] Done. Run either:"
echo "       java -cp \"bin;lib/java-cup-11b-runtime.jar;lib/java-cup-11b.jar\" Main examples/sample.test"
echo "   or  java -jar app.jar examples/sample.test"
