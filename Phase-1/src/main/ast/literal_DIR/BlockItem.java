package main.ast.literal_DIR;

import main.ast.nodes_DIR.Declaration;
import main.ast.nodes_DIR.Node;
import main.ast.statement_DIR.Stmt;
import main.visitor.IVisitor;

import java.util.ArrayList;
import java.util.List;

public class BlockItem extends Node {
    private Stmt stmt;
    private Declaration decl;

    public BlockItem(Stmt stmt) {
        this.stmt = stmt;
        this.decl = null;
        this.setLine(stmt.getLine());
    }

    public BlockItem(Declaration decl) {
        this.stmt = null;
        this.decl = decl;
        this.setLine(decl.getLine());
    }

    public Stmt getStmt() {
        return stmt;
    }

    public Declaration getDecl() {
        return decl;
    }

    @Override
    public List<Node> accept_subNodes() {
        List<Node> children = new ArrayList<>();
        if (stmt != null) {
            children.add(stmt);
        }
        if (decl != null) {
            children.add(decl);
        }
        return children;
    }
}
