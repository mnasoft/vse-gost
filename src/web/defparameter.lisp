(in-package #:vse-gost/web)

(defparameter *public_html* nil)

(let ((machine-instance (machine-instance)))
  (cond 
    ((string= machine-instance "N000325")
     (setf *public_html*
           "//n133906/home/_namatv/PRG/msys64/home/namatv/public_html/"))
    (t *public_html*
       "~/public_html/")))

#+nil
(defparameter *vsegost-com-Data*
  (concatenate 'string (uiop:getenv "HOME") "/public_html/vsegost.com/Data/"))

#+nil 
(defparameter *img-logos-path*
  "~/public_html/images/logos/")

(defparameter *vsegost-com-Data*
  (concatenate 'string *public_html* "vsegost.com/Data/"))

(defparameter *img-logos-path*
  (concatenate 'string *public_html* "images/logos/"))
