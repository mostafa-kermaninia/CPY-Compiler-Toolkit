grammar SimpleLang;

@header {
    import main.ast.declaration_DIR.*;
    import main.ast.expression_DIR.*;
    import main.ast.literal_DIR.*;
    import main.ast.nodes_DIR.*;
    import main.ast.statement_DIR.*;
    import java.util.stream.Collectors;
}

//program
//    : translationUnit? EOF ;
program
	returns[Program programRet]:
	{$programRet = new Program();} (
		tu = translationUnit { $programRet.setTranslationUnit($tu.translationUnitRet);
     $programRet.setLine($tu.translationUnitRet.getLine()); }
	)? EOF;

//translationUnit
//    : externalDeclaration+ ;
translationUnit
	returns[TranslationUnit translationUnitRet]:
	{$translationUnitRet = new TranslationUnit();} (
		ed = externalDeclaration {
        $translationUnitRet.addDeclaration($ed.externalDeclarationRet);
        $translationUnitRet.setLine($ed.externalDeclarationRet.getLine());
    }
	)+;

//externalDeclaration
//    : functionDefinition | declaration | Semi ; // stray ;
externalDeclaration
	returns[ExternalDeclaration externalDeclarationRet]:
	fd = functionDefinition {
        $externalDeclarationRet = $fd.functionDefinitionRet;
        $externalDeclarationRet.setLine($fd.functionDefinitionRet.getLine());
    }
	| d = declaration {
        $externalDeclarationRet = $d.declarationRet;
        $externalDeclarationRet.setLine($d.declarationRet.getLine());
    }
	| Semi; // stray ;

//functionDefinition
//    : declarationSpecifiers? declarator declarationList? compoundStatement ;
functionDefinition
	returns[FunctionDefinition functionDefinitionRet]:
	(
		ds = declarationSpecifiers {
        $functionDefinitionRet = new FunctionDefinition();
        $functionDefinitionRet.setDeclarationSpecifiers($ds.declarationSpecifiersRet);
        $functionDefinitionRet.setLine($ds.declarationSpecifiersRet.getLine());
    }
	)? d = declarator {
        if ($functionDefinitionRet == null) {
            $functionDefinitionRet = new FunctionDefinition();
        }
        $functionDefinitionRet.setDeclarator($d.declaratorRet);
        String functionName = $d.declaratorRet.getDirectDeclarator().getIdentifier();
        if (functionName != null) {
            $functionDefinitionRet.setFunctionName(functionName);
        }
        $functionDefinitionRet.setLine($d.declaratorRet.getLine());
    } (
		dl = declarationList {
        $functionDefinitionRet.setDeclarationList($dl.declarationListRet);
        $functionDefinitionRet.setLine($dl.declarationListRet.getLine());
    }
	)? cs = compoundStatement {
        $functionDefinitionRet.setCompoundStatement($cs.compoundStatementRet);
        $functionDefinitionRet.setLine($cs.compoundStatementRet.getLine());
    };

//declarationList
//    : declaration+ ;
declarationList
	returns[DeclarationList declarationListRet]:
	{$declarationListRet = new DeclarationList();}
     (
		d = declaration {
        $declarationListRet.addDeclaration($d.declarationRet);
        $declarationListRet.setLine($d.declarationRet.getLine());
    }
	)+;

//


