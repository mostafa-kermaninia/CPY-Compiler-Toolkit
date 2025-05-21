package main.visitor;

import main.ast.baseNodes_DIR.*;
import main.ast.declaration_DIR.*;
import main.ast.expression_DIR.*;
import main.ast.literal_DIR.*;
import main.ast.statement_DIR.*;
import main.symbolTable.*;
import main.symbolTable.exceptions.*;
import main.symbolTable.item.*;
import main.visitor.utils.ScopedErrorCollector;

public class NameAnalyzer extends Visitor<Void> {
    private SymbolTable rootTable;
    private final ScopedErrorCollector errorReporter = new ScopedErrorCollector();

    public SymbolTable getRootTable() { return rootTable; }
    public boolean hasNoErrors() { return !errorReporter.hasErrors(); }

    @Override
    public Void visit(Program program) {
        SymbolTable.top = new SymbolTable();
        SymbolTable.root = SymbolTable.top;
        program.setSymbolTable(SymbolTable.top);

        program.getTranslationUnit().accept(this);

        rootTable = SymbolTable.top;
        return null;
    }

    @Override
    public Void visit(TranslationUnit translationUnit) {
        for (ExternalDeclaration ext : translationUnit.getExternalDeclaration())
            ext.accept(this);
        return null;
    }

    @Override
    public Void visit(ExternalDeclaration ext) {
        if (ext.getDeclaration() != null)
            ext.getDeclaration().accept(this);
        else if (ext.getFunctionDefinition() != null)
            ext.getFunctionDefinition().accept(this);
        return null;
    }

    @Override
    public Void visit(FunctionDefinition fn) {
        ParameterList params = fn.getDeclarator().getDirectDec().getParameterList();
        fn.setNumArgs(params == null ? 0 : params.getParameterDecs().size());

        try {
            SymbolTable.top.put(new FuncDecSymbolTableItem(fn));
        } catch (ItemAlreadyExistsException e) {
            errorReporter.redefineFunction(
                    fn.getDeclarator().getDirectDec().getDirectDec().getIdentifier(),
                    fn.getDeclarator().getDirectDec().getDirectDec().getLine()
            );
        }

        SymbolTable localScope = new SymbolTable(SymbolTable.top);
        fn.setSymbolTable(localScope);
        SymbolTable.push(localScope);

        if (fn.getDecSpecifiers() != null)
            fn.getDecSpecifiers().accept(this);
        fn.getDeclarator().accept(this);
        if (fn.getDecList() != null)
            fn.getDecList().accept(this);
        fn.getCompoundStmt().accept(this);

        SymbolTable.pop();
        return null;
    }

    @Override
    public Void visit(Declaration declaration) {
        declaration.getDeclarationSpecifiers().accept(this);
        if (declaration.getInitDeclaratorList() != null)
            declaration.getInitDeclaratorList().accept(this);
        return null;
    }

    @Override
    public Void visit(DecList decList) {
        for (Declaration d : decList.getDeclarations())
            d.accept(this);
        return null;
    }

    @Override
    public Void visit(DeclarationSpecifiers specs) {
        for (DeclarationSpecifier s : specs.getDeclarationSpecifiers())
            s.accept(this);
        // Typedef mapping logic
        if (!specs.getDeclarationSpecifiers().isEmpty()
                && "typedef".equals(specs.getDeclarationSpecifiers().get(0).getType()))
            specs.getDeclarationSpecifiers().get(specs.getDeclarationSpecifiers().size() - 1)
                    .getTypeSpecifier().setTypeDef(specs.getDeclarationSpecifiers().get(1).getType());
        return null;
    }

    @Override
    public Void visit(ForDec forDec) {
        forDec.getDeclarationSpecifiers().accept(this);
        if (forDec.getInitDecList() != null)
            forDec.getInitDecList().accept(this);
        return null;
    }

    @Override
    public Void visit(DeclarationSpecifier spec) {
        if (spec.getTypeSpecifier() != null)
            spec.getTypeSpecifier().accept(this);
        return null;
    }

    @Override
    public Void visit(InitDeclaratorList list) {
        for (InitDeclarator decl : list.getInitDeclarators())
            decl.accept(this);
        return null;
    }

    @Override
    public Void visit(InitDeclarator decl) {
        DirectDec d = decl.getDeclarator().getDirectDec();
        while (d.getIdentifier().isEmpty())
            d = d.getDirectDec();
        if (!d.getIdentifier().isEmpty()) {
            TypeSpecifier ts = new TypeSpecifier(d.getIdentifier());
            ts.setLine(d.getLine());
            d.setTypeSpecifier(ts);
            try {
                SymbolTable.top.put(new VarDecSymbolTableItem(ts));
            } catch (ItemAlreadyExistsException e) {
                errorReporter.redefineVariable(ts.getType(), ts.getLine());
            }
        }
        decl.getDeclarator().accept(this);
        if (decl.getInitializer() != null)
            decl.getInitializer().accept(this);
        return null;
    }

