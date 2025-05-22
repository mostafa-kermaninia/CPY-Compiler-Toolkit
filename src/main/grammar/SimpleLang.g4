grammar SimpleLang;


@header{
    import main.ast.baseNodes_DIR.*;
    import main.ast.declaration_DIR.*;
    import main.ast.Expressionession_DIR.*;
    import main.ast.literal_DIR.*;
    import main.ast.statement_DIR.*;
}


program returns [Program programRet]
    : {$programRet = new Program();} (id = translationUnit {$programRet.setTranslationUnit($id.translationUnitRet);})? EOF ;

translationUnit returns [TranslationUnit translationUnitRet]
    : {$translationUnitRet = new TranslationUnit();} (id = externalDeclaration
        {$translationUnitRet.addExternalDeclaration($id.externalDeclarationRet);})+ ;

externalDeclaration returns [ExternalDeclaration externalDeclarationRet]
    : a = functionDefinition
        {
            $externalDeclarationRet = new ExternalDeclaration();
            $externalDeclarationRet.setFunctionDefinition($a.functionDefinitionRet);
        }
    | b = declaration
        {
            $externalDeclarationRet = new ExternalDeclaration();
            $externalDeclarationRet.setDeclaration($b.declarationRet);
            $externalDeclarationRet.setLine($b.declarationRet.getLine());
        }
    | {$externalDeclarationRet = new ExternalDeclaration();} Semi ; // stray ;
functionDefinition returns [FunctionDefinition functionDefinitionRet]
    : {$functionDefinitionRet = new FunctionDefinition();}
        (ds = declarationSpecifiers {$functionDefinitionRet.setDecSpecifiers($ds.declarationSpecifiersRet);})?
        d = declarator {$functionDefinitionRet.setDeclarator($d.declaratorRet); $functionDefinitionRet.setLine($d.declaratorRet.getLine());}
        (dl = declarationList {$functionDefinitionRet.setDecList($dl.decListRet);})?
         c = compoundStatement {$functionDefinitionRet.setCompoundStmt($c.compoundStmtRet);} ;
// az in be bala ham zadam

declarationList returns [DecList decListRet]
    : {$decListRet = new DecList();} (d = declaration {$decListRet.addDeclaration($d.declarationRet);})+ ;

