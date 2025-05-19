package main.ast.nodes;

import main.ast.nodes.expr.Expr;
import main.visitor.IVisitor;

import java.util.ArrayList;

public class DeclarationSpecifier extends Node{
    private TypeSpecifier typeSpecifier;
    private String typeName;

    public DeclarationSpecifier() {
        typeSpecifier = null;
    }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }

    public TypeSpecifier getTypeSpecifier() { return typeSpecifier; }
    public void setTypeSpecifier(TypeSpecifier typeSpecifier) { this.typeSpecifier = typeSpecifier; }

    public String getType() { return typeName; }
    public void setType(String typeName) { this.typeName = typeName; }
}
