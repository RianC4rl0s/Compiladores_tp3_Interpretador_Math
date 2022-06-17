%{ 
/* analisador léxico para uma calculadora */
/* com suporte a definição de variáveis */
#include "parser.h"
%}

%option yylineno
%option noyywrap

digito	[0-9]
letra_	[a-zA-ZáàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ_]
pontdig {digito}*"."?{digito}+
digpont {digito}+"."
oper    if|print|sqrt|pow 
numero  {pontdig}|{digpont}
id		{letra_}({letra_}|{digito})*
text    \"[a-zA-z0-9,.\\\/ ]*\"
%%

[\t ]+		{ ; /* ignora espaço em branco */ }
{numero}    { yylval.num = atof(yytext); return NUM; }
{oper}      {  if (strcmp(yytext, "if") == 0) { /*retorna funcoes de acordo com o if*/
                    return IF;
                } else if (strcmp(yytext, "print") == 0) {
                    return PRINT;
                } else if (strcmp(yytext, "sqrt") == 0) {
                    return SQRT;
                } else if (strcmp(yytext, "pow") == 0) {
                    return POW;
                } 
            }
{id}		{ strcpy(yylval.id, yytext); return ID; }
{text}      { strcpy(yylval.text, yytext); return TEXT; }
"=="        { return EQUALS; /*retorna operadores*/}
"!="        { return DIFFERENT; }
"<="        { return LEQUALS; }
">="        { return MEQUALS; }
"<"         { return LESS; }
">"         { return MORE; }
<<EOF>>     {return yytext[0];}
.|\n		{ return yytext[0]; }

%%
