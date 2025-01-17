(module generic-interfaces "pre-base.rkt"

  ;; Defines (forgeries of) generic interfaces that correspond to struct
  ;; properties that come from racket/base.
  ;; Since racket/base can't depend on racket/generics, we can't use
  ;; `define-generics' to build these generic interfaces. Thus we must
  ;; forge them.

  (#%require (for-syntax '#%kernel) "generic-methods.rkt")

  (#%provide gen:equal+hash gen:equal-mode+hash gen:custom-write)

  (define-values (prop:gen:equal+hash equal+hash? gen:equal+hash-acc)
    (make-struct-type-property
     'prop:gen:equal+hash
     (lambda (v si)
       (if (and (vector? v)
                (= 3 (vector-length v))
                (procedure? (vector-ref v 0))
                (procedure-arity-includes? (vector-ref v 0) 3)
                (procedure? (vector-ref v 1))
                (procedure-arity-includes? (vector-ref v 1) 2)
                (procedure? (vector-ref v 2))
                (procedure-arity-includes? (vector-ref v 2) 2))
           v
           (raise-argument-error 'guard-for-prop:gen:equal+hash
                                 (string-append
                                  "(vector/c (procedure-arity-includes/c 3)\n"
                                  "          (procedure-arity-includes/c 2)\n"
                                  "          (procedure-arity-includes/c 2))")
                                 v)))
     (list (cons prop:equal+hash vector->list))))

  ;; forgeries of generic functions that don't exist
  (define (equal-proc-impl a b e) (equal? a b))
  (define (hash-proc-impl x h)  (equal-hash-code x))
  (define (hash2-proc-impl x h) (equal-secondary-hash-code x))

  (define-syntax gen:equal+hash
    (make-generic-info (quote-syntax gen:equal+hash)
                       (quote-syntax prop:gen:equal+hash)
                       (quote-syntax equal+hash?)
                       (quote-syntax gen:equal+hash-acc)
                       ;; Unbound identifiers will be `free-identifier=?` to unbound in clients:
                       (list (quote-syntax equal-proc)
                             (quote-syntax hash-proc)
                             (quote-syntax hash2-proc))
                       ;; Bound identifiers used for implementations:
                       (list (quote-syntax equal-proc-impl)
                             (quote-syntax hash-proc-impl)
                             (quote-syntax hash2-proc-impl))))

  (define-values (prop:gen:equal-mode+hash equal-mode+hash? gen:equal-mode+hash-acc)
    (make-struct-type-property
     'prop:gen:equal-mode+hash
     (lambda (v si)
       (if (and (vector? v)
                (= 2 (vector-length v))
                (procedure? (vector-ref v 0))
                (procedure-arity-includes? (vector-ref v 0) 4)
                (procedure? (vector-ref v 1))
                (procedure-arity-includes? (vector-ref v 1) 3))
           v
           (raise-argument-error 'guard-for-prop:gen:equal-mode+hash
                                 (string-append
                                  "(vector/c (procedure-arity-includes/c 4)\n"
                                  "          (procedure-arity-includes/c 3))")
                                 v)))
     (list (cons prop:equal+hash vector->list))))

  ;; forgeries of generic functions that don't exist
  (define (equal-mode-proc-impl a b e m)
    (if m (equal? a b) (equal-always? a b)))
  (define (hash-mode-proc-impl x h m)
    (if m (equal-hash-code x) (equal-always-hash-code x)))

  (define-syntax gen:equal-mode+hash
    (make-generic-info (quote-syntax gen:equal-mode+hash)
                       (quote-syntax prop:gen:equal-mode+hash)
                       (quote-syntax equal-mode+hash?)
                       (quote-syntax gen:equal-mode+hash-acc)
                       ;; Unbound identifiers will be `free-identifier=?` to unbound in clients:
                       (list (quote-syntax equal-mode-proc)
                             (quote-syntax hash-mode-proc))
                       ;; Bound identifiers used for implementations:
                       (list (quote-syntax equal-mode-proc-impl)
                             (quote-syntax hash-mode-proc-impl) )))

  (define-values (prop:gen:custom-write gen:custom-write? gen:custom-write-acc)
    (make-struct-type-property
     'prop:gen:custom-write
     (lambda (v si)
       (if (and (vector? v)
                (= 1 (vector-length v))
                (procedure? (vector-ref v 0))
                (procedure-arity-includes? (vector-ref v 0) 3))
           v
           (raise-argument-error 'guard-for-prop:gen:custom-write
                                 "(vector/c (procedure-arity-includes/c 3))"
                                 v)))
     (list (cons prop:custom-write (lambda (v) (vector-ref v 0))))))

  ;; see above for equal+hash
  (define (write-proc-impl v p w)
    (case w
      [(#t) (write v p)]
      [(#f) (display v p)]
      [(0 1) (print v p w)]
      [else (error 'write-proc "internal error; should not happen")]))

  (define-syntax gen:custom-write
    (make-generic-info (quote-syntax gen:custom-write)
                       (quote-syntax prop:gen:custom-write)
                       (quote-syntax gen:custom-write?)
                       (quote-syntax gen:custom-write-acc)
                       (list (quote-syntax write-proc))
                       (list (quote-syntax write-proc-impl))))

  )
