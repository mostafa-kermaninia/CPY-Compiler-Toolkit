package main.optimization;

import main.symbolTable.SymbolTable;
import main.visitor.Visitor;

public class Optimizer extends Visitor<Void> {
    public SymbolTable symbolTableMain;
    @Override
    public Void visit(Program program) {
        program.getTranslationUnit().accept(this);
        return null;
    }
}