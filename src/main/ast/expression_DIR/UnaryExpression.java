package main.ast.expression_DIR;

import main.visitor.IVisitor;

public class UnaryExpression extends Expression {
    private Expression expression;
    private String operation;

    public UnaryExpression(Expression expression, String operation){
        this.expression = expression;
        this.operation = operation;
    }
    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }

    public Expression getExpression(){ return expression; }
    public String getOperation(){ return operation; }

}
