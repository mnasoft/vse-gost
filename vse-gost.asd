;;;; vse-gost.asd

(asdf:defsystem #:vse-gost
  :description "Describe vse-gost here"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :depends-on (#:inferior-shell #:cl-ppcre #:uiop)
  :serial t
  :components ((:file "package")
               (:file "vse-gost")
;;;;	       (:file "compile_func")
;;;;	       (:file "directory")
;;;;	       (:file "gif_to_pdf")
;;;;	       (:file "open_file")
	       (:file "parse-shtml")
      	       (:file "walk-dir")
	       ))
