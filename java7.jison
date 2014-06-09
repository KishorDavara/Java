%token ABSTRACT ASSERT
%token BOOLEAN BREAK BYTE
%token CASE CATCH CHAR CLASS CONST CONTINUE
%token DEFAULT DO DOUBLE
%token ELSE ENUM EXTENDS
%token FINAL FINALLY FLOAT FOR
%token IF
%token GOTO
%token IMPLEMENTS IMPORT INSTANCEOF INT INTERFACE
%token LONG
%token NATIVE NEW
%token PACKAGE PRIVATE PROTECTED PUBLIC
%token RETURN
%token SHORT STATIC STRICTFP SUPER SWITCH SYNCHRONIZED
%token THIS THROW THROWS TRANSIENT TRY VOID VOLATILE WHILE

%token IntegerLiteral FloatingPointLiteral BooleanLiteral CharacterLiteral StringLiteral NullLiteral

%token LPAREN RPAREN LBRACE RBRACE LBRACK RBRACK SEMI COMMA DOT

%token ASSIGN GT LSHIFT LT BANG TILDE QUESTION COLON EQUAL LE GE NOTEQUAL AND OR INC DEC ADD SUB MUL DIV BITAND BITOR CARET MOD
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN AND_ASSIGN OR_ASSIGN XOR_ASSIGN MOD_ASSIGN LSHIFT_ASSIGN RSHIFT_ASSIGN URSHIFT_ASSIGN

%token AT ELLIPSIS

%token Identifier

%token TEMPLATE

%token EOF

%left LSHIFT TEMPLATE

%left MOD
%left MUL DIV
%left ADD SUB

%right ASSIGN ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN AND_ASSIGN OR_ASSIGN XOR_ASSIGN RSHIFT_ASSIGN URSHIFT_ASSIGN LSHIFT_ASSIGN MOD_ASSIGN

%start compilationUnit


%%
compilationUnit
    :	packageDeclaration EOF
        {
            return {
                "type": "CompilationUnit",
                "packageDeclaration": $1
            };
        }
    |   packageDeclaration importDeclarations EOF
        {
            return {
                "type": "CompilationUnit",
                "packageDeclaration": $1,
                "importDeclarations": $2
            };
        }
    |   packageDeclaration importDeclarations typeDeclarations EOF
        {
            return {
                "type": "CompilationUnit",
                "packageDeclaration": $1,
                "importDeclarations": $2,
                "typeDeclarations": $3
            };
        }
    |	packageDeclaration typeDeclarations EOF
        {
            return {
                "type": "CompilationUnit",
                "packageDeclaration": $1,
                "typeDeclarations": $2
            };
        }
    |	importDeclarations typeDeclarations EOF
        {
            return {
                "type": "CompilationUnit",
                "importDeclarations": $1,
                "typeDeclarations": $2
            };
        }
    |	typeDeclarations EOF
        {
            return {
                "type": "CompilationUnit",
                "typeDeclarations": $1
            };
        }
    |   SEMI
    ;

packageDeclaration
    :	annotationl packageDeclaration
    |   packageDeclaration
        
    ;

packageDeclaration
    :   PACKAGE qualifiedName SEMI
        {
            $$ = {
                "type": "PackageDeclaration",
                "name": $2
            };
        }
    ;

importDeclarations
    :   importDeclaration
        {
            $$ = [ $1 ];
        }
    |   importDeclarations importDeclaration
        {
            $1.push($2);
            $$ = $1;
        }
    ;

importDeclaration
    :   IMPORT STATIC qualifiedName DOT MUL SEMI
        {
            $$ = {
                "type": "ImportDeclaration",
                "name": $3 + "." + "*"
            };
        }
    |   IMPORT STATIC qualifiedName SEMI
        {
            $$ = {
                "type": "ImportDeclaration",
                "name": $3
            };
        }
    |	IMPORT qualifiedName DOT MUL SEMI
        {
            $$ = {
                "type": "ImportDeclaration",
                "name": $2 + "." + "*"
            };
        }
    |   IMPORT qualifiedName SEMI
        {
            $$ = {
                "type": "ImportDeclaration",
                "name": $2 
            };
        }
    ;

typeDeclarations
    :   typeDeclarationWithPrefixes
        {
            $$ = [ $1 ];
        }
    |   typeDeclarations typeDeclarationWithPrefixes
        {
            $1.push($2);
            $$ = $1;
        }
    ;

