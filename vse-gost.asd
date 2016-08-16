;;;; vse-gost.asd

(asdf:defsystem #:vse-gost
  :description "Describe vse-gost here"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :depends-on (#:cl-ppcre)
  :serial t
  :components ((:file "package")
               (:file "vse-gost")
	       (:file "parse-shtml")
      	       (:file "walk-dir")))
