package main.ast;

import main.visitor.IVisitor;

public class Pointer extends Node{

    public Pointer() {}

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }
}
