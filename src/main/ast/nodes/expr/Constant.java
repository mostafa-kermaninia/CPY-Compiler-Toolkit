package main.ast.nodes.expr;

import main.visitor.IVisitor;
import main.ast.nodes.*;

public class Constant extends Expr{
    private String constant;

    public Constant(String constant){
        this.constant = constant;
    }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }

    public String getConstant(){ return constant; }
}
