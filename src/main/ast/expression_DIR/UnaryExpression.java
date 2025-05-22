package main.ast.Expression_DIR;

import main.visitor.IVisitor;

public class UnaryExpression extends Expression{
    private Expression Expression;
    private String Op;

    public UnaryExpression(Expression Expression, String Op){
        this.Expression = Expression;
        this.Op = Op;
    }
    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }

    public Expression getExpression(){ return Expression; }
    public String getOp(){ return Op; }

}
