grammar SimpleLang;

@header {
    import main.ast.nodes.*;
    import main.ast.nodes.Stmt.*;
    import main.ast.nodes.declaration.*;
    import main.ast.nodes.design.*;
    import main.ast.nodes.expr.*;
    import main.ast.nodes.expr.operator.*;
    import main.ast.nodes.expr.primitives.*;
    import main.ast.nodes.initializer.*;
    import main.ast.nodes.type.*;
    import java.util.stream.Collectors;
}

program returns [Program programRet]
    : { $programRet = new Program(); }
    (t = translationUnit { $programRet.setTranslationUnit($t.translationUnitRet);
     $programRet.setLine($t.translationUnitRet.getLine()); }) ? EOF ;

translationUnit returns [TranslationUnit translationUnitRet]
    : ed1=externalDeclaration {
        $translationUnitRet = new TranslationUnit();
        $translationUnitRet.addDeclaration($ed1.externalRet);
        $translationUnitRet.setLine($ed1.externalRet.getLine());
    }
    (eds=externalDeclaration {
        $translationUnitRet.addDeclaration($eds.externalRet);
        $translationUnitRet.setLine($eds.externalRet.getLine());
    })*
    ;

externalDeclaration returns [ExternalDeclaration externalRet]
    : fd=functionDefinition {
        $externalRet = $fd.functionDefinitionRet;
        $externalRet.setLine($fd.functionDefinitionRet.getLine());
    }
    | d=declaration {
        $externalRet = $d.declarationRet;
        $externalRet.setLine($d.declarationRet.getLine());
    }
    ;

functionDefinition returns [FunctionDefinition functionDefinitionRet]
    :
    (ds=declarationSpecifiers {
        $functionDefinitionRet = new FunctionDefinition();
        $functionDefinitionRet.setDeclarationSpecifiers($ds.decSpecsRet);
        $functionDefinitionRet.setLine($ds.decSpecsRet.getLine());
    })?

    d=declarator {
        if ($functionDefinitionRet == null) {
            $functionDefinitionRet = new FunctionDefinition();
        }
        $functionDefinitionRet.setDeclarator($d.declaratorRet);
        String functionName = $d.declaratorRet.getDirectDeclarator().getIdentifier();
        if (functionName != null) {
            $functionDefinitionRet.setFunctionName(functionName);
        }
        $functionDefinitionRet.setLine($d.declaratorRet.getLine());
    }

    (dl=declarationList {
        $functionDefinitionRet.setDeclarationList($dl.decListRet);
        $functionDefinitionRet.setLine($dl.decListRet.getLine());
    })?

    cs=compoundStatement {
        $functionDefinitionRet.setCompoundStatement($cs.compoundStmtRet);
        $functionDefinitionRet.setLine($cs.compoundStmtRet.getLine());
    }
    ;

declarationList returns [DeclarationList decListRet]
    : d1=declaration {
        $decListRet = new DeclarationList();
        $decListRet.addDeclaration($d1.declarationRet);
        $decListRet.setLine($d1.declarationRet.getLine());
    }
    (d=declaration {
        $decListRet.addDeclaration($d.declarationRet);
        $decListRet.setLine($d.declarationRet.getLine());
    })*
    ;

