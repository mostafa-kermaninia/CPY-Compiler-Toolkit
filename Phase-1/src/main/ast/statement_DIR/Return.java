package main.ast.statement_DIR;

import main.ast.nodes_DIR.Node;
import main.ast.expression_DIR.Expr;
import main.visitor.IVisitor;

import java.util.ArrayList;
import java.util.List;

public class Return extends Stmt {

    private Expr return_value;

    public Return( Expr expr) {
        this.return_value = expr;
    }

    public Expr getReturn_value() {
        return return_value;
    }


    @Override
    public List<Node> accept_subNodes() {
        List<Node> children = new ArrayList<>();
        if (return_value != null) {
            children.add(return_value);
        }
        return children;
    }

}
