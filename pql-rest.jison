/* description: Parses a PQL DSL. */

/* lexical grammar */
%lex

%options case-insensitive

%%

\s+                                               /* skip whitespace */
SHIP                                              return 'SHIP_IDENTIFIER'
FLEET                                             return 'FLEET_IDENTIFIER'
IMO                                               return 'IMO_IDENTIFIER'
MMSI                                              return 'MMSI_IDENTIFIER'
STARTS\sWITH                                      return 'OPERATOR_STARTS_WIDTH'
IS                                                return 'OPERATOR_EXACT'
GREATER\sTHEN                                     return 'OPERATOR_GT'
LESSER\sTHEN                                      return 'OPERATOR_LT'
AND                                               return 'LOGICAL_AND'
[0-9]+(\.[0-9]+)?                                 return 'NUMERIC'
['](\\.|[^'])*[']                                 return 'STRING'
<<EOF>>                                           return 'EOF'
.                                                 return 'INVALID'

/lex

%start query

%% /* language grammar */

query
    : q EOF
        { return $1; }
    ;

q
  : condition { $$ = $1; }
  | q connector condition { $$ = $1 + $2 + $3; }
  ;

connector
  : LOGICAL_AND { $$ = '&'; }
  ;

condition
  : SHIP_IDENTIFIER stringComparison stringValue { $$ = $1.toLowerCase() + '__ship_name' + $2 + '=' + $3; }
  | FLEET_IDENTIFIER stringComparison stringValue { $$ = $1.toLowerCase() + '__name' + $2 + '=' + $3; }
  | IMO_IDENTIFIER numberComparison numberValue { $$ = 'ship__' + $1.toLowerCase() + '_number' + $2 + '=' + $3; }
  | MMSI_IDENTIFIER numberComparison numberValue { $$ = 'ship__' + $1.toLowerCase() + $2 + '=' + $3; }
  ;

stringComparison
  : OPERATOR_STARTS_WIDTH { $$ = '__istartswidth'; }
  | OPERATOR_EXACT { $$ = '__iexact'; }
  ;

stringValue
  : STRING { $$ = encodeURIComponent(yytext.substr(1, yytext.length - 2)) }
  ;

numberComparison
  : OPERATOR_GT { $$ = '__gt'; }
  | OPERATOR_LT { $$ = '__lt'; }
  | OPERATOR_EXACT { $$ = '__iexact'; }
  ;

numberValue
  : NUMERIC { $$ = Number(yytext) }
  ;