expression
    returns [Expr exprRet]
  : id=Identifier {
        $exprRet = new IdentifierExpr($id.text);
        $exprRet.setLine($id.getLine());
    }
  | c=Constant {
        $exprRet = new ConstantExpr($c.text);
        $exprRet.setLine($c.getLine());
    }
  | sl+=StringLiteral+ {
        $exprRet = new StringExpr($sl.stream().map(x -> x.getText()).collect(Collectors.toList()));
        $exprRet.setLine($sl.get(0).getLine());
    }
  | LeftParen e=expression RightParen {
        $exprRet = $e.exprRet;
        $exprRet.setLine($e.exprRet.getLine());
    }
  | LeftParen tn=typeName RightParen LeftBrace il=initializerList Comma? RightBrace {
        $exprRet = new CompoundLiteralExpr($tn.typeNameRet, $il.ret);
        $exprRet.setLine($tn.typeNameRet.getLine());
    }
  | e12=expression LeftBracket e2=expression RightBracket {
        $exprRet = new ArrayAccessExpr($e12.exprRet, $e2.exprRet);
        $exprRet.setLine($e12.exprRet.getLine());
    }
  | e13=expression LeftParen args=argumentExpressionList? RightParen {
        $exprRet = new FunctionCallExpr(
            $e13.exprRet,
            $args.argumentExpressionListRet.getArguments() != null ? $args.argumentExpressionListRet.getArguments() : new ArrayList<>()
        );
        $exprRet.setLine($e13.exprRet.getLine());
  }
  | e=expression op=(PlusPlus | MinusMinus) {
        $exprRet = new PostfixExpr($e.exprRet, $op.getText());
        $exprRet.setLine($e.exprRet.getLine());
    }
  | pre+=(PlusPlus | MinusMinus | Sizeof)* base=expressionBase {
        $exprRet = $base.exprRet;
        for (Token p : $pre) {
            $exprRet = new PrefixExpr(p.getText(), $exprRet);
        }
        $exprRet.setLine($base.exprRet.getLine());
    }
  | LeftParen tn=typeName RightParen ce=castExpression {
        $exprRet = new CastExpr($tn.typeNameRet, $ce.castRet);
        $exprRet.setLine($tn.typeNameRet.getLine());
    }
  | e14=expression op=(Star | Div | Mod) e2=expression {
        $exprRet = new BinaryExpr($e14.exprRet, $op.getText(), $e2.exprRet);
        $exprRet.setLine($e14.exprRet.getLine());
    }
  | e15=expression op=(Plus | Minus) e2=expression {
        $exprRet = new BinaryExpr($e15.exprRet, $op.getText(), $e2.exprRet);
        $exprRet.setLine($e15.exprRet.getLine());
    }
  | e16=expression op=(LeftShift | RightShift) e2=expression {
        $exprRet = new BinaryExpr($e16.exprRet, $op.getText(), $e2.exprRet);
        $exprRet.setLine($e16.exprRet.getLine());
    }
  | e17=expression op=(Less | Greater | LessEqual | GreaterEqual) e2=expression {
        $exprRet = new BinaryExpr($e17.exprRet, $op.getText(), $e2.exprRet);
        $exprRet.setLine($e17.exprRet.getLine());
    }
  | e18=expression op=(Equal | NotEqual) e2=expression {
        $exprRet = new BinaryExpr($e18.exprRet, $op.getText(), $e2.exprRet);
        $exprRet.setLine($e18.exprRet.getLine());
    }
  | e19=expression op=And e2=expression {
        $exprRet = new BinaryExpr($e19.exprRet, $op.getText(), $e2.exprRet);
        $exprRet.setLine($e19.exprRet.getLine());
    }
  | e20=expression op=Xor e2=expression {
        $exprRet = new BinaryExpr($e20.exprRet, $op.getText(), $e2.exprRet);
        $exprRet.setLine($e20.exprRet.getLine());
    }
  | e21=expression op=Or e2=expression {
        $exprRet = new BinaryExpr($e21.exprRet, $op.getText(), $e2.exprRet);
        $exprRet.setLine($e12.exprRet.getLine());
    }
  | e22=expression op=AndAnd e2=expression {
        $exprRet = new BinaryExpr($e22.exprRet, $op.getText(), $e2.exprRet);
        $exprRet.setLine($e22.exprRet.getLine());
    }
  | e23=expression op=OrOr e2=expression {
        $exprRet = new BinaryExpr($e23.exprRet, $op.getText(), $e2.exprRet);
        $exprRet.setLine($e23.exprRet.getLine());
    }
  | e24=expression Question e2=expression Colon e3=expression {
        $exprRet = new ConditionalExpr($e24.exprRet, $e2.exprRet, $e3.exprRet);
        $exprRet.setLine($e24.exprRet.getLine());
    }
  | e25=expression ao=assignmentOperator e2=expression {
        $exprRet = new AssignmentExpr($e25.exprRet, $ao.assignmentOperatorRet.getOperatorType(), $e2.exprRet);
        $exprRet.setLine($e25.exprRet.getLine());
    }
  | head=expression (Comma tail+=expression)+ {
      List<Expr> exprList = new ArrayList<>();
      exprList.add($head.exprRet);
      exprList.addAll($tail.stream().map(e -> e.exprRet).collect(Collectors.toList()));
      $exprRet = new CommaExpr(exprList);
      $exprRet.setLine($head.exprRet.getLine());
  }
  ;

