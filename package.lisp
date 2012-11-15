;;;; package.lisp

(restas:define-module #:restas-twitter
  (:use #:cl)
  (:export #:*key*
	   #:*secret*
	   #:*host*
	   #:*port*
	   #:*redirect-uri*
	   #:auth
	   #:get-auth-uri))
