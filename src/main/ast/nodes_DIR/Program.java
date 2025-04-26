package main.ast.nodes_DIR;

import main.visitor.IVisitor;

/**
 * Root node of the AST.
 * */
public class Program extends Node {

    private TranslationUnit translationUnit;   // may be null for an empty file

    public Program() {
        super();
    }

    public Program(int line, int column, TranslationUnit translationUnit) {
        super(line, column);
        this.translationUnit = translationUnit;
    }

    public TranslationUnit getTranslationUnit() {
        return translationUnit;
    }

    public void setTranslationUnit(TranslationUnit translationUnit) {
        this.translationUnit = translationUnit;
    }


    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }
}
