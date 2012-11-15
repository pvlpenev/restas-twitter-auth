;;;; restas-twitter.lisp

(in-package #:restas-twitter)

;;; "restas-twitter" goes here. Hacks and glory await!

;;; insert your credentials and auxiliary information here.
(defparameter *key* "42nOkdVJKmapE6JQL12U8g")
(defparameter *secret* "4hOWjm4D8SdZLXZ9k8rTNl8ZtOK5DFWJkdc2BXomc")
(defparameter *callback-uri* nil)
(defparameter *host* "85.130.11.8")
(defparameter *port* 8080)
(defparameter *redirect-uri* "/")

(defparameter *get-request-token-endpoint* "http://twitter.com/oauth/request_token")
(defparameter *auth-request-token-endpoint* "http://twitter.com/oauth/authorize")
(defparameter *get-access-token-endpoint* "http://twitter.com/oauth/access_token")
(defparameter *consumer-token* (oauth:make-consumer-token :key *key* :secret *secret*))
(defparameter *request-token* nil)
(defparameter *access-token* nil)

;;; initialization

(defmethod restas:initialize-module-instance ((module (eql #.*package*)) context)
  (restas:context-add-variable context
			       '*callback-uri*
			       (format nil "http://~a:~a~a" *host* *port* (restas:genurl 'login))))


;;; get a request token
(defun get-request-token ()
  (oauth:obtain-request-token
    *get-request-token-endpoint*
    *consumer-token*
    :callback-uri *callback-uri*))

(restas:define-route main ("/")
  ;(setf *callback-uri* (restas:gen-full-url 'login))
  (if (tbnl:session-value 'auth)
      (format nil "Hello, ~a" (tbnl:session-value 'auth))
      (let* ((auth-uri (oauth:make-authorization-uri *auth-request-token-endpoint*
						     (setf *request-token* (get-request-token)))))
	(format nil "<a href=\"~A\">Sign in</a> ~s" (puri:uri auth-uri) *callback-uri*))))

(restas:define-route auth ("/auth")
  (if (tbnl:session-value 'auth)
      (hunchentoot:redirect *redirect-uri*)
      (let* ((auth-uri (oauth:make-authorization-uri *auth-request-token-endpoint*
						     (setf *request-token* (get-request-token)))))
	(hunchentoot:redirect (format nil "~a" (puri:uri auth-uri))))))

(restas:define-route login ("/loginf")
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

(restas:define-route logout ("/logout")
  (setf (tbnl:session-value 'auth) nil)
  (setf *request-token* (get-request-token))
  (hunchentoot:redirect  *redirect-uri*))

