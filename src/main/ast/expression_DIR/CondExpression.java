package main.ast.Expression_DIR;

import main.visitor.IVisitor;

public class CondExpression extends Expression{
    private Expression Expression1;
    private Expression Expression2;
    private Expression Expression3;

    public CondExpression(Expression Expression1, Expression Expression2, Expression Expression3){
        this.Expression1 = Expression1;
        this.Expression2 = Expression2;
        this.Expression3 = Expression3;
    }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }

    public Expression getExpression1(){ return Expression1; }
    public Expression getExpression2(){ return Expression2; }
    public Expression getExpression3(){ return Expression3; }
}
