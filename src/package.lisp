;;;; package.lisp

(defpackage :vse-gost
  (:use #:cl)
  (:export 
	   *vsegost-Catalog*
	   main-create-bash-script-gif-pdf-convertion
	   *vsegost-Data*)
  (:export create-html-vsegost)
  (:export pth-Catalog->Data)
  )

(in-package :vse-gost)
