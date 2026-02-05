package main.ast.expression_DIR;

import main.ast.nodes_DIR.Node;
import main.visitor.IVisitor;

import java.util.List;
import java.util.ArrayList;

public class ArgumentExpressionList extends Node {
    private List<Expr> arguments;

    public ArgumentExpressionList() {
        this.arguments = new ArrayList<>();
    }

    public void addArgument(Expr expr) {
        arguments.add(expr);
    }

    public List<Expr> getArguments() {
        return arguments;
    }

    @Override
    public List<Node> accept_subNodes() {
        List<Node> children = new ArrayList<>();
        for (Expr expr : arguments) {
            children.add(expr);
        }
        return children;
    }
}
