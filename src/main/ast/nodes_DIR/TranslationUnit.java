package main.ast.nodes_DIR;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import main.visitor.IVisitor;


public class TranslationUnit extends Node {

    private List<ExternalDeclaration> externalDeclarations = new ArrayList<>();

    public TranslationUnit() {
    }

    public TranslationUnit(int line, int column) {
        super(line, column);
    }

    public void addExternalDeclaration(ExternalDeclaration decl) {
        if (decl != null)
            externalDeclarations.add(decl);
    }

//    public void setExternalDeclarations(ArrayList<ExternalDeclaration> externalDeclarations) {
//        this.externalDeclarations = externalDeclarations;
//    }

    public List<ExternalDeclaration> getExternalDeclarations() {
        return Collections.unmodifiableList(externalDeclarations);
    }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }
}
