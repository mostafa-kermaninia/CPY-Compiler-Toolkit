package main.ast.statement_DIR;

import main.ast.expression_DIR.Expression;
import main.ast.statement_DIR.*;
import main.visitor.IVisitor;
import main.symbolTable.SymbolTable;

public class SelectionStatement extends Statement {
    private final Statement mainStatement;
    private Statement elseStatement;
    private final Expression expression;
    private int elseLine;
    private SymbolTable symbolTable;

    public SelectionStatement(Expression expression, Statement mainStatement) {
        this.expression = expression;
        this.mainStatement = mainStatement;
    }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }


    public Expression getExpression() {
        return expression;
    }

    public Statement getMainStatement() { return mainStatement; }

    public Statement getElseStatement() { return elseStatement; }
    public void setElseStatement(Statement statement) { this.elseStatement = statement; }

    public boolean allReturn() {
        boolean result = true;
        if (elseStatement == null) {
            return false;
        }
        else if (elseStatement instanceof SelectionStatement) {
            SelectionStatement selStatement = (SelectionStatement) elseStatement;
            result = result && selStatement.allReturn();
        }
        else if (elseStatement instanceof CompoundStatement) {
            CompoundStatement compoundStatement = (CompoundStatement) elseStatement;
            result = result && compoundStatement.hasJumpStatement();
        }
        if (mainStatement instanceof CompoundStatement)
            result = result & ((CompoundStatement) mainStatement).hasJumpStatement();
        else if (mainStatement instanceof SelectionStatement)
            result = result && ((SelectionStatement) mainStatement).allReturn();

        return result;
    }
    public int getElseLine() { return elseLine; }
    public void setElseLine(int line) { this.elseLine = line; }

    public SymbolTable getSymbolTable() { return symbolTable; }
    public void setSymbolTable(SymbolTable symbolTable) { this.symbolTable = symbolTable; }
}