//expression
//  : Identifier | Constant | StringLiteral+
expression
	returns[Expr expressionRet]:
	id = Identifier {
        $expressionRet = new IdentifierExpr($id.text);
        $expressionRet.setLine($id.getLine());
    }
	| c = Constant {
        $expressionRet = new ConstantExpr($c.text);
        $expressionRet.setLine($c.getLine());
    }
	| sl += StringLiteral+ {
        $expressionRet = new StringLiteralExpr($sl.stream().map(x -> x.getText()).collect(Collectors.toList()));
        $expressionRet.setLine($sl.get(0).getLine());
    }
    //  | LeftParen expression RightParen
	| lp = LeftParen e1 = expression rp = RightParen {
        $expressionRet = $e1.expressionRet;
        $expressionRet.setLine($e1.expressionRet.getLine());
    }
    //  | LeftParen typeName RightParen LeftBrace initializerList Comma? RightBrace
	| lp = LeftParen tn = typeName rp = RightParen lb = LeftBrace il = initializerList c = Comma? rb = RightBrace {
        $expressionRet = new CompoundLiteralExpr($tn.typeNameRet, $il.initializerListRet);
        $expressionRet.setLine($tn.typeNameRet.getLine());
    }
    //  | expression LeftBracket expression RightBracket                                // Array indexing
	| e2 = expression lb = LeftBracket e3 = expression rb = RightBracket {
        $expressionRet = new ArrIndexExpr($e2.expressionRet, $e3.expressionRet);
        $expressionRet.setLine($e2.expressionRet.getLine());
    }
    //  | expression LeftParen argumentExpressionList? RightParen                       // Function call                                                       // Postfix decrement
	| e4 = expression lp = LeftParen args = argumentExpressionList? rp = RightParen {
        $expressionRet = new FunctionCallExpr(
            $e4.expressionRet,
            $args.argumentExpressionListRet.getArguments() != null ? $args.argumentExpressionListRet.getArguments() : new ArrayList<>()
        );
        $expressionRet.setLine($e4.expressionRet.getLine());
  }
    //  | expression PlusPlus                                                           // Postfix increment
    //  | expression MinusMinus
	| e5 = expression op = (PlusPlus | MinusMinus) {
        $expressionRet = new PostfixExpr($e5.expressionRet, $op.getText());
        $expressionRet.setLine($e5.expressionRet.getLine());
    }
      //  | (PlusPlus  | MinusMinus | Sizeof)* (                                          // Prefix operators (zero or more)
      //         Identifier
      //       | Constant
      //       | StringLiteral+
      //       | LeftParen expression RightParen
      //       | LeftParen typeName RightParen LeftBrace initializerList Comma? RightBrace
      //       | unaryOperator castExpression
      //       | Sizeof LeftParen typeName RightParen
      //    )
	| pre += (PlusPlus | MinusMinus | Sizeof)* base = helpExpr {
        $expressionRet = $base.helpExprRet;
        for (Token p : $pre) {
            $expressionRet = new PrefixExpr(p.getText(), $expressionRet);
        }
        $expressionRet.setLine($base.helpExprRet.getLine());
    }
    //  | LeftParen typeName RightParen castExpression                                  // Cast expression
	| LeftParen tn = typeName RightParen ce = castExpression {
        $expressionRet = new CastExpr($tn.typeNameRet, $ce.castExpressionRet);
        $expressionRet.setLine($tn.typeNameRet.getLine());
    }
    //  | expression (Star | Div | Mod) expression                                      // Multiplicative
	| e6 = expression op = (Star | Div | Mod) e7 = expression {
        $expressionRet = new BinaryExpr($e6.expressionRet, $op.getText(), $e7.expressionRet);
        $expressionRet.setLine($e6.expressionRet.getLine());
    }
    //  | expression (Plus | Minus) expression                                          // Additive
	| e8 = expression op = (Plus | Minus) e9 = expression {
        $expressionRet = new BinaryExpr($e8.expressionRet, $op.getText(), $e9.expressionRet);
        $expressionRet.setLine($e8.expressionRet.getLine());
    }
    //  | expression (LeftShift | RightShift) expression                                // Shift
	| e10 = expression op = (LeftShift | RightShift) e11 = expression {
        $expressionRet = new BinaryExpr($e10.expressionRet, $op.getText(), $e11.expressionRet);
        $expressionRet.setLine($e10.expressionRet.getLine());
    }
    //  | expression (Less | Greater | LessEqual | GreaterEqual) expression             // Relational
	| e12 = expression op = (
		Less
		| Greater
		| LessEqual
		| GreaterEqual
	) e13 = expression {
        $expressionRet = new BinaryExpr($e12.expressionRet, $op.getText(), $e13.expressionRet);
        $expressionRet.setLine($e12.expressionRet.getLine());
    }
    //  | expression (Equal | NotEqual) expression                                      // Equality
	| e14 = expression op = (Equal | NotEqual) e15 = expression {
        $expressionRet = new BinaryExpr($e14.expressionRet, $op.getText(), $e15.expressionRet);
        $expressionRet.setLine($e14.expressionRet.getLine());
    }
    //  | expression And expression                                                     // Bitwise AND
    //  | expression Xor expression                                                     // Bitwise XOR
    //  | expression Or expression                                                      // Bitwise OR
    //  | expression AndAnd expression                                                  // Logical AND
    //  | expression OrOr expression                                                    // Logical OR
	| e16 = expression op = And e17 = expression {
        $expressionRet = new BinaryExpr($e16.expressionRet, $op.getText(), $e17.expressionRet);
        $expressionRet.setLine($e16.expressionRet.getLine());
    }
	| e18 = expression op = Xor e19 = expression {
        $expressionRet = new BinaryExpr($e18.expressionRet, $op.getText(), $e19.expressionRet);
        $expressionRet.setLine($e18.expressionRet.getLine());
    }
	| e20 = expression op = Or e21 = expression {
        $expressionRet = new BinaryExpr($e20.expressionRet, $op.getText(), $e21.expressionRet);
        $expressionRet.setLine($e20.expressionRet.getLine());
    }
	| e22 = expression op = AndAnd e23 = expression {
        $expressionRet = new BinaryExpr($e22.expressionRet, $op.getText(), $e23.expressionRet);
        $expressionRet.setLine($e22.expressionRet.getLine());
    }
	| e24 = expression op = OrOr e25 = expression {
        $expressionRet = new BinaryExpr($e24.expressionRet, $op.getText(), $e25.expressionRet);
        $expressionRet.setLine($e24.expressionRet.getLine());
    }
    //  | expression Question expression Colon expression                               // Conditional operator
	| e26 = expression Q = Question e27 = expression C = Colon e28 = expression {
        $expressionRet = new ConditionalExpr($e26.expressionRet, $e27.expressionRet, $e28.expressionRet);
        $expressionRet.setLine($e26.expressionRet.getLine());
    }
    //  | expression assignmentOperator expression                                      // Assignment
	| e29 = expression ao = assignmentOperator e30 = expression {
        $expressionRet = new AssignmentExpr($e29.expressionRet, $ao.assignmentOperatorRet.getOperatorType(), $e30.expressionRet);
        $expressionRet.setLine($e29.expressionRet.getLine());
    }
    //  | expression (Comma expression)+ ;
	| e_start = expression (Comma e_other += expression)+ {
      List<Expr> exprList = new ArrayList<>();
      exprList.add($e_start.expressionRet);
      exprList.addAll($e_other.stream().map(e -> e.expressionRet).collect(Collectors.toList()));
      $expressionRet = new CommaExpr(exprList);
      $expressionRet.setLine($e_start.expressionRet.getLine());
  };

