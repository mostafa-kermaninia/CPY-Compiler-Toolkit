package main.ast.nodes;

import main.visitor.IVisitor;
import java.util.Objects;


public class FunctionDefinition extends ExternalDeclaration {

    private DeclarationSpecifiers declarationSpecifiers;        // may be null

    /** The function header: name + parameters + qualifiers */
    private Declarator declarator;               // never null

    /** Optional list of local declarations that precede the body */
    private DeclarationList declarationList;     // may be null

    /** Function body (compound statement) */
    private CompoundStatement compoundStatement; // never null


    public FunctionDefinition() { }              // super() invoked implicitly

    public FunctionDefinition(int line, int column) {
        super(line, column);
    }

//    public FunctionDefinition(int line, int column,
//                              String declarationSpecifiers,
//                              Declarator declarator,
//                              DeclarationList declarationList,
//                              CompoundStatement compoundStatement) {
//        super(line, column);
//        this.declarationSpecifiers = declarationSpecifiers;
//        this.declarator            = Objects.requireNonNull(declarator);
//        this.declarationList       = declarationList;
//        this.compoundStatement     = Objects.requireNonNull(compoundStatement);
//    }


    public String getDeclarationSpecifiers() {
        return declarationSpecifiers;
    }
    public void setDeclarationSpecifiers(DeclarationSpecifiers specifiers) {
        this.declarationSpecifiers = specifiers;
    }

    public Declarator getDeclarator() {
        return declarator;
    }
    public void setDeclarator(Declarator declarator) {
        this.declarator = declarator;
    }

    public DeclarationList getDeclarationList() {
        return declarationList;
    }
    public void setDeclarationList(DeclarationList list) {
        this.declarationList = list;
    }

    public CompoundStatement getCompoundStatement() {
        return compoundStatement;
    }
    public void setCompoundStatement(CompoundStatement compoundStatement) {
        this.compoundStatement = compoundStatement;
    }


    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }
}