Expressionession returns [Expression ExpressionRet]
  : id = Identifier {$ExpressionRet = new Identifier($id.text); $ExpressionRet.setLine($id.line);}
  | c = Constant {$ExpressionRet = new Constant($c.text); $ExpressionRet.setLine($c.line);}
  | s = StringLiteral+ {$ExpressionRet = new Identifier($s.text); $ExpressionRet.notFirst();}
  | LeftParen e = Expressionession {$ExpressionRet = $e.ExpressionRet; $e.ExpressionRet.notFirst();} RightParen
  | LeftParen t = typeName RightParen LeftBrace i = initializerList {$ExpressionRet = new TIExpression($t.typeNameRet, $i.initializerListRet);} Comma? RightBrace
  | e1 = Expressionession LeftBracket e2 = Expressionession RightBracket {$ExpressionRet = new ArrayIndexing($e1.ExpressionRet, $e2.ExpressionRet);  $e1.ExpressionRet.notFirst(); $e2.ExpressionRet.notFirst();}                               // Array indexing
  | fe = Expressionession {$ExpressionRet = new FuncCall($fe.ExpressionRet); $ExpressionRet.notFirst();} LeftParen (fa = argumentExpressionessionList {$ExpressionRet.setArgExpression($fa.argExpressionRet); $fa.argExpressionRet.notFirstExpression();})? RightParen                       // Function call
  | ue = Expressionession pp = PlusPlus  {$ExpressionRet = new UnaryExpression($ue.ExpressionRet, $pp.text); $ExpressionRet.setLine($pp.line);  $ue.ExpressionRet.notFirst();}                                                         // Postfix increment
  | ue2 = Expressionession mm = MinusMinus {$ExpressionRet = new UnaryExpression($ue2.ExpressionRet, $mm.text); $ExpressionRet.setLine($mm.line);   $ue2.ExpressionRet.notFirst();}                                                         // Postfix decrement
  | {PrefixExpression pe = new PrefixExpression();} (pp = PlusPlus {pe.addOp($pp.text);} | mm = MinusMinus {pe.addOp($mm.text);} | s = Sizeof {pe.addOp($s.text);})* (                                          // Prefix operators (zero or more)
         id = Identifier {pe.setIdentifier($id.text);}
       | c = Constant {pe.setConstant($c.text);}
       | StringLiteral+
       | LeftParen e = Expressionession RightParen {pe.setExpression($e.ExpressionRet); $e.ExpressionRet.notFirst();}
       | LeftParen t = typeName RightParen LeftBrace i = initializerList
            {
            pe.setTIExpression(new TIExpression($t.typeNameRet, $i.initializerListRet));
            }     Comma? RightBrace
       | u = unaryOperator c1 = castExpressionession
            {
            pe.setUnaryOp($u.unaryOpRet);
            pe.setCastExpression($c1.castExpressionRet);
            $c1.castExpressionRet.getExpression().notFirst();
            }
       | Sizeof LeftParen t1 = typeName {pe.setTypeName($t1.typeNameRet); } RightParen
    ) {$ExpressionRet = pe;}
  | LeftParen t = typeName RightParen ce = castExpressionession  {$ExpressionRet = new ExpressionCast($t.typeNameRet, $ce.castExpressionRet);}                                // Cast Expressionession
  | e1 = Expressionession op = (Star | Div | Mod) e2 = Expressionession {$e1.ExpressionRet.notFirst(); $e2.ExpressionRet.notFirst();} {$ExpressionRet = new BinaryExpression($e1.ExpressionRet, $e2.ExpressionRet, $op.text); $ExpressionRet.setLine($op.line);}                                     // Multiplicative
  | e1 = Expressionession op = (Plus | Minus) e2 = Expressionession {$e1.ExpressionRet.notFirst(); $e2.ExpressionRet.notFirst();} {$ExpressionRet = new BinaryExpression($e1.ExpressionRet, $e2.ExpressionRet, $op.text); $ExpressionRet.setLine($op.line);}                                          // Additive
  | e1 = Expressionession op = (LeftShift | RightShift) e2 = Expressionession {$e1.ExpressionRet.notFirst(); $e2.ExpressionRet.notFirst();} {$ExpressionRet = new BinaryExpression($e1.ExpressionRet, $e2.ExpressionRet, $op.text); $ExpressionRet.setLine($op.line);}                               // Shift
  | e1 = Expressionession op = (Less | Greater | LessEqual | GreaterEqual) e2 = Expressionession {$e1.ExpressionRet.notFirst(); $e2.ExpressionRet.notFirst();} {$ExpressionRet = new BinaryExpression($e1.ExpressionRet, $e2.ExpressionRet, $op.text); $ExpressionRet.setLine($op.line);}            // Relational
  | e1 = Expressionession op = (Equal | NotEqual) e2 = Expressionession {$e1.ExpressionRet.notFirst(); $e2.ExpressionRet.notFirst();} {$ExpressionRet = new BinaryExpression($e1.ExpressionRet, $e2.ExpressionRet, $op.text); $ExpressionRet.setLine($op.line);}                                     // Equality
  | e1 = Expressionession op = And e2 = Expressionession {$e1.ExpressionRet.notFirst(); $e2.ExpressionRet.notFirst();} {$ExpressionRet = new BinaryExpression($e1.ExpressionRet, $e2.ExpressionRet, $op.text); $ExpressionRet.setLine($op.line);}                                                    // Bitwise AND
  | e1 = Expressionession op = Xor e2 = Expressionession {$e1.ExpressionRet.notFirst(); $e2.ExpressionRet.notFirst();} {$ExpressionRet = new BinaryExpression($e1.ExpressionRet, $e2.ExpressionRet, $op.text); $ExpressionRet.setLine($op.line);}                                                    // Bitwise XOR
  | e1 = Expressionession op = Or e2 = Expressionession {$e1.ExpressionRet.notFirst(); $e2.ExpressionRet.notFirst();} {$ExpressionRet = new BinaryExpression($e1.ExpressionRet, $e2.ExpressionRet, $op.text); $ExpressionRet.setLine($op.line);}                                                     // Bitwise OR
  | e1 = Expressionession op = AndAnd e2 = Expressionession  {$e1.ExpressionRet.notFirst(); $e2.ExpressionRet.notFirst();} {$ExpressionRet = new BinaryExpression($e1.ExpressionRet, $e2.ExpressionRet, $op.text); $ExpressionRet.setLine($op.line);}                                                // Logical AND
  | e1 = Expressionession op = OrOr e2 = Expressionession {$e1.ExpressionRet.notFirst(); $e2.ExpressionRet.notFirst();} {$ExpressionRet = new BinaryExpression($e1.ExpressionRet, $e2.ExpressionRet, $op.text); $ExpressionRet.setLine($op.line);}                                                   // Logical OR
  | e1 = Expressionession q = Question e2 = Expressionession Colon e3 = Expressionession {$e1.ExpressionRet.notFirst(); $e2.ExpressionRet.notFirst(); $e3.ExpressionRet.notFirst();} {$ExpressionRet = new CondExpression($e1.ExpressionRet, $e2.ExpressionRet, $e3.ExpressionRet); $ExpressionRet.setLine($q.line);}                               // Conditional operator
  | e1 = Expressionession a = assignmentOperator e2 = Expressionession {$e1.ExpressionRet.notFirst(); $e2.ExpressionRet.notFirst();} {$ExpressionRet = new BinaryExpression($e1.ExpressionRet, $e2.ExpressionRet, $a.assignmentOpRet); $ExpressionRet.setLine($a.assignmentOpRet.getLine());}                                     // Assignment
  ;//| e1 = Expressionession {$ExpressionRet = new CommaExpression($e1.ExpressionRet); $e1.ExpressionRet.notFirst();} (c = Comma e = Expressionession {$ExpressionRet.addExpression($e.ExpressionRet); $e.ExpressionRet.notFirst(); $ExpressionRet.setLine($c.line);})+ ;                                              // Comma operator
