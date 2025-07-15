import main.ast.baseNodes_DIR.Program;
import main.ast.CPY_DIR.CPYtoC;
import main.grammar.SimpleLangLexer;
import main.grammar.SimpleLangParser;
import main.visitor.*;
import main.vulnerability.VulnerabilityReporter;
import main.vulnerability.VulnerabilityDataCollector;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;

import java.io.IOException;

public class SimpleLang {
    public static void main(String[] args) throws IOException {
        CPYtoC CPYtoC = new CPYtoC(args[0]);
//        CPYtoC CPYtoC = new CPYtoC();
        CharStream reader = CharStreams.fromString(CPYtoC.converted);
        SimpleLangLexer simpleLangLexer = new SimpleLangLexer(reader);
        CommonTokenStream tokens = new CommonTokenStream(simpleLangLexer);
        SimpleLangParser flParser = new SimpleLangParser(tokens);
        Program program = flParser.program().programRet;
        System.out.println();
 

        VulnerabilityDataCollector my_vulnerabilityDataCollector = new VulnerabilityDataCollector();
        my_vulnerabilityDataCollector.visit(program);

        VulnerabilityReporter my_vulnerabilityReporter = new VulnerabilityReporter(my_vulnerabilityDataCollector.symbolTableMain);
        my_vulnerabilityReporter.visit(program);

        TypeChecker my_typeChecker = new TypeChecker(my_vulnerabilityDataCollector.symbolTableMain);
        my_typeChecker.visit(program);

    }
}