package main.ast.nodes;

import main.ast.nodes.expr.Expr;
import main.visitor.IVisitor;

import java.util.ArrayList;

public class Pointer extends Node{

    public Pointer() {}

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }
}
