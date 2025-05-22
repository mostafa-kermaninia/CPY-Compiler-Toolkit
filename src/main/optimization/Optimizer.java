package main.optimization;

import main.ast.declaration_DIR.*;
import main.ast.literal_DIR.*;
import main.ast.expression_DIR.*;
import main.ast.statement_DIR.*;
import main.ast.baseNodes_DIR.Program;
import main.ast.baseNodes_DIR.TranslationUnit;
import main.symbolTable.SymbolTable;
import main.symbolTable.exceptions.ItemNotFoundException;
import main.symbolTable.item.FuncDecSymbolTableItem;
import main.symbolTable.item.SymbolTableItem;
import main.symbolTable.item.VarDecSymbolTableItem;
import main.visitor.Visitor;

public class Optimizer extends Visitor<Void> {
    private final SymbolTable globalSymbolTable;
    private boolean hasChanged = false;

    public Optimizer(SymbolTable globalSymbolTable) {
        this.globalSymbolTable = globalSymbolTable;
    }

    public boolean hasChanged() {
        return hasChanged;
    }

    @Override
    public Void visit(Program program) {
        program.getTranslationUnit().accept(this);
        return null;
    }

    public Void visit(TranslationUnit translationUnit) {
        for (ExternalDeclaration extDecl : translationUnit.getExternalDeclaration()) {
            if (extDecl.getFunctionDefinition() != null) {
                String functionName = extDecl.getFunctionDefinition()
                        .getDeclarator().getDirectDec().getDirectDec().getIdentifier();
                if ("main".equals(functionName)) {
                    SymbolTable funcSymbolTable = extDecl.getFunctionDefinition().getSymbolTable();
                    globalSymbolTable.push(funcSymbolTable);
                    SymbolTable current = globalSymbolTable.top;
                    while (current != null) {
                        for (SymbolTableItem item : current.items.values()) {
                            if (item instanceof FuncDecSymbolTableItem && !item.isUsed()) {
                                hasChanged |= translationUnit.removeFuncDec(
                                        ((FuncDecSymbolTableItem) item).getFuncDec()
                                );
                            }
                        }
                        current = current.pre;
                    }
                    globalSymbolTable.pop();
                }
            }
        }
        for (ExternalDeclaration extDecl : translationUnit.getExternalDeclaration()) {
            extDecl.accept(this);
        }
        return null;
    }

    public Void visit(ExternalDeclaration externalDeclaration) {
        if (externalDeclaration.getDeclaration() != null) {
            externalDeclaration.getDeclaration().accept(this);
        } else if (externalDeclaration.getFunctionDefinition() != null) {
            externalDeclaration.getFunctionDefinition().accept(this);
        }
        return null;
    }

    public Void visit(FunctionDefinition funcDef) {
        globalSymbolTable.push(funcDef.getSymbolTable());
        if (funcDef.getDecSpecifiers() != null) {
            funcDef.getDecSpecifiers().accept(this);
        }
        funcDef.getDeclarator().accept(this);
        if (funcDef.getDecList() != null) {
            funcDef.getDecList().accept(this);
        }
        funcDef.getCompoundStmt().accept(this);

        ParameterList params = funcDef.getDeclarator().getDirectDec().getParameterList();
        funcDef.setNumArgs(params == null ? 0 : params.getParameterDecs().size());
        globalSymbolTable.pop();
        return null;
    }

    public Void visit(CastExpr castExpr) {
        if (castExpr.getCastExpr() != null) {
            castExpr.getCastExpr().accept(this);
        }
        if (castExpr.getExpr() != null) {
            castExpr.getExpr().accept(this);
        }
        if (castExpr.getTypeName() != null) {
            castExpr.getTypeName().accept(this);
        }
        return null;
    }

    public Void visit(Declaration declaration) {
        declaration.getDeclarationSpecifiers().accept(this);
        if (declaration.getInitDeclaratorList() != null) {
            declaration.getInitDeclaratorList().accept(this);
        }
        return null;
    }

    public Void visit(DecList decList) {
        for (Declaration decl : decList.getDeclarations()) {
            decl.accept(this);
        }
        return null;
    }

    public Void visit(DeclarationSpecifiers specifiers) {
        for (DeclarationSpecifier spec : specifiers.getDeclarationSpecifiers()) {
            spec.accept(this);
        }
        return null;
    }

