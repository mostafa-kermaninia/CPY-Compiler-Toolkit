package main.visitor;

import main.ast.declaration_DIR.*;
import main.ast.expression_DIR.*;
import main.ast.literal_DIR.*;
import main.ast.nodes_DIR.*;
import main.ast.statement_DIR.*;


public interface IVisitor<T> {

    T visit(Program program);
    T visit(VarDec varDec);
    T visit(IfStmt ifStmt);
    T visit(FuncCallStmt funcCall);
    T visit(Assign assign);
    T visit(UnaryExpr unaryExpr);
    T visit(BinaryExpr binaryExpr);
    T visit(Identifier identifier);
    T visit(IntVal int_Val);
    T visit(StringVal string_val);
    T visit(BoolVal int_Val);
    T visit(DoubleVal double_val);
    T visit(FuncCallExpr func_call_expr);
    T visit(Return returnStmt);

    T visit (TranslationUnit translationUnit);
    T visit (FunctionDefinition functionDefinition);
    T visit (Declaration declaration);
    T visit (TypeSpecifier typeSpecifier);
    T visit (DeclarationSpecifiers declarationSpecifiers);
    T visit (UnaryOperator unaryOperator_2);
    T visit (Pointer pointer);
    T visit (ExternalDeclaration externalDeclaration);
    T visit (DirectDeclarator directDeclarator);
    T visit (ForCondition forCondition);
    T visit (SelectionStatement selectionStatement);
    T visit (ExpressionStatement expressionStatement);
    T visit (BlockItem blockItem);
    T visit (Designator designator);
    T visit (Designation designation);
    T visit (Initializer initializer);
    T visit (InitializerList initializerList);
    T visit (AbstractDeclarator abstractDeclarator);
    T visit (IdentifierList identifierList);
    T visit (DirectAbstractDeclarator directAbstractDeclarator);
    T visit (InitDeclarator initDeclarator);
    T visit (InitDeclaratorList initDeclaratorList);
    T visit (SpecifierQualifierList specifierQualifierList);
    T visit (CompoundStatement compoundStatement);
    T visit (Expr expr);
    T visit (TypeName typeName);
    T visit (JumpStatement jumpStatement);
    T visit (AssignmentOperator assignmentOperator);
    T visit (ArgumentExpressionList argumentExpressionList);
    T visit (IterationStatement iterationStatement);
    T visit (StraySemiColon straySemiColon);
    T visit (InitializerListEntry initializerListEntry);
}
