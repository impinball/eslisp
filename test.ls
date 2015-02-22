#!/usr/bin/env lsc
test = (name, test-func) ->
  (require \tape) name, (t) ->
    test-func.call t  # Make `this` refer to tape's asserts
    t.end!            # Automatically end tests

esl = require \./index.ls

test "plain literal" ->
  esl "3"
    ..`@equals` "3;"

test "n-ary plus" ->
  esl "(+ 3 4 5)"
    ..`@equals` "3 + (4 + 5);"

test "plus nests" ->
  esl "(+ 1 (+ 2 3))"
    ..`@equals` "1 + (2 + 3);"

test "unary plus" ->
  esl "(+ 1)"
    ..`@equals` "+1;"

test "unary minus" ->
  esl "(- 1)"
    ..`@equals` "-1;"

test "n-ary minus" ->
  esl "(- 10 2 1)"
    ..`@equals` "10 - (2 - 1);"

test "n-ary multiplication" ->
  esl "(* 1 2 3)"
    ..`@equals` "1 * (2 * 3);"

test "unary multiplication is invalid" ->
  esl "(* 2)"
    ..`@throws` Error

test "n-ary division" ->
  esl "(/ 1 2 3)"
    ..`@equals` "1 / (2 / 3);"

test "unary division is invalid" ->
  esl "(/ 2)"
    ..`@throws` Error

test "n-ary modulus" ->
  esl "(% 1 2 3)"
    ..`@equals` "1 % (2 % 3);"

test "increment-after expression" ->
  esl "(_++ x)"
    ..`@equals` "x++;"

test "increment-before expression" ->
  esl "(++_ x) (++ x)"
    ..`@equals` "++x;\n++x;"

test "decrement-after expression" ->
  esl "(_-- x)"
    ..`@equals` "x--;"

test "decrement-before expression" ->
  esl "(--_ x) (-- x)"
    ..`@equals` "--x;\n--x;"

test "chainable logical expressions" ->
  esl "(and 1 2 3) (or 1 2 3)"
    ..`@equals` "1 && (2 && 3);\n1 || (2 || 3);"

test "unary logical not" ->
  esl "(not 1)"
    ..`@equals` "!1;"

test "unary delete" ->
  esl "(delete x)"
    ..`@equals` "delete x;"

test "unary delete" ->
  esl "(typeof x)"
    ..`@equals` "typeof x;"

test "unary void" ->
  esl "(void x)"
    ..`@equals` "void x;"

test "chainable instanceof" -> # yes, making that chain is maybe odd
  esl "(instanceof x y z)"
    ..`@equals` "x instanceof (y instanceof z);"

test "chainable in" ->
  esl "(in x y z)"
    ..`@equals` "x in (y in z);"

test "bitwise &, |, ^ are chainable" ->
  esl "(& 1 2 3) (| 1 2 3) (^ 1 2 3)"
    ..`@equals` "1 & (2 & 3);\n1 | (2 | 3);\n1 ^ (2 ^ 3);"

test "bitwise shifts are chainable" ->
  esl "(<< 1 2 3) (>> 1 2 3) (>>> 1 2 3)"
    ..`@equals` "1 << (2 << 3);\n1 >> (2 >> 3);\n1 >>> (2 >>> 3);"

test "unary bitwise not" ->
  esl "(~ x)"
    ..`@equals` "~x;"

test "equals expression, chainable" ->
  esl "(== x y z)"
    ..`@equals` "x == (y == z);"
test "disequals expression, chainable" ->
  esl "(!= x y z)"
    ..`@equals` "x != (y != z);"
test "strong-equals expression, chainable" ->
  esl "(=== x y z)"
    ..`@equals` "x === (y === z);"
test "strong-disequals expression, chainable" ->
  esl "(!== x y z)"
    ..`@equals` "x !== (y !== z);"

test "comparison expressions, chainable" -> # >, <= and >= are same code path
  esl "(< x y z)"
    ..`@equals` "x < (y < z);"

test "func expression" ->
  esl "(lambda (x) (+ x 1))"
    ..`@equals` "(function (x) {\n    return x + 1;\n});"

test "assignment expression" -> # += and whatever are same code path
  esl "(:= f (lambda (x) (+ x 1)))"
    ..`@equals` "f = function (x) {\n    return x + 1;\n};"

test "variable declaration statement" ->
  esl "(= f (lambda (x) (+ x 1)))"
    ..`@equals` "var f = function (x) {\n    return x + 1;\n};"