typeDeclarationWithPrefixes
    :   annotationl modifierL typeDeclaration
        {
            $$ = $3;
        }
    |   modifierL annotationl typeDeclaration
        {
            $$ = $3;
        }
    |   modifierL typeDeclaration
        {
            $$ = $2;
        }
    |   annotationl typeDeclaration
        {
            $$ = $2;
        }
    |   typeDeclaration
        {
            $$ = $1;
        }
    ;

typeDeclaration
    :   classDeclaration
    |   interfaceDeclaration
    |   enumDeclaration
    |   annotationTypeDeclaration
    |   SEMI
    ;

classDeclaration
    :   CLASS Identifier classInheritance interfaceImplentation classBody
        {
            $$ = {
                "type": "ClassDeclaration",
                "name": $2,
                "extends": $3,
                "implements": $4,
                "body": ""
            };
        }
    |   CLASS Identifier typeParameters classInheritance interfaceImplentation classBody
    ;

classInheritance
    :   %empty /* empty */
        {
            $$ = null;
        }
    |   EXTENDS type
        {
            $$ = $2;
        }
    ;

interfaceImplentation
    :   %empty /* empty */
        {
            $$ = [];
        }
    |   IMPLEMENTS typeList
        {
            $$ = $2;
        }
    ;

typeParameters
    :   TEMPLATE
    ;

enumDeclaration
    :   ENUM Identifier interfaceImplentation
        enumBody
    /*|      ENUM Identifier interfaceImplentation
        LBRACE enumOptionalConstantDeclaration optionalComma enumOptionalBodyDeclarations RBRACE*/
    ;

enumBody
    :   LBRACE RBRACE
    |   LBRACE enumBodyDeclaration RBRACE
    ;

enumBodyDeclaration
    :   enumConstants
    |   enumConstants COMMA
    |   enumConstants SEMI
    |   enumConstants COMMA SEMI
    |   enumConstants SEMI classBodyDeclarationl
    |   enumConstants COMMA SEMI classBodyDeclarationl
    ;

enumOptionalConstantDeclaration
    :   %empty /* empty */
    |   enumConstants
    ;

enumOptionalClassBody
    :   %empty /* empty */
    |   classBodyDeclarationl
    ;

enumConstants
    :   annotations Identifier enumConstantArguments enumConstantClassBody
    |   enumConstants COMMA annotations Identifier enumConstantArguments enumConstantClassBody
    ;

enumConstant
    :   annotations Identifier enumConstantArguments enumConstantClassBody
    ;

enumConstantArguments
    :   %empty /* empty */
    |   arguments
    ;
enumConstantClassBody
    :   %empty /* empty */
    |   classBody
    ;

interfaceDeclaration
    :   INTERFACE Identifier optionalTypeParameters interfaceBody
    |   INTERFACE Identifier optionalTypeParameters EXTENDS typeList interfaceBody
    ;

typeList
    :   type
        {
            $$ = [ $1 ];
        }
    |   typeList COMMA type
        {
            $1.push($3);
            $$ = $1;
        }
    ;

optionalTypeParameters
    :   %empty
    |   typeParameters
    ;
classBody
    :   LBRACE  RBRACE
    |   LBRACE classBodyDeclarationl RBRACE
    ;

/*Can be zero or more*/
classBodyDeclarations
    :   %empty /* empty */
    |   classBodyDeclarationl
    ;

classBodyDeclarationl
    :   classBodyDeclaration
    |   classBodyDeclarationl classBodyDeclaration
    ;

classStaticBlock
    :   STATIC block
    |   block     /* check openjdk/jdk/src/share/classes/com/sun/java/util/jar/pack/Package.java:62 */
    ;

interfaceBody
    :   LBRACE RBRACE
    |   LBRACE interfaceBodyDeclarationl RBRACE
        
    ;

interfaceBodyDeclarations
    :   %empty /* empty */
    |   interfaceBodyDeclarationl
    ;

interfaceBodyDeclarationl
    :   interfaceBodyDeclaration
    |   interfaceBodyDeclarationl interfaceBodyDeclaration
    ;

