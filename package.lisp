;;;; package.lisp

(defpackage #:vse-gost
  (:use #:cl)
  (:export main-create-PostgreSQL-import-file
	   *vsegost-Catalog*
	   main-create-bash-script-gif-pdf-convertion
	   *vsegost-Data*)
  (:export create-html-vsegost)
  (:export walk-vsegost)
  (:export pth-Catalog->Data)
  )

;;;;(declaim (optimize (space 0) (compilation-speed 0)  (speed 0) (safety 3) (debug 3)))

;;;; (declaim (optimize (compilation-speed 0) (debug 3) (safety 0) (space 0) (speed 0)))