test "empty statement" ->
  esl "()"
    ..`@equals` ";"

test "break and continue statements" ->
  esl "(break) (continue)"
    ..`@equals` "break;\ncontinue;"

test "return statement" ->
  esl "(return \"hello there\")"
    ..`@equals` "return 'hello there';"

test "member expression" ->
  esl "(. console log)"
    ..`@equals` "console.log;"

test "call expression" ->
  esl "(f)"
    ..`@equals` "f();"

test "member, then call with arguments" ->
  esl '((. console log) "hi")'
    ..`@equals` "console.log('hi');"

test "func with member and call in it" ->
  esl "(lambda (x) ((. console log) x))"
    ..`@equals` "(function (x) {\n    return console.log(x);\n});"

test "if statement" ->
  esl '(if (+ 1 0) ((. console log) "yes") ((. console error) "no"))'
    ..`@equals` "if (1 + 0)\n    console.log(\'yes\');\nelse\n    console.error(\'no\');"

test "ternary expression" ->
  esl '(?: "something" 0 1)'
    ..`@equals` "'something' ? 0 : 1;"

test "multiple statements in program" ->
  esl '((. console log) "hello") ((. console log) "world")'
    ..`@equals` "console.log('hello');\nconsole.log('world');"

test "multiple statements in function" ->
  esl '(lambda (x) ((. console log) "hello") \
                   ((. console log) "world"))'
    ..`@equals` "(function (x) {\n    console.log(\'hello\');\n    return console.log(\'world\');\n});"

test "quoting a list produces array" ->
  esl "'(1 2 3)"
    ..`@equals` "[\n    1,\n    2,\n    3\n];"

test "quoting numbers produces numbers" ->
  esl "'(1)"
    ..`@equals` "[1];"

test "quoting strings produces strings" ->
  esl "'(\"hi\")"
    ..`@equals` "['hi'];"

test "quoting atoms produces an object representing it" ->
  esl "'(fun)"
    ..`@equals` "[{\n        \'type\': \'atom\',\n        \'text\': \'fun\'\n    }];"

test "simple quoting macro" ->
  esl "(macro random () '((. Math random)))
       (+ (random) (random))"
    ..`@equals` "Math.random() + Math.random();"

test "simple non-quoting macro" ->
  esl "(macro three () (+ 1 2))
       (three)"
    ..`@equals` "3;"

test "empty macro" ->
  esl "(macro nothing () `())
       (nothing)"
    ..`@equals` ";"

test "null-returning macro" ->
  esl "(macro nothing () undefined)
       (nothing)"
    ..`@equals` ""

test "macros mask others defined before with the same name" ->
  esl "(macro m () ())
       (macro m () '((. console log) \"hi\"))
       (m)"
    ..`@equals` "console.log('hi');"

test "macros can be defined inside function bodies" ->
  esl "(= f (lambda (x)
         (macro x () 5)
         (return (x))))"
    ..`@equals` "var f = function (x) {\n    return 5;\n};"

test "macros go out of scope at the end of the nesting level" ->
  esl "(= f (lambda (x)
         (macro x () 5)
         (return (x))))
       (x)"
    ..`@equals` "var f = function (x) {\n    return 5;\n};\nx();"

test "dead simple quasiquote" ->
  esl "(macro q () `(+ 2 3))
       (q)"
    ..`@equals` "2 + 3;"

test "quasiquote is like quote if no unquotes contained" ->
  esl "(macro rand ()
                  `(* 5
                      ((. Math random))))
       (rand)"
    ..`@equals` "5 * Math.random();"

test "macros can quasiquote to unquote arguments into output" ->
  esl "(macro rand (upper)
                  `(* ,upper
                      ((. Math random))))
       (rand 5)"
    ..`@equals` "5 * Math.random();"

test "macros can unquote modified arguments too" ->
  esl "(macro rand (upper)
                  (= x (* 2
                          (evaluate upper)))
                  `(* ,x
                      ((. Math random))))
       (rand 5)"
    ..`@equals` "10 * Math.random();"


test "macros can evaluate arguments and operate on them further" ->
  esl "(macro increment (x)
                  (+ 1 (evaluate x)))
       (increment 1)"
    ..`@equals` "2;"

test "macros can splice arrays into quasiquoted lists" ->
  esl "(macro sum (xs)
        `(+ ,@xs))
       (sum (1 2 3))"
    ..`@equals` "1 + (2 + 3);"
