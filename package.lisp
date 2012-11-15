;;;; package.lisp

(restas:define-module #:restas-twitter
  (:use #:cl)
  (:export #:*host*
	   #:*port*
	   #:*redirect-uri*
	   #:auth))
