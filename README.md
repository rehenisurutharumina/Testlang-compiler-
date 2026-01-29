# Testlang-compiler-
# TestLang++ Compiler

TestLang++ is a **domain-specific language (DSL)** designed to describe **API test cases** in a simple, readable format.  
This project implements a **compiler** for TestLang++ that translates DSL test definitions into **JUnit 5 test cases** using Java.

The compiler was developed as an academic project to demonstrate concepts of **lexical analysis, parsing, and code generation**.

---

## 📌 Features

- Custom DSL for writing API test cases
- Lexer implemented using **JFlex**
- Parser implemented using **JavaCUP**
- Generates **JUnit 5** test classes automatically
- Supports:
  - Configuration blocks
  - Test cases
  - HTTP methods (GET, POST, etc.)
  - Assertions (status codes, response checks)

---

## 🛠 Technologies Used

- **Java**
- **JFlex** – Lexical Analyzer
- **JavaCUP** – Parser Generator
- **JUnit 5** – Test framework
- **PowerShell / Bash** – Build scripts

---

## 📂 Project Structure

MycompilerTestLang++-it23369924/
│
├── src/
│ ├── Main.java
│ └── lexer/
│ └── lexer.flex
│
├── parser/
│ └── parser.cup
│
├── examples/
│ └── sample.test
│
├── build.ps1
├── build.sh
├── manifest.mf
└── .gitignore

---

## 🚀 How It Works

1. User writes API test cases using the **TestLang++ DSL**
2. The compiler:
   - Tokenizes input using **JFlex**
   - Parses syntax using **JavaCUP**
   - Generates Java source code
3. Output is a **JUnit 5 test class** that can be executed to test APIs

---

## ▶️ How to Run

### Using PowerShell (Windows)
```powershell
.\build.ps1
