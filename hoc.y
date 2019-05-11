%{
  #include <stdio.h>
  #include <math.h>
  
  int yylex();
  int yyerror(char *s);
  int warning(char *s, char *t);
  int execerror(char *s, char *t);
  int fpecatch();
  double mem[26];
  %}
%union {        /* stack type */
  double val;   /* actual value */
  int index;    /* index into mem[] */
}
%token <val>   NUMBER
%token <index> VAR
%type  <val>   expr
%right '='
%left  '+' '-'
%left  '*' '/' '%'
%left  UNARYMINUS UNARYPLUS
%%
list:  /* nothing */
| list '\n'
| list expr '\n'  { printf("\t%.8g\n", $2); }
| list error '\n' { yyerror;}
;
expr:  NUMBER   { $$ = $1;}
| VAR           { $$ = mem[$1]; }
| VAR  '=' expr { $$ = mem[$1] = $3; } 
| expr '+' expr { $$ = $1 + $3;}
| expr '-' expr { $$ = $1 - $3;}
| expr '*' expr { $$ = $1 * $3;}
| expr '/' expr {
  if($3 == 0.0)
    execerror("division by zero", "");
  $$ = $1 / $3; }
| expr '%' expr { $$ = fmod($1, $3);}
| '-' expr %prec UNARYMINUS { $$ = -$2;}
| '+' expr %prec UNARYPLUS { $$ = +$2;}
| '(' expr ')' { $$ = $2;}
;
%%
/* end of grammar */

#include <stdio.h>
#include <ctype.h>
#include <math.h>
#include <signal.h>
#include <setjmp.h>

char *progname;   /* for error message */
int lineno = 1;
jmp_buf begin;

main(int argc, char **argv) {  /* hoc1 */
  int fpecatch();
  
  progname = argv[0];
  setjmp(begin);
  signal(SIGFPE, fpecatch);
  yyparse();
}

int execerror(char *s, char *t) {
  warning(s, t);
  longjmp(begin, 0);
}

int fpecatch() {
  execerror("floating point exception", (char*)0);
}

int yylex() {
  int c;

  while((c = getchar()) == ' ' || c == '\t')
    ;
  if(c == EOF)
    return 0;
  if(c == '.' || isdigit(c)) { /* number */
    ungetc(c, stdin);
    scanf("%lf", &yylval.val);
    return NUMBER;
  }
  if(islower(c)) {
    yylval.index = c - 'a';  /* ASCII only*/
    return VAR;
  }
  if(c == '\n')
    lineno++;
  return c;
}

int yyerror(char *s) {
  warning(s, (char*)0);
}

int warning(char *s, char *t) {
  fprintf(stderr, "%s: %s", progname, s);
  if(t)
    fprintf(stderr, " %s", t);
  fprintf(stderr, " near line %d\n", lineno);
}
