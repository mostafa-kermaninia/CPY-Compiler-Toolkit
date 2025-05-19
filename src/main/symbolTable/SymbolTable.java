package main.symbolTable;


import main.symbolTable.exceptions.ItemAlreadyExistsException;
import main.symbolTable.exceptions.ItemNotFoundException;
import main.symbolTable.item.SymbolTableItem;

import java.util.*;


public class SymbolTable {

    //Start of static members

    public static SymbolTable top;
    public static SymbolTable root;
    private static Stack<SymbolTable> stack = new Stack<>();

    public static void push(SymbolTable symbolTable) {
        if (top != null)
            stack.push(top);
        top = symbolTable;
    }

    public static void pop() {
        top = stack.pop();
    }

    public SymbolTable pre;
    public Map<String, SymbolTableItem> items;

    public SymbolTable() {
        this(null);
    }

    public SymbolTable(SymbolTable pre) {
        this.pre = pre;
        this.items = new HashMap<>();
    }

    public static Stack<SymbolTable> getStack() {
        return stack;
    }

    public void put(SymbolTableItem item) throws ItemAlreadyExistsException {
        if (items.containsKey(item.getKey()))
            throw new ItemAlreadyExistsException();
        items.put(item.getKey(), item);
    }

    public SymbolTableItem getItem(String key) throws ItemNotFoundException {
        key = key.trim();
        SymbolTable currentSymbolTable = this;
        while(currentSymbolTable != null) {
            SymbolTableItem symbolTableItem = currentSymbolTable.items.get(key);
            if( symbolTableItem != null ) {
//                System.out.println(symbolTableItem.getKey().equals(key));
//                System.out.println(symbolTableItem.getKey() + " shombol " + key);
//                System.out.println(key.hashCode());
//                System.out.println(symbolTableItem.getKey().hashCode());
//                System.out.println(key.hashCode() == symbolTableItem.getKey().hashCode());
                return symbolTableItem;
            }
            currentSymbolTable = currentSymbolTable.pre;
        }
        throw new ItemNotFoundException();
    }

    public int getItemsSize() {
        return this.items.size();
    }
}