    public Void visit(ForDec forDec) {
        forDec.getDeclarationSpecifiers().accept(this);
        if (forDec.getInitDecList() != null) {
            forDec.getInitDecList().accept(this);
        }
        return null;
    }

    public Void visit(DeclarationSpecifier specifier) {
        if (specifier.getTypeSpecifier() != null && specifier.getTypeSpecifier().Used()) {
            specifier.getTypeSpecifier().accept(this);
        }
        return null;
    }

    public Void visit(InitDeclaratorList initList) {
        for (InitDeclarator initDecl : initList.getInitDeclarators()) {
            initDecl.accept(this);
        }
        return null;
    }

    public Void visit(InitDeclarator initDeclarator) {
        initDeclarator.getDeclarator().accept(this);
        if (initDeclarator.getInitializer() != null) {
            initDeclarator.getInitializer().accept(this);
        }
        return null;
    }

    public Void visit(ArgExpr argExpr) {
        for (Expr expr : argExpr.getExprs()) {
            if (expr != null) {
                expr.accept(this);
            }
        }
        return null;
    }

    public Void visit(UnaryOperator unaryOperator) {
        return null;
    }

    public Void visit(TypeSpecifier typeSpecifier) {
        return null;
    }

    public Void visit(AssignmentOp assignmentOp) {
        return null;
    }

    public Void visit(Pointer pointer) {
        return null;
    }

    public Void visit(ParameterList paramList) {
        for (SymbolTableItem item : globalSymbolTable.top.items.values()) {
            if (item instanceof VarDecSymbolTableItem && !item.isUsed()) {
                hasChanged |= paramList.removeParamDec((TypeSpecifier) ((VarDecSymbolTableItem) item).getVarDec());
            }
        }
        return null;
    }

    public Void visit(Declarator declarator) {
        declarator.getDirectDec().accept(this);
        if (declarator.getPointer() != null) {
            declarator.getPointer().accept(this);
        }
        return null;
    }

    public Void visit(DirectDec directDec) {
        if (directDec.getDeclarator() != null) {
            directDec.getDeclarator().accept(this);
        }
        if (directDec.getDirectDec() != null) {
            directDec.getDirectDec().accept(this);
        }
        if (directDec.getIdentifierList() != null) {
            directDec.getIdentifierList().accept(this);
        }
        if (directDec.getExpr() != null) {
            directDec.getExpr().accept(this);
        }
        if (directDec.getParameterList() != null) {
            directDec.getParameterList().accept(this);
        }
        return null;
    }

    public Void visit(SpecifierQualifierList qualifierList) {
        if (qualifierList.getTypeSpecifier() != null) {
            qualifierList.getTypeSpecifier().accept(this);
        }
        if (qualifierList.getSpecifierQualifierList() != null) {
            qualifierList.getSpecifierQualifierList().accept(this);
        }
        return null;
    }

    public Void visit(ParameterDec paramDec) {
        paramDec.getDeclarationSpecifier().accept(this);
        if (paramDec.getAbstractDec() != null) {
            paramDec.getAbstractDec().accept(this);
        }
        if (paramDec.getDeclarator() != null) {
            paramDec.getDeclarator().accept(this);
        }
        return null;
    }

    public Void visit(IdentifierList identifierList) {
        return null;
    }

    public Void visit(TypeName typeName) {
        typeName.getSpecifierQualifierList().accept(this);
        if (typeName.getAbstractDec() != null) {
            typeName.getAbstractDec().accept(this);
        }
        return null;
    }

    public Void visit(DirectAbsDec directAbsDec) {
        if (directAbsDec.getExpr() != null) {
            directAbsDec.getExpr().accept(this);
        }
        if (directAbsDec.getAbstractDec() != null) {
            directAbsDec.getAbstractDec().accept(this);
        }
        if (directAbsDec.getParameterList() != null) {
            directAbsDec.getParameterList().accept(this);
        }
        if (directAbsDec.getDirectAbsDec() != null) {
            directAbsDec.getDirectAbsDec().accept(this);
        }
        return null;
    }

    public Void visit(AbstractDec abstractDec) {
        abstractDec.getPointer().accept(this);
        if (abstractDec.getDirectAbsDec() != null) {
            abstractDec.getDirectAbsDec().accept(this);
        }
        return null;
    }

