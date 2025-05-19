package main.ast.nodes;

import main.ast.nodes.expr.Expr;
import main.visitor.IVisitor;

public class Designator extends Node{
    private Expr expr;

    public Designator() { expr = null; }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }


    public Expr getExpr() {
        return expr;
    }
    public void setExpr(Expr expr) {
        this.expr = expr;
    }
}
