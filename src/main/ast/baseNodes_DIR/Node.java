package main.ast.baseNodes_DIR;

import main.symbolTable.SymbolTable;
import main.visitor.IVisitor;

public abstract class Node {
    private int line;
    protected SymbolTable symbolTable;
    public void setSymbolTable(SymbolTable symbolTable) { this.symbolTable = symbolTable; }
    public SymbolTable getSymbolTable() { return symbolTable; }
    public void setLine(int line){this.line = line;}
    public int getLine(){return this.line;}
    public abstract <T> T accept(IVisitor<T> visitor);

}
