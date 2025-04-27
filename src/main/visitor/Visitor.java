package main.visitor;

import main.ast.declaration_DIR.*;
import main.ast.expression_DIR.*;
import main.ast.literal_DIR.*;
import main.ast.nodes_DIR.*;
import main.ast.statement_DIR.*;

/*GOALs:
*   1. print out scope changes each time a new scope starts
*   2. print the identifier if it is initialized
*   3. print the identifier if it is used
*   4. print out the name of the function when it is defined
*   5. print out the name of the function when it is used
*
* */

public abstract class Visitor<T> implements IVisitor<T> {
    @Override
    public T visit(Program program) {
        return null;
    }

    public T visit(Assign assign) {
        return null;
    }
    public T visit(VarDec varDec) {
        return null;
    }
    public T visit(IfStmt ifStmt) {
        return null;
    }
    public T visit(FuncCallStmt funcCall) {
        return null;
    }
    public T visit(UnaryExpr unaryExpr) {
        return null;
    }
    public T visit(BinaryExpr binaryExpr) {
        return null;
    }
    public T visit(Identifier identifier) {
        return null;
    }

    public T visit(IntVal int_Val) {
        return null;
    }
    public T visit(StringVal string_val){return null;}
    public T visit(BoolVal bool_val){return null;}
    public T visit(DoubleVal double_vals){return null;}
    public T visit(FuncCallExpr func_call_expr){
        return null;
    }
    public T visit(Return the_return){
        return null;
    }

    public T visit(TranslationUnit translationUnit) { return null; }
    public T visit(FunctionDefinition functionDefinition) { return null; }
    public T visit(Declaration declaration) { return null; }
    public T visit(TypeSpecifier typeSpecifier) { return null; }
    public T visit(UnaryOperator unaryOperator_2) { return null; }
    public T visit(Pointer pointer) { return null; }
    public T visit(ExternalDeclaration externalDeclaration) { return null; }
    public T visit(DirectDeclarator directDeclarator) { return null; }
    public T visit(ForCondition forCondition) { return null; }
    public T visit(SelectionStatement selectionStatement) { return null; }
    public T visit(ExpressionStatement expressionStatement) { return null; }
    public T visit(BlockItem blockItem) { return null; }
    public T visit(Designation designation) { return null; }
    public T visit(Initializer initializer) { return null; }
    public T visit(InitializerList initializerList) { return null; }
    public T visit(AbstractDeclarator abstractDeclarator) { return null; }
    public T visit(IdentifierList identifierList) { return null; }
    public T visit(DirectAbstractDeclarator directAbstractDeclarator) { return null; }
    public T visit(InitDeclarator initDeclarator) { return null; }
    public T visit(InitDeclaratorList initDeclaratorList) { return null; }
    public T visit(SpecifierQualifierList specifierQualifierList) { return null; }
    public T visit(CompoundStatement compoundStatement) { return null; }
    public T visit(Expr expr) { return null; }
    public T visit(TypeName typeName) { return null; }
    public T visit(JumpStatement jumpStatement) { return null; }
    public T visit(AssignmentOperator assignmentOperator) { return null; }
    public T visit(IterationStatement iterationStatement) { return null; }
    public T visit(StraySemiColon straySemiColon) { return null; }
    public T visit(InitializerListEntry initializerListEntry) { return null; }
}
