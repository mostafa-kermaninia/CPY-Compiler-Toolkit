package main.ast.nodes.expr;

import main.visitor.IVisitor;
import main.ast.nodes.*;

public class TIExpr extends Expr{
    private InitializerList initializerList;
    private TypeName typeName;

    public TIExpr(TypeName typeName, InitializerList initializerList){
        this.typeName = typeName;
        this.initializerList = initializerList;
    }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }

    public InitializerList getInitializerList(){ return initializerList; }
    public TypeName getTypeName(){ return typeName; }
}
