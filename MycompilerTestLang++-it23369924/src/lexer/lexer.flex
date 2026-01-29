/* JFlex specification for TestLang++ */
import java_cup.runtime.Symbol;
import java_cup.runtime.ComplexSymbolFactory;
import java.util.HashMap;
import java.util.Map;

%%

%public
%class Yylex
%unicode
%cup
%line
%column

%state STRING_ERR

%{
  private StringBuilder stringBuf = new StringBuilder();

  // Use CUP ComplexSymbolFactory so tokens carry locations
  private final ComplexSymbolFactory symbolFactory = new ComplexSymbolFactory();

  // Keyword map
  private static final Map<String, Integer> KEYWORDS = new HashMap<>();
  static {
    KEYWORDS.put("config",   sym.CONFIG);
    KEYWORDS.put("base_url", sym.BASE_URL);
    KEYWORDS.put("header",   sym.HEADER);
    KEYWORDS.put("let",      sym.LET);
    KEYWORDS.put("test",     sym.TEST);
    KEYWORDS.put("GET",      sym.GET);
    KEYWORDS.put("POST",     sym.POST);
    KEYWORDS.put("PUT",      sym.PUT);
    KEYWORDS.put("DELETE",   sym.DELETE);
    KEYWORDS.put("expect",   sym.EXPECT);
    KEYWORDS.put("status",   sym.STATUS);
    KEYWORDS.put("body",     sym.BODY);
    KEYWORDS.put("contains", sym.CONTAINS);
  }

  public int getLine() {
    return yyline + 1; // 1-based
  }

  public int getColumn() {
    return yycolumn + 1; // 1-based
  }

  private Symbol symbol(int type) {
    ComplexSymbolFactory.Location loc = new ComplexSymbolFactory.Location(getLine(), getColumn());
    return symbolFactory.newSymbol(sym.terminalNames[type], type, loc, loc);
  }

  private Symbol symbol(int type, Object value) {
    ComplexSymbolFactory.Location loc = new ComplexSymbolFactory.Location(getLine(), getColumn());
    return symbolFactory.newSymbol(sym.terminalNames[type], type, loc, loc, value);
  }

  private void lexError(String message) {
    throw new RuntimeException(
      "Lexical error at line " + getLine() + ", column " + getColumn() + ": " + message
    );
  }
%}

/* Macros */
BOM        = \uFEFF
WHITESPACE = [ \t\f\r\n]+
IDENT      = [A-Za-z_][A-Za-z0-9_]*
NUMBER     = [0-9]+
BACK       = \\
DQ         = \u0022
STR_CHAR   = [^\\\u0022\r\n]

%%

/* EOF */
<<EOF>>                 { return symbol(sym.EOF); }

/* Ignore BOM (Byte Order Mark) */
{BOM}                   { /* ignore */ }

/* Whitespace (track positions via %line/%column) */
<YYINITIAL>{WHITESPACE} { /* ignore */ }

/* Line comments */
<YYINITIAL>"//"[^\r\n]* { /* ignore */ }

/* Punctuation used in grammar */
"{"                     { return symbol(sym.LBRACE); }
"}"                     { return symbol(sym.RBRACE); }
";"                     { return symbol(sym.SEMI); }
"="                     { return symbol(sym.EQ); }

/* Numbers (non-negative integers) */
{NUMBER}                { return symbol(sym.NUMBER, Integer.parseInt(yytext())); }

/* Identifiers and reserved keywords */
{IDENT}                 {
  Integer kw = KEYWORDS.get(yytext());
  if (kw != null) return symbol(kw);
  return symbol(sym.IDENT, yytext());
}

/* Strings: full literal match with escapes */
{DQ}(({BACK}{DQ})|({BACK}{BACK})|({BACK}.)|{STR_CHAR})*{DQ} {
  String raw = yytext();
  String s = raw.substring(1, raw.length()-1);
  StringBuilder sb = new StringBuilder(s.length());
  for (int i = 0; i < s.length(); i++) {
    char c = s.charAt(i);
    if (c == '\\' && i+1 < s.length()) {
      char n = s.charAt(++i);
      if (n == '"') sb.append('"');
      else if (n == '\\') sb.append('\\');
      else { sb.append('\\').append(n); }
    } else {
      sb.append(c);
    }
  }
  return symbol(sym.STRING, sb.toString());
}

/* Unterminated string: start quote without closing before EOL/EOF */
{DQ}                     { yybegin(STRING_ERR); }
<STRING_ERR>[^\r\n]+    { /* consume until EOL */ }
<STRING_ERR>\r\n        { yybegin(YYINITIAL); lexError("Unterminated string literal"); }
<STRING_ERR>[\r\n]     { yybegin(YYINITIAL); lexError("Unterminated string literal"); }
<STRING_ERR><<EOF>>     { lexError("Unterminated string literal"); }

/* Any other single unexpected character (outside strings) */
<YYINITIAL>.             { lexError("Unexpected character '" + yytext() + "'"); }