// az in be paiin class zadam

argumentExpressionessionList returns [ArgExpression argExpressionRet]
  : e = Expressionession {$argExpressionRet = new ArgExpression($e.ExpressionRet);} (Comma e1 = Expressionession {$argExpressionRet.addExpression($e1.ExpressionRet);})* ;

unaryOperator returns [UnaryOperator unaryOpRet]
  : t = And {$unaryOpRet = new UnaryOperator($t.text);}
  | t = Star {$unaryOpRet = new UnaryOperator($t.text);}
  | t = Plus {$unaryOpRet = new UnaryOperator($t.text);}
  | t = Minus {$unaryOpRet = new UnaryOperator($t.text);}
  | t = Tilde {$unaryOpRet = new UnaryOperator($t.text);}
  | t = Not {$unaryOpRet = new UnaryOperator($t.text);} ;

castExpressionession returns [CastExpression castExpressionRet]
  : {$castExpressionRet = new CastExpression();} LeftParen t = typeName {$castExpressionRet.setTypeName($t.typeNameRet);}
        RightParen c = castExpressionession {$castExpressionRet.setCastExpression($c.castExpressionRet);}
  |  {$castExpressionRet = new CastExpression();} e = Expressionession {$castExpressionRet.setExpression($e.ExpressionRet);}
  | {$castExpressionRet = new CastExpression();} n = DigitSequence {$castExpressionRet.setNum($n.text);} ;

assignmentOperator returns [AssignmentOp assignmentOpRet]
  : t = Assign {$assignmentOpRet = new AssignmentOp($t.text); $assignmentOpRet.setLine($t.line);}
  | t = StarAssign {$assignmentOpRet = new AssignmentOp($t.text); $assignmentOpRet.setLine($t.line);}
  | t = DivAssign {$assignmentOpRet = new AssignmentOp($t.text); $assignmentOpRet.setLine($t.line);}
  | t = ModAssign {$assignmentOpRet = new AssignmentOp($t.text); $assignmentOpRet.setLine($t.line);}
  | t = PlusAssign {$assignmentOpRet = new AssignmentOp($t.text); $assignmentOpRet.setLine($t.line);}
  | t = MinusAssign {$assignmentOpRet = new AssignmentOp($t.text); $assignmentOpRet.setLine($t.line);}
  | t = LeftShiftAssign {$assignmentOpRet = new AssignmentOp($t.text); $assignmentOpRet.setLine($t.line);}
  | t = RightShiftAssign {$assignmentOpRet = new AssignmentOp($t.text); $assignmentOpRet.setLine($t.line);}
  | t = AndAssign {$assignmentOpRet = new AssignmentOp($t.text); $assignmentOpRet.setLine($t.line);}
  | t = XorAssign {$assignmentOpRet = new AssignmentOp($t.text); $assignmentOpRet.setLine($t.line);}
  | t = OrAssign {$assignmentOpRet = new AssignmentOp($t.text); $assignmentOpRet.setLine($t.line);} ;

