package main.ast.statement_DIR;

import main.visitor.IVisitor;

import java.util.ArrayList;

public class CompoundStatement extends Statement { ;
    private ArrayList<BlockItem> blockItems = new ArrayList<BlockItem>();

    public CompoundStatement() {}

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }


    public ArrayList<BlockItem> getBlockItems() { return blockItems; }
    public void addBlockItem(BlockItem blockItem) { this.blockItems.add(blockItem); }
}
