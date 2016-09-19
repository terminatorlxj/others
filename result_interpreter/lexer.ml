# 1 "lexer.mll"
 
	open Parser
	let line_num = ref 0

# 7 "lexer.ml"
let __ocaml_lex_tables = {
  Lexing.lex_base = 
   "\000\000\243\255\244\255\245\255\246\255\010\000\248\255\249\255\
    \250\255\001\000\000\000\002\000\003\000\000\000\000\000\004\000\
    \000\000\001\000\001\000\000\000\000\000\001\000\006\000\003\000\
    \001\000\007\000\002\000\011\000\006\000\007\000\009\000\023\000\
    \025\000\255\255\012\000\018\000\023\000\019\000\001\000\014\000\
    \030\000\032\000\254\255\019\000\025\000\030\000\026\000\040\000\
    \022\000\038\000\040\000\002\000\043\000\021\000\003\000\046\000\
    \004\000\029\000\040\000\043\000\037\000\051\000\041\000\253\255\
    \034\000\054\000\044\000\005\000\052\000\040\000\041\000\045\000\
    \043\000\010\000\252\255\061\000\051\000\251\255\151\000\247\255\
    \248\255\249\255\250\255\061\000\066\000\064\000\065\000\047\000\
    \069\000\068\000\058\000\055\000\067\000\062\000\064\000\006\000\
    \074\000\066\000\078\000\067\000\062\000\070\000\065\000\081\000\
    \070\000\084\000\086\000\255\255\073\000\079\000\084\000\080\000\
    \094\000\076\000\092\000\094\000\254\255\081\000\087\000\092\000\
    \088\000\102\000\084\000\100\000\102\000\007\000\105\000\083\000\
    \008\000\108\000\009\000\091\000\102\000\105\000\099\000\113\000\
    \103\000\253\255\096\000\116\000\106\000\010\000\114\000\102\000\
    \103\000\107\000\105\000\011\000\252\255\123\000\114\000\251\255\
    ";
  Lexing.lex_backtrk = 
   "\255\255\255\255\255\255\255\255\255\255\008\000\255\255\255\255\
    \255\255\012\000\012\000\012\000\012\000\012\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\008\000\008\000\008\000\008\000\008\000\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    ";
  Lexing.lex_default = 
   "\001\000\000\000\000\000\000\000\000\000\255\255\000\000\000\000\
    \000\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\000\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\000\000\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\000\000\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\000\000\255\255\255\255\000\000\079\000\000\000\
    \000\000\000\000\000\000\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\000\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\000\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\000\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\000\000\255\255\255\255\000\000\
    ";
  Lexing.lex_trans = 
   "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\003\000\004\000\000\000\000\000\003\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \003\000\022\000\052\000\055\000\057\000\068\000\096\000\126\000\
    \129\000\131\000\142\000\000\000\000\000\000\000\006\000\000\000\
    \005\000\005\000\005\000\005\000\005\000\005\000\005\000\005\000\
    \005\000\005\000\005\000\005\000\005\000\005\000\005\000\005\000\
    \005\000\005\000\005\000\005\000\074\000\148\000\010\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\012\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\064\000\039\000\015\000\025\000\013\000\075\000\043\000\
    \034\000\016\000\019\000\023\000\030\000\008\000\021\000\020\000\
    \017\000\024\000\009\000\007\000\011\000\018\000\026\000\027\000\
    \014\000\028\000\029\000\031\000\032\000\033\000\035\000\036\000\
    \037\000\038\000\040\000\041\000\042\000\044\000\045\000\046\000\
    \047\000\048\000\049\000\050\000\051\000\053\000\054\000\056\000\
    \058\000\059\000\060\000\061\000\062\000\063\000\065\000\066\000\
    \067\000\069\000\070\000\071\000\072\000\073\000\076\000\077\000\
    \081\000\082\000\149\000\138\000\081\000\117\000\108\000\088\000\
    \089\000\090\000\091\000\092\000\093\000\094\000\095\000\097\000\
    \098\000\099\000\100\000\101\000\102\000\103\000\104\000\081\000\
    \105\000\106\000\107\000\109\000\110\000\111\000\112\000\113\000\
    \114\000\115\000\116\000\118\000\119\000\120\000\121\000\122\000\
    \123\000\124\000\125\000\127\000\128\000\130\000\132\000\133\000\
    \134\000\135\000\136\000\137\000\139\000\140\000\141\000\143\000\
    \144\000\145\000\146\000\147\000\150\000\084\000\151\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\086\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\087\000\000\000\000\000\000\000\
    \002\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\083\000\000\000\085\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\080\000\
    ";
  Lexing.lex_check = 
   "\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\000\000\000\000\255\255\255\255\000\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\021\000\051\000\054\000\056\000\067\000\095\000\125\000\
    \128\000\130\000\141\000\255\255\255\255\255\255\000\000\255\255\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\005\000\005\000\005\000\005\000\005\000\005\000\
    \005\000\005\000\005\000\005\000\073\000\147\000\000\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\000\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\010\000\038\000\014\000\024\000\000\000\009\000\011\000\
    \012\000\015\000\018\000\022\000\029\000\000\000\020\000\019\000\
    \016\000\023\000\000\000\000\000\000\000\017\000\025\000\026\000\
    \013\000\027\000\028\000\030\000\031\000\032\000\034\000\035\000\
    \036\000\037\000\039\000\040\000\041\000\043\000\044\000\045\000\
    \046\000\047\000\048\000\049\000\050\000\052\000\053\000\055\000\
    \057\000\058\000\059\000\060\000\061\000\062\000\064\000\065\000\
    \066\000\068\000\069\000\070\000\071\000\072\000\075\000\076\000\
    \078\000\078\000\083\000\084\000\078\000\085\000\086\000\087\000\
    \088\000\089\000\090\000\091\000\092\000\093\000\094\000\096\000\
    \097\000\098\000\099\000\100\000\101\000\102\000\103\000\078\000\
    \104\000\105\000\106\000\108\000\109\000\110\000\111\000\112\000\
    \113\000\114\000\115\000\117\000\118\000\119\000\120\000\121\000\
    \122\000\123\000\124\000\126\000\127\000\129\000\131\000\132\000\
    \133\000\134\000\135\000\136\000\138\000\139\000\140\000\142\000\
    \143\000\144\000\145\000\146\000\149\000\078\000\150\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\078\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\078\000\255\255\255\255\255\255\
    \000\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\078\000\255\255\078\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\078\000\
    ";
  Lexing.lex_base_code = 
   "";
  Lexing.lex_backtrk_code = 
   "";
  Lexing.lex_default_code = 
   "";
  Lexing.lex_trans_code = 
   "";
  Lexing.lex_check_code = 
   "";
  Lexing.lex_code = 
   "";
}

