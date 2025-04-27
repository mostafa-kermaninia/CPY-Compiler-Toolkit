package main.ast.statement_DIR;

import main.ast.literal_DIR.BlockItem;
import main.ast.nodes_DIR.Node;
import main.visitor.IVisitor;

import java.util.ArrayList;
import java.util.List;

public class CompoundStatement extends Stmt {
    private ArrayList<BlockItem> statements;
    private int rightBraceLine;

    public CompoundStatement() {
        this.statements = new ArrayList<>();
    }

    public void addStatement(BlockItem stmt) {
        this.statements.add(stmt);
    }

    public ArrayList<BlockItem> getStatements() {
        return statements;
    }

    public void setStatements(ArrayList<BlockItem> statements) {
        this.statements = statements;
    }

    public int getRightBraceLine() {
        return rightBraceLine;
    }

    public void setRightBraceLine(int rightBraceLine) {
        this.rightBraceLine = rightBraceLine;
    }

    @Override
    public List<Node> accept_subNodes() {
        return new ArrayList<>(statements);
    }


}