    @Override
    public Void visit(ArgExpr args) {
        for (Expr e : args.getExprs())
            if (e != null)
                e.accept(this);
        return null;
    }

    @Override
    public Void visit(UnaryOperator u) { return null; }

    @Override
    public Void visit(TypeSpecifier ts) {
        try {
            TypeSpecifier base = ((VarDecSymbolTableItem)
                    SymbolTable.top.getItem(VarDecSymbolTableItem.START_KEY + ts.getType())).getVarDec();
            if (base.isTypeDef()) {
                ts.setType(base.getTypeDefName());
                ts.setNotVarDec();
            }
        } catch (ItemNotFoundException ignored) {}

        if (ts.isVar_dec()) {
            try {
                SymbolTable.top.put(new VarDecSymbolTableItem(ts));
            } catch (ItemAlreadyExistsException e) {
                errorReporter.redefineVariable(ts.getType(), ts.getLine());
            }
        }
        return null;
    }

    @Override
    public Void visit(AssignmentOp op) { return null; }
    @Override
    public Void visit(Pointer ptr) { return null; }

    @Override
    public Void visit(ParameterList list) {
        for (ParameterDec p : list.getParameterDecs())
            p.accept(this);
        return null;
    }

    @Override
    public Void visit(Declarator decl) {
        decl.getDirectDec().accept(this);
        if (decl.getPointer() != null)
            decl.getPointer().accept(this);
        return null;
    }

    @Override
    public Void visit(DirectDec d) {
        if (d.getDeclarator() != null)
            d.getDeclarator().accept(this);
        if (d.getDirectDec() != null)
            d.getDirectDec().accept(this);
        if (d.getIdentifierList() != null)
            d.getIdentifierList().accept(this);
        if (d.getExpr() != null)
            d.getExpr().accept(this);
        if (d.getParameterList() != null)
            d.getParameterList().accept(this);
        return null;
    }

    @Override
    public Void visit(SpecifierQualifierList q) {
        if (q.getTypeSpecifier() != null)
            q.getTypeSpecifier().accept(this);
        if (q.getSpecifierQualifierList() != null)
            q.getSpecifierQualifierList().accept(this);
        return null;
    }

    @Override
    public Void visit(ParameterDec p) {
        p.getDeclarationSpecifier().accept(this);
        if (p.getAbstractDec() != null)
            p.getAbstractDec().accept(this);
        if (p.getDeclarator() != null)
            p.getDeclarator().accept(this);
        return null;
    }

    @Override
    public Void visit(IdentifierList l) { return null; }

    @Override
    public Void visit(TypeName t) {
        t.getSpecifierQualifierList().accept(this);
        if (t.getAbstractDec() != null)
            t.getAbstractDec().accept(this);
        return null;
    }

    @Override
    public Void visit(DirectAbsDec n) {
        if (n.getExpr() != null)
            n.getExpr().accept(this);
        if (n.getAbstractDec() != null)
            n.getAbstractDec().accept(this);
        if (n.getParameterList() != null)
            n.getParameterList().accept(this);
        if (n.getDirectAbsDec() != null)
            n.getDirectAbsDec().accept(this);
        return null;
    }

    @Override
    public Void visit(AbstractDec n) {
        n.getPointer().accept(this);
        if (n.getDirectAbsDec() != null)
            n.getDirectAbsDec().accept(this);
        return null;
    }

    @Override
    public Void visit(Initializer init) {
        if (init.getExpr() != null)
            init.getExpr().accept(this);
        else if (init.getInitList() != null)
            init.getInitList().accept(this);
        return null;
    }

    @Override
    public Void visit(InitializerList list) {
        for (Initializer i : list.getInitializers())
            i.accept(this);
        for (Designation d : list.getDesignations())
            d.accept(this);
        return null;
    }

    @Override
    public Void visit(Designation n) {
        for (Designator d : n.getDesignators())
            d.accept(this);
        return null;
    }

    @Override
    public Void visit(Designator n) {
        if (n.getExpr() != null)
            n.getExpr().accept(this);
        return null;
    }

    @Override
    public Void visit(CompoundStmt block) {
        for (BlockItem b : block.getBlockItems())
            b.accept(this);
        return null;
    }

    @Override
    public Void visit(BlockItem item) {
        if (item.getStmt() != null)
            item.getStmt().accept(this);
        else if (item.getDeclaration() != null)
            item.getDeclaration().accept(this);
        return null;
    }

