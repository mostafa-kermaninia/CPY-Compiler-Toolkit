package main.ast.nodes;

import main.ast.nodes.expr.Expr;
import main.visitor.IVisitor;

import java.util.ArrayList;

public class UnaryOperator extends Node{
    private String OpType;

    public UnaryOperator(String OpType) {
        this.OpType = OpType;
    }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }

    public String getOpType() { return OpType; }

}
