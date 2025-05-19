package main.ast.nodes.Stmt;

import main.ast.nodes.expr.Expr;
import main.visitor.IVisitor;

public class JumpStmt extends Stmt {
    private Expr returnExpr;

    public JumpStmt() { returnExpr = null; }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }


    public Expr getCondition() {
        return returnExpr;
    }

    public void setReturnExpr(Expr returnExpr) {
        this.returnExpr = returnExpr;
    }
}
