package main.ast.expression_DIR;

import main.ast.literal_DIR.TypeName;
import main.ast.baseNodes_DIR.Node;
import main.visitor.IVisitor;

public class CastExpression extends Node {
    private CastExpr castExpression;
    private Expr expr;
    private TypeName typeName;
    private String number;

    public CastExpression() {
        castExpression = null;
        expr = null;
        typeName = null;
    }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }

    public Expr getExpr() { return expr; }
    public void setExpr(Expr expr) { this.expr = expr; }

    public TypeName getTypeName() { return typeName; }
    public void setTypeName(TypeName typeName) { this.typeName = typeName; }

    public String getNum() { return number; }
    public void setNum(String number) { this.number = number; }

    public CastExpr getCastExpr() { return castExpression; }
    public void setCastExpr(CastExpr castExpression) { this.castExpression = castExpression; }
}
