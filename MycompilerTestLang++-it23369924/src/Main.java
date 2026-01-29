import java.io.FileReader;
import java.io.Reader;
import java_cup.runtime.ComplexSymbolFactory;

public class Main {
  public static void main(String[] args) {
    if (args.length != 1) {
      System.err.println("Usage: java Main <input.test>");
      System.exit(2);
    }

    try (Reader reader = new FileReader(args[0])) {
      Yylex scanner = new Yylex(reader);
      ComplexSymbolFactory sf = new ComplexSymbolFactory();
      Parser parser = new Parser(scanner, sf);
      parser.parse();
      System.out.println("OK: GeneratedTests.java created");
    } catch (Exception e) {
      e.printStackTrace(System.err);
      System.exit(1);
    }
  }
}
