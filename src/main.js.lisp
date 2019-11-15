(in-package :mysite.js)


; Demos how you can use common lisp libraries (arrow-macros) with parenscript
(progn
  ((parenscript:@ console log) "hello")
  ((parenscript:@ console log) (arrow-macros:-> 1 (+ 2 3))))
