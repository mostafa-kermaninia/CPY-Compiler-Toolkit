package main.ast.nodes;

import main.ast.nodes.expr.Expr;
import main.visitor.IVisitor;

import java.lang.reflect.Parameter;

public class AbstractDec extends Node{
    private Pointer pointer;
    private DirectAbsDec directAbsDec;

    public AbstractDec(){
        directAbsDec = null;
    }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }


    public Pointer getPointer() {
        return pointer;
    }
    public void setPointer(Pointer pointer) {this.pointer = pointer;}


    public DirectAbsDec getDirectAbsDec() { return directAbsDec; }
    public void setDirectAbsDec(DirectAbsDec directAbsDec) { this.directAbsDec = directAbsDec; }
}
