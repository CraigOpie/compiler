// A simple syntax-directed translator for a simple language

grammar MyLanguageV1Code;

// Root non-terminal symbol
// A program is a bunch of declarations followed by a bunch of statements
// The Java code outputs the necessary NASM code around these declarations
program
  : 
    {
      System.out.println("%include \"asm_io.inc\"");
      System.out.println("segment .bss"); 
    }
    declaration*
    { System.out.println("segment .data"); }
    initialized_declaration*
    {
      System.out.println("segment .text"); 
      System.out.println("\tglobal asm_main"); 
      System.out.println("asm_main:"); 
      System.out.println("\tenter 0,0"); 
      System.out.println("\tpusha"); 
    }
    statement*
    {
      System.out.println("\tpopa"); 
      System.out.println("\tmov eax,0"); 
      System.out.println("\tleave"); 
      System.out.println("\tret"); 
    } 
    subfunction*
  ;

// Parse rule for variable declarations
declaration
  : INT a=NAME SEMICOLON
    { 
      int a;

      System.out.println("\t"+$a.text + "  resd 1");
    }
  ;

// Parse rule for variable declarations
initialized_declaration
  : INT a=NAME ASSIGN b=INTEGER SEMICOLON
    { 
      int a, b;

      System.out.println("\t"+$a.text + "  dd " + $b.text);
    }
  ;

// Parse rule for statements
statement
  : ifstmt 
  | ifelsestmt
  | dowhilestmt
  | printstmt 
  | assignstmt 
  | returnstmt
  | functioncallstmt
  ;

// Parse rule for if statements
ifstmt
  : IF LPAREN a=identifier EQUAL b=integer RPAREN
    { 
      int a, b;
      String endif_label;

      System.out.println("if_"+Integer.toString($IF.index)+":"); 
      System.out.println("\tcmp dword "+$a.toString+","+$b.toString);
      endif_label = "endif_"+Integer.toString($IF.index);
      System.out.println("\tjnz "+endif_label); 
    }
    statement*

    ENDIF
    { System.out.println(endif_label+":"); }
  ;

// Parse rule for if-else statements
ifelsestmt
  : IF LPAREN a=identifier EQUAL b=integer RPAREN
    { 
      int a, b;
      String else_label;
      String endif_label;

      System.out.println("if_"+Integer.toString($IF.index)+":"); 
      System.out.println("\tcmp dword "+$a.toString+","+$b.toString);
      else_label = "else_"+Integer.toString($IF.index);
      endif_label = "endif_"+Integer.toString($IF.index);
      System.out.println("\tjnz "+else_label); 
    }
    statement*

    ELSE
    {
      System.out.println("\tjmp "+endif_label);
      System.out.println(else_label+":");
    }
    statement*

    ENDIF
    { System.out.println(endif_label+":"); }
  ;

// Parse rule for do-while statements
dowhilestmt
  : DO
    { 
      int a, b;
      String do_label;
      
      do_label = "do_label_"+Integer.toString($DO.index);
      System.out.println(do_label+":");
    }
    statement*

    WHILE LPAREN a=identifier NOTEQUAL b=integer RPAREN
    {
      System.out.println("\tcmp dword "+$a.toString+","+$b.toString);
      System.out.println("\tjnz "+do_label);
    }
  ;

// Parse rule for print statements
printstmt
  : PRINT term SEMICOLON
    {
      System.out.println("\tmov eax, "+$term.toString);
      System.out.println("\tcall print_int");
      System.out.println("\tcall print_nl");
    } 
  ;

// Parse rule for assignment statements
assignstmt
  : a=NAME ASSIGN expression SEMICOLON 
    {
      int a;

      System.out.println("\tmov ["+$a.text+"], eax");
    }
  ;

// Parse rule for return statement
returnstmt
  : RETURN expression SEMICOLON
    {
      System.out.println("\tleave"); 
      System.out.println("\tret");
    }
  ;

// Parse rule for function call statement
functioncallstmt
  : a=NAME ASSIGN b=NAME LPAREN RPAREN SEMICOLON
    {
      int a, b;

      System.out.println("\tcall func_"+$b.text);
      System.out.println("\tmov ["+$a.text+"], eax");
    }
  ;

// Parse rule for expressions
expression
  : a=term 
    {
      int a, b;

      System.out.println("\tmov eax,"+$a.toString);
    }
  | a=term PLUS b=term 
    {
      System.out.println("\tmov eax,"+$a.toString);
      System.out.println("\tadd eax,"+$b.toString);
    }
  | a=term MINUS b=term
    {
      System.out.println("\tmov eax,"+$a.toString);
      System.out.println("\tsub eax,"+$b.toString);
    }                
  ;

// Parse rule for terms
term returns [String toString]
  : identifier { $toString = $identifier.toString; } 
  | integer { $toString = $integer.toString; } 
  ;

// Parse rule for identifiers
identifier returns [String toString]
  : NAME { $toString = "["+$NAME.text+"]"; }
  ;

// Parse rule for numbers 
integer returns [String toString]
  : INTEGER {$toString = $INTEGER.text;}
  ;

// Parse rule for subfunction
subfunction
  : function
  ;


// Parse rule for functions
function
  : INT a=NAME LPAREN RPAREN LBRACK
    {
      String func_label;

      func_label = "func_"+$a.text;
      System.out.println(func_label+":"); 
      System.out.println("\tenter 0,0");
    }
    statement*

    RBRACK
    {
      System.out.println("\tleave"); 
      System.out.println("\tret");
    }
  ;


// Reserved Keywords
IF: 'if';
ELSE: 'else';
ENDIF: 'endif';
PRINT: 'print';
INT: 'int';
DO: 'do';
WHILE: 'while';
RETURN: 'return';

// Operators
PLUS: '+';
MINUS: '-';
EQUAL: '==';
ASSIGN: '=';
NOTEQUAL: '!=';

// Semicolon and parentheses
SEMICOLON: ';';
LPAREN: '(';
RPAREN: ')';
LBRACK: '{';
RBRACK: '}';

// Integers
INTEGER: [0-9][0-9]*;

// Variable names
NAME: [a-z]+;

// Ignore all white spaces 
WS: [ \t\r\n]+ -> skip ; 
