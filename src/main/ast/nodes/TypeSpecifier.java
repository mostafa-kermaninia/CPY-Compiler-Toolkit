package main.ast.nodes;

import main.ast.nodes.expr.Expr;
import main.visitor.IVisitor;

import java.util.ArrayList;

public class TypeSpecifier extends Node{
    private String type;
    private boolean var_dec = false;

    public TypeSpecifier(String type) {
        this.type = type;
    }

    public TypeSpecifier(String type, boolean var_dec) {
        this.type = type;
        this.var_dec = var_dec;
    }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }

    public String getType() { return type; }
    public boolean isVar_dec() { return var_dec; }

}
