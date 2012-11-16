(restas:define-module #:twitter-test
    (:use #:cl)
  (:export #:start
	   #:start2))

(in-package #:twitter-test)

(restas:define-route main ("")
  (if (hunchentoot:session-value :auth)
      (format nil "~a <a href=\"~a\">log out</a>"
	      (hunchentoot:session-value :auth)
	      ;; generate logout url
	      (restas:genurl-submodule 'twitter-auth 'restas-twitter-auth:logout))
      (format nil "<a href=\"~a\">Log in</a>"
	      ;; get the twitter url for authentication
	      (restas-twitter-auth:get-auth-uri))))

(defun start ()
  (restas:mount-submodule twitter-auth (#:restas-twitter-auth)
    (restas-twitter-auth:*baseurl* '("twitter")) ; optional
    (restas-twitter-auth:*key* "")    ;; Obtain from dev.twitter.com,
    (restas-twitter-auth:*secret* "") ;; after registering app.
    (restas-twitter-auth:*redirect-uri* "/"))
  (restas:start '#:twitter-test :port 8080 :hostname "localhost"))

(defun start2 ()
  (restas:mount-submodule twitter-auth (#:restas-twitter-auth)
    (restas-twitter-auth:*baseurl* '("twitter")) ; optional
    (restas-twitter-auth:*key* "") ;; Obtain from dev.twitter.com,
    (restas-twitter-auth:*secret* "") ;; after registering app.
    (restas-twitter-auth:*redirect-uri* "/")
    (restas-twitter-auth:*login-function*
     #'(lambda (access-token)
	 (setf (hunchentoot:session-value :auth)
	       (restas-twitter-auth:get-access-token-screen-name access-token))))
    (restas-twitter-auth:*logout-function*
     #'(lambda ()
	 (hunchentoot:delete-session-value :auth))))
  (restas:start '#:twitter-test :port 8080 :hostname "localhost"))
