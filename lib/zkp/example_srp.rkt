#lang racket

(require math/number-theory)

(provide srp-login srp-register)

;; Find a prime p such that 2p+1 is also prime
(define (search-n start rounds)
  (if (zero? rounds)
      #f
      (let ([p (next-prime start)])
        (if (prime? (+ 1 (* 2 p)))
            (values p (+ 1 (* 2 p)))
            (search-n (+ p 2) (- rounds 1))))))

(define n 2027)
(define g 5)

(define *user-db* (make-hash))

(define (my-hash things)
  (string-length (format "~a" things)))

(define (srp-register username password)
 (with-modulus n
    (let* ([salt 42]
           [x (my-hash (list username salt password))]
           [v (modexpt g x)])
      (hash-set! *user-db* username (list salt v)))))

(define (srp-login username password)
  (with-modulus n
    (let* ([k (my-hash (list n g))]
           [a 7]
           [A (modexpt g a)]
           [b 12]
           [v (second (hash-ref *user-db* username))]
           [salt (first (hash-ref *user-db* username))]
           [x (my-hash (list username salt password))]
           [B (mod+ (mod* k v) (modexpt g b))]
           [u (my-hash (list A B))]
           [s_carol (modexpt (mod- B (mod* k (modexpt g x)))
                             (mod+ a (mod* u x)))]
           [s_steve (modexpt (mod* A (modexpt v u)) b)])
      `((v ,v)
        (salt ,salt)
        (u ,u)
        (k ,k)
        (x ,x)
        (a ,a)
        (A ,A)
        (b ,b)
        (B ,B)
        (s_carol ,s_carol)
        (s_steve ,s_steve)))))

