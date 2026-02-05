package main.ast.nodes_DIR;

import main.visitor.IVisitor;

import java.util.ArrayList;
import java.util.List;

public class TranslationUnit extends Node {
    private ArrayList<ExternalDeclaration> externalDeclarations;

    public TranslationUnit() {
        this.externalDeclarations = new ArrayList<>();
    }

    public void addExternalDeclaration(ExternalDeclaration decl) {
        this.externalDeclarations.add(decl);
    }

    public ArrayList<ExternalDeclaration> getExternalDeclarations() {
        return externalDeclarations;
    }

    public void setExternalDeclarations(ArrayList<ExternalDeclaration> externalDeclarations) {
        this.externalDeclarations = externalDeclarations;
    }

    public void addDeclaration(ExternalDeclaration externalDecl) {
        externalDeclarations.add(externalDecl);
    }

    @Override
    public List<Node> accept_subNodes() {
        return new ArrayList<>(externalDeclarations);
    }

}
