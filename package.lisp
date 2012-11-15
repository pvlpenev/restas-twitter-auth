;;;; package.lisp

(restas:define-module #:restas-twitter-auth
  (:use #:cl)
  (:export #:*key*
	   #:*secret*
	   #:*host*
	   #:*redirect-uri*
	   #:logout
	   #:get-auth-uri))
