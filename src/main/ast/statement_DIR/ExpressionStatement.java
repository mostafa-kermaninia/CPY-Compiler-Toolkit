package main.ast.statement_DIR;

import main.ast.nodes_DIR.Node;
import main.ast.expression_DIR.Expr;
import main.visitor.IVisitor;

import java.util.ArrayList;
import java.util.List;

public class ExpressionStatement extends Stmt {
    private Expr expression;

    public ExpressionStatement() {}

    public ExpressionStatement(Expr expression) {
        this.expression = expression;
    }

    public Expr getExpression() {
        return expression;
    }

    public void setExpression(Expr expression) {
        this.expression = expression;
    }

    @Override
    public List<Node> accept_subNodes() {
        List<Node> children = new ArrayList<>();
        if (expression != null) {
            children.add(expression);
        }
        return children;
    }

}
