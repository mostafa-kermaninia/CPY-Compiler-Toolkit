package main.ast.literal_DIR;

import main.ast.nodes_DIR.Node;
import main.visitor.IVisitor;

import java.util.ArrayList;
import java.util.List;

public class InitializerListEntry extends Node {
    private Designation designation;
    private Initializer initializer;

    public InitializerListEntry(Designation designation, Initializer initializer) {
        this.designation = designation;
        this.initializer = initializer;
    }

    public Designation getDesignation() {
        return designation;
    }

    public Initializer getInitializer() {
        return initializer;
    }


    @Override
    public List<Node> accept_subNodes() {
        List<Node> children = new ArrayList<>();
        if (designation != null) {
            children.add(designation);
        }
        if (initializer != null) {
            children.add(initializer);
        }
        return children;
    }

}