expressionBase
    returns [Expr exprRet]
  : id=Identifier {
        $exprRet = new IdentifierExpr($id.text);
        $exprRet.setLine($id.getLine());
    }
  | c=Constant {
        $exprRet = new ConstantExpr($c.text);
        $exprRet.setLine($c.getLine());
    }
  | sl+=StringLiteral+ {
        $exprRet = new StringExpr($sl.stream().map(x -> x.getText()).collect(Collectors.toList()));
        $exprRet.setLine($sl.get(0).getLine());
    }
  | LeftParen e=expression RightParen {
        $exprRet = $e.exprRet;
        $exprRet.setLine($e.exprRet.getLine());
    }
  | LeftParen tn=typeName RightParen LeftBrace il=initializerList Comma? RightBrace {
        $exprRet = new CompoundLiteralExpr($tn.typeNameRet, $il.ret);
        $exprRet.setLine($tn.typeNameRet.getLine());
    }
  | uop=unaryOperator_2 ce=castExpression {
        $exprRet = new UnaryExpr($uop.text, $ce.castRet);
        $exprRet.setLine($ce.castRet.getLine());
    }
  | Sizeof LeftParen tn=typeName RightParen {
        $exprRet = new SizeofTypeExpr($tn.typeNameRet);
        $exprRet.setLine($tn.typeNameRet.getLine());
    }
  ;

argumentExpressionList returns [ArgumentExpressionList argumentExpressionListRet]
  : e=expression {
      $argumentExpressionListRet = new ArgumentExpressionList();
      $argumentExpressionListRet.addArgument($e.exprRet);
  }
  (Comma e2=expression {
      $argumentExpressionListRet.addArgument($e2.exprRet);
  })* ;

unaryOperator_2 returns [UnaryOperator_2 unaryOpRet]
    : a=And     { $unaryOpRet = new UnaryOperator_2($a.text); $unaryOpRet.setLine($a.line); }
    | s=Star    { $unaryOpRet = new UnaryOperator_2($s.text); $unaryOpRet.setLine($s.line); }
    | p=Plus    { $unaryOpRet = new UnaryOperator_2($p.text); $unaryOpRet.setLine($p.line); }
    | m=Minus   { $unaryOpRet = new UnaryOperator_2($m.text); $unaryOpRet.setLine($m.line); }
    | t=Tilde   { $unaryOpRet = new UnaryOperator_2($t.text); $unaryOpRet.setLine($t.line); }
    | n=Not     { $unaryOpRet = new UnaryOperator_2($n.text); $unaryOpRet.setLine($n.line); }
    ;

castExpression returns [CastExpression castRet]
    : l=LeftParen t=typeName r=RightParen e=castExpression {
        $castRet = new CastExpression($t.typeNameRet, $e.castRet);
        $castRet.setLine($l.getLine());
    }
    | ee=expression {
        $castRet = new CastExpression($ee.exprRet);
        $castRet.setLine($ee.exprRet.getLine());
    }
    | d=DigitSequence {
        $castRet = new CastExpression($d.getText());
        $castRet.setLine($d.getLine());
    };

assignmentOperator returns [AssignmentOperator assignmentOperatorRet]
    : op=(Assign
        | StarAssign
        | DivAssign
        | ModAssign
        | PlusAssign
        | MinusAssign
        | LeftShiftAssign
        | RightShiftAssign
        | AndAssign
        | XorAssign
        | OrAssign)
    {
        $assignmentOperatorRet = new AssignmentOperator($op.getText());
        $assignmentOperatorRet.setLine($op.getLine());
    };

declaration returns [Declaration declarationRet]
    : ds = declarationSpecifiers {
        $declarationRet = new Declaration();
        $declarationRet.setDeclarationSpecifiers($ds.decSpecsRet);
    }

    (idl = initDeclaratorList {
        $declarationRet.setInitDeclarators($idl.initDecListRet);
    })?

    s = Semi {
        $declarationRet.setLine($s.getLine());
    }
    ;

declarationSpecifiers returns [DeclarationSpecifiers decSpecsRet]
    : ds1=declarationSpecifier {
        $decSpecsRet = new DeclarationSpecifiers();
        $decSpecsRet.addDeclarationSpecifier($ds1.decSpecsRet);
    }
    (ds=declarationSpecifier {
        $decSpecsRet.addDeclarationSpecifier($ds.decSpecsRet);
    })*
    ;

declarationSpecifier returns [DeclarationSpecifier decSpecsRet]
    :
    ts=Typedef {
        $decSpecsRet = new DeclarationSpecifier($ts.getText());
        $decSpecsRet.setLine($ts.getLine());
    }
    |
    t=typeSpecifier {
        $decSpecsRet = new DeclarationSpecifier($t.typeSpecifierRet);
        $decSpecsRet.setLine($t.typeSpecifierRet.getLine());
    }
    |
    c=Const {
        $decSpecsRet = new DeclarationSpecifier($c.getText());
        $decSpecsRet.setLine($c.getLine());
    };


