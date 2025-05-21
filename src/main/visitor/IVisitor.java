package main.visitor;

import main.ast.literal_DIR.*;
import main.ast.baseNodes_DIR.Program;
import main.ast.baseNodes_DIR.TranslationUnit;
import main.ast.declaration_DIR.Declaration;
import main.ast.declaration_DIR.ExternalDeclaration;
import main.ast.declaration_DIR.FunctionDefinition;
import main.ast.declaration_DIR.ForDec;
import main.ast.expression_DIR.ForExpression;
import main.ast.statement_DIR.*;
import main.ast.expression_DIR.*;


public interface IVisitor<T> {

    T visit(Program program);
    T visit(TranslationUnit translationUnit);
    T visit(ExternalDeclaration externalDeclaration);
    T visit(FunctionDefinition functionDefinition);
    T visit(Declaration declaration);

    T visit(ForDec forDec);
    T visit(ArgumentExpression argumentExpression);
    T visit(CastExpression castExpression);
    T visit(DecList decList);
    T visit(DeclarationSpecifier declarationSpecifier);
    T visit(DeclarationSpecifiers declarationSpecifiers);
    T visit(InitDeclaratorList initDeclaratorList);
    T visit(AssignmentOp assignmentOp);
    T visit(UnaryOperator unaryOperator);
    T visit(InitDeclarator initDeclarator);
    T visit(TypeSpecifier typeSpecifier);
    T visit(SpecifierQualifierList specifierQualifierList);
    T visit(Declarator declarator);
    T visit(DirectDec directDec);
    T visit(ParameterList parameterList);
    T visit(ParameterDec parameterDec);
    T visit(IdentifierList identifierList);
    T visit(TypeName typeName);
    T visit(Pointer pointer);
    T visit(AbstractDec abstractDec);
    T visit(DirectAbsDec directAbsDec);
    T visit(Initializer initializer);
    T visit(InitializerList initializerList);
    T visit(Designation designation);
    T visit(Designator designator);
    T visit(CompoundStatement compoundStmt);
    T visit(BlockItem blockItem);
    T visit(ExpressionStatement exprStmt);
    T visit(SelectionStatement selectionStmt);
    T visit(IterStatement iterStmt);
    T visit(ForCondition forCondition);
    T visit(ForExpression forExpression);
    T visit(JumpStatement jumpStmt);

    // az inja be baad male expr ha
    T visit(FunctionCall functionCall);
    T visit(UnaryExpression unaryExpr);
    T visit(ExpressionCast exprCast);
    T visit(BinaryExpression binaryExpr);
    T visit(CondExpression condExpr);
    T visit(CommaExpression commaExpr);
    T visit(ArrayIndexing arrayIndexing);
    T visit(Identifier identifier);
    T visit(Constant constant);
    T visit(TypeInitExpression tiExpr);
    T visit(PrefixExpression prefixExpr);





}