classBodyDeclaration
    :   SEMI

    |   annotationl modifierL classMemberDeclaration
    |   modifierL annotationl classMemberDeclaration
    |   modifierL classMemberDeclaration

    |   annotationl classMemberDeclaration
    |   classMemberDeclaration
    |   classStaticBlock
    ;

staticBlock
    : %empty /* empty */
    | STATIC block
    ;

modifier
    :   STATIC
    |   FINAL
    |   ABSTRACT
    |   STRICTFP
    |   TRANSIENT
    |   VOLATILE
    |   PUBLIC
    |   PRIVATE
    |   PROTECTED
    |   NATIVE
    |   SYNCHRONIZED
    ;

modifierL
    :   modifier
    |   modifierL modifier
    ;

modifiers
    :   %empty /* empty */
    |   modifierL
    ;

classMemberDeclaration
    : /* Methods */
        VOID Identifier formalParameters arrayDimensionBracks throwsList block
    |   VOID Identifier formalParameters arrayDimensionBracks block
    |   VOID Identifier formalParameters block
    |   type Identifier formalParameters arrayDimensionBracks throwsList block
    |   type Identifier formalParameters arrayDimensionBracks block
    |   type Identifier formalParameters block
    |   VOID Identifier formalParameters arrayDimensionBracks throwsList SEMI
    |   VOID Identifier formalParameters arrayDimensionBracks SEMI
    |   VOID Identifier formalParameters SEMI
    |   type Identifier formalParameters arrayDimensionBracks throwsList SEMI
    |   type Identifier formalParameters arrayDimensionBracks SEMI
    |   type Identifier formalParameters SEMI
    |   typeParameters VOID Identifier formalParameters arrayDimensionBracks throwsList block
    |   typeParameters VOID Identifier formalParameters arrayDimensionBracks block
    |   typeParameters VOID Identifier formalParameters block
    |   typeParameters type Identifier formalParameters arrayDimensionBracks throwsList block
    |   typeParameters type Identifier formalParameters arrayDimensionBracks block
    |   typeParameters type Identifier formalParameters block
    |   typeParameters VOID Identifier formalParameters arrayDimensionBracks throwsList SEMI
    |   typeParameters VOID Identifier formalParameters arrayDimensionBracks SEMI
    |   typeParameters VOID Identifier formalParameters SEMI
    |   typeParameters type Identifier formalParameters arrayDimensionBracks throwsList SEMI
    |   typeParameters type Identifier formalParameters arrayDimensionBracks SEMI
    |   typeParameters type Identifier formalParameters SEMI

    /* Fields */
    |    type variableDeclarators SEMI

    /* Constructor */
    |    Identifier formalParameters throwsList block
    |    typeParameters Identifier formalParameters throwsList block

    /* Inner class, enum, interface or annotation type */
    |   classDeclaration
    |   interfaceDeclaration
    |   enumDeclaration
    |   annotationTypeDeclaration
    ;


throwsList
    : %empty /* empty */
    |   THROWS qualifiedNameList
    ;
/*
methodDeclaration
    :   VOID Identifier formalParameters arrayDimensionBracks throwsList block
    |   VOID Identifier formalParameters arrayDimensionBracks block
    |   VOID Identifier formalParameters block
    |   type Identifier formalParameters arrayDimensionBracks throwsList block
    |   type Identifier formalParameters arrayDimensionBracks block
    |   type Identifier formalParameters block
    |   VOID Identifier formalParameters arrayDimensionBracks throwsList SEMI
    |   VOID Identifier formalParameters arrayDimensionBracks SEMI
    |   VOID Identifier formalParameters SEMI
    |   type Identifier formalParameters arrayDimensionBracks throwsList SEMI
    |   type Identifier formalParameters arrayDimensionBracks SEMI
    |   type Identifier formalParameters SEMI
    ;

genericMethodDeclaration
    :   typeParameters methodDeclaration
    ; 

constructorDeclaration
    :   Identifier formalParameters throwsList block
    ;

genericConstructorDeclaration
    :   typeParameters Identifier formalParameters throwsList block
    ;

fieldDeclaration
    :   type variableDeclarators SEMI
    |   "$&*@#$^@$^@$^$^@^" // bogus state
    ;

interfaceConstOrMethodModifier
    :   PUBLIC
    |   PROTECTED
    ; */  