initializer returns [Initializer initRet]
    : e=expression {
        $initRet = new Initializer();
        $initRet.setExpression($e.exprRet);
        $initRet.setLine($e.exprRet.getLine());
    }
    | l=LeftBrace il=initializerList c=Comma? RightBrace {
        $initRet = new Initializer();
        $initRet.setInitializerList($il.ret);
        $initRet.setLine($l.getLine());
    }
    ;

initializerList returns [InitializerList ret]
    : (d=designation? i=initializer {
        $ret = new InitializerList();
        $ret.addEntry($d.designationRet, $i.initRet);
    })
    (Comma d2=designation? i2=initializer {
        $ret.addEntry($d2.designationRet, $i2.initRet);
    })*
    ;

initDeclaratorList returns [InitDeclaratorList initDecListRet]
    : d1=initDeclarator {
        $initDecListRet = new InitDeclaratorList();
        $initDecListRet.addInitDeclarator($d1.initDecRet);
    }
    (Comma d2=initDeclarator {
        $initDecListRet.addInitDeclarator($d2.initDecRet);
    })*
    ;

initDeclarator returns [InitDeclarator initDecRet]
    :
    d=declarator {
        $initDecRet = new InitDeclarator($d.declaratorRet);
        $initDecRet.setLine($d.declaratorRet.getLine());
    }
    (a=Assign i=initializer {
        $initDecRet.setInitializer($i.initRet);
    })?;

typeSpecifier returns [TypeSpecifier typeSpecifierRet]
    :
    v=Void {
        $typeSpecifierRet = new TypeSpecifier($v.getText());
        $typeSpecifierRet.setLine($v.getLine());
    }
    | c=Char {
        $typeSpecifierRet = new TypeSpecifier($c.getText());
        $typeSpecifierRet.setLine($c.getLine());
    }
    | s=Short {
        $typeSpecifierRet = new TypeSpecifier($s.getText());
        $typeSpecifierRet.setLine($s.getLine());
    }
    | i=Int {
        $typeSpecifierRet = new TypeSpecifier($i.getText());
        $typeSpecifierRet.setLine($i.getLine());
    }
    | l=Long {
        $typeSpecifierRet = new TypeSpecifier($l.getText());
        $typeSpecifierRet.setLine($l.getLine());
    }
    | f=Float {
        $typeSpecifierRet = new TypeSpecifier($f.getText());
        $typeSpecifierRet.setLine($f.getLine());
    }
    | d=Double {
        $typeSpecifierRet = new TypeSpecifier($d.getText());
        $typeSpecifierRet.setLine($d.getLine());
    }
    | sig=Signed {
        $typeSpecifierRet = new TypeSpecifier($sig.getText());
        $typeSpecifierRet.setLine($sig.getLine());
    }
    | uns=Unsigned {
        $typeSpecifierRet = new TypeSpecifier($uns.getText());
        $typeSpecifierRet.setLine($uns.getLine());
    }
    | b=Bool {
        $typeSpecifierRet = new TypeSpecifier($b.getText());
        $typeSpecifierRet.setLine($b.getLine());
    }
    | id=Identifier {
        $typeSpecifierRet = new TypeSpecifier($id.getText());
        $typeSpecifierRet.setLine($id.getLine());
    }
    ;

specifierQualifierList returns [SpecifierQualifierList specifierQualifierListRet]
    : (ts=typeSpecifier {
          $specifierQualifierListRet = new SpecifierQualifierList();
          $specifierQualifierListRet.addTypeSpecifier($ts.typeSpecifierRet);
       }
      | c=Const {
          $specifierQualifierListRet = new SpecifierQualifierList();
          $specifierQualifierListRet.setConstLine($c.getLine());
          $specifierQualifierListRet.setIsConst(true);
       })
      s=specifierQualifierList? {
          if ($s.specifierQualifierListRet != null) {
              $specifierQualifierListRet.append($s.specifierQualifierListRet);
          }
       }
    ;

declarator returns [Declarator declaratorRet]
    :
      (p=pointer { $declaratorRet = new Declarator(); $declaratorRet.setPointer($p.ptrRet); })?
      d=directDeclarator
      {
          if ($declaratorRet == null) {
              $declaratorRet = new Declarator();
          }
          $declaratorRet.setDirectDeclarator($d.directDecRet);
      }
    ;