//argumentExpressionList
//  : expression (Comma expression)* ;
argumentExpressionList
	returns[ArgumentExpressionList argumentExpressionListRet]:
	e = expression {
      $argumentExpressionListRet = new ArgumentExpressionList();
      $argumentExpressionListRet.addArgument($e.expressionRet);
  } (
		c = Comma e2 = expression {
      $argumentExpressionListRet.addArgument($e2.expressionRet);
  }
	)*;

//unaryOperator
//  : And | Star | Plus | Minus | Tilde | Not ;
unaryOperator
	returns[UnaryOperator unaryOperatorRet]:
	a = And { $unaryOperatorRet = new UnaryOperator($a.text); $unaryOperatorRet.setLine($a.line); }
	| s = Star { $unaryOperatorRet = new UnaryOperator($s.text); $unaryOperatorRet.setLine($s.line); }
	| p = Plus { $unaryOperatorRet = new UnaryOperator($p.text); $unaryOperatorRet.setLine($p.line); }
	| m = Minus { $unaryOperatorRet = new UnaryOperator($m.text); $unaryOperatorRet.setLine($m.line); }
	| t = Tilde { $unaryOperatorRet = new UnaryOperator($t.text); $unaryOperatorRet.setLine($t.line); }
	| n = Not { $unaryOperatorRet = new UnaryOperator($n.text); $unaryOperatorRet.setLine($n.line); };

//castExpression
//  : LeftParen typeName RightParen castExpression | expression | DigitSequence ;
castExpression
	returns[CastExpression castExpressionRet]:
	lp = LeftParen t = typeName rp = RightParen ce = castExpression {
        $castExpressionRet = new CastExpression($t.typeNameRet, $ce.castExpressionRet);
        $castExpressionRet.setLine($lp.getLine());
    }
	| e = expression {
        $castExpressionRet = new CastExpression($e.expressionRet);
        $castExpressionRet.setLine($e.expressionRet.getLine());
    }
	| ds = DigitSequence {
        $castExpressionRet = new CastExpression($ds.getText());
        $castExpressionRet.setLine($ds.getLine());
    };

//assignmentOperator
//  : Assign | StarAssign | DivAssign | ModAssign | PlusAssign | MinusAssign | LeftShiftAssign | RightShiftAssign | AndAssign | XorAssign | OrAssign ;
assignmentOperator
	returns[AssignmentOperator assignmentOperatorRet]:
	op = (
		 Assign
		| StarAssign
		| DivAssign
		| ModAssign
		| PlusAssign
		| MinusAssign
		| LeftShiftAssign
		| RightShiftAssign
		| AndAssign
		| XorAssign
		| OrAssign
	) {
        $assignmentOperatorRet = new AssignmentOperator($op.getText());
        $assignmentOperatorRet.setLine($op.getLine());
    };

//declaration
//    : declarationSpecifiers initDeclaratorList? Semi ;
declaration
	returns[Declaration declarationRet]:
	ds = declarationSpecifiers {
        $declarationRet = new Declaration();
        $declarationRet.setDeclarationSpecifiers($ds.declarationSpecifiersRet);
    } (
		idl = initDeclaratorList {
        $declarationRet.setInitDeclarators($idl.initdeclarationListRet);
    }
	)? s = Semi {
        $declarationRet.setLine($s.getLine());
    };

//declarationSpecifiers
//    : declarationSpecifier+ ;
declarationSpecifiers
	returns[DeclarationSpecifiers declarationSpecifiersRet]:
	{ $declarationSpecifiersRet = new DeclarationSpecifiers(); }
    (
		ds = declarationSpecifier {
        $declarationSpecifiersRet.addDeclarationSpecifier($ds.declarationSpecifiersRet);
    }
	)+;

//declarationSpecifier
//    : Typedef | typeSpecifier | Const ;
declarationSpecifier
	returns[DeclarationSpecifier declarationSpecifiersRet]:
	td = Typedef {
        $declarationSpecifiersRet = new DeclarationSpecifier($td.getText());
        $declarationSpecifiersRet.setLine($td.getLine());
    }
	| ts = typeSpecifier {
        $declarationSpecifiersRet = new DeclarationSpecifier($ts.typeSpecifierRet);
        $declarationSpecifiersRet.setLine($ts.typeSpecifierRet.getLine());
    }
	| c = Const {
        $declarationSpecifiersRet = new DeclarationSpecifier($c.getText());
        $declarationSpecifiersRet.setLine($c.getLine());
    };

