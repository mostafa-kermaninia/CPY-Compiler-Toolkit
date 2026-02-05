package main.ast.nodes_DIR;

import main.visitor.IVisitor;

import java.util.ArrayList;
import java.util.List;

public abstract class Node {
    private int line;

    public void setLine(int line){this.line = line;}
    public int getLine(){return this.line;}

    public List<Node> accept_subNodes() {
        return new ArrayList<>();
    }
}