directDeclarator returns [DirectDeclarator directDecRet]
    : id=Identifier {
        $directDecRet = new DirectDeclarator($id.getText());
    }
    | LeftParen d=declarator RightParen {
        $directDecRet = new DirectDeclarator($d.declaratorRet);
    }
    | dd=directDeclarator { $directDecRet = new DirectDeclarator($dd.directDecRet); } LeftBracket
        (e=expression { $directDecRet.setSize($e.exprRet); })?
        RightBracket

    | dd=directDeclarator LeftParen pl=parameterList RightParen {
        $directDecRet = new DirectDeclarator($dd.directDecRet, $pl.paramListRet);
    }
    | dd=directDeclarator { $directDecRet = new DirectDeclarator($dd.directDecRet); } LeftParen
        (il=identifierList { $directDecRet.setIdentifierList($il.ret); })?
      RightParen
    ;


pointer returns [Pointer ptrRet]
    : (stars+=Star (consts+=Const+)?)+ {
        $ptrRet = new Pointer();

        int starCount = $stars.size();
        boolean isConst = $consts != null && !$consts.isEmpty();

        $ptrRet.setPointerLevel(starCount);
        $ptrRet.setConst(isConst);
        $ptrRet.setLine($stars.get(0).getLine());
    }
    ;

parameterList returns [ParameterList paramListRet]
    : p1=parameterDeclaration {
        $paramListRet = new ParameterList();
        $paramListRet.addParameter($p1.parDecRet);
    }
    (Comma p2=parameterDeclaration {
        $paramListRet.addParameter($p2.parDecRet);
    })*
    ;


parameterDeclaration returns [ParameterDeclaration parDecRet]
    : declarationSpecifiers declarator {
        $parDecRet = new ParameterDeclaration($declarationSpecifiers.decSpecsRet, $declarator.declaratorRet);
    }
    | declarationSpecifiers abstractDeclarator {
        $parDecRet = new ParameterDeclaration($declarationSpecifiers.decSpecsRet, $abstractDeclarator.abstractDecRet);
    }
    ;

identifierList returns [IdentifierList ret]
    : id1=Identifier (Comma idN+=Identifier)* {
        List<Identifier> identifiers = new ArrayList<>();
        Identifier first = new Identifier($id1.getText());
        first.setLine($id1.getLine());
        identifiers.add(first);

        for (Token tok : $idN) {
            Identifier id = new Identifier(tok.getText());
            id.setLine(tok.getLine());
            identifiers.add(id);
        }

        $ret = new IdentifierList(identifiers);
    };

typeName returns [TypeName typeNameRet]
    : s=specifierQualifierList a=abstractDeclarator? {
        $typeNameRet = new TypeName($s.specifierQualifierListRet, $a.abstractDecRet != null ? $a.abstractDecRet : null);
        $typeNameRet.setLine($s.specifierQualifierListRet.getLine());
    }
    ;

abstractDeclarator returns [AbstractDeclarator abstractDecRet]
    : p=pointer {
        $abstractDecRet = new AbstractDeclarator();
        $abstractDecRet.setPointer($p.ptrRet);
    }
    | p2=pointer? d=directAbstractDeclarator {
        $abstractDecRet = new AbstractDeclarator();
        if ($p2.ptrRet != null) $abstractDecRet.setPointer($p2.ptrRet);
        $abstractDecRet.setDirectAbstractDeclarator($d.directAbstractDecRet);
    };

directAbstractDeclarator
    returns [DirectAbstractDeclarator directAbstractDecRet]
  :
    lb1=LeftBracket expr1=expression? rb1=RightBracket
    {
        $directAbstractDecRet = new DirectAbstractDeclarator();
        if ($expr1.exprRet != null) {
            $directAbstractDecRet.setExpression($expr1.exprRet);
        }
        $directAbstractDecRet.setLine($lb1.getLine());
    }

  | lp1=LeftParen ad1=abstractDeclarator rp1=RightParen
    {
        $directAbstractDecRet = new DirectAbstractDeclarator();
        $directAbstractDecRet.setAbstractDeclarator($ad1.abstractDecRet);
        $directAbstractDecRet.setLine($lp1.getLine());
    }
  | lp2=LeftParen pl1=parameterList? rp2=RightParen
    {
        $directAbstractDecRet = new DirectAbstractDeclarator();
        if ($pl1.paramListRet != null) {
            $directAbstractDecRet.setParameterList($pl1.paramListRet);
        }
        $directAbstractDecRet.setLine($lp2.getLine());
    }

  | dad1=directAbstractDeclarator lb2=LeftBracket expr2=expression? rb2=RightBracket
    {
        $directAbstractDecRet = new DirectAbstractDeclarator();
        $directAbstractDecRet.setPreviousDeclarator($dad1.directAbstractDecRet);
        if ($expr2.exprRet != null) {
            $directAbstractDecRet.setExpression($expr2.exprRet);
        }
        $directAbstractDecRet.setLine($lb2.getLine());
    }

  | dad2=directAbstractDeclarator lp3=LeftParen pl2=parameterList? rp3=RightParen
    {
        $directAbstractDecRet = new DirectAbstractDeclarator();
        $directAbstractDecRet.setPreviousDeclarator($dad2.directAbstractDecRet);
        if ($pl2.paramListRet != null) {
            $directAbstractDecRet.setParameterList($pl2.paramListRet);
        }
        $directAbstractDecRet.setLine($lp3.getLine());
    }
  ;