    public Void visit(Initializer initializer) {
        if (initializer.getExpr() != null) {
            initializer.getExpr().accept(this);
        } else if (initializer.getInitList() != null) {
            initializer.getInitList().accept(this);
        }
        return null;
    }

    public Void visit(InitializerList initList) {
        for (Initializer initializer : initList.getInitializers()) {
            initializer.accept(this);
        }
        for (Designation designation : initList.getDesignations()) {
            designation.accept(this);
        }
        return null;
    }

    public Void visit(Designation designation) {
        for (Designator designator : designation.getDesignators()) {
            designator.accept(this);
        }
        return null;
    }

    public Void visit(Designator designator) {
        if (designator.getExpr() != null) {
            designator.getExpr().accept(this);
        }
        return null;
    }

    public Void visit(CompoundStmt compoundStmt) {
        for (int i = 0; i < compoundStmt.getBlockItems().size(); i++) {
            BlockItem item = compoundStmt.getBlockItems().get(i);
            item.accept(this);
            if ((item.getStmt() instanceof JumpStmt) ||
                    (item.getStmt() instanceof SelectionStmt && ((SelectionStmt)item.getStmt()).allReturn())) {
                hasChanged |= compoundStmt.removeNextBIs(item);
            }
            if (item.getStmt() instanceof ExprStmt) {
                ExprStmt exprStmt = (ExprStmt) item.getStmt();
                Expr expr = exprStmt.getExpr();
                if (expr != null && (
                        (expr instanceof BinaryExpr && ((BinaryExpr) expr).getAssignmentOp() == null) ||
                                expr instanceof Constant ||
                                expr instanceof Identifier ||
                                expr instanceof ArrayIndexing ||
                                expr instanceof CondExpr ||
                                expr instanceof CommaExpr
                )) {
                    boolean removed = compoundStmt.removeBI(item);
                    if (removed) i--;
                    hasChanged |= removed;
                }
            }
            if (item.getDeclaration() != null) {
                for (SymbolTableItem symItem : globalSymbolTable.top.items.values()) {
                    if (symItem instanceof VarDecSymbolTableItem && !symItem.isUsed()) {
                        Declaration decl = item.getDeclaration();
                        DeclarationSpecifiers specs = decl.getDeclarationSpecifiers();
                        int lastIdx = specs.getDeclarationSpecifiers().size() - 1;
                        TypeSpecifier typeSpec = specs.getDeclarationSpecifiers().get(lastIdx).getTypeSpecifier();
                        VarDecSymbolTableItem varItem = (VarDecSymbolTableItem) symItem;
                        boolean typeMatch = typeSpec.equals(varItem.getVarDec());
                        boolean idMismatch = decl.getInitDeclaratorList() != null &&
                                !decl.getInitDeclaratorList().getInitDeclarators().get(0)
                                        .getDeclarator().getDirectDec().getIdentifier()
                                        .equals(varItem.getVarDec().getType());
                        if (typeMatch || idMismatch) {
                            boolean removed = compoundStmt.removeBI(item);
                            if (removed) i--;
                            hasChanged |= removed;
                        }
                    }
                }
            }
        }
        return null;
    }

    public Void visit(BlockItem blockItem) {
        if (blockItem.getStmt() != null) {
            blockItem.getStmt().accept(this);
        } else if (blockItem.getDeclaration() != null) {
            blockItem.getDeclaration().accept(this);
        }
        return null;
    }

    public Void visit(ExprStmt exprStmt) {
        if (exprStmt.getExpr() != null) {
            exprStmt.getExpr().accept(this);
        }
        return null;
    }

    public Void visit(SelectionStmt selectionStmt) {
        SymbolTable.push(selectionStmt.getSymbolTable());
        selectionStmt.getExpr().accept(this);
        selectionStmt.getMainStmt().accept(this);
        if (selectionStmt.getElseStmt() != null) {
            selectionStmt.getElseStmt().accept(this);
        }
        SymbolTable.pop();
        return null;
    }

