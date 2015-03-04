/* description: Parses a PQL DSL. */

/* lexical grammar */
%lex

%options case-insensitive

%%

\s+                                               /* skip whitespace */
SHIP|FLEET                                        return 'STRING_IDENTIFIER'
IMO|MMSI                                          return 'NUMBER_IDENTIFIER'
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
  : condition { $$ = [$1]; }
  | q connector condition  { $$ = $1; $3.connector=$2; $1.push($3); }
  ;

connector
  : LOGICAL_AND { $$ = '&'; }
  ;

condition
  : STRING_IDENTIFIER stringComparison value { $$ = {field: $1, comparison: $2, value: $3}; }
  | NUMBER_IDENTIFIER numberComparison value { $$ = {field: $1, comparison: $2, value: $3}; }
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