designation returns [Designation designationRet]
    : d+=designator+ a=Assign {
        $designationRet = new Designation();
        for (var dItem : $d) {
            $designationRet.addDesignator(dItem.designatorRet);
        }
        $designationRet.setLine($a.getLine());
    }
    ;

designator returns [Designator designatorRet]
    : LeftBracket expr=expression RightBracket {
        $designatorRet = new Designator($expr.exprRet);
        $designatorRet.setLine($expr.exprRet.getLine());
    }
    | Dot id=Identifier {
        $designatorRet = new Designator($id.getText());
        $designatorRet.setLine($id.getLine());
    }
    ;

statement returns [Stmt statementRet]
    : cs=compoundStatement {
        $statementRet = $cs.compoundStmtRet;
    }
    | es=expressionStatement {
        $statementRet = $es.exprStmtRet;
    }
    | ss=selectionStatement {
        $statementRet = $ss.selectionStmtRet;
    }
    | is=iterationStatement {
        $statementRet = $is.stmtRet;
    }
    | js=jumpStatement {
        $statementRet = $js.jumpStmtRet;
    }
    ;

compoundStatement returns [CompoundStatement compoundStmtRet]
    : l=LeftBrace {
        $compoundStmtRet = new CompoundStatement();
        $compoundStmtRet.setLine($l.getLine());
    }

    (b=blockItem { $compoundStmtRet.addStatement($b.blockItemRet); })*

    r=RightBrace {
        $compoundStmtRet.setRightBraceLine($r.getLine());
    }

    ;

blockItem returns [BlockItem blockItemRet]
    : s=statement {
        $blockItemRet = new BlockItem($s.statementRet);
    }
    | d=declaration {
        $blockItemRet = new BlockItem($d.declarationRet);
    }
    ;


expressionStatement returns [ExpressionStatement exprStmtRet]
    : e=expression? s=Semi {
        $exprStmtRet = new ExpressionStatement();
        $exprStmtRet.setLine($s.getLine());
        if ($e.exprRet != null)
            $exprStmtRet.setExpression($e.exprRet);
    }
    ;

selectionStatement returns [SelectionStatement selectionStmtRet]
    : i = If LeftParen e = expression RightParen s1 = statement {
        $selectionStmtRet = new SelectionStatement($e.exprRet, $s1.statementRet);
    }
    (Else s2 = statement {
        $selectionStmtRet.setElseBody($s2.statementRet);
    })?
    { $selectionStmtRet.setLine($i.line); }
    ;

iterationStatement returns [IterationStatement stmtRet]
    : w=While lp=LeftParen cond=expression rp=RightParen body=statement
        {
            $stmtRet = new IterationStatement(
                IterationStatement.LoopType.WHILE,
                $cond.exprRet,
                $body.statementRet
            );
            $stmtRet.setLine($w.getLine());
        }
    | d=Do body1=statement w2=While lp2=LeftParen cond2=expression rp2=RightParen s=Semi
        {
            $stmtRet = new IterationStatement(
                IterationStatement.LoopType.DO_WHILE,
                $cond2.exprRet,
                $body1.statementRet
            );
            $stmtRet.setLine($d.getLine());
        }
    | f=For lp3=LeftParen fc=forCondition rp3=RightParen body2=statement
        {
            $stmtRet = new IterationStatement(
                IterationStatement.LoopType.FOR,
                $fc.forCondRet,
                $body2.statementRet
            );
            $stmtRet.setLine($f.getLine());
        }
    ;

