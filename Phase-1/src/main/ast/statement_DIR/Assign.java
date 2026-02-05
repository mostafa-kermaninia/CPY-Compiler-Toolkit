package main.ast.statement_DIR;

import main.ast.nodes_DIR.Node;
import main.ast.expression_DIR.Expr;
import main.visitor.IVisitor;

import java.util.ArrayList;
import java.util.List;

public class Assign extends Stmt {
    private String leftHand;
    private Expr rightHand;

    public Assign(String leftHand, Expr expr) {
        this.leftHand = leftHand;
        this.rightHand = expr;
    }


    public String getLeftHand() {
        return leftHand;
    }

    public void setLeftHand(String leftHand) {
        this.leftHand = leftHand;
    }

    public Expr getRightHand() {
        return rightHand;
    }

    public void setRightHand(Expr rightHand) {
        this.rightHand = rightHand;
    }

    @Override
    public List<Node> accept_subNodes() {
        List<Node> children = new ArrayList<>();
        if (rightHand != null) {
            children.add(rightHand);
        }
        return children;
    }

}
