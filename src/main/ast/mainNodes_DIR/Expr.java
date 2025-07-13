package main.ast.mainNodes_DIR;

import main.ast.expression_DIR.ArgExpr;
import main.ast.literal_DIR.AssignmentOp;
import main.ast.baseNodes_DIR.Node;

public abstract class Expr extends Node {
    private boolean isFirst = true;
    public void addExpr(Expr expr) {}
    public void setArgExpr(ArgExpr argExpr) {}
    public void notFirst() { isFirst = false; }
    public boolean getFirst() { return isFirst; }
}