    @Override
    public Void visit(ExprStmt stmt) {
        if (stmt.getExpr() != null)
            stmt.getExpr().accept(this);
        return null;
    }

    @Override
    public Void visit(SelectionStmt stmt) {
        SymbolTable scope = new SymbolTable(SymbolTable.top);
        stmt.setSymbolTable(scope);
        SymbolTable.push(scope);

        stmt.getExpr().accept(this);
        stmt.getMainStmt().accept(this);
        if (stmt.getElseStmt() != null)
            stmt.getElseStmt().accept(this);

        SymbolTable.pop();
        return null;
    }

    @Override
    public Void visit(IterStmt stmt) {
        SymbolTable scope = new SymbolTable(SymbolTable.top);
        stmt.setSymbolTable(scope);
        SymbolTable.push(scope);

        if (stmt.getForCondition() != null)
            stmt.getForCondition().accept(this);
        if (stmt.getExpr() != null)
            stmt.getExpr().accept(this);
        if (stmt.getStmt() != null)
            stmt.getStmt().accept(this);

        SymbolTable.pop();
        return null;
    }

    @Override
    public Void visit(ForCondition cond) {
        if (cond.getForDec() != null)
            cond.getForDec().accept(this);
        if (cond.getExpr() != null)
            cond.getExpr().accept(this);
        if (cond.getForExpr1() != null)
            cond.getForExpr1().accept(this);
        if (cond.getForExpr2() != null)
            cond.getForExpr2().accept(this);
        return null;
    }

    @Override
    public Void visit(ForExpr expr) {
        for (Expr e : expr.getExprs())
            if (e != null)
                e.accept(this);
        return null;
    }

    @Override
    public Void visit(JumpStmt stmt) {
        if (stmt.getCondition() != null)
            stmt.getCondition().accept(this);
        return null;
    }

    @Override
    public Void visit(FuncCall call) {
        String funcName = ((Identifier) call.getExpr()).getIdentifier();
        int line = ((Identifier) call.getExpr()).getLine();
        ((Identifier) call.getExpr()).setFunc();

        if (!("scanf".equals(funcName) || "printf".equals(funcName))) {
            try {
                SymbolTable.top.getItem(FuncDecSymbolTableItem.START_KEY + call.getNumArgs() + funcName);
            } catch (ItemNotFoundException e) {
                errorReporter.undeclaredFunction(funcName, line, call.getNumArgs());
            }
        }
        call.getExpr().accept(this);
        if (call.getArgExpr() != null)
            call.getArgExpr().accept(this);
        return null;
    }

    @Override
    public Void visit(UnaryExpr node) {
        node.getExpr().accept(this);
        return null;
    }

    @Override
    public Void visit(ExprCast node) {
        node.getCastExpr().accept(this);
        node.getTypeName().accept(this);
        return null;
    }

    @Override
    public Void visit(BinaryExpr node) {
        node.getExpr1().accept(this);
        node.getExpr2().accept(this);
        if (node.getAssignmentOp() != null)
            node.getAssignmentOp().accept(this);
        return null;
    }

    @Override
    public Void visit(CondExpr node) {
        node.getExpr1().accept(this);
        node.getExpr2().accept(this);
        node.getExpr3().accept(this);
        return null;
    }

    @Override
    public Void visit(CommaExpr node) {
        for (Expr e : node.getExprs())
            if (e != null)
                e.accept(this);
        return null;
    }

    @Override
    public Void visit(ArrayIndexing node) {
        node.getExpr1().accept(this);
        node.getExpr2().accept(this);
        return null;
    }

    @Override
    public Void visit(Identifier id) {
        if (!id.isFunc() && !id.getIdentifier().startsWith("\"")) {
            try {
                SymbolTable.top.getItem(VarDecSymbolTableItem.START_KEY + id.getIdentifier());
            } catch (ItemNotFoundException e) {
                errorReporter.undeclaredVariable(id.getIdentifier(), id.getLine());
            }
        }
        return null;
    }

    @Override
    public Void visit(Constant node) { return null; }

    @Override
    public Void visit(TIExpr node) {
        node.getInitializerList().accept(this);
        node.getTypeName().accept(this);
        return null;
    }

    @Override
    public Void visit(PrefixExpr node) {
        if (node.getExpr() != null)
            node.getExpr().accept(this);
        if (node.getCastExpr() != null)
            node.getCastExpr().accept(this);
        if (node.getTypeName() != null)
            node.getTypeName().accept(this);
        if (node.getTIExpr() != null)
            node.getTIExpr().accept(this);
        if (node.getUnaryOp() != null)
            node.getUnaryOp().accept(this);
        return null;
    }
}