let rec token lexbuf =
    __ocaml_lex_token_rec lexbuf 0
and __ocaml_lex_token_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 10 "lexer.mll"
                           (FATAL_ERROR)
# 199 "lexer.ml"

  | 1 ->
# 11 "lexer.mll"
                (FATAL_ERROR)
# 204 "lexer.ml"

  | 2 ->
# 12 "lexer.mll"
                            (FATAL_ERROR)
# 209 "lexer.ml"

  | 3 ->
# 13 "lexer.mll"
                  (FATAL_ERROR)
# 214 "lexer.ml"

  | 4 ->
# 14 "lexer.mll"
          (token lexbuf)
# 219 "lexer.ml"

  | 5 ->
# 15 "lexer.mll"
         (M)
# 224 "lexer.ml"

  | 6 ->
# 16 "lexer.mll"
        (S)
# 229 "lexer.ml"

  | 7 ->
# 17 "lexer.mll"
        (DOT)
# 234 "lexer.ml"

  | 8 ->
let
# 18 "lexer.mll"
              s
# 240 "lexer.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 18 "lexer.mll"
                (I (int_of_string s))
# 244 "lexer.ml"

  | 9 ->
# 19 "lexer.mll"
         (line_num := (!line_num) + 1; dummy lexbuf)
# 249 "lexer.ml"

  | 10 ->
# 20 "lexer.mll"
                   (token lexbuf)
# 254 "lexer.ml"

  | 11 ->
# 21 "lexer.mll"
        (File_end)
# 259 "lexer.ml"

  | 12 ->
# 22 "lexer.mll"
      (dummy lexbuf)
# 264 "lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; __ocaml_lex_token_rec lexbuf __ocaml_lex_state

and dummy lexbuf =
    __ocaml_lex_dummy_rec lexbuf 78
and __ocaml_lex_dummy_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 24 "lexer.mll"
                           (FATAL_ERROR)
# 275 "lexer.ml"

  | 1 ->
# 25 "lexer.mll"
                (FATAL_ERROR)
# 280 "lexer.ml"

  | 2 ->
# 26 "lexer.mll"
                            (FATAL_ERROR)
# 285 "lexer.ml"

  | 3 ->
# 27 "lexer.mll"
                  (FATAL_ERROR)
# 290 "lexer.ml"

  | 4 ->
# 28 "lexer.mll"
          (token lexbuf)
# 295 "lexer.ml"

  | 5 ->
# 29 "lexer.mll"
         (line_num := (!line_num) + 1; dummy lexbuf)
# 300 "lexer.ml"

  | 6 ->
# 30 "lexer.mll"
                   (dummy lexbuf)
# 305 "lexer.ml"

  | 7 ->
# 31 "lexer.mll"
        (File_end)
# 310 "lexer.ml"

  | 8 ->
# 32 "lexer.mll"
      (dummy lexbuf)
# 315 "lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; __ocaml_lex_dummy_rec lexbuf __ocaml_lex_state

;;

