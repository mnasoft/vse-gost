(in-package #:vse-gost/web)

(defparameter *public_html* nil)

(let ((machine-instance (machine-instance)))
  (cond 
    ((string= machine-instance "N000325")
     (setf *public_html*
           "//n133906/home/_namatv/PRG/msys64/home/namatv/public_html/"))
    (t (setf *public_html*
        "~/public_html/"))))

(defparameter *vsegost-com-Data*
  (concatenate 'string *public_html* "vsegost.com/Data/"))

(defparameter *img-logos-path*
  (concatenate 'string *public_html* "images/logos/"))

(defparameter *imges*
  '(("MNASoft.png"     "https://mnasoft.ddns.net"           "MNASoft")
    ("ArchLinux.png"   "https://archlinux.org"              "ArchLinux")
    ("Common-Lisp.png" "https://common-lisp.net"            "Common-Lisp")
    ("SBCL.png"        "https://sbcl.org"                   "SBCL")
    ("Emacs.png"       "https://www.gnu.org/software/emacs" "Emacs")
    ("SLY.png"         "https://github.com/joaotavora/sly"  "SLY")
    ("40ants.png"      "https://40ants.com/reblocks"        "Reblocks")))

(defparameter *img-ref-data*
  (loop :for (png http name) :in *imges*
        :when (probe-file (mnas-path:pathname-merge *img-logos-path* png))
          :collect 
          (list
           (probe-file (mnas-path:pathname-merge *img-logos-path* png))
           http
           name)))
