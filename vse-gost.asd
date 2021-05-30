;;;; vse-gost.asd

(defsystem #:vse-gost
  :description "Describe vse-gost here"
  :author "Nick Matvyeyev <mnasoft@gmail.com>"
  :license "GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007 or later"  
  :depends-on (#:cl-ppcre)
  :serial t
  :components ((:file "package")
               (:file "vse-gost")
	       (:file "parse-shtml")
      	       (:file "walk-dir")))