//initDeclaratorList
//    : initDeclarator (Comma initDeclarator)* ;
initDeclaratorList
	returns[InitDeclaratorList initdeclarationListRet]:
	d1 = initDeclarator {
        $initdeclarationListRet = new InitDeclaratorList();
        $initdeclarationListRet.addInitDeclarator($d1.initDeclaratorRet);
    } (
		c = Comma d2 = initDeclarator {
        $initdeclarationListRet.addInitDeclarator($d2.initDeclaratorRet);
    }
	)*;

//initDeclarator
//    : declarator (Assign initializer)? ;
initDeclarator
	returns[InitDeclarator initDeclaratorRet]:
	d = declarator {
        $initDeclaratorRet = new InitDeclarator($d.declaratorRet);
        $initDeclaratorRet.setLine($d.declaratorRet.getLine());
    } (
		a = Assign i = initializer {
        $initDeclaratorRet.setInitializer($i.initializerRet);
    }
	)?;

//typeSpecifier
//    : Void | Char | Short | Int | Long | Float | Double | Signed | Unsigned | Bool | Identifier ;
typeSpecifier
	returns[TypeSpecifier typeSpecifierRet]:
	v = Void {
        $typeSpecifierRet = new TypeSpecifier($v.getText());
        $typeSpecifierRet.setLine($v.getLine());
    }
	| c = Char {
        $typeSpecifierRet = new TypeSpecifier($c.getText());
        $typeSpecifierRet.setLine($c.getLine());
    }
	| s = Short {
        $typeSpecifierRet = new TypeSpecifier($s.getText());
        $typeSpecifierRet.setLine($s.getLine());
    }
	| i = Int {
        $typeSpecifierRet = new TypeSpecifier($i.getText());
        $typeSpecifierRet.setLine($i.getLine());
    }
	| l = Long {
        $typeSpecifierRet = new TypeSpecifier($l.getText());
        $typeSpecifierRet.setLine($l.getLine());
    }
	| f = Float {
        $typeSpecifierRet = new TypeSpecifier($f.getText());
        $typeSpecifierRet.setLine($f.getLine());
    }
	| d = Double {
        $typeSpecifierRet = new TypeSpecifier($d.getText());
        $typeSpecifierRet.setLine($d.getLine());
    }
	| si = Signed {
        $typeSpecifierRet = new TypeSpecifier($si.getText());
        $typeSpecifierRet.setLine($si.getLine());
    }
	| u = Unsigned {
        $typeSpecifierRet = new TypeSpecifier($u.getText());
        $typeSpecifierRet.setLine($u.getLine());
    }
	| b = Bool {
        $typeSpecifierRet = new TypeSpecifier($b.getText());
        $typeSpecifierRet.setLine($b.getLine());
    }
	| id = Identifier {
        $typeSpecifierRet = new TypeSpecifier($id.getText());
        $typeSpecifierRet.setLine($id.getLine());
    };

//specifierQualifierList
//    : (typeSpecifier | Const) specifierQualifierList? ;
specifierQualifierList
	returns[SpecifierQualifierList specifierQualifierListRet]: (
		ts = typeSpecifier {
          $specifierQualifierListRet = new SpecifierQualifierList();
          $specifierQualifierListRet.addTypeSpecifier($ts.typeSpecifierRet);
       }
		| c = Const {
          $specifierQualifierListRet = new SpecifierQualifierList();
          $specifierQualifierListRet.setConstLine($c.getLine());
          $specifierQualifierListRet.setIsConst(true);
       }
	) sq = specifierQualifierList? {
          if ($sq.specifierQualifierListRet != null) {
              $specifierQualifierListRet.append($sq.specifierQualifierListRet);
          }
       };

//declarator
//    : pointer? directDeclarator ;
declarator
	returns[Declarator declaratorRet]:
	(
		p = pointer { $declaratorRet = new Declarator(); $declaratorRet.setPointer($p.pointerRet); }
	)? d = directDeclarator {
          if ($declaratorRet == null) {
              $declaratorRet = new Declarator();
          }
          $declaratorRet.setDirectDeclarator($d.directDeclaratorRet);
      };

//directDeclarator
//    : Identifier
directDeclarator
	returns[DirectDeclarator directDeclaratorRet]:
	id = Identifier {
        $directDeclaratorRet = new DirectDeclarator($id.getText());
    }
    //    | LeftParen declarator RightParen
	| LeftParen d = declarator RightParen {
        $directDeclaratorRet = new DirectDeclarator($d.declaratorRet);
    }
    //    | directDeclarator LeftBracket expression? RightBracket
	| dd1 = directDeclarator { $directDeclaratorRet = new DirectDeclarator($dd1.directDeclaratorRet); } LeftBracket
		(
		e = expression { $directDeclaratorRet.setSize($e.expressionRet); }
	)? RightBracket
	//    | directDeclarator LeftParen  (parameterList | identifierList?) RightParen ;
	| dd2 = directDeclarator lp = LeftParen pl = parameterList rp = RightParen {
        $directDeclaratorRet = new DirectDeclarator($dd2.directDeclaratorRet, $pl.parameterListRet);
    }
	| dd3 = directDeclarator { $directDeclaratorRet = new DirectDeclarator($dd3.directDeclaratorRet); } LeftParen (
		il = identifierList { $directDeclaratorRet.setIdentifierList($il.identifierListRet); }
	)? rp = RightParen;

