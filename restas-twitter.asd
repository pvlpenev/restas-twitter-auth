;;;; restas-twitter.asd

(asdf:defsystem #:restas-twitter
  :serial t
  :description "Describe restas-twitter here"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :depends-on (#:restas
               #:cl-oauth)
  :components ((:file "package")
               (:file "restas-twitter")))

