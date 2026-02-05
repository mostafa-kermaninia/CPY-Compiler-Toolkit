package main.ast.statement_DIR;

import main.ast.nodes_DIR.Node;
import main.ast.expression_DIR.Expr;
import main.visitor.IVisitor;

import java.util.ArrayList;
import java.util.List;

public class IfStmt extends Stmt {
    private Stmt ifBody;
    private Stmt elseBody;
    private Expr condition;

    public IfStmt(Expr expr) {
        this.condition = expr;
    }


    public Stmt getIfBody() {
        return ifBody;
    }

    public void setIfBody(Stmt ifBody) {
        this.ifBody = ifBody;
    }

    public Stmt getElseBody() {
        return elseBody;
    }

    public void setElseBody(Stmt elseBody) {
        this.elseBody = elseBody;
    }

    public Expr getCondition() {
        return condition;
    }

    public void setCondition(Expr condition) {
        this.condition = condition;
    }

    @Override
    public List<Node> accept_subNodes() {
        List<Node> children = new ArrayList<>();
        if (condition != null) {
            children.add(condition);
        }
        if (ifBody != null) {
            children.add(ifBody);
        }
        if (elseBody != null) {
            children.add(elseBody);
        }
        return children;
    }

}