//| dd2 = directDeclarator LeftParen
//    (pl = parameterList {
//        $directDeclaratorRet = new DirectDeclarator($dd2.directDeclaratorRet, $pl.parameterListRet);
//    }
//    | il = identifierList {
//        $directDeclaratorRet = new DirectDeclarator($dd2.directDeclaratorRet);
//        $directDeclaratorRet.setIdentifierList($il.identifierListRet);
//    })?
//RightParen;

//pointer
//    : ((Star) (Const+)?)+ ;
pointer
	returns[Pointer pointerRet]: (
		stars += Star (consts += Const+)?
	)+ {
        $pointerRet = new Pointer();

        int starCount = $stars.size();
        boolean isConst = $consts != null && !$consts.isEmpty();

        $pointerRet.setPointerLevel(starCount);
        $pointerRet.setConst(isConst);
        $pointerRet.setLine($stars.get(0).getLine());
    };

//parameterList
//    : parameterDeclaration (Comma parameterDeclaration)* ;
parameterList
	returns[ParameterList parameterListRet]:
	p1 = parameterDeclaration {
        $parameterListRet = new ParameterList();
        $parameterListRet.addParameter($p1.parameterDeclarationRet);
    } (
		c = Comma p2 = parameterDeclaration {
        $parameterListRet.addParameter($p2.parameterDeclarationRet);
    }
	)*;

//parameterDeclaration
//    : declarationSpecifiers (declarator | abstractDeclarator?) ;
parameterDeclaration
	returns[ParameterDeclaration parameterDeclarationRet]:
	declarationSpecifiers declarator {
        $parameterDeclarationRet = new ParameterDeclaration($declarationSpecifiers.declarationSpecifiersRet, $declarator.declaratorRet);
    }
	| declarationSpecifiers abstractDeclarator {
        $parameterDeclarationRet = new ParameterDeclaration($declarationSpecifiers.declarationSpecifiersRet, $abstractDeclarator.abstractDeclaratorRet);
    };

//identifierList
//    : Identifier (Comma Identifier)* ;
identifierList
	returns[IdentifierList identifierListRet]:
	id1 = Identifier (c = Comma idN += Identifier)* {
        List<Identifier> identifiers = new ArrayList<>();
        Identifier first = new Identifier($id1.getText());
        first.setLine($id1.getLine());
        identifiers.add(first);

        for (Token tok : $idN) {
            Identifier id = new Identifier(tok.getText());
            id.setLine(tok.getLine());
            identifiers.add(id);
        }

        $identifierListRet = new IdentifierList(identifiers);
    };

//typeName
//    : specifierQualifierList abstractDeclarator? ;
typeName
	returns[TypeName typeNameRet]:
	s = specifierQualifierList a = abstractDeclarator? {
        $typeNameRet = new TypeName($s.specifierQualifierListRet, $a.abstractDeclaratorRet != null ? $a.abstractDeclaratorRet : null);
        $typeNameRet.setLine($s.specifierQualifierListRet.getLine());
    };

//abstractDeclarator
//    : pointer | pointer? directAbstractDeclarator ;
abstractDeclarator
	returns[AbstractDeclarator abstractDeclaratorRet]:
	p = pointer {
        $abstractDeclaratorRet = new AbstractDeclarator();
        $abstractDeclaratorRet.setPointer($p.pointerRet);
    }
	| p2 = pointer? d = directAbstractDeclarator {
        $abstractDeclaratorRet = new AbstractDeclarator();
        if ($p2.pointerRet != null) $abstractDeclaratorRet.setPointer($p2.pointerRet);
        $abstractDeclaratorRet.setDirectAbstractDeclarator($d.directAbstractDeclaratorRet);
    };

//directAbstractDeclarator
//    : LeftBracket expression? RightBracket
//    | LeftParen  (abstractDeclarator | parameterList?) RightParen
//    | directAbstractDeclarator LeftBracket expression? RightBracket
//    | directAbstractDeclarator LeftParen parameterList? RightParen ;
directAbstractDeclarator returns [DirectAbstractDeclarator directAbstractDeclaratorRet]:
    { $directAbstractDeclaratorRet = new DirectAbstractDeclarator(); }
    LeftBracket ( e=expression { $directAbstractDeclaratorRet.setExpression($e.expressionRet); } )? RightBracket
    { $directAbstractDeclaratorRet.setLine($LeftBracket.getLine()); }
  | { $directAbstractDeclaratorRet = new DirectAbstractDeclarator(); }
    LeftParen ( ad=abstractDeclarator { $directAbstractDeclaratorRet.setAbstractDeclarator($ad.abstractDeclaratorRet); }
                | ( pl=parameterList { $directAbstractDeclaratorRet.setParameterList($pl.parameterListRet); } )? ) RightParen
    { $directAbstractDeclaratorRet.setLine($LeftParen.getLine()); }
  | dd=directAbstractDeclarator
    { $directAbstractDeclaratorRet = new DirectAbstractDeclarator();
      $directAbstractDeclaratorRet.setPreviousDeclarator($dd.directAbstractDeclaratorRet); }
    LeftBracket ( ex=expression { $directAbstractDeclaratorRet.setExpression($ex.expressionRet); } )? RightBracket
    { $directAbstractDeclaratorRet.setLine($LeftBracket.getLine()); }
  | dd2=directAbstractDeclarator
    { $directAbstractDeclaratorRet = new DirectAbstractDeclarator();
      $directAbstractDeclaratorRet.setPreviousDeclarator($dd2.directAbstractDeclaratorRet); }
    LeftParen ( pl2=parameterList { $directAbstractDeclaratorRet.setParameterList($pl2.parameterListRet); } )? RightParen
    { $directAbstractDeclaratorRet.setLine($LeftParen.getLine()); }
