;;;; package.lisp

(restas:define-module #:restas-twitter-auth
  (:use #:cl)
  (:export #:*key*
	   #:*secret*
	   #:*host*
	   #:*redirect-uri*
	   #:*login-function*
	   #:*logout-function*
	   #:get-access-token-screen-name
	   #:simple-get-user-auth
	   #:logout
	   #:get-auth-uri))
