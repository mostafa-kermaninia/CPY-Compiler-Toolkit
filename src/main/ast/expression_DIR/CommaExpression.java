package main.ast.Expression_DIR;

import main.visitor.IVisitor;

import java.util.ArrayList;

public class CommaExpression extends Expression{
    private ArrayList<Expression> Expressions;

    public CommaExpression(Expression Expression){
        Expressions = new ArrayList<>();
        Expressions.add(Expression);
    }

    @Override
    public <T> T accept(IVisitor<T> visitor) {
        return visitor.visit(this);
    }


    public ArrayList<Expression> getExpressions(){ return Expressions; }
    @Override
    public void addExpression(Expression Expression){ Expressions.add(Expression); }
}