;





//initializer
//    : expression | LeftBrace initializerList Comma? RightBrace ;
initializer
	returns[Initializer initializerRet]:
	e = expression {
        $initializerRet = new Initializer();
        $initializerRet.setExpression($e.expressionRet);
        $initializerRet.setLine($e.expressionRet.getLine());
    }
	| lb = LeftBrace il = initializerList c = Comma? rb = RightBrace {
        $initializerRet = new Initializer();
        $initializerRet.setInitializerList($il.initializerListRet);
        $initializerRet.setLine($lb.getLine());
    };


//initializerList
//    : designation? initializer (Comma designation? initializer)* ;
initializerList
	returns[InitializerList initializerListRet]: (
		d = designation? i = initializer {
        $initializerListRet = new InitializerList();
        $initializerListRet.addEntry($d.designationRet, $i.initializerRet);
    }
	) (
		c = Comma d2 = designation? i2 = initializer {
        $initializerListRet.addEntry($d2.designationRet, $i2.initializerRet);
    }
	)*;

//designation
//    : designator+ Assign ;
designation
	returns[Designation designationRet]:
	d += designator+ a = Assign {
        $designationRet = new Designation();
        for (var dItem : $d) {
            $designationRet.addDesignator(dItem.designatorRet);
        }
        $designationRet.setLine($a.getLine());
    };

//designator
//    : LeftBracket expression RightBracket | Dot Identifier ;
designator
	returns[Designator designatorRet]:
	lb = LeftBracket expr = expression rb = RightBracket {
        $designatorRet = new Designator($expr.expressionRet);
        $designatorRet.setLine($expr.expressionRet.getLine());
    }
	| d = Dot id = Identifier {
        $designatorRet = new Designator($id.getText());
        $designatorRet.setLine($id.getLine());
    };

//statement
//    : compoundStatement | expressionStatement | selectionStatement | iterationStatement | jumpStatement ;
statement
	returns[Stmt statementRet]:
	cs = compoundStatement {
        $statementRet = $cs.compoundStatementRet;
    }
	| es = expressionStatement {
        $statementRet = $es.expressionStatementRet;
    }
	| ss = selectionStatement {
        $statementRet = $ss.selectionStatementRet;
    }
	| is = iterationStatement {
        $statementRet = $is.iterationStatementRet;
    }
	| js = jumpStatement {
        $statementRet = $js.jumpStatementRet;
    };

//compoundStatement
//    : LeftBrace (blockItem+)? RightBrace ;
compoundStatement
	returns[CompoundStatement compoundStatementRet]:
	lb = LeftBrace {
        $compoundStatementRet = new CompoundStatement();
        $compoundStatementRet.setLine($lb.getLine());
    } (
		b = blockItem { $compoundStatementRet.addStatement($b.blockItemRet); }
	)* rb = RightBrace {
        $compoundStatementRet.setRightBraceLine($rb.getLine());
    };

//blockItem
//    : statement | declaration ;
blockItem
	returns[BlockItem blockItemRet]:
	s = statement {
        $blockItemRet = new BlockItem($s.statementRet);
    }
	| d = declaration {
        $blockItemRet = new BlockItem($d.declarationRet);
    };

//expressionStatement
//    : expression? Semi ;
expressionStatement
	returns[ExpressionStatement expressionStatementRet]:
	e = expression? s = Semi {
        $expressionStatementRet = new ExpressionStatement();
        $expressionStatementRet.setLine($s.getLine());
        if ($e.expressionRet != null)
            $expressionStatementRet.setExpression($e.expressionRet);
    };


//selectionStatement
//    : If LeftParen expression RightParen statement (Else statement)? ;
selectionStatement
	returns[SelectionStatement selectionStatementRet]:
	i = If lp = LeftParen e = expression rp = RightParen s1 = statement {
        $selectionStatementRet = new SelectionStatement($e.expressionRet, $s1.statementRet);
    } (
		el = Else s2 = statement {
        $selectionStatementRet.setElseBody($s2.statementRet);
    }
	)? { $selectionStatementRet.setLine($i.line); };


