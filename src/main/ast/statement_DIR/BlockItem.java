package main.ast.statement_DIR;

import main.ast.declaration_DIR.Declaration;
import main.ast.baseNodes_DIR.Node;
import main.visitor.IVisitor;

public class BlockItem extends Node {
    private Statement Statement;
    private Declaration declaration;

    public BlockItem() {
        Statement = null;
        declaration = null;
    }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }

    public Statement getStatement() { return Statement; }
    public void setStatement(Statement stmt) { this.Statement = stmt; }

    public Declaration getDeclaration() { return declaration; }
    public void setDeclaration(Declaration declaration) { this.declaration = declaration; }
}
