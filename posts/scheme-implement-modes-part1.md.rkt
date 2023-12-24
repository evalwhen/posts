#lang punct "../common.rkt"

---
title: Scheme implement models part1
date: 2023-12-24T00:00:00+00:00
---


这是 scheme 实现模型的第一篇，目标是 heap-based model。
在这篇介绍中，第一部分是对实现代码的解读，将会依照代码 case by case
的介绍。过程中，有些有趣的 scheme 只做简单介绍，避免偏离主要目标。
第二部分是挑选一些具有代表性的代码实际运行 heap-based model。
第三部分会提出该模型的改进点，待下一篇博客的 stack-based model
解决。

# 编译器


```scheme
(define compile 
  (lambda (x e next)
    (cond
      [(symbol? x)
       (list 'refer (compile-lookup x e) next)]
      [(pair? x)
       (record-case x
         [quote (obj)
          (list 'constant obj next)]
         [lambda (vars body)
          (list 'close (compile body (extend e vars) '(return)) next)]
         [if (test then else)
          (let ([thenc (compile then e next)]
                [elsec (compile else e next)])
            (compile test e (list 'test thenc elsec)))]
         [set! (var x)
          (let ([access (compile-lookup var e)])
            (compile x e (list 'assign access next)))]
         [call/cc (x)
          (let ([c (list 'conti
                         (list 'argument
                               (compile x e '(apply))))])
            (if (tail? next)
                c
                (list 'frame next c)))]
         [else
          (let loop ([args (cdr x)]
                     [c (compile (car x) e '(apply))])
            (if (null? args)
                (if (tail? next)
                    c
                    (list 'frame next c))
                (loop (cdr args)
                      (compile (car args) e
                               (list 'argument c)))))])]
      [else
       (list 'constant x next)])))
  
(define extend 
  (lambda (e r)
    (cons r e)))

(define compile-lookup 
  (lambda (var e)
    (let nxtrib ([e e] [rib 0])
      (let nxtelt ([vars (car e)] [elt 0])
        (cond
          [(null? vars) (nxtrib (cdr e) (+ rib 1))]
          [(eq? (car vars) var) (cons rib elt)]
          [else (nxtelt (cdr vars) (+ elt 1))])))))
 
```
# 虚拟机

```racket
(define VM 
  (lambda (a x e r s)
    (record-case x
      [halt () a]
      [refer (var x)
       (VM (mcar (lookup var e)) x e r s)]
      [constant (obj x)
       (VM obj x e r s)]
      [close (body x)
       (VM (closure body e) x e r s)]
      [test (then else)
       (VM a (if a then else) e r s)]
      [assign (var x)
       (set-mcar! (lookup var e) a)
       (VM a x e r s)]
      [conti (x)
       (VM (continuation s) x e r s)]
      [nuate (s var)
       (VM (car (lookup var e)) '(return) e r s)]
      [frame (ret x)
       (VM a x e '() (call-frame ret e r s))]
      [argument (x)
       (VM a x e (mcons a r) s)]
      [apply ()
       (record a (body e)
        (VM a body (extend e r) '() s))]
      [return ()
       (record s (x e r s)
        (VM a x e r s))])))
```
