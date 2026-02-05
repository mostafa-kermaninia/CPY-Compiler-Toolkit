package main.ast.expression_DIR;

import main.ast.nodes_DIR.Node;
import main.ast.literal_DIR.TypeName;

import java.util.ArrayList;
import java.util.List;

public class SizeofTypeExpr extends Expr {
    private TypeName typeName;

    public SizeofTypeExpr(TypeName typeName) {
        this.typeName = typeName;
    }

    public TypeName getTypeName() {
        return typeName;
    }

    public void setTypeName(TypeName typeName) {
        this.typeName = typeName;
    }

    @Override
    public List<Node> accept_subNodes() {
        List<Node> children = new ArrayList<>();
        if (typeName != null) {
            children.add(typeName);
        }
        return children;
    }

}