interfaceBodyDeclaration
    :   annotationl modifierL interfaceMemberDeclaration
    |   modifierL annotationl interfaceMemberDeclaration
    |   annotationl interfaceMemberDeclaration
    |   modifierL interfaceMemberDeclaration
    |   interfaceMemberDeclaration
    |   SEMI
    ;

interfaceMemberDeclaration
    :   type constDelarators SEMI
    |   VOID Identifier formalParameters arrayDimensionBracks throwsList SEMI
    |   VOID Identifier formalParameters arrayDimensionBracks SEMI
    |   VOID Identifier formalParameters SEMI
    |   type Identifier formalParameters arrayDimensionBracks throwsList SEMI
    |   type Identifier formalParameters arrayDimensionBracks SEMI
    |   type Identifier formalParameters SEMI
    |   typeParameters VOID Identifier formalParameters arrayDimensionBracks throwsList SEMI
    |   typeParameters VOID Identifier formalParameters arrayDimensionBracks SEMI
    |   typeParameters VOID Identifier formalParameters SEMI
    |   typeParameters type Identifier formalParameters arrayDimensionBracks throwsList SEMI
    |   typeParameters type Identifier formalParameters arrayDimensionBracks SEMI
    |   typeParameters type Identifier formalParameters SEMI
    |   classDeclaration
    |   interfaceDeclaration
    |   enumDeclaration
    |   annotationTypeDeclaration
    ;

constDeclaration
    :   constDelarators SEMI
    ;

constDelarators
    :   constantDeclarator
    |   constDelarators COMMA constantDeclarator
    ;

constantDeclarator
    :   Identifier ASSIGN variableInitializer
    |   Identifier arrayDimensionBrackl ASSIGN variableInitializer
    ;

/* see matching of [] comment in methodDeclaratorRest*/
/*interfaceMethodDeclaration
    :   interfaceVoidMethod
    |   TEMPLATE interfaceVoidMethod   
    |   interfaceNonVoidMethod
    |   TEMPLATE interfaceNonVoidMethod
    ;

interfaceVoidMethod
    :   VOID Identifier formalParameters arrayDimensionBracks throwsList SEMI
    |   VOID Identifier formalParameters arrayDimensionBracks SEMI
    |   VOID Identifier formalParameters SEMI
    ;

interfaceNonVoidMethod
    :   type Identifier formalParameters arrayDimensionBracks throwsList SEMI
    |   type Identifier formalParameters arrayDimensionBracks SEMI
    |   type Identifier formalParameters SEMI
    ; */

variableDeclarators
    :   variableDeclarator
    |   variableDeclarators COMMA variableDeclarator
    ;

variableDeclarator
    :   variableDeclaratorId
    |   variableDeclaratorId ASSIGN variableInitializer
    ;

variableDeclaratorId
    :   Identifier arrayDimensionBracks
    ;

variableInitializer
    :   arrayInitializer
    |   expression
    ;

arrayInitializer
    :   LBRACE RBRACE /*(variableInitializerL (",")? )?*/
    |   LBRACE variableInitializerL SEMI RBRACE
    |   LBRACE variableInitializerL RBRACE
    |   LBRACE variableInitializerL COMMA RBRACE
    ;

variableInitializerL
    :   variableInitializer
    |   variableInitializerL COMMA variableInitializer
    ;

enumConstantName
    :   qualifiedName
    ;

type
    :   qualifiedName arrayDimensionBracks
    |   primitiveType arrayDimensionBracks
    ;

arrayDimensionBracks
    :   %empty /* empty */
    |   arrayDimensionBrackl
    ;

arrayDimensionBrackl
    :   arrayDimensionBrack
    |   arrayDimensionBrackl arrayDimensionBrack
    ;

arrayDimensionBrack
    :   LBRACK RBRACK
    ;
classOrInterfaceType
    :   qualifiedName
    |   qualifiedName typeParameters
    ;

primitiveType
    :   BOOLEAN
    |   CHAR
    |   BYTE
    |   SHORT
    |   INT
    |   LONG
    |   FLOAT
    |   DOUBLE
    ;

typeArguments
    :   %empty /* empty */
    |   LT typeArgumentList GT
    ;

typeArgumentList
    :   typeArgument
    |   typeArgumentList COMMA typeArgument
    ;

typeArgument
    :   type
    |   QUESTION EXTENDS type
    |   QUESTION SUPER type
    ;

