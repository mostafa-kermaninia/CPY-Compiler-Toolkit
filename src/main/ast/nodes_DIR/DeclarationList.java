package main.ast.nodes;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import main.visitor.IVisitor;


public class DeclarationList extends Node {

    private ArrayList<Declaration> declarations;

    public DeclarationList() { }              // super() invoked implicitly

    public DeclarationList(int line, int column) {
        super(line, column);
    }

    public void addDeclaration(Declaration d) {
        if (d != null)
            declarations.add(d);
    }

    public List<Declaration> getDeclarations() {
        return Collections.unmodifiableList(declarations);
    }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }
}
