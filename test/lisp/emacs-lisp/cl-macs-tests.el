;;; cl-macs-tests.el --- tests for emacs-lisp/cl-macs.el  -*- lexical-binding:t -*-

;; Copyright (C) 2017-2020 Free Software Foundation, Inc.

;; This file is part of GNU Emacs.

;; This program is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see `https://www.gnu.org/licenses/'.

;;; Commentary:

;;; Code:

(require 'cl-lib)
(require 'cl-macs)
(require 'ert)


;;;; cl-loop tests -- many adapted from Steele's CLtL2

;;; ANSI 6.1.1.7 Destructuring
(ert-deftest cl-macs-loop-and-assignment ()
  "Bug#6583"
  :expected-result :failed
  (should (equal (cl-loop for numlist in '((1 2 4.0) (5 6 8.3) (8 9 10.4))
                          for a = (cl-first numlist)
                          and b = (cl-second numlist)
                          and c = (cl-third numlist)
                          collect (list c b a))
                 '((4.0 2 1) (8.3 6 5) (10.4 9 8)))))

(ert-deftest cl-macs-loop-and-arrays ()
  "Bug#40727"
  (should (equal (cl-loop for y = (- (or x 0)) and x across [1 2]
                          collect (cons x y))
                 '((1 . 0) (2 . -1))))
  (should (equal (cl-loop for x across [1 2] and y = (- (or x 0))
                          collect (cons x y))
                 '((1 . 0) (2 . -1)))))

(ert-deftest cl-macs-loop-destructure ()
  (should (equal (cl-loop for (a b c) in '((1 2 4.0) (5 6 8.3) (8 9 10.4))
                          collect (list c b a))
                 '((4.0 2 1) (8.3 6 5) (10.4 9 8)))))

(ert-deftest cl-macs-loop-destructure-nil ()
  (should (equal (cl-loop for (a nil b) = '(1 2 3)
                          do (cl-return (list a b)))
                 '(1 3))))

(ert-deftest cl-macs-loop-destructure-cons ()
  (should (equal (cl-loop for ((a . b) (c . d)) in
                          '(((1.2 . 2.4) (3 . 4)) ((3.4 . 4.6) (5 . 6)))
                          collect (list a b c d))
                 '((1.2 2.4 3 4) (3.4 4.6 5 6)))))

(ert-deftest cl-loop-destructuring-with ()
  (should (equal (cl-loop with (a b c) = '(1 2 3) return (+ a b c)) 6)))

;;; 6.1.2.1.1 The for-as-arithmetic subclause
(ert-deftest cl-macs-loop-for-as-arith ()
  "Test various for-as-arithmetic subclauses."
  (should (equal (cl-loop for i to 10 by 3 collect i)
                 '(0 3 6 9)))
  (should (equal (cl-loop for i upto 3 collect i)
                 '(0 1 2 3)))
  (should (equal (cl-loop for i below 3 collect i)
                 '(0 1 2)))
  (should (equal (cl-loop for i below 10 by 2 collect i)
                 '(0 2 4 6 8)))
  (should (equal (cl-loop for i downfrom 10 above 4 by 2 collect i)
                 '(10 8 6)))
  (should (equal (cl-loop for i from 10 downto 1 by 3 collect i)
                 '(10 7 4 1)))
  (should (equal (cl-loop for i downfrom 10 above 0 by 2 collect i)
                 '(10 8 6 4 2)))
  (should (equal (cl-loop for i from 15 downto 10 collect i)
                 '(15 14 13 12 11 10))))

(ert-deftest cl-macs-loop-for-as-arith-order-side-effects ()
  "Test side effects generated by different arithmetic phrase order."
  :expected-result :failed
  (should
   (equal (let ((x 1)) (cl-loop for i from x to 10 by (cl-incf x) collect i))
          '(1 3 5 7 9)))
  (should
   (equal (let ((x 1)) (cl-loop for i from x by (cl-incf x) to 10 collect i))
          '(1 3 5 7 9)))
  (should
   (equal (let ((x 1)) (cl-loop for i to 10 from x by (cl-incf x) collect i))
          '(1 3 5 7 9)))
  (should
   (equal (let ((x 1)) (cl-loop for i to 10 by (cl-incf x) from x collect i))
          '(2 4 6 8 10)))
  (should
   (equal (let ((x 1)) (cl-loop for i by (cl-incf x) from x to 10 collect i))
          '(2 4 6 8 10)))
  (should
   (equal (let ((x 1)) (cl-loop for i by (cl-incf x) to 10 from x collect i))
          '(2 4 6 8 10))))

(ert-deftest cl-macs-loop-for-as-arith-invalid ()
  "Test for invalid phrase combinations."
  :expected-result :failed
  ;; Mixing arithmetic-up and arithmetic-down* subclauses
  (should-error (cl-loop for i downfrom 10 below 20 collect i))
  (should-error (cl-loop for i upfrom 20 above 10 collect i))
  (should-error (cl-loop for i upto 10 by 2 downfrom 5))
  ;; Repeated phrases
  (should-error (cl-loop for i from 10 to 20 above 10))
  (should-error (cl-loop for i from 10 to 20 upfrom 0))
  (should-error (cl-loop for i by 2 to 10 by 5))
  ;; negative step
  (should-error (cl-loop for i by -1))
  ;; no step given for a downward loop
  (should-error (cl-loop for i downto -5 collect i)))


;;; 6.1.2.1.2 The for-as-in-list subclause
(ert-deftest cl-macs-loop-for-as-in-list ()
  (should (equal (cl-loop for x in '(1 2 3 4 5 6) collect (* x x))
                 '(1 4 9 16 25 36)))
  (should (equal (cl-loop for x in '(1 2 3 4 5 6) by #'cddr collect (* x x))
                 '(1 9 25))))

;;; 6.1.2.1.3 The for-as-on-list subclause
(ert-deftest cl-macs-loop-for-as-on-list ()
  (should (equal (cl-loop for x on '(1 2 3 4) collect x)
                 '((1 2 3 4) (2 3 4) (3 4) (4))))
  (should (equal (cl-loop as (item) on '(1 2 3 4) by #'cddr collect item)
                 '(1 3))))

;;; 6.1.2.1.4 The for-as-equals-then subclause
(ert-deftest cl-macs-loop-for-as-equals-then ()
  (should (equal (cl-loop for item = 1 then (+ item 10)
                          repeat 5
                          collect item)
                 '(1 11 21 31 41)))
  (should (equal (cl-loop for x below 5 for y = nil then x collect (list x y))
                 '((0 nil) (1 1) (2 2) (3 3) (4 4))))
  (should (equal (cl-loop for x below 5 and y = nil then x collect (list x y))
                 '((0 nil) (1 0) (2 1) (3 2) (4 3))))
  (should (equal (cl-loop for x below 3 for y = (+ 10 x) nconc (list x y))
                 '(0 10 1 11 2 12)))
  (should (equal (cl-loop with start = 5
                          for x = start then (cl-incf start)
                          repeat 5
                          collect x)
                 '(5 6 7 8 9))))

;;; 6.1.2.1.5 The for-as-across subclause
(ert-deftest cl-macs-loop-for-as-across ()
  (should (string= (cl-loop for x across "aeiou"
                            concat (char-to-string x))
                   "aeiou"))
  (should (equal (cl-loop for v across (vector 1 2 3) vconcat (vector v (+ 10 v)))
                 [1 11 2 12 3 13])))

;;; 6.1.2.1.6 The for-as-hash subclause
(ert-deftest cl-macs-loop-for-as-hash ()
  ;; example in Emacs manual 4.7.3
  (should (equal (let ((hash (make-hash-table)))
                   (setf (gethash 1 hash) 10)
                   (setf (gethash "test" hash) "string")
                   (setf (gethash 'test hash) 'value)
                   (cl-loop for k being the hash-keys of hash
                            using (hash-values v)
                            collect (list k v)))
                 '((1 10) ("test" "string") (test value)))))

;;; 6.1.2.2 Local Variable Initializations
(ert-deftest cl-macs-loop-with ()
  (should (equal (cl-loop with a = 1
                          with b = (+ a 2)
                          with c = (+ b 3)
                          return (list a b c))
                 '(1 3 6)))
  (should (equal (let ((a 5)
                       (b 10))
                   (cl-loop with a = 1
                            and b = (+ a 2)
                            and c = (+ b 3)
                            return (list a b c)))
                 '(1 7 13)))
  (should (and (equal (cl-loop for i below 3 with loop-with
                               do (push (* i i) loop-with)
                               finally (cl-return loop-with))
                      '(4 1 0))
               (not (boundp 'loop-with)))))

;;; 6.1.3 Value Accumulation Clauses
(ert-deftest cl-macs-loop-accum ()
  (should (equal (cl-loop for name in '(fred sue alice joe june)
                          for kids in '((bob ken) () () (kris sunshine) ())
                          collect name
                          append kids)
                 '(fred bob ken sue alice joe kris sunshine june))))

(ert-deftest cl-macs-loop-collect ()
  (should (equal (cl-loop for i in '(bird 3 4 turtle (1 . 4) horse cat)
                          when (symbolp i) collect i)
                 '(bird turtle horse cat)))
  (should (equal (cl-loop for i from 1 to 10
                          if (cl-oddp i) collect i)
                 '(1 3 5 7 9)))
  (should (equal (cl-loop for i in '(a b c d e f g) by #'cddr
                          collect i into my-list
                          finally return (nbutlast my-list))
                 '(a c e))))

(ert-deftest cl-macs-loop-append/nconc ()
  (should (equal (cl-loop for x in '((a) (b) ((c)))
                          append x)
                 '(a b (c))))
  (should (equal (cl-loop for i upfrom 0
                          as x in '(a b (c))
                          nconc (if (cl-evenp i) (list x) nil))
                 '(a (c)))))

(ert-deftest cl-macs-loop-count ()
  (should (eql (cl-loop for i in '(a b nil c nil d e)
                        count i)
               5)))

(ert-deftest cl-macs-loop-max/min ()
  (should (eql (cl-loop for i in '(2 1 5 3 4)
                        maximize i)
               5))
  (should (eql (cl-loop for i in '(2 1 5 3 4)
                        minimize i)
               1))
  (should (equal (cl-loop with series = '(4.3 1.2 5.7)
                          for v in series
                          minimize (round v) into min-result
                          maximize (round v) into max-result
                          collect (list min-result max-result))
                 '((4 4) (1 4) (1 6)))))

(ert-deftest cl-macs-loop-sum ()
  (should (eql (cl-loop for i in '(1 2 3 4 5)
                        sum i)
               15))
  (should (eql (cl-loop with series = '(1.2 4.3 5.7)
                        for v in series
                        sum (* 2.0 v))
               22.4)))

;;; 6.1.4 Termination Test Clauses
(ert-deftest cl-macs-loop-repeat ()
  (should (equal (cl-loop with n = 4
                          repeat (1+ n)
                          collect n)
                 '(4 4 4 4 4)))
  (should (equal (cl-loop for i upto 5
                          repeat 3
                          collect i)
                 '(0 1 2))))

(ert-deftest cl-macs-loop-always ()
  (should (cl-loop for i from 0 to 10
                   always (< i 11)))
  (should-not (cl-loop for i from 0 to 10
                       always (< i 9)
                       finally (cl-return "you won't see this"))))

(ert-deftest cl-macs-loop-never ()
  (should (cl-loop for i from 0 to 10
                   never (> i 11)))
  (should-not (cl-loop never t
                       finally (cl-return "you won't see this"))))

(ert-deftest cl-macs-loop-thereis ()
  (should (eql (cl-loop for i from 0
                        thereis (when (> i 10) i))
               11))
  (should (string= (cl-loop thereis "Here is my value"
                            finally (cl-return "you won't see this"))
                   "Here is my value"))
  (should (cl-loop for i to 10
                   thereis (> i 11)
                   finally (cl-return i))))

(ert-deftest cl-macs-loop-anon-collection-conditional ()
  "Always/never/thereis should error when used with an anonymous
collection clause."
  :expected-result :failed
  (should-error (cl-loop always nil collect t))
  (should-error (cl-loop never t nconc t))
  (should-error (cl-loop thereis t append t)))

(ert-deftest cl-macs-loop-while ()
  (should (equal (let ((stack '(a b c d e f)))
                   (cl-loop while stack
                            for item = (length stack) then (pop stack)
                            collect item))
                 '(6 a b c d e f))))

(ert-deftest cl-macs-loop-until ()
  (should (equal (cl-loop for i to 100
                          collect 10
                          until (= i 3)
                          collect i)
                 '(10 0 10 1 10 2 10))))

;;; 6.1.5 Unconditional Execution Clauses
(ert-deftest cl-macs-loop-do ()
  (should (equal (cl-loop with list
                          for i from 1 to 3
                          do
                          (push 10 list)
                          (push i list)
                          finally (cl-return list))
                 '(3 10 2 10 1 10)))
  (should (equal (cl-loop with res = 0
                          for i from 1 to 10
                          doing (cl-incf res i)
                          finally (cl-return res))
                 55))
  (should (equal (cl-loop for i from 10
                          do (when (= i 15)
                               (cl-return i))
                          finally (cl-return 0))
                 15)))

;;; 6.1.6 Conditional Execution Clauses
(ert-deftest cl-macs-loop-when ()
  (should (equal (cl-loop for i in '(1 2 3 4 5 6)
                          when (and (> i 3) i)
                            collect it)
                 '(4 5 6)))
  (should (eql (cl-loop for i in '(1 2 3 4 5 6)
                        when (and (> i 3) i)
                          return it)
               4))

  (should (equal (cl-loop for elt in '(1 a 2 "a" (3 4) 5 6)
                          when (numberp elt)
                            when (cl-evenp elt) collect elt into even
                            else collect elt into odd
                          else
                            when (symbolp elt) collect elt into syms
                            else collect elt into other
                          finally return (list even odd syms other))
                 '((2 6) (1 5) (a) ("a" (3 4))))))

(ert-deftest cl-macs-loop-if ()
  (should (equal (cl-loop for i to 5
                          if (cl-evenp i)
                            collect i
                            and when (and (= i 2) 'two)
                              collect it
                              and if (< i 3)
                                collect "low")
                 '(0 2 two "low" 4)))
  (should (equal (cl-loop for i to 5
                          if (cl-evenp i)
                            collect i
                            and when (and (= i 2) 'two)
                              collect it
                            end
                            and if (< i 3)
                              collect "low")
                 '(0 "low" 2 two "low" 4)))
  (should (equal (cl-loop with funny-numbers = '(6 13 -1)
                          for x below 10
                          if (cl-evenp x)
                            collect x into evens
                          else
                            collect x into odds
                            and if (memq x funny-numbers) return (cdr it)
                          finally return (vector odds evens))
                 [(1 3 5 7 9) (0 2 4 6 8)])))

(ert-deftest cl-macs-loop-unless ()
  (should (equal (cl-loop for i to 5
                          unless (= i 3)
                            collect i
                          else
                            collect 'three)
                 '(0 1 2 three 4 5))))


;;; 6.1.7.1 Control Transfer Clauses
(ert-deftest cl-macs-loop-named ()
  (should (eql (cl-loop named finished
                        for i to 10
                        when (> (* i i) 30)
                          do (cl-return-from finished i))
               6)))

;;; 6.1.7.2 Initial and Final Execution
(ert-deftest cl-macs-loop-initially ()
  (should (equal (let ((var (list 1 2 3 4 5)))
                   (cl-loop for i in var
                            collect i
                            initially
                              (setf (car var) 10)
                              (setf (cadr var) 20)))
                 '(10 20 3 4 5))))

(ert-deftest cl-macs-loop-finally ()
  (should (eql (cl-loop for i from 10
                        finally
                          (cl-incf i 10)
                          (cl-return i)
                        while (< i 20))
               30)))

;;; Emacs extensions to loop
(ert-deftest cl-macs-loop-in-ref ()
  (should (equal (cl-loop with my-list = (list 1 2 3 4 5)
                          for x in-ref my-list
                          do (cl-incf x)
                          finally return my-list)
                 '(2 3 4 5 6))))

(ert-deftest cl-macs-loop-across-ref ()
  (should (equal (cl-loop with my-vec = (vector (cl-copy-seq "one")
                                                (cl-copy-seq "two")
                                                (cl-copy-seq "three"))
                          for x across-ref my-vec
                          do (setf (aref x 0) (upcase (aref x 0)))
                          finally return my-vec)
                 ["One" "Two" "Three"])))

(ert-deftest cl-macs-loop-being-elements ()
  (should (equal (let ((var "StRiNG"))
                   (cl-loop for x being the elements of var
                            collect (downcase x)))
                 (string-to-list "string"))))

(ert-deftest cl-macs-loop-being-elements-of-ref ()
  (should (equal (let ((var (list 1 2 3 4 5)))
                   (cl-loop for x being the elements of-ref var
                            do (cl-incf x)
                            finally return var))
                 '(2 3 4 5 6))))

(ert-deftest cl-macs-loop-being-symbols ()
  (should (eq (cl-loop for sym being the symbols
                       when (eq sym 'cl-loop)
                         return 'cl-loop)
              'cl-loop)))

(ert-deftest cl-macs-loop-being-keymap ()
  (should (equal (let ((map (make-sparse-keymap))
                       (parent (make-sparse-keymap))
                       res)
                   (define-key map    "f" #'forward-char)
                   (define-key map    "b" #'backward-char)
                   (define-key parent "n" #'next-line)
                   (define-key parent "p" #'previous-line)
                   (set-keymap-parent map parent)
                   (cl-loop for b being the key-bindings of map
                            using (key-codes c)
                            do (push (list c b) res))
                   (cl-loop for s being the key-seqs of map
                            using (key-bindings b)
                            do (push (list (cl-copy-seq s) b) res))
                   res)
                 '(([?n] next-line)    ([?p] previous-line)
                   ([?f] forward-char) ([?b] backward-char)
                   (?n next-line)      (?p previous-line)
                   (?f forward-char)   (?b backward-char)))))

(ert-deftest cl-macs-loop-being-overlays ()
  (should (equal (let ((ov (make-overlay (point) (point))))
                   (overlay-put ov 'prop "test")
                   (cl-loop for o being the overlays
                            when (eq o ov)
                              return (overlay-get o 'prop)))
                 "test")))

(ert-deftest cl-macs-loop-being-frames ()
  (should (eq (cl-loop with selected = (selected-frame)
                       for frame being the frames
                       when (eq frame selected)
                         return frame)
              (selected-frame))))

(ert-deftest cl-macs-loop-being-windows ()
  (should (eq (cl-loop with selected = (selected-window)
                       for window being the windows
                       when (eq window selected)
                         return window)
              (selected-window))))

(ert-deftest cl-macs-loop-being-buffers ()
  (should (eq (cl-loop with current = (current-buffer)
                       for buffer being the buffers
                       when (eq buffer current)
                         return buffer)
              (current-buffer))))

(ert-deftest cl-macs-loop-vconcat ()
  (should (equal (cl-loop for x in (list 1 2 3 4 5)
                          vconcat (vector (1+ x)))
                 [2 3 4 5 6])))

(ert-deftest cl-macs-loop-for-as-equals-and ()
  "Test for https://debbugs.gnu.org/29799 ."
  (let ((arr (make-vector 3 0)))
    (should (equal '((0 0) (1 1) (2 2))
                   (cl-loop for k below 3 for x = k and z = (elt arr k)
                            collect (list k x))))))


(ert-deftest cl-defstruct/builtin-type ()
  (should-error
   (macroexpand '(cl-defstruct hash-table))
   :type 'wrong-type-argument)
  (should-error
   (macroexpand '(cl-defstruct (hash-table (:predicate hash-table-p))))
   :type 'wrong-type-argument))

(ert-deftest cl-macs-test--symbol-macrolet ()
  ;; A `setq' shouldn't be converted to a `setf' just because it occurs within
  ;; a symbol-macrolet!
  (should-error
   ;; Use `eval' so the error is signaled when running the test rather than
   ;; when macroexpanding it.
   (eval '(let ((l (list 1))) (cl-symbol-macrolet ((x 1)) (setq (car l) 0)))))
  ;; Make sure `gv-synthetic-place' isn't macro-expanded before `setf' gets to
  ;; see its `gv-expander'.
  (should (equal (let ((l '(0)))
                   (let ((cl (car l)))
                     (cl-symbol-macrolet
                         ((p (gv-synthetic-place cl (lambda (v) `(setcar l ,v)))))
                       (cl-incf p)))
                   l)
                 '(1))))