typeArgument_
    : %empty /* empty */
    |   EXTENDS type
    |   SUPER type
    ;

qualifiedNameList
    :   qualifiedName
    |   qualifiedNameList COMMA qualifiedName
    ;

formalParameters
    :   LPAREN RPAREN
    |   LPAREN formalParameterList RPAREN
    ;

formalParameterList
    :   usualParameterList
    |   usualParameterList COMMA lastFormalParameter
    |   lastFormalParameter
    ;

usualParameterList
    :   usualParameter
    |   usualParameterList COMMA usualParameter
    ;


variableModifiers
    :   FINAL annotationl
    |   annotationl
    |   FINAL
    |   annotationl FINAL
    ;

variableModifierL
    :   variableModifier
    |   variableModifierL variableModifier
    ;

variableModifier
    :   FINAL
    |   annotations
    ;

usualParameter
    :   variableModifiers type variableDeclaratorId
    |   type variableDeclaratorId
    ;

lastFormalParameter
    :   variableModifiers type ELLIPSIS variableDeclaratorId
    |   type ELLIPSIS variableDeclaratorId
    ;

methodBody
    :   block
    ;

constructorBody
    :   block
    ;

qualifiedName
    :   Identifier
        { $$ = $1; }
    |   Identifier typeParameters
        { $$ = $1; }
    |   qualifiedName DOT Identifier
        { $$ = $1 + "." + $3; }
    |   qualifiedName DOT Identifier typeParameters
        { $$ = $1 + "." + $3; }
    ;

literal
    :   IntegerLiteral
    |   FloatingPointLiteral
    |   CharacterLiteral
    |   StringLiteral
    |   BooleanLiteral
    |   NullLiteral
    ;

/* ANNOTATIONS */

annotations
    :   %empty /* empty */
    |   annotationl
    ;

annotationl
    :   annotation
    |   annotationl annotation
    ;

annotation
    :   AT qualifiedName
    |   AT qualifiedName LPAREN elementValueList RPAREN
    |   AT qualifiedName LPAREN elementValuePairs RPAREN
    ;

annotationOptValues
    :   %empty /* empty */
    |   LPAREN annotationElement RPAREN
    ;

annotationElement
    :   %empty /* empty */
    |   elementValuePairs
    |   elementValue
    ;
annotationName
    :   qualifiedName
    ;

elementValuePairs
    :   elementValuePair
    |   elementValuePairs COMMA elementValuePair
    ;

elementValuePair
    :   Identifier ASSIGN elementValue
    ;

elementValue
    :   expression
    |   annotations
    |   LBRACE RBRACE /*(elementValue ("," elementValue)*)? (",")?*/
    |   LBRACE elementValueList RBRACE
    ;

elementValueArrayInitializer
    :   LBRACE RBRACE /*(elementValue ("," elementValue)*)? (",")?*/
    |   LBRACE elementValueList RBRACE
    ;

elementValueListOpt
    :   %empty /* empty */
    |   elementValueList
    ;

elementValueList
    :   elementValue
    |   elementValueList COMMA elementValue
    ;

annotationTypeDeclaration
    :   AT INTERFACE Identifier annotationTypeBody
    |   AT INTERFACE Identifier EXTENDS typeList annotationTypeBody
        
    ;

annotationTypeBody
    :   LBRACE RBRACE
    |   LBRACE annotationTypeElementDeclarations RBRACE
    ;


annotationTypeElementDeclarations
    :   annotationTypeElementDeclaration
    |   annotationTypeElementDeclarations annotationTypeElementDeclaration
    ;

annotationTypeElementDeclaration
    :   modifierL annotationTypeElementRest
    |   annotationl annotationTypeElementRest
    |   annotationl modifierL annotationTypeElementRest
    |   modifierL annotationl annotationTypeElementRest
    |   annotationTypeElementRest
    |   SEMI /* this is not allowed by the grammar, but apparently allowed by the actual compiler*/
    ;

annotationTypeElementRest
    :   type annotationConstantRest SEMI
    |   typeParameters type annotationMethodRest SEMI
    |   type annotationMethodRest SEMI
    |   classDeclaration
    |   interfaceDeclaration
    |   enumDeclaration
    |   annotationTypeDeclaration
    ;

semiOpt
    :   %empty /* empty */
    |   SEMI
    ;