//iterationStatement
//    : While LeftParen expression RightParen statement
//    | Do statement While LeftParen expression RightParen Semi
//    | For LeftParen forCondition RightParen statement ;
iterationStatement
	returns[IterationStatement iterationStatementRet]:
	w = While lp = LeftParen cond = expression rp = RightParen body = statement {
            $iterationStatementRet = new IterationStatement(
                IterationStatement.LoopType.WHILE,
                $cond.expressionRet,
                $body.statementRet
            );
            $iterationStatementRet.setLine($w.getLine());
        }
	| d = Do body1 = statement w2 = While lp2 = LeftParen cond2 = expression rp2 = RightParen s =
		Semi {
            $iterationStatementRet = new IterationStatement(
                IterationStatement.LoopType.DO_WHILE,
                $cond2.expressionRet,
                $body1.statementRet
            );
            $iterationStatementRet.setLine($d.getLine());
        }
	| f = For lp3 = LeftParen fc = forCondition rp3 = RightParen body2 = statement {
            $iterationStatementRet = new IterationStatement(
                IterationStatement.LoopType.FOR,
                $fc.forConditionRet,
                $body2.statementRet
            );
            $iterationStatementRet.setLine($f.getLine());
        };

//forCondition
//    : (forDeclaration | expression?) Semi forExpression? Semi forExpression? ;
forCondition
	returns[ForCondition forConditionRet]: (
		d = forDeclaration {
            $forConditionRet = new ForCondition();
            $forConditionRet.setForDeclaration($d.forDeclarationRet);
        }
		| e1 = expression {
            $forConditionRet = new ForCondition();
            $forConditionRet.setCondition($e1.expressionRet);
        }
		| {
            $forConditionRet = new ForCondition();
        }
	) s1 = Semi (
		e2 = forExpression {
        $forConditionRet.setCondition2($e2.forExpressionRet);
    }
	)? s2 = Semi (
		e3 = forExpression {
        $forConditionRet.setUpdateExpression($e3.forExpressionRet);
    }
	)?;


//forDeclaration
//    : declarationSpecifiers initDeclaratorList? ;
forDeclaration returns[ForDeclaration forDeclarationRet]:
    { $forDeclarationRet = new ForDeclaration(); }
    declSpecifiers = declarationSpecifiers
    { $forDeclarationRet.setDeclarationSpecifiers($declSpecifiers.declarationSpecifiersRet); }
    ( initDecList = initDeclaratorList
        { $forDeclarationRet.setInitDeclaratorList($initDecList.initdeclarationListRet); } )?
;

//forExpression
//    : expression (Comma expression)* ;
forExpression
	returns[ForExpression forExpressionRet]:
	e1 = expression {
        $forExpressionRet = new ForExpression();
        $forExpressionRet.addExpression($e1.expressionRet);
    } (
		c = Comma e2 = expression {
        $forExpressionRet.addExpression($e2.expressionRet);
    }
	)*;

//jumpStatement
//    : ( Continue | Break | Return expression? ) Semi ;
jumpStatement
	returns[JumpStatement jumpStatementRet]:
	c = Continue Semi {
            $jumpStatementRet = new JumpStatement(JumpStatement.CONTINUE, null, $c.getLine());
        }
	| b = Break Semi {
            $jumpStatementRet = new JumpStatement(JumpStatement.BREAK, null, $b.getLine());
        }
	| r1 = Return e = expression Semi {
            $jumpStatementRet = new JumpStatement(JumpStatement.RETURN, $e.expressionRet, $r1.getLine());
        }
	| r2 = Return Semi {
            $jumpStatementRet = new JumpStatement(JumpStatement.RETURN, null, $r2.getLine());
        };
//   It's an additional rule for having simpler expression rule
helpExpr
	returns[Expr helpExprRet]:
	id = Identifier {
        $helpExprRet = new IdentifierExpr($id.text);
        $helpExprRet.setLine($id.getLine());
    }
	| c = Constant {
        $helpExprRet = new ConstantExpr($c.text);
        $helpExprRet.setLine($c.getLine());
    }
	| sl += StringLiteral+ {
        $helpExprRet = new StringLiteralExpr($sl.stream().map(x -> x.getText()).collect(Collectors.toList()));
        $helpExprRet.setLine($sl.get(0).getLine());
    }
	| LeftParen e = expression RightParen {
        $helpExprRet = $e.expressionRet;
        $helpExprRet.setLine($e.expressionRet.getLine());
    }
	| LeftParen tn = typeName RightParen LeftBrace il = initializerList Comma? RightBrace {
        $helpExprRet = new CompoundLiteralExpr($tn.typeNameRet, $il.initializerListRet);
        $helpExprRet.setLine($tn.typeNameRet.getLine());
    }
	| uop = unaryOperator ce = castExpression {
        $helpExprRet = new UnaryExpr($uop.text, $ce.castExpressionRet);
        $helpExprRet.setLine($ce.castExpressionRet.getLine());
    }
	| Sizeof LeftParen tn = typeName RightParen {
        $helpExprRet = new SizeofTypeExpr($tn.typeNameRet);
        $helpExprRet.setLine($tn.typeNameRet.getLine());
    };