declaration returns [Declaration declarationRet]
    : d = declarationSpecifiers {$declarationRet = new Declaration($d.declarationSpecifiersRet);}
        (i = initDeclaratorList {$declarationRet.setInitDecList($i.initDeclaratorListRet);})? Semi ;

declarationSpecifiers returns [DeclarationSpecifiers declarationSpecifiersRet]
    : {$declarationSpecifiersRet = new DeclarationSpecifiers();}
       (d = declarationSpecifier {$declarationSpecifiersRet.addDeclarationSpecifier($d.declarationSpecifierRet);})+ ;

declarationSpecifier returns [DeclarationSpecifier declarationSpecifierRet]
    : {$declarationSpecifierRet = new DeclarationSpecifier();} t = Typedef {$declarationSpecifierRet.setType($t.text);}
    | {$declarationSpecifierRet = new DeclarationSpecifier();} ts = typeSpecifier {$declarationSpecifierRet.setTypeSpecifier($ts.typeSpecifierRet);}
    | {$declarationSpecifierRet = new DeclarationSpecifier();} t = Const {$declarationSpecifierRet.setType($t.text);};

initDeclaratorList returns [InitDeclaratorList initDeclaratorListRet]
    : i = initDeclarator {$initDeclaratorListRet = new InitDeclaratorList($i.initDeclaratorRet);}
        (Comma i1 = initDeclarator {$initDeclaratorListRet.addInitDeclarator($i1.initDeclaratorRet);})* ;

initDeclarator returns [InitDeclarator initDeclaratorRet]
    : d = declarator {$initDeclaratorRet = new InitDeclarator($d.declaratorRet);}
        (Assign i = initializer {$initDeclaratorRet.setInitializer($i.initializerRet);})? ;

typeSpecifier returns [TypeSpecifier typeSpecifierRet]
    : t = Void {$typeSpecifierRet = new TypeSpecifier($t.text);}
    | t = Char {$typeSpecifierRet = new TypeSpecifier($t.text);}
    | t = Short {$typeSpecifierRet = new TypeSpecifier($t.text);}
    | t = Int {$typeSpecifierRet = new TypeSpecifier($t.text);}
    | t = Long {$typeSpecifierRet = new TypeSpecifier($t.text);}
    | t = Float {$typeSpecifierRet = new TypeSpecifier($t.text);}
    | t = Double {$typeSpecifierRet = new TypeSpecifier($t.text);}
    | t = Signed {$typeSpecifierRet = new TypeSpecifier($t.text);}
    | t = Unsigned {$typeSpecifierRet = new TypeSpecifier($t.text);}
    | t = Bool {$typeSpecifierRet = new TypeSpecifier($t.text);}
    | t = Identifier {$typeSpecifierRet = new TypeSpecifier($t.text, true); $typeSpecifierRet.setLine($t.line);};

specifierQualifierList returns [SpecifierQualifierList specifierQualifierListRet]
    : {$specifierQualifierListRet = new SpecifierQualifierList();}
        (t = typeSpecifier {$specifierQualifierListRet.setTypeSpecifier($t.typeSpecifierRet);} | Const)
        (s = specifierQualifierList {$specifierQualifierListRet.setSpecifierQualifierList($s.specifierQualifierListRet);})? ;

declarator returns [Declarator declaratorRet]
    : {$declaratorRet = new Declarator();} (p = pointer {$declaratorRet.setPointer($p.pointerRet);})?
        d = directDeclarator {$declaratorRet.setDirectDec($d.directDecRet); $declaratorRet.setLine($d.directDecRet.getLine());} ;

directDeclarator returns [DirectDec directDecRet]
    : {$directDecRet = new DirectDec();} id = Identifier {$directDecRet.setIdentifier($id.text); $directDecRet.setLine($id.line);}
    | {$directDecRet = new DirectDec();} l = LeftParen d = declarator {$directDecRet.setDeclarator($d.declaratorRet); $directDecRet.setLine($l.line);} RightParen
    |  d1 = directDeclarator {$directDecRet = new DirectDec();} {$directDecRet.setDirectDec($d1.directDecRet);}
        LeftBracket (e = Expressionession {$directDecRet.setExpression($e.ExpressionRet);})? RightBracket
    |  d2 = directDeclarator {$directDecRet = new DirectDec();} {$directDecRet.setDirectDec($d2.directDecRet);}
        l = LeftParen  (p = parameterList {$directDecRet.setParameterList($p.parameterListRet); $directDecRet.setLine($l.line);}
        | (i = identifierList {$directDecRet.setIdentifierList($i.identifierListRet);} )?) RightParen ;