(ert-deftest cl-macs-loop-conditional-step-clauses ()
  "These tests failed under the initial fixes in #bug#29799."
  (should (cl-loop for i from 1 upto 100 and j = 1 then (1+ j)
                   if (not (= i j))
                   return nil
                   end
                   until (> j 10)
                   finally return t))

  (should (equal (let* ((size 7)
                        (arr (make-vector size 0)))
                   (cl-loop for k below size
                            for x = (* 2 k) and y = (1+ (elt arr k))
                            collect (list k x y)))
                 '((0 0 1) (1 2 1) (2 4 1) (3 6 1) (4 8 1) (5 10 1) (6 12 1))))

  (should (equal (cl-loop for x below 3
                          for y below 2 and z = 1
                          collect x)
                 '(0 1)))

  (should (equal (cl-loop for x below 3
                          and y below 2
                          collect x)
                 '(0 1)))

  ;; this is actually disallowed in clisp, but is semantically consistent
  (should (equal (cl-loop with result
                          for x below 3
                          for y = (progn (push x result) x) and z = 1
                          append (list x y) into result1
                          finally return (append result result1))
                 '(2 1 0 0 0 1 1 2 2)))

  (should (equal (cl-loop with result
                          for x below 3
                          for _y = (progn (push x result))
                          finally return result)
                 '(2 1 0)))

  ;; this unintuitive result is replicated by clisp
  (should (equal (cl-loop with result
                          for x below 3
                          and y = (progn (push x result))
                          finally return result)
                 '(2 1 0 0)))

  ;; this unintuitive result is replicated by clisp
  (should (equal (cl-loop with result
                          for x below 3
                          and y = (progn (push x result)) then (progn (push (1+ x) result))
                          finally return result)
                 '(3 2 1 0)))

  (should (cl-loop with result
                   for x below 3
                   for y = (progn (push x result) x) then (progn (push (1+ x) result) (1+ x))
                   and z = 1
                   collect y into result1
                   finally return  (equal (nreverse result) result1))))

;;; cl-macs-tests.el ends here