Break: 'break';
Char: 'char';
Const: 'const';
Continue: 'continue';
Do: 'do';
Double: 'double';
Else: 'else';
Float: 'float';
For: 'for';
If: 'if';
Int: 'int';
Long: 'long';
Return: 'return';
Short: 'short';
Signed: 'signed';
Sizeof: 'sizeof';
Switch: 'switch';
Typedef: 'typedef';
Unsigned: 'unsigned';
Void: 'void';
While: 'while';
Bool: 'bool';
LeftParen: '(';
RightParen: ')';
LeftBracket: '[';
RightBracket: ']';
LeftBrace: '{';
RightBrace: '}';
Less: '<';
LessEqual: '<=';
Greater: '>';
GreaterEqual: '>=';
LeftShift: '<<';
RightShift: '>>';
Plus: '+';
PlusPlus: '++';
Minus: '-';
MinusMinus: '--';
Star: '*';
Div: '/';
Mod: '%';
And: '&';
Or: '|';
AndAnd: '&&';
OrOr: '||';
Xor: '^';
Not: '!';
Tilde: '~';
Question: '?';
Colon: ':';
Semi: ';';
Comma: ',';
Assign: '=';
StarAssign: '*=';
DivAssign: '/=';
ModAssign: '%=';
PlusAssign: '+=';
MinusAssign: '-=';
LeftShiftAssign: '<<=';
RightShiftAssign: '>>=';
AndAssign: '&=';
XorAssign: '^=';
OrAssign: '|=';
Equal: '==';
NotEqual: '!=';
Arrow: '->';
Dot: '.';

Identifier: IdentifierNondigit (IdentifierNondigit | Digit)*;

fragment IdentifierNondigit: Nondigit | UniversalCharacterName;

fragment Nondigit: [a-zA-Z_];

fragment Digit: [0-9];

fragment UniversalCharacterName:
	'\\u' HexQuad
	| '\\U' HexQuad HexQuad;

fragment HexQuad:
	HexadecimalDigit HexadecimalDigit HexadecimalDigit HexadecimalDigit;

Constant:
	IntegerConstant
	| FloatingConstant
	| CharacterConstant;

fragment IntegerConstant:
	DecimalConstant IntegerSuffix?
	| OctalConstant IntegerSuffix?
	| HexadecimalConstant IntegerSuffix?
	| BinaryConstant;

fragment BinaryConstant: '0' [bB] [0-1]+;

fragment DecimalConstant: NonzeroDigit Digit*;

fragment OctalConstant: '0' OctalDigit*;

fragment HexadecimalConstant:
	HexadecimalPrefix HexadecimalDigit+;

fragment HexadecimalPrefix: '0' [xX];

fragment NonzeroDigit: [1-9];

fragment OctalDigit: [0-7];

fragment HexadecimalDigit: [0-9a-fA-F];

fragment IntegerSuffix:
	UnsignedSuffix LongSuffix?
	| UnsignedSuffix LongLongSuffix
	| LongSuffix UnsignedSuffix?
	| LongLongSuffix UnsignedSuffix?;

fragment UnsignedSuffix: [uU];

fragment LongSuffix: [lL];

fragment LongLongSuffix: 'll' | 'LL';

fragment FloatingConstant:
	DecimalFloatingConstant
	| HexadecimalFloatingConstant;

fragment DecimalFloatingConstant:
	FractionalConstant ExponentPart? FloatingSuffix?
	| DigitSequence ExponentPart FloatingSuffix?;

fragment HexadecimalFloatingConstant:
	HexadecimalPrefix (
		HexadecimalFractionalConstant
		| HexadecimalDigitSequence
	) BinaryExponentPart FloatingSuffix?;

fragment FractionalConstant:
	DigitSequence? Dot DigitSequence
	| DigitSequence Dot;

fragment ExponentPart: [eE] Sign? DigitSequence;

fragment Sign: [+-];

DigitSequence: Digit+;

fragment HexadecimalFractionalConstant:
	HexadecimalDigitSequence? Dot HexadecimalDigitSequence
	| HexadecimalDigitSequence Dot;

fragment BinaryExponentPart: [pP] Sign? DigitSequence;

fragment HexadecimalDigitSequence: HexadecimalDigit+;

fragment FloatingSuffix: [flFL];

fragment CharacterConstant:
	'\'' CCharSequence '\''
	| 'L\'' CCharSequence '\''
	| 'u\'' CCharSequence '\''
	| 'U\'' CCharSequence '\'';

fragment CCharSequence: CChar+;

fragment CChar: ~['\\\r\n] | EscapeSequence;

fragment EscapeSequence:
	SimpleEscapeSequence
	| OctalEscapeSequence
	| HexadecimalEscapeSequence
	| UniversalCharacterName;

fragment SimpleEscapeSequence: '\\' ['"?abfnrtv\\];

fragment OctalEscapeSequence:
	'\\' OctalDigit OctalDigit? OctalDigit?;

fragment HexadecimalEscapeSequence: '\\x' HexadecimalDigit+;

StringLiteral: EncodingPrefix? '"' SCharSequence? '"';

fragment EncodingPrefix: 'u8' | 'u' | 'U' | 'L';

fragment SCharSequence: SChar+;

fragment SChar: ~["\\\r\n] | EscapeSequence | '\\\n' | '\\\r\n';

MultiLineMacro:
	'#' (~[\n]*? '\\' '\r'? '\n')+ ~ [\n]+ -> channel(HIDDEN);

Directive: '#' ~[\n]* -> channel(HIDDEN);

Whitespace: [ \t]+ -> channel(HIDDEN);

Newline: ('\r' '\n'? | '\n') -> channel(HIDDEN);

BlockComment: '/*' .*? '*/' -> channel(HIDDEN);

LineComment: '//' ~[\r\n]* -> channel(HIDDEN);