pointer returns [Pointer pointerRet]
    : {$pointerRet = new Pointer();} ((Star) (Const+)?)+ ;

parameterList returns [ParameterList parameterListRet]
    : p = parameterDeclaration {$parameterListRet = new ParameterList($p.parameterDecRet);}
    (Comma p1 = parameterDeclaration {$parameterListRet.addParameterDec($p1.parameterDecRet);})* ;

parameterDeclaration returns [ParameterDec parameterDecRet]
    : d = declarationSpecifiers {$parameterDecRet = new ParameterDec($d.declarationSpecifiersRet);}
     (d2 = declarator {$parameterDecRet.setDeclarator($d2.declaratorRet);} | (a = abstractDeclarator {$parameterDecRet.setAbstractDec($a.abstractDecRet);})?) ;

identifierList returns [IdentifierList identifierListRet]
    : id = Identifier {$identifierListRet = new IdentifierList($id.text);}
    (Comma id1 = Identifier {$identifierListRet.addIdentifier($id1.text);})* ;

typeName returns [TypeName typeNameRet]
    : s = specifierQualifierList {$typeNameRet = new TypeName($s.specifierQualifierListRet);}
        (a = abstractDeclarator {$typeNameRet.setAbstractDec($a.abstractDecRet);})? ;

abstractDeclarator returns [AbstractDec abstractDecRet]
    : {$abstractDecRet = new AbstractDec();} p = pointer {$abstractDecRet.setPointer($p.pointerRet);}
    | {$abstractDecRet = new AbstractDec();} (p = pointer {$abstractDecRet.setPointer($p.pointerRet);})?
     d = directAbstractDeclarator {$abstractDecRet.setDirectAbsDec($d.directAbsDecRet);} ;

directAbstractDeclarator returns [DirectAbsDec directAbsDecRet]
    : {$directAbsDecRet = new DirectAbsDec();} LeftBracket (e = Expressionession {$directAbsDecRet.setExpression($e.ExpressionRet);})? RightBracket
    | {$directAbsDecRet = new DirectAbsDec();} LeftParen
     (a = abstractDeclarator {$directAbsDecRet.setAbstractDec($a.abstractDecRet);} |
     (p = parameterList {$directAbsDecRet.setParameterList($p.parameterListRet);})?) RightParen
    |  d = directAbstractDeclarator {$directAbsDecRet = new DirectAbsDec();} {$directAbsDecRet.setDirectAbsDec($d.directAbsDecRet);}
     LeftBracket (e = Expressionession {$directAbsDecRet.setExpression($e.ExpressionRet);})? RightBracket
    |  d = directAbstractDeclarator {$directAbsDecRet = new DirectAbsDec();} {$directAbsDecRet.setDirectAbsDec($d.directAbsDecRet);}
     LeftParen (p = parameterList {$directAbsDecRet.setParameterList($p.parameterListRet);})? RightParen ;

initializer returns [Initializer initializerRet]
    : {$initializerRet = new Initializer();} e = Expressionession {$initializerRet.setExpression($e.ExpressionRet);}
    | {$initializerRet = new Initializer();}
        LeftBrace i = initializerList {$initializerRet.setInitializerList($i.initializerListRet);} Comma? RightBrace ;

initializerList returns [InitializerList initializerListRet]
    : {$initializerListRet = new InitializerList();} (d = designation {$initializerListRet.addDesignation($d.designationRet);})?
     i = initializer {$initializerListRet.addInitializer($i.initializerRet);}
      (Comma (d1 = designation {$initializerListRet.addDesignation($d1.designationRet);})?
       i1 = initializer {$initializerListRet.addInitializer($i1.initializerRet);})* ;

designation returns [Designation designationRet]
    : {$designationRet = new Designation();} (d = designator {$designationRet.addDesignator($d.designatorRet);})+ Assign ;

