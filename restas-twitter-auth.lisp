;;;; restas-twitter.lisp

(in-package #:restas-twitter-auth)

;;; "restas-twitter" goes here. Hacks and glory await!

(defparameter *get-request-token-endpoint* "http://twitter.com/oauth/request_token")
(defparameter *auth-request-token-endpoint* "http://twitter.com/oauth/authorize")
(defparameter *get-access-token-endpoint* "http://twitter.com/oauth/access_token")
(defparameter *request-token* nil)
(defparameter *access-token* nil)
(defparameter *login-function* nil)
(defparameter *logout-function* nil)

;;; initialization. Gets called when the module is mounted with restas:mount-submodule
(defmethod restas:initialize-module-instance :before ((module (eql #.*package*)) context)
  (restas:with-context context
    (restas:context-add-variable
     context '*consumer-token* (oauth:make-consumer-token :key *key* :secret *secret*)))
  
  ;; Because context variables in restas are available only in routes,
  ;; an ordinary function using them needs to be defined at module initialization time,
  ;; to capture the value of context, where the variables are stored.
  (defun get-request-token ()
    "Generate a request token"
    (restas:with-context context
      (oauth:obtain-request-token
       *get-request-token-endpoint*
       *consumer-token*
       :callback-uri (format nil "http://~a~{/~a~}~a"
			     (hunchentoot:host) *baseurl* (restas:genurl 'auth))))))

(defun simple-login (access-token)
  (setf (hunchentoot:session-value :auth)
	(cdr (assoc "screen_name"
		    (oauth:token-user-data access-token)
		    :test #'string=))))

(defun simple-logout ()
  (setf (hunchentoot:session-value :auth) nil))

(defun simple-get-user-auth ()
  (hunchentoot:session-value :auth))

(defun get-access-token-screen-name (access-token)
  (cdr (assoc "screen_name"
	      (oauth:token-user-data access-token)
	      :test #'string=)))

(defun get-auth-uri ()
  "Returns the twitter url where the user should be pointed to,
in order to authenticate, and allow the app to access his twitter account."
  (oauth:make-authorization-uri *auth-request-token-endpoint*
				(setf *request-token* (get-request-token))))

(restas:define-route auth ("auth")
  "Callback route, called when twitter either authenticates, or denies the request token"
  (handler-case
      (oauth:authorize-request-token-from-request
       (lambda (rt-key)
	 (assert *request-token*)
	 (unless (equal (hunchentoot:url-encode rt-key) (oauth:token-key *request-token*))
	   (warn "Keys differ: ~S / ~S~%"
		 (hunchentoot:url-encode rt-key)
		 (oauth:token-key *request-token*)))
	 *request-token*))
    (error (c)
      (return-from auth (format nil "Couldn't verify request token authorization: ~A" c))))
  (when (oauth:request-token-authorized-p *request-token*)
    (setf *access-token* (oauth:obtain-access-token *get-access-token-endpoint* *request-token*))
    (if *login-function*
	(funcall *login-function* *access-token*)
	(simple-login *access-token*))
    (hunchentoot:redirect *redirect-uri*)))

(restas:define-route logout ("logout")
  "Route to log out the user, and reset the request token"
  (setf *request-token* (get-request-token))
  (if *login-function*
      (funcall *logout-function*)
      (simple-logout))
  (hunchentoot:redirect *redirect-uri*))
