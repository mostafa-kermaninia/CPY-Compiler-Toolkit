package main.visitor;

import main.ast.nodes_DIR.Node;
import main.ast.statement_DIR.CompoundStatement;
import main.ast.statement_DIR.IterationStatement;
import main.ast.statement_DIR.SelectionStatement;
import main.ast.nodes_DIR.FunctionDefinition;

public class TestVisitor {

    public void count(Node node) {

        /* function scope */
        if (node instanceof FunctionDefinition) {
            FunctionDefinition fn = (FunctionDefinition) node;
            int stmtCount = stmtCount(fn.getBody());

            System.out.println("Line " + fn.getLine()
                    + ": function '" + fn.getFunctionName()
                    + "' → " + stmtCount + " statement(s)");
        }

        /* loop scope (FOR / WHILE) */
        else if (node instanceof IterationStatement) {
            IterationStatement it = (IterationStatement) node;

            switch (it.getType()) {
                case FOR:
                case WHILE:     // DO-WHILE intentionally skipped
                    int stmtCount = stmtCount(it.getBody());

                    System.out.println("Line " + it.getLine()
                            + ": " + it.getType().name().toLowerCase()
                            + " loop → " + stmtCount + " statement(s)");
                    break;
                default:
                    /* do-while → nothing to report */
            }
        }

        /* selection scope (IF) */
        else if (node instanceof SelectionStatement) {
            SelectionStatement sel = (SelectionStatement) node;

            /* then-part */
            int thenCount = stmtCount(sel.getThenBody());
            System.out.println("Line " + sel.getThenBody().getLine()
                    + ": if-body → " + thenCount + " statement(s)");

            /* else-part (ignore else-if chains) */
            if (sel.getElseBody() != null
                    && !(sel.getElseBody() instanceof SelectionStatement)) {

                int elseCount = stmtCount(sel.getElseBody());
                System.out.println("Line " + sel.getElseBody().getLine()
                        + ": else-body → " + elseCount + " statement(s)");
            }
        }

        for (Node child : node.get_child()) {
            count(child);
        }
    }

    private int stmtCount(Node body) {
        if (body instanceof CompoundStatement)
            return ((CompoundStatement) body).getStatements().size();

        return (body != null) ? 1 : 0;
    }
}