designator returns [Designator designatorRet]
    : {$designatorRet = new Designator();} LeftBracket e = Expressionession {$designatorRet.setExpression($e.ExpressionRet);} RightBracket
    | Dot id = Identifier {$designatorRet.setLine($id.line);};

statement returns [Stmt stmtRet]
    : c = compoundStatement {$stmtRet = $c.compoundStmtRet; }
    | e = ExpressionessionStatement {$stmtRet = $e.ExpressionStmtRet; }
    | s = selectionStatement {$stmtRet = $s.selectionStmtRet; }
    | i = iterationStatement {$stmtRet = $i.iterStmtRet; }
    | j = jumpStatement {$stmtRet = $j.jumpStmtRet; };

compoundStatement returns [CompoundStmt compoundStmtRet]
    : {$compoundStmtRet = new CompoundStmt();} LeftBrace
     ((b = blockItem {$compoundStmtRet.addBlockItem($b.blockItemRet);})+)? RightBrace ;

blockItem returns [BlockItem blockItemRet]
    : {$blockItemRet = new BlockItem();} s = statement {$blockItemRet.setStmt($s.stmtRet);}
    | {$blockItemRet = new BlockItem();} d = declaration {$blockItemRet.setDeclaration($d.declarationRet);};

ExpressionessionStatement returns [ExpressionStmt ExpressionStmtRet]
    : {$ExpressionStmtRet = new ExpressionStmt();} (e = Expressionession {$ExpressionStmtRet.setExpression($e.ExpressionRet);})? Semi ;

selectionStatement returns [SelectionStmt selectionStmtRet]
    : i = If LeftParen e = Expressionession RightParen s = statement {$selectionStmtRet = new SelectionStmt($e.ExpressionRet, $s.stmtRet);}
     {$selectionStmtRet.setLine($i.line);} (el = Else es = statement {$selectionStmtRet.setElseStmt($es.stmtRet); {$selectionStmtRet.setElseLine($el.line);}})? ;

iterationStatement returns [IterStmt iterStmtRet]
    : w = While LeftParen e = Expressionession RightParen s = statement
     {
        $iterStmtRet = new IterStmt();
        $iterStmtRet.setExpression($e.ExpressionRet);
        $iterStmtRet.setStmt($s.stmtRet);
        $iterStmtRet.setLine($w.line);
        $iterStmtRet.setType($w.text);
     }
    | Do s1 = statement w = While LeftParen e1 = Expressionession RightParen Semi
         {
            $iterStmtRet = new IterStmt();
            $iterStmtRet.setExpression($e1.ExpressionRet);
            $iterStmtRet.setStmt($s1.stmtRet);
            $iterStmtRet.setLine($w.line);
            $iterStmtRet.setType($w.text);
         }
    | f2 = For LeftParen f = forCondition RightParen s2 = statement
         {
            $iterStmtRet = new IterStmt();
            $iterStmtRet.setForCondition($f.forConditionRet);
            $iterStmtRet.setStmt($s2.stmtRet);
            $iterStmtRet.setLine($f2.line);
            $iterStmtRet.setType($f2.text);
         }
    ;

forCondition returns [ForCondition forConditionRet]
    : {$forConditionRet = new ForCondition();}
        (fd = forDeclaration {$forConditionRet.setForDec($fd.forDecRet);} | (e = Expressionession {$forConditionRet.setExpression($e.ExpressionRet);})?)
         Semi (fe1 = forExpressionession {$forConditionRet.setForExpression1($fe1.forExpressionRet);})?
         Semi (fe2 = forExpressionession {$forConditionRet.setForExpression1($fe2.forExpressionRet);})? ;

forDeclaration returns [ForDec forDecRet]
    : d = declarationSpecifiers {$forDecRet = new ForDec($d.declarationSpecifiersRet);}
        (i = initDeclaratorList {$forDecRet.setInitDecList($i.initDeclaratorListRet);})? ;

forExpressionession returns [ForExpression forExpressionRet]
    : e = Expressionession {$forExpressionRet = new ForExpression($e.ExpressionRet);} (Comma a = Expressionession {$forExpressionRet.addExpression($a.ExpressionRet);})* ;

jumpStatement returns [JumpStmt jumpStmtRet]
    : {$jumpStmtRet = new JumpStmt();}( Continue | Break |
        Return (e = Expressionession { $jumpStmtRet.setReturnExpression($e.ExpressionRet);})? ) Semi ;

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