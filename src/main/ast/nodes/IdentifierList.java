package main.ast.nodes;

import main.ast.nodes.expr.Expr;
import main.visitor.IVisitor;

import java.util.ArrayList;

public class IdentifierList extends Node{
    private ArrayList<String> identifiers;

    public IdentifierList(String identifier) {
        identifiers = new ArrayList<>();
        identifiers.add(identifier);
    }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }


    public ArrayList<String> addIdentifier() { return identifiers; }
    public void addIdentifier(String identifier) { this.identifiers.add(identifier); }
}
