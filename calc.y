%{
/* analisador sintático para uma calculadora */
/* com suporte a definição de variáveis */
#include <iostream>
#include <string>
#include <unordered_map>
#include <math.h>
#include <sstream>
#include <cstring>
using std::string;
using std::unordered_map;
using std::cout;

/* protótipos das funções especiais */
int yylex(void);
int yyparse(void);
void yyerror(const char *);
/*funções para manipular a string*/
string toString(float f);
char* handleString(char* text, int size);
/* tabela de símbolos */
unordered_map<string,double> variables;
/*criando a stringo para o cout*/
string sysout = "";
%}

%union {
	double num;
	char id[256];
	char text[4096];
}

%token <id> ID
%token <num> NUM
%type <num> expr
%token <text> TEXT
%token LEQUALS MEQUALS DIFFERENT EQUALS
%token IF
%token PRINT
%token SQRT POW

%left '+' '-'
%left SQRT POW '*' '/'
%left LESS MORE LEQUALS MEQUALS DIFFERENT EQUALS
%nonassoc IF
%nonassoc UMINUS

%%

math: math calc '\n'
	| calc '\n'
	;

calc: ID '=' expr 								{ variables[$1] = $3;								 	} 	
	| IF '(' expr ')' PRINT '(' argment ')'     { if ($3 == 1 ) cout << sysout << "\n"; sysout =  "";	}
	| IF '(' expr ')' ID '=' expr       		{ if ($3 == 1 ) variables[$5] = $7;  					}
	| PRINT '(' argment ')' 					{cout << sysout << "\n"; sysout =  "";					}
	| expr										{ cout << "= " << $1 << "\n"; 							}
	| '\n'
	; 
argment: buff ',' argment				
	| buff								
buff: TEXT					{sysout.append(handleString($1, strlen($1) - 1));/*mandando o texto menos a caractere de final de linha*/}
	| expr					{sysout.append(toString($1));/*convertendo para string*/}
expr: expr '+' expr			{ $$ = $1 + $3; }
	| expr '-' expr   		{ $$ = $1 - $3; }
	| expr '*' expr			{ $$ = $1 * $3; }
	| expr '/' expr			
	{ 
		if ($3 == 0)
			yyerror("divisão por zero");
		else
			$$ = $1 / $3; 
	}
	| '(' expr ')'					{ $$ = $2; 				}
	| '-' expr %prec UMINUS 		{ $$ = - $2; 			}
	| expr EQUALS expr				{ $$ = $1 == $3;  		}
	| expr LESS expr				{ $$ = $1 < $3; 		}
	| expr MORE expr				{ $$ = $1 > $3;  		}
	| expr LEQUALS expr				{ $$ = $1 <= $3;  		}
	| expr MEQUALS expr				{ $$ = $1 >= $3;  		}
	| expr DIFFERENT expr			{ $$ = $1 != $3; 		}
	| SQRT '(' expr ')'             { $$ = sqrt( $3 );      }
    | POW  '(' expr ',' expr ')'    { $$ = pow( $3, $5);    }
	| ID							{ $$ = variables[$1]; 	}
	| NUM
	;

%%
extern FILE * yyin;  

int main(int argc, char ** argv )
{
	if (argc > 1)//vendo se tem args
	{
		FILE * file; //criando arquivo
		file = fopen(argv[1], "r");
		if (!file) //verifica se abriu arquivo
		{
			cout << "Arquivo " << argv[1] << " não encontrado!\n";
			exit(1);
		}
		
		/* entrada ajustada para ler do arquivo */
		yyin = file; // le o arquivo
	}
	yyparse();
}

string toString(float f) {//Pesquisei na internet e achei essa solução para convenrter float do string
    std::ostringstream st;
    st << f;
    return st.str();
}
char* handleString(char* text, int size){ //Ajustando texto

	char* newText = new char[size + 1]; // criando cadeia de char do tamanho do texto
    for (int i = 0; i < size - 1; i++)  // retira a ultima caractere , no caso "
        newText[i] = *(text + 1  + i);//inicia a nova string sem a caractere  "
    newText[size] = 0;
    return newText;
}
void yyerror(const char * s)
{
	/* variáveis definidas no analisador léxico */
	extern int yylineno;    
	extern char * yytext;   

	/* mensagem de erro exibe o símbolo que causou erro e o número da linha */
    cout << "Erro (" << s << "): símbolo \"" << yytext << "\" (linha " << yylineno << ")\n";
}