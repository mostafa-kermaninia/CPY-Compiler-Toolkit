package main.ast.nodes_DIR;

import main.visitor.IVisitor;

public class Declaration extends ExternalDeclaration {

    private DeclarationSpecifiers declarationSpecifiers;

    private InitDeclaratorList initDeclaratorList;

    public Declaration() { }

    public Declaration(int line, int column) {
        super(line, column);
    }

//    public Declaration(int line,
//                       int column,
//                       String declarationSpecifiers,
//                       InitDeclaratorList initDeclaratorList) {
//        super(line, column);
//        this.declarationSpecifiers = declarationSpecifiers;
//        this.initDeclaratorList    = initDeclaratorList;
//    }


    public DeclarationSpecifiers getDeclarationSpecifiers() {
        return declarationSpecifiers;
    }
    public void setDeclarationSpecifiers(DeclarationSpecifiers specifiers) {
        this.declarationSpecifiers = specifiers;
    }

    public InitDeclaratorList getInitDeclaratorList() {
        return initDeclaratorList;
    }
    public void setInitDeclaratorList(InitDeclaratorList list) {
        this.initDeclaratorList = list;
    }


    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }
}