annotationMethodRest
    :   Identifier LPAREN RPAREN defaultValue
    |   Identifier LPAREN RPAREN
    ;

defaultValueOpt
    :   %empty /* empty */
    |   defaultValue
    ;
annotationConstantRest
    :   variableDeclarators
    ;

defaultValue
    :   DEFAULT elementValue
    ;

/* STATEMENTS / BLOCKS */

block
    :   LBRACE RBRACE
        
    |   LBRACE blockStatementList RBRACE
        
    ;

blockStatements
    :   %empty /* empty */
    |   blockStatementList
    ;

blockStatementList
    :   blockStatement
    |   blockStatementList blockStatement
    ;

blockStatement
    :   statement
    /*|   typeDeclaration */
    |   LBRACE RBRACE
        
    |   LBRACE blockStatementList RBRACE
        
    ;

localVariableDeclarationStatement
    :   localVariableDeclaration SEMI
    ;

localVariableDeclaration
    :   type variableDeclarators
    ;

assertExpression
    :   expression
    |   expression COLON expression
    ;

optionalElseStatement
    :   %empty /* empty */
    |   ELSE blockStatement
    ;

statement
    :   ASSERT assertExpression SEMI
    |   IF LPAREN expression RPAREN blockStatement optionalElseStatement
/*       % {console.log('IF block'); %} */
    |   FOR LPAREN forControl RPAREN blockStatement
    |   WHILE LPAREN expression RPAREN blockStatement
    |   DO blockStatement WHILE LPAREN expression RPAREN SEMI
    |   TRY block catchFinallyOrOnlyFinally
    |   TRY resourceSpecification block catchClauses
    |   TRY resourceSpecification block optionalFinallyBlock
    |   TRY resourceSpecification block catchClauses optionalFinallyBlock
    |   SWITCH LPAREN expression RPAREN LBRACE switchBlockStatementGroups emptySwitchLabels RBRACE
    |   SYNCHRONIZED LPAREN expression RPAREN block
    |   RETURN SEMI
    |   RETURN expression SEMI
    |   THROW expression SEMI
    |   BREAK optionalIdentifier SEMI
    |   CONTINUE optionalIdentifier SEMI
/*    |   SEMI*/
    |   Identifier COLON blockStatement
    |   expression SEMI
    |   typeDeclarationWithPrefixes /*Refer openjdk/hotspot/agent/src/share/classes/sun/jvm/hotspot/tools/PermStat.java:70 */
    |   variableDeclaratorsWithPrefixes
    /*|   LBRACE RBRACE
        { console.log('Found empty code block')}
    |   LBRACE blockStatementList RBRACE
        { console.log('Found code block')} */
    ;

variableDeclaratorsWithPrefixes
    :   annotationl modifierL localVariableDeclaration
    |   modifierL annotationl localVariableDeclaration
    |   modifierL localVariableDeclaration
    |   annotationl localVariableDeclaration
    |   localVariableDeclaration 
    ;

simpleExpressionStatement
    :   expression SEMI
    ;
optionalIdentifier
    :   %empty /* empty */
    |   Identifier
    ;

catchFinallyOrOnlyFinally
    :   catchClauses optionalFinallyBlock
    |   finallyBlock
    ;

optionalFinallyBlock
    :   %empty /* empty */
    |   finallyBlock
    ;
catchClauses
    :   catchClause
    |   catchClauses catchClause
    ;

catchClause
    :   CATCH LPAREN variableModifiers catchType Identifier RPAREN block
    |   CATCH LPAREN catchType Identifier RPAREN block
    ;

catchType
    :   qualifiedName
    |   catchType BITOR qualifiedName
    ;

finallyBlock
    :   FINALLY block
    ;

resourceSpecification
    :   LPAREN resources semiOpt RPAREN
    ;

resources
    :   resource
    |   resources SEMI resource
    ;

resource
    :   variableModifiers classOrInterfaceType variableDeclaratorId ASSIGN expression
    |   classOrInterfaceType variableDeclaratorId ASSIGN expression
    ;


switchBlockStatementGroups
    :   %empty /* empty */
    |   switchBlockStatementGroupL
    ;

switchBlockStatementGroupL
    :   switchBlockStatementGroup
    |   switchBlockStatementGroupL switchBlockStatementGroup
    ;

switchBlockStatementGroup
    :   switchLabelL blockStatementList
    |   switchLabelL
    ;