forCondition returns [ForCondition forCondRet]
    : (
        d = forDeclaration {
            $forCondRet = new ForCondition();
            $forCondRet.setForDeclaration($d.forDeclRet);
        }
        |
        e1 = expression {
            $forCondRet = new ForCondition();
            $forCondRet.setCondition($e1.exprRet);
        }
        |
        {
            $forCondRet = new ForCondition();
        }
    )
    Semi

    (e2 = forExpression {
        $forCondRet.setCondition2($e2.forExprRet);
    })?

    Semi

    (e3 = forExpression {
        $forCondRet.setUpdateExpression($e3.forExprRet);
    })?
    ;


forDeclaration returns [ForDeclaration forDeclRet]
    : declSpecifiers=declarationSpecifiers initDecList=initDeclaratorList? {
        $forDeclRet = new ForDeclaration();
        $forDeclRet.setDeclarationSpecifiers($declSpecifiers.decSpecsRet);
        if ($initDecList.initDecListRet != null) {
            $forDeclRet.setInitDeclaratorList($initDecList.initDecListRet);
        }
    }
    ;

forExpression returns [ForExpression forExprRet]
    : e1=expression {
        $forExprRet = new ForExpression();
        $forExprRet.addExpression($e1.exprRet);
    }
    (Comma e2=expression {
        $forExprRet.addExpression($e2.exprRet);
    })*
    ;

jumpStatement returns [JumpStatement jumpStmtRet]
    : c=Continue Semi
        {
            $jumpStmtRet = new JumpStatement(JumpStatement.CONTINUE, null, $c.getLine());
        }
    | b=Break    Semi
        {
            $jumpStmtRet = new JumpStatement(JumpStatement.BREAK, null, $b.getLine());
        }
    | r1=Return e=expression Semi
        {
            $jumpStmtRet = new JumpStatement(JumpStatement.RETURN, $e.exprRet, $r1.getLine());
        }
    | r2=Return  Semi
        {
            $jumpStmtRet = new JumpStatement(JumpStatement.RETURN, null, $r2.getLine());
        }
    ;


Break                 : 'break'                 ;
Char                  : 'char'                  ;
Const                 : 'const'                 ;
Continue              : 'continue'              ;
Do                    : 'do'                    ;
Double                : 'double'                ;
Else                  : 'else'                  ;
Float                 : 'float'                 ;
For                   : 'for'                   ;
If                    : 'if'                    ;
Int                   : 'int'                   ;
Long                  : 'long'                  ;
Return                : 'return'                ;
Short                 : 'short'                 ;
Signed                : 'signed'                ;
Sizeof                : 'sizeof'                ;
Switch                : 'switch'                ;
Typedef               : 'typedef'               ;
Unsigned              : 'unsigned'              ;
Void                  : 'void'                  ;
While                 : 'while'                 ;
Bool                  : 'bool'                  ;
LeftParen             : '('                     ;
RightParen            : ')'                     ;
LeftBracket           : '['                     ;
RightBracket          : ']'                     ;
LeftBrace             : '{'                     ;
RightBrace            : '}'                     ;
Less                  : '<'                     ;
LessEqual             : '<='                    ;
Greater               : '>'                     ;
GreaterEqual          : '>='                    ;
LeftShift             : '<<'                    ;
RightShift            : '>>'                    ;
Plus                  : '+'                     ;
PlusPlus              : '++'                    ;
Minus                 : '-'                     ;
MinusMinus            : '--'                    ;
Star                  : '*'                     ;
Div                   : '/'                     ;
Mod                   : '%'                     ;
And                   : '&'                     ;
Or                    : '|'                     ;
AndAnd                : '&&'                    ;
OrOr                  : '||'                    ;
Xor                   : '^'                     ;
Not                   : '!'                     ;
Tilde                 : '~'                     ;
Question              : '?'                     ;
Colon                 : ':'                     ;
Semi                  : ';'                     ;
Comma                 : ','                     ;
Assign                : '='                     ;
StarAssign            : '*='                    ;
DivAssign             : '/='                    ;
ModAssign             : '%='                    ;
PlusAssign            : '+='                    ;
MinusAssign           : '-='                    ;
LeftShiftAssign       : '<<='                   ;
RightShiftAssign      : '>>='                   ;
AndAssign             : '&='                    ;
XorAssign             : '^='                    ;
OrAssign              : '|='                    ;
Equal                 : '=='                    ;
NotEqual              : '!='                    ;
Arrow                 : '->'                    ;
Dot                   : '.'                     ;

