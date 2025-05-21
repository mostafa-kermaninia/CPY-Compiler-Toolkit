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

    private SymbolTable globalTable;
    private final ScopedErrorCollector errors = new ScopedErrorCollector();

    public SymbolTable getGlobalTable() {
        return globalTable;
    }

    public boolean analysisSucceeded() {
        return !errors.hasErrors();
    }

    @Override
    public Void visit(Program node) {
        initializeTable(node);
        analyzeTranslationUnit(node.getTranslationUnit());
        globalTable = SymbolTable.top;
        return null;
    }

    /* ---------- Top Level Analysis ---------- */

    private void initializeTable(Program node) {
        SymbolTable.top = SymbolTable.root = new SymbolTable();
        node.setSymbolTable(SymbolTable.top);
    }

    private void analyzeTranslationUnit(TranslationUnit tu) {
        tu.getExternalDeclaration().forEach(this::analyzeExternalDecl);
    }

    private void analyzeExternalDecl(ExternalDeclaration ext) {
        if (ext.getDeclaration() != null)
            analyzeDeclaration(ext.getDeclaration());
        else if (ext.getFunctionDefinition() != null)
            analyzeFunction(ext.getFunctionDefinition());
    }

    /* ---------- Function Analysis ---------- */

    private void analyzeFunction(FunctionDefinition f) {
        setNumArgs(f);
        declareFunction(f);
        pushScopeForNode(f);

        acceptIfNotNull(f.getDecSpecifiers());
        acceptIfNotNull(f.getDeclarator());
        acceptIfNotNull(f.getDecList());
        acceptIfNotNull(f.getCompoundStmt());

        SymbolTable.pop();
    }

    private void setNumArgs(FunctionDefinition f) {
        ParameterList params = f.getDeclarator().getDirectDec().getParameterList();
        f.setNumArgs(params == null ? 0 : params.getParameterDecs().size());
    }

    private void declareFunction(FunctionDefinition f) {
        try {
            SymbolTable.top.put(new FuncDecSymbolTableItem(f));
        } catch (ItemAlreadyExistsException e) {
            errors.redefineFunction(
                    f.getDeclarator().getDirectDec().getDirectDec().getIdentifier(),
                    f.getDeclarator().getDirectDec().getDirectDec().getLine()
            );
        }
    }

    /* ---------- Declaration Analysis ---------- */

    private void analyzeDeclaration(Declaration d) {
        d.getDeclarationSpecifiers().accept(this);
        acceptIfNotNull(d.getInitDeclaratorList());
    }

    @Override
    public Void visit(DeclarationSpecifiers specs) {
        specs.getDeclarationSpecifiers().forEach(this::acceptIfNotNull);
        // Handle "typedef" mapping
        if (isTypedef(specs)) {
            var all = specs.getDeclarationSpecifiers();
            all.get(all.size() - 1).getTypeSpecifier().setTypeDef(all.get(1).getType());
        }
        return null;
    }

    private boolean isTypedef(DeclarationSpecifiers specs) {
        var declSpecs = specs.getDeclarationSpecifiers();
        return !declSpecs.isEmpty() && "typedef".equals(declSpecs.get(0).getType());
    }

    @Override
    public Void visit(InitDeclaratorList l) {
        l.getInitDeclarators().forEach(this::analyzeVarInit);
        return null;
    }

    private void analyzeVarInit(InitDeclarator decl) {
        DirectDec idNode = getDirectDecWithId(decl.getDeclarator().getDirectDec());
        if (idNode != null && !idNode.getIdentifier().isEmpty()) {
            declareVariable(idNode);
        }
        acceptIfNotNull(decl.getDeclarator());
        acceptIfNotNull(decl.getInitializer());
    }

    private DirectDec getDirectDecWithId(DirectDec d) {
        while (d != null && d.getIdentifier().isEmpty())
            d = d.getDirectDec();
        return d;
    }

    private void declareVariable(DirectDec idNode) {
        TypeSpecifier type = new TypeSpecifier(idNode.getIdentifier());
        type.setLine(idNode.getLine());
        idNode.setTypeSpecifier(type);
        try {
            SymbolTable.top.put(new VarDecSymbolTableItem(type));
        } catch (ItemAlreadyExistsException e) {
            errors.redefineVariable(type.getType(), type.getLine());
        }
    }

    /* ---------- Expression & Statement Analysis ---------- */

    @Override
    public Void visit(ParameterList params) {
        params.getParameterDecs().forEach(this::acceptIfNotNull);
        return null;
    }

    @Override
    public Void visit(ParameterDec p) {
        acceptIfNotNull(p.getDeclarationSpecifier());
        acceptIfNotNull(p.getAbstractDec());
        acceptIfNotNull(p.getDeclarator());
        return null;
    }

    @Override
    public Void visit(Declarator d) {
        acceptIfNotNull(d.getDirectDec());
        acceptIfNotNull(d.getPointer());
        return null;
    }

    @Override
    public Void visit(DirectDec d) {
        acceptIfNotNull(d.getDeclarator());
        acceptIfNotNull(d.getDirectDec());
        acceptIfNotNull(d.getIdentifierList());
        acceptIfNotNull(d.getExpr());
        acceptIfNotNull(d.getParameterList());
        return null;
    }

    @Override
    public Void visit(TypeSpecifier t) {
        try {
            TypeSpecifier def = ((VarDecSymbolTableItem)
                    SymbolTable.top.getItem(VarDecSymbolTableItem.START_KEY + t.getType())).getVarDec();
            if (def.isTypeDef()) {
                t.setType(def.getTypeDefName());
                t.setNotVarDec();
            }
        } catch (ItemNotFoundException ignored) {}
        if (t.isVar_dec())
            declareVariableFromTypeSpecifier(t);
        return null;
    }

    private void declareVariableFromTypeSpecifier(TypeSpecifier t) {
        try {
            SymbolTable.top.put(new VarDecSymbolTableItem(t));
        } catch (ItemAlreadyExistsException e) {
            errors.redefineVariable(t.getType(), t.getLine());
        }
    }

    /* ---------- Scoping Utilities ---------- */

    private void pushScopeForNode(Node n) {
        SymbolTable scope = new SymbolTable(SymbolTable.top);
        n.setSymbolTable(scope);
        SymbolTable.push(scope);
    }

    /* ---------- Utility Accept ---------- */

    private void acceptIfNotNull(Node n) {
        if (n != null) n.accept(this);
    }

    /* ---------- Statements ---------- */

    @Override
    public Void visit(CompoundStmt c) {
        c.getBlockItems().forEach(this::acceptIfNotNull);
        return null;
    }

    @Override
    public Void visit(BlockItem b) {
        acceptIfNotNull(b.getStmt());
        acceptIfNotNull(b.getDeclaration());
        return null;
    }

    @Override
    public Void visit(ExprStmt s) {
        acceptIfNotNull(s.getExpr());
        return null;
    }

    @Override
    public Void visit(SelectionStmt s) {
        pushScopeForNode(s);
        acceptIfNotNull(s.getExpr());
        acceptIfNotNull(s.getMainStmt());
        acceptIfNotNull(s.getElseStmt());
        SymbolTable.pop();
        return null;
    }

    @Override
    public Void visit(IterStmt s) {
        pushScopeForNode(s);
        acceptIfNotNull(s.getForCondition());
        acceptIfNotNull(s.getExpr());
        acceptIfNotNull(s.getStmt());
        SymbolTable.pop();
        return null;
    }

    @Override
    public Void visit(ForCondition f) {
        acceptIfNotNull(f.getForDec());
        acceptIfNotNull(f.getExpr());
        acceptIfNotNull(f.getForExpr1());
        acceptIfNotNull(f.getForExpr2());
        return null;
    }

    @Override
    public Void visit(ForExpr f) {
        f.getExprs().forEach(this::acceptIfNotNull);
        return null;
    }

    /* ---------- Expressions ---------- */

    @Override
    public Void visit(FuncCall call) {
        checkFunctionCall(call);
        acceptIfNotNull(call.getExpr());
        acceptIfNotNull(call.getArgExpr());
        return null;
    }

    private void checkFunctionCall(FuncCall call) {
        Identifier id = (Identifier) call.getExpr();
        String name = id.getIdentifier();
        int line = id.getLine();
        id.setFunc();
        if (!("scanf".equals(name) || "printf".equals(name))) {
            try {
                SymbolTable.top.getItem(FuncDecSymbolTableItem.START_KEY + call.getNumArgs() + name);
            } catch (ItemNotFoundException e) {
                errors.undeclaredFunction(name, line, call.getNumArgs());
            }
        }
    }

    @Override
    public Void visit(Identifier id) {
        if (id.isFunc() || id.getIdentifier().startsWith("\"")) return null;
        try {
            SymbolTable.top.getItem(VarDecSymbolTableItem.START_KEY + id.getIdentifier());
        } catch (ItemNotFoundException e) {
            errors.undeclaredVariable(id.getIdentifier(), id.getLine());
        }
        return null;
    }

    /* ---------- Catch-All for Simple/Recursive Nodes ---------- */

    @Override public Void visit(CastExpr n) { acceptIfNotNull(n.getCastExpr()); acceptIfNotNull(n.getExpr()); acceptIfNotNull(n.getTypeName()); return null; }
    @Override public Void visit(ArgExpr n) { n.getExprs().forEach(this::acceptIfNotNull); return null; }
    @Override public Void visit(UnaryOperator n) { return null; }
    @Override public Void visit(AssignmentOp n) { return null; }
    @Override public Void visit(Pointer n) { return null; }
    @Override public Void visit(IdentifierList n) { return null; }
    @Override public Void visit(TypeName n) { acceptIfNotNull(n.getSpecifierQualifierList()); acceptIfNotNull(n.getAbstractDec()); return null; }
    @Override public Void visit(DirectAbsDec n) { acceptIfNotNull(n.getExpr()); acceptIfNotNull(n.getAbstractDec()); acceptIfNotNull(n.getParameterList()); acceptIfNotNull(n.getDirectAbsDec()); return null; }
    @Override public Void visit(AbstractDec n) { acceptIfNotNull(n.getPointer()); acceptIfNotNull(n.getDirectAbsDec()); return null; }
    @Override public Void visit(Initializer n) { acceptIfNotNull(n.getExpr()); acceptIfNotNull(n.getInitList()); return null; }
    @Override public Void visit(InitializerList n) { n.getInitializers().forEach(this::acceptIfNotNull); n.getDesignations().forEach(this::acceptIfNotNull); return null; }
    @Override public Void visit(Designation n) { n.getDesignators().forEach(this::acceptIfNotNull); return null; }
    @Override public Void visit(Designator n) { acceptIfNotNull(n.getExpr()); return null; }
    @Override public Void visit(SpecifierQualifierList n) { acceptIfNotNull(n.getTypeSpecifier()); acceptIfNotNull(n.getSpecifierQualifierList()); return null; }
    @Override public Void visit(JumpStmt n) { acceptIfNotNull(n.getCondition()); return null; }
    @Override public Void visit(UnaryExpr n) { acceptIfNotNull(n.getExpr()); return null; }
    @Override public Void visit(ExprCast n) { acceptIfNotNull(n.getCastExpr()); acceptIfNotNull(n.getTypeName()); return null; }
    @Override public Void visit(BinaryExpr n) { acceptIfNotNull(n.getExpr1()); acceptIfNotNull(n.getExpr2()); acceptIfNotNull(n.getAssignmentOp()); return null; }
    @Override public Void visit(CondExpr n) { acceptIfNotNull(n.getExpr1()); acceptIfNotNull(n.getExpr2()); acceptIfNotNull(n.getExpr3()); return null; }
    @Override public Void visit(CommaExpr n) { n.getExprs().forEach(this::acceptIfNotNull); return null; }
    @Override public Void visit(ArrayIndexing n) { acceptIfNotNull(n.getExpr1()); acceptIfNotNull(n.getExpr2()); return null; }
    @Override public Void visit(Constant n) { return null; }
    @Override public Void visit(TIExpr n) { acceptIfNotNull(n.getInitializerList()); acceptIfNotNull(n.getTypeName()); return null; }
    @Override public Void visit(PrefixExpr n) { acceptIfNotNull(n.getExpr()); acceptIfNotNull(n.getCastExpr()); acceptIfNotNull(n.getTypeName()); acceptIfNotNull(n.getTIExpr()); acceptIfNotNull(n.getUnaryOp()); return null; }
}