;;;; restas-twitter.asd
;;; Copyright (C) 2012 Pavel Penev
;;; All rights reserved.
;;; See the file LICENSE for terms of use and distribution.

(asdf:defsystem #:restas-twitter-auth
  :serial t
  :description "Twitter authentication plugin for restas"
  :author "Pavel Penev <pvl.penev@gmail.com>"
  :license "MIT"
  :depends-on (#:restas
               #:cl-oauth)
  :components ((:file "package")
               (:file "restas-twitter-auth")))

