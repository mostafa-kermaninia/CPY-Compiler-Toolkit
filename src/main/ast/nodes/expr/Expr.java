package main.ast.nodes.expr;

import main.ast.nodes.ArgExpr;
import main.ast.nodes.AssignmentOp;
import main.ast.nodes.Node;

public abstract class Expr extends Node {
    private boolean isFirst = true;
    public void addExpr(Expr expr) {}
    public void setArgExpr(ArgExpr argExpr) {}
    public void notFirst() { isFirst = false; }
    public boolean getFirst() { return isFirst; }
}