    public Void visit(IterStmt iterStmt) {
        SymbolTable.push(iterStmt.getSymbolTable());
        if (iterStmt.getExpr() != null) {
            iterStmt.getExpr().accept(this);
        }
        if (iterStmt.getStmt() != null) {
            iterStmt.getStmt().accept(this);
        }
        if (iterStmt.getForCondition() != null) {
            iterStmt.getForCondition().accept(this);
        }
        SymbolTable.pop();
        return null;
    }

    public Void visit(ForCondition forCond) {
        if (forCond.getForDec() != null) {
            forCond.getForDec().accept(this);
        }
        if (forCond.getExpr() != null) {
            forCond.getExpr().accept(this);
        }
        if (forCond.getForExpr1() != null) {
            forCond.getForExpr1().accept(this);
        }
        if (forCond.getForExpr2() != null) {
            forCond.getForExpr2().accept(this);
        }
        return null;
    }

    public Void visit(ForExpr forExpr) {
        for (Expr expr : forExpr.getExprs()) {
            if (expr != null) {
                expr.accept(this);
            }
        }
        return null;
    }

    public Void visit(JumpStmt jumpStmt) {
        if (jumpStmt.getCondition() != null) {
            jumpStmt.getCondition().accept(this);
        }
        return null;
    }

    public Void visit(FuncCall funcCall) {
        String funcName = ((Identifier) funcCall.getExpr()).getIdentifier();
        int lineNum = ((Identifier) funcCall.getExpr()).getLine();
        FuncDecSymbolTableItem funcDec = null;

        if (!"scanf".equals(funcName) && !"printf".equals(funcName)) {
            try {
                funcDec = (FuncDecSymbolTableItem)
                        SymbolTable.top.getItem(FuncDecSymbolTableItem.START_KEY + funcCall.getNumArgs() + funcName);
            } catch (ItemNotFoundException e) {
                System.out.println("Line:" + lineNum + "-> " + funcName + " not declared");
            }
            while (funcDec != null && funcCall.getNumArgs() != funcDec.getFuncDec().getNumArgs()) {
                funcCall.removeArg();
                hasChanged = true;
            }
        }
        funcCall.getExpr().accept(this);
        if (funcCall.getArgExpr() != null) {
            funcCall.getArgExpr().accept(this);
        }
        return null;
    }

    public Void visit(UnaryExpr unaryExpr) {
        unaryExpr.getExpr().accept(this);
        return null;
    }

    public Void visit(ExprCast exprCast) {
        exprCast.getCastExpr().accept(this);
        exprCast.getTypeName().accept(this);
        return null;
    }

    public Void visit(BinaryExpr binaryExpr) {
        binaryExpr.getExpr1().accept(this);
        binaryExpr.getExpr2().accept(this);
        if (binaryExpr.getAssignmentOp() != null) {
            binaryExpr.getAssignmentOp().accept(this);
        }
        return null;
    }

    public Void visit(CondExpr condExpr) {
        condExpr.getExpr1().accept(this);
        condExpr.getExpr2().accept(this);
        condExpr.getExpr3().accept(this);
        return null;
    }

    public Void visit(CommaExpr commaExpr) {
        for (Expr expr : commaExpr.getExprs()) {
            if (expr != null) {
                expr.accept(this);
            }
        }
        return null;
    }

    public Void visit(ArrayIndexing arrayIndex) {
        arrayIndex.getExpr1().accept(this);
        arrayIndex.getExpr2().accept(this);
        return null;
    }

    public Void visit(Identifier identifier) {
        return null;
    }

    public Void visit(Constant constant) {
        return null;
    }

    public Void visit(TIExpr tiExpr) {
        tiExpr.getInitializerList().accept(this);
        tiExpr.getTypeName().accept(this);
        return null;
    }

    public Void visit(PrefixExpr prefixExpr) {
        if (prefixExpr.getExpr() != null) {
            prefixExpr.getExpr().accept(this);
        }
        if (prefixExpr.getCastExpr() != null) {
            prefixExpr.getCastExpr().accept(this);
        }
        if (prefixExpr.getTypeName() != null) {
            prefixExpr.getTypeName().accept(this);
        }
        if (prefixExpr.getTIExpr() != null) {
            prefixExpr.getTIExpr().accept(this);
        }
        if (prefixExpr.getUnaryOp() != null) {
            prefixExpr.getUnaryOp().accept(this);
        }
        return null;
    }
}