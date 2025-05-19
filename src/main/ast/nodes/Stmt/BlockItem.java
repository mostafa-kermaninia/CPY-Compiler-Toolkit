package main.ast.nodes.Stmt;

import main.ast.nodes.ExternalDeclaration.Declaration;
import main.ast.nodes.Node;
import main.ast.nodes.expr.Expr;
import main.visitor.IVisitor;

public class BlockItem extends Node {
    private Stmt stmt;
    private Declaration declaration;

    public BlockItem() {
        stmt = null;
        declaration = null;
    }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }

    public Stmt getStmt() { return stmt; }
    public void setStmt(Stmt stmt) { this.stmt = stmt; }

    public Declaration getDeclaration() { return declaration; }
    public void setDeclaration(Declaration declaration) { this.declaration = declaration; }
}
