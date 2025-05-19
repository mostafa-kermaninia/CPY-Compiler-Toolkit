package main.ast.nodes.For;

import main.ast.nodes.DeclarationSpecifier;
import main.ast.nodes.DeclarationSpecifiers;
import main.ast.nodes.InitDeclaratorList;
import main.ast.nodes.expr.Expr;
import main.visitor.IVisitor;
import main.ast.nodes.Node;

import java.util.ArrayList;


public class ForDec extends Node{
    private DeclarationSpecifiers declarationSpecifiers;
    private InitDeclaratorList initDeclaratorList;

    public ForDec(DeclarationSpecifiers declarationSpecifiers) {
        this.declarationSpecifiers = declarationSpecifiers;
        initDeclaratorList = null;
    }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }

    public InitDeclaratorList getInitDecList() { return initDeclaratorList; }
    public void setInitDecList(InitDeclaratorList initDeclaratorList) { this.initDeclaratorList = initDeclaratorList; }

    public DeclarationSpecifiers getDeclarationSpecifiers() { return declarationSpecifiers; }
}
