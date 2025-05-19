package main.ast.nodes;

import main.ast.nodes.expr.Expr;
import main.visitor.IVisitor;

import java.util.ArrayList;

public class Initializer extends Node{
    private Expr expr;
    private InitializerList initList;
    public Initializer() { expr = null;  initList = null; }

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

    public InitializerList getInitList() { return initList; }
    public void setInitializerList(InitializerList initList) { this.initList = initList; }
}
