package main.ast.Expression_DIR;

import main.ast.literal_DIR.AssignmentOp;
import main.visitor.IVisitor;

public class BinaryExpression extends Expression{
    private Expression Expression1;
    private Expression Expression2;
    private String operator;
    private AssignmentOp assignmentOp;

    public BinaryExpression(Expression Expression1, Expression Expression2, String operator){
        this.Expression1 = Expression1;
        this.Expression2 = Expression2;
        this.operator = operator;
    }

    public BinaryExpression(Expression Expression1, Expression Expression2, AssignmentOp assignmentOp){
        this.Expression1 = Expression1;
        this.Expression2 = Expression2;
        this.assignmentOp = assignmentOp;
    }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }

    public Expression getExpression1(){ return Expression1; }
    public Expression getExpression2(){ return Expression2; }
    public String getOperator(){ return operator; }
    public AssignmentOp getAssignmentOp(){ return assignmentOp; }
}
