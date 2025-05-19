package main.ast.nodes;

import main.ast.nodes.expr.Expr;
import main.visitor.IVisitor;

import java.util.ArrayList;

public class SpecifierQualifierList extends Node{
    private TypeSpecifier typeSpecifier;
    private SpecifierQualifierList specifierQualifierList;

    public SpecifierQualifierList() {
        typeSpecifier = null;
        specifierQualifierList = null;
    }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }


    public SpecifierQualifierList getSpecifierQualifierList() {
        return specifierQualifierList;
    }
    public void setSpecifierQualifierList(SpecifierQualifierList specifierQualifierList) { this.specifierQualifierList = specifierQualifierList; }

    public TypeSpecifier getTypeSpecifier() { return typeSpecifier; }
    public void setTypeSpecifier(TypeSpecifier typeSpecifier) { this.typeSpecifier = typeSpecifier; }
}