Identifier
    : IdentifierNondigit (IdentifierNondigit | Digit)* ;

fragment IdentifierNondigit
    : Nondigit | UniversalCharacterName ;

fragment Nondigit
    : [a-zA-Z_] ;

fragment Digit
    : [0-9] ;

fragment UniversalCharacterName
    : '\\u' HexQuad | '\\U' HexQuad HexQuad ;

fragment HexQuad
    : HexadecimalDigit HexadecimalDigit HexadecimalDigit HexadecimalDigit ;

Constant
    : IntegerConstant | FloatingConstant | CharacterConstant ;

fragment IntegerConstant
    : DecimalConstant IntegerSuffix?
    | OctalConstant IntegerSuffix?
    | HexadecimalConstant IntegerSuffix?
    | BinaryConstant ;

fragment BinaryConstant
    : '0' [bB] [0-1]+ ;

fragment DecimalConstant
    : NonzeroDigit Digit* ;

fragment OctalConstant
    : '0' OctalDigit* ;

fragment HexadecimalConstant
    : HexadecimalPrefix HexadecimalDigit+ ;

fragment HexadecimalPrefix
    : '0' [xX] ;

fragment NonzeroDigit
    : [1-9] ;

fragment OctalDigit
    : [0-7] ;

fragment HexadecimalDigit
    : [0-9a-fA-F] ;

fragment IntegerSuffix
    : UnsignedSuffix LongSuffix? | UnsignedSuffix LongLongSuffix | LongSuffix UnsignedSuffix? | LongLongSuffix UnsignedSuffix? ;

fragment UnsignedSuffix
    : [uU] ;

fragment LongSuffix
    : [lL] ;

fragment LongLongSuffix
    : 'll' | 'LL' ;

fragment FloatingConstant
    : DecimalFloatingConstant | HexadecimalFloatingConstant ;

fragment DecimalFloatingConstant
    : FractionalConstant ExponentPart? FloatingSuffix? | DigitSequence ExponentPart FloatingSuffix? ;

fragment HexadecimalFloatingConstant
    : HexadecimalPrefix (HexadecimalFractionalConstant | HexadecimalDigitSequence) BinaryExponentPart FloatingSuffix? ;

fragment FractionalConstant
    : DigitSequence? Dot DigitSequence | DigitSequence Dot ;

fragment ExponentPart
    : [eE] Sign? DigitSequence ;

fragment Sign
    : [+-] ;

DigitSequence
    : Digit+ ;

fragment HexadecimalFractionalConstant
    : HexadecimalDigitSequence? Dot HexadecimalDigitSequence | HexadecimalDigitSequence Dot ;

fragment BinaryExponentPart
    : [pP] Sign? DigitSequence ;

fragment HexadecimalDigitSequence
    : HexadecimalDigit+ ;

fragment FloatingSuffix
    : [flFL] ;

fragment CharacterConstant
    : '\'' CCharSequence '\'' | 'L\'' CCharSequence '\''| 'u\'' CCharSequence '\'' | 'U\'' CCharSequence '\''
    ;

fragment CCharSequence
    : CChar+ ;

fragment CChar
    : ~['\\\r\n] | EscapeSequence ;

fragment EscapeSequence
    : SimpleEscapeSequence | OctalEscapeSequence | HexadecimalEscapeSequence | UniversalCharacterName ;

fragment SimpleEscapeSequence
    : '\\' ['"?abfnrtv\\] ;

fragment OctalEscapeSequence
    : '\\' OctalDigit OctalDigit? OctalDigit? ;

fragment HexadecimalEscapeSequence
    : '\\x' HexadecimalDigit+ ;

StringLiteral
    : EncodingPrefix? '"' SCharSequence? '"' ;

fragment EncodingPrefix
    : 'u8' | 'u' | 'U' | 'L' ;

fragment SCharSequence
    : SChar+ ;

fragment SChar
    : ~["\\\r\n] | EscapeSequence | '\\\n' | '\\\r\n' ;

MultiLineMacro
    : '#' (~[\n]*? '\\' '\r'? '\n')+ ~ [\n]+ -> channel(HIDDEN) ;

Directive
    : '#' ~[\n]* -> channel(HIDDEN) ;

Whitespace
    : [ \t]+ -> channel(HIDDEN) ;

Newline
    : ('\r' '\n'? | '\n') -> channel(HIDDEN) ;

BlockComment
    : '/*' .*? '*/' -> channel(HIDDEN) ;

LineComment
    : '//' ~[\r\n]* -> channel(HIDDEN) ;