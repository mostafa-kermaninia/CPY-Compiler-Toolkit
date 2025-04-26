package main.ast.nodes_DIR;

public abstract class ExternalDeclaration extends Node {

    @Override
    public abstract <T> T accept(main.visitor.IVisitor<T> visitor);
}
