package main.ast.nodes_DIR;

import main.visitor.IVisitor;

import java.util.ArrayList;
import java.util.List;

public class Program extends Node {

    private TranslationUnit translationUnit;

    public TranslationUnit getTranslationUnit() {
        return translationUnit;
    }

    public void setTranslationUnit(TranslationUnit translationUnit) {
        this.translationUnit = translationUnit;
    }


    @Override
    public List<Node> accept_subNodes() {
        List<Node> children = new ArrayList<>();
        if (translationUnit != null)
            children.add(translationUnit);
        return children;
    }


}
