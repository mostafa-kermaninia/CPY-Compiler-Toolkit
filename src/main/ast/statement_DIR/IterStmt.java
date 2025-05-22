package main.ast.statement_DIR;

import main.ast.expression_DIR.Expression;
import main.ast.literal_DIR.ForCondition;
import main.symbolTable.SymbolTable;
import main.visitor.IVisitor;

public class IterStmt extends Stmt {
    private Stmt stmt;
    private Expression expression;
    private ForCondition forCondition;
    private String type;
    private SymbolTable symbolTable;

    public IterStmt() {
        stmt = null;
        expression = null;
        forCondition = null;
    }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }

    public Expression getExpression() {
        return expression;
    }

    public void setExpression(Expression expression) {
        this.expression = expression;
    }

    public Stmt getStmt() {
        return stmt;
    }

    public void setStmt(Stmt stmt) {
        this.stmt = stmt;
    }

    public ForCondition getForCondition() {
        return forCondition;
    }

    public void setForCondition(ForCondition forCondition) {
        this.forCondition = forCondition;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public SymbolTable getSymbolTable() {
        return symbolTable;
    }

    public void setSymbolTable(SymbolTable symbolTable) {
        this.symbolTable = symbolTable;
    }
}
