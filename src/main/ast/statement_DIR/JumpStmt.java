package main.ast.statement_DIR;

import main.ast.Expressionession_DIR.Expression;
import main.visitor.IVisitor;

public class JumpStmt extends Stmt {
    private Expression returnExpression;

    public JumpStmt() { returnExpression = null; }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }


    public Expression getCondition() {
        return returnExpression;
    }

    public void setReturnExpression(Expression returnExpression) {
        this.returnExpression = returnExpression;
    }
}
