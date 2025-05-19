package main.ast.nodes;

import main.ast.nodes.expr.Expr;
import main.visitor.IVisitor;

import java.util.ArrayList;

public class Designation extends Node{
    private ArrayList<Designator> designators;

    public Designation() { designators = new ArrayList<Designator>(); }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }


    public ArrayList<Designator> getDesignators() {
        return designators;
    }
    public void addDesignator(Designator designator) {
        this.designators.add(designator);
    }
}
