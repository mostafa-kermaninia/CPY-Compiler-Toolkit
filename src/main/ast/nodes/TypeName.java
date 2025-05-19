package main.ast.nodes;

import main.ast.nodes.expr.Expr;
import main.visitor.IVisitor;

import java.util.ArrayList;

public class TypeName extends Node{
    private SpecifierQualifierList specifierQualifierList;
    private AbstractDec abstractDec;

    public TypeName(SpecifierQualifierList specifierQualifierList) {
        this.specifierQualifierList = specifierQualifierList;
        abstractDec = null;
    }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }


    public SpecifierQualifierList getSpecifierQualifierList() {
        return specifierQualifierList;
    }

    public AbstractDec getAbstractDec() { return abstractDec; }
    public void setAbstractDec(AbstractDec abstractDec) { this.abstractDec = abstractDec; }
}
