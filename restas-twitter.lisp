;;;; restas-twitter.lisp

(in-package #:restas-twitter)

;;; "restas-twitter" goes here. Hacks and glory await!

;;; insert your credentials and auxiliary information here.
(defparameter *key* nil)
(defparameter *secret* nil)
(defparameter *callback-uri* "auth")
(defparameter *host* nil )
(defparameter *port* 8080)
(defparameter *redirect-uri* nil)

(defparameter *get-request-token-endpoint* "http://twitter.com/oauth/request_token")
(defparameter *auth-request-token-endpoint* "http://twitter.com/oauth/authorize")
(defparameter *get-access-token-endpoint* "http://twitter.com/oauth/access_token")
(defparameter *consumer-token* )
(defparameter *request-token* nil)
(defparameter *access-token* nil)

;;; initialization



;;; get a request token
(defmethod restas:initialize-module-instance :before ((module (eql #.*package*)) context)
  (restas:context-add-variable
   context '*consumer-token*
   (oauth:make-consumer-token :key
			      (restas:context-symbol-value context '*key*)
			      :secret
			      (restas:context-symbol-value context '*secret*)))
  (defun get-request-token ()
    (restas:with-context context
      (oauth:obtain-request-token
       *get-request-token-endpoint*
       *consumer-token*
       :callback-uri (concatenate 'string "http://" *host* *callback-uri*)))))

(defun get-auth-uri ()
  (oauth:make-authorization-uri *auth-request-token-endpoint*
				(setf *request-token* (get-request-token))))

(restas:define-route auth ("auth")
  (handler-case
      (oauth:authorize-request-token-from-request
       (lambda (rt-key)
	 (assert *request-token*)
	 (unless (equal (tbnl:url-encode rt-key) (oauth:token-key *request-token*))
	   (warn "Keys differ: ~S / ~S~%" (tbnl:url-encode rt-key) (oauth:token-key *request-token*)))
	 *request-token*))
    (error (c)
      (warn "Couldn't verify request token authorization: ~A" c)))
  (when (oauth:request-token-authorized-p *request-token*)
    (format t "Successfully verified request token with key ~S~%" (oauth:token-key *request-token*))
    (setf *access-token* (oauth:obtain-access-token *get-access-token-endpoint* *request-token*))
    (setf (tbnl:session-value 'auth) (cdr (assoc "screen_name"
						 (oauth:token-user-data *access-token*)
						 :test #'string=)))
    (hunchentoot:redirect *redirect-uri*)))

(restas:define-route logout ("logout")
  (setf (tbnl:session-value 'auth) nil)
  (setf *request-token* (get-request-token))
  (hunchentoot:redirect  *redirect-uri*))