emptySwitchLabels
    :   %empty /* empty */
    |   switchLabelL
    ;

switchLabelL
    :   switchLabel
    |   switchLabelL switchLabel
    ;

switchLabel
    :   CASE expression COLON /* openjdk/jdk/src/share/classes/com/sun/java/util/jar/pack/BandStructure.java:2421 */
    /*|   CASE enumConstantName COLON*/
    |   DEFAULT COLON
    ;

forControl
    :   enhancedForControl
        
    |   forInit SEMI optionalExpression SEMI optionalForUpdate
    |   SEMI optionalExpression SEMI optionalForUpdate
    ;

optionalForInit
    :   %empty /* empty */
    |   forInit
    ;

optionalExpression
    :   %empty /* empty */
    |   expression
    ;

optionalForUpdate
    :   %empty /* empty */
    |   forUpdate
    ;

forInit
    :   variableDeclaratorsWithPrefixes
    |   expressionList
    ;

enhancedForControl
    :   modifierL type variableDeclaratorId COLON expression
    |   type variableDeclaratorId COLON expression
    ;

forUpdate
    :   expressionList
    ;

/* EXPRESSIONS */

parExpression
    :   LPAREN expression RPAREN
    ;

expressionList
    :   expression
    |   expressionList COMMA expression
    ;

optionalExpressionList
    :   %empty /* empty */
    |   expressionList
    ;
statementExpression
    :   expression
    ;

constantExpression
    :   expression
    ;

optionalNonWildcardTypeArguments
    :   %empty /* empty */
    |   nonWildcardTypeArguments
    ;

/* Postfix inc or dec */
incrementOrDecrement
    :   INC
    |   DEC
    ;

/* Prefix arithmetic unary operators */

plusMinusIncOrDec
    :   ADD
    |   SUB
    |   INC
    |   DEC
    ;

prefixTildeOrBang
    :   TILDE
    |   BANG
    ;

/* Binary operators */
mulDivOrMod
    :   MUL
    |   DIV
    |   MOD
    ;

addOrSub
    :   ADD
    |   SUB
    ;

bitShiftOperator
    :   LT LT           /* << left shift */
    |   GT GT GT        /* >>> unsigned right shift */
    |   GT GT           /* right shift */
    ;
lE_GE_LT_GT
    :   LE
    |   GE
    |   GT
    |   LT
    ;

equals_NotEqual
    :   EQUAL
    |   NOTEQUAL
    ;

assignmentToken
    :   ASSIGN
    |   ADD_ASSIGN
    |   SUB_ASSIGN
    |   MUL_ASSIGN
    |   DIV_ASSIGN
    |   AND_ASSIGN
    |   OR_ASSIGN
    |   XOR_ASSIGN
    |   RSHIFT_ASSIGN
    |   URSHIFT_ASSIGN
    |   LSHIFT_ASSIGN
    |   MOD_ASSIGN
    ;

newCreator
    :   NEW creator
    ;


expression
    :   parExpression
    |   qualifiedName
    /*|   qualifiedName LT expression */
    /*|   qualifiedName DOT CLASS*/
    |   qualifiedName DOT CLASS
    |   expression DOT qualifiedName
    |   expression DOT SUPER
    |   qualifiedName DOT SUPER
    |   qualifiedName DOT SUPER DOT expression
    |   expression DOT SUPER DOT expression
    |   expression DOT SUPER arguments
    |   expression DOT SUPER LPAREN RPAREN
    |   expression 
    |   qualifiedName DOT newCreator
    |   expression DOT newCreator /* openjdk/jdk/src/share/classes/com/sun/java/util/jar/pack/Attribute.java:487 */
    |   qualifiedName arrayDimensionBrackl DOT CLASS
    |   primitiveType DOT CLASS
    /*|   type DOT CLASS*/
    |   primitiveType arrayDimensionBrackl DOT CLASS
    |   qualifiedName DOT THIS
    |   expression DOT THIS
    |   expression DOT NEW optionalNonWildcardTypeArguments innerCreator
    |   qualifiedName DOT explicitGenericInvocation
    |   expression DOT qualifiedName 
    |   expression DOT typeParameters Identifier arguments
    |   expression LBRACK expression RBRACK
    |   qualifiedName LBRACK expression RBRACK
    |   expression arguments
    |   expression LPAREN RPAREN
    |   newCreator
    |   parExpression expression
    /*|   typeCast expression*/
    /*|   typeCast DOT qualifiedName*/
    |   expression incrementOrDecrement
    |   plusMinusIncOrDec expression
    |   prefixTildeOrBang expression
    |   expression mulDivOrMod expression
    |   expression addOrSub expression
    |   expression LSHIFT expression
    |   expression GT GT expression
    |   expression GT GT GT expression
    |   expression lE_GE_LT_GT expression
    |   expression INSTANCEOF type
    |   expression equals_NotEqual expression
    |   expression BITAND expression
    |   expression CARET expression
    |   expression BITOR expression
    |   expression AND expression
    |   expression OR expression
    |   expression QUESTION expression COLON expression
    |   expression assignmentToken expression
    |   THIS
    |   SUPER
    |   IntegerLiteral
    |   FloatingPointLiteral
    |   CharacterLiteral
    |   StringLiteral
    |   BooleanLiteral
    |   NullLiteral
    |   VOID DOT CLASS
    |   nonWildcardTypeArguments explicitGenericInvocationSuffixOrThisArgs
    ;

