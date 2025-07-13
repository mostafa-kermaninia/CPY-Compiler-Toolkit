package main.ast.statement_DIR;

import main.ast.mainNodes_DIR.Stmt;
import main.ast.nodes.For.ForCondition;
import main.ast.nodes.expr.Expr;
import main.visitor.IVisitor;

public class ExprStmt  extends Stmt { ;
    private Expr expr;

    public ExprStmt() { expr = null; }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }


    public Expr getExpr() { return expr; }
    public void setExpr(Expr expr) { this.expr = expr; }
}