parExpression
    :   LPAREN primitiveType RPAREN
    |   LPAREN qualifiedName arrayDimensionBrackl RPAREN
    |   LPAREN qualifiedName typeParameters arrayDimensionBrackl RPAREN
    |   LPAREN qualifiedName typeParameters RPAREN
    |   LPAREN primitiveType arrayDimensionBrackl RPAREN
    |   LPAREN expression RPAREN /* All except this are type casts */
    /*|   parExpression*/
    /*|   LPAREN qualifiedName LSHIFT expression RPAREN
    |   LPAREN qualifiedName GT GT GT expression RPAREN
    |   LPAREN qualifiedName GT GT expression RPAREN*/
    ;

explicitGenericInvocationSuffixOrThisArgs
    :   explicitGenericInvocationSuffix
    |   THIS arguments
    ;

creator
    :   nonWildcardTypeArguments createdName classCreatorRest
    |   createdName arrayOrClassCreator
    ;

arrayOrClassCreator
    :   arrayCreatorRest
    |   classCreatorRest
    ;

createdName
    :   qualifiedName optionalTypeArgumentsOrDiamonds
    |   primitiveType
    ;

optionalTypeArgumentsOrDiamonds
    :   %empty /* empty */
    |   typeArgumentsOrDiamondList
    ;

typeArgumentsOrDiamondList
    :   typeArgumentsOrDiamond
    |   typeArgumentsOrDiamondList DOT Identifier  typeArgumentsOrDiamond
    ;

innerCreator
    :   Identifier optionalNonWildcardTypeArgumentsOrDiamond classCreatorRest
    ;

optionalNonWildcardTypeArgumentsOrDiamond
    :   %empty /* empty */
    |   nonWildcardTypeArgumentsOrDiamond
    ;
arrayCreatorRest
    :   LBRACK RBRACK arrayDimensionBracks arrayInitializer
    |   bracketedExpressions arrayDimensionBracks
    ;

bracketedExpressions
    :   LBRACK expression RBRACK
    |   bracketedExpressions LBRACK expression RBRACK
    ;

classCreatorRest
    :   arguments
    |   LPAREN RPAREN
    |   LPAREN RPAREN classBody
    |   arguments classBody
    ;

optionalClassBody
    :   %empty /* empty */
    |   classBody
    ;

explicitGenericInvocation
    :   nonWildcardTypeArguments explicitGenericInvocationSuffix
    ;

nonWildcardTypeArguments
    :  TEMPLATE
    ;

typeArgumentsOrDiamond
    :   LT GT
    |   typeParameters
    ;

nonWildcardTypeArgumentsOrDiamond
    :   LT GT
    |   nonWildcardTypeArguments
    ;

superSuffix
    :   arguments
    |   DOT Identifier
    |   DOT Identifier arguments
    ;

optionalArguments
    :   %empty /* empty */
    |   arguments
    ;

explicitGenericInvocationSuffix
    :   SUPER superSuffix
    |   Identifier arguments
    ;

arguments
    :   LPAREN RPAREN
    |   LPAREN expressionList RPAREN
    ;

optionalCOMMA
    :   %empty /* empty */
    |   COMMA
    ;