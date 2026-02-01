(in-package :vse-gost/web)

(defclass img-ref ()
  ((pathname
    :initarg :pathname
    :accessor img-ref-pathname
    :initform #P"/"
    :type pathname
             :documentation "pathname to image")
   (href
    :initarg :href
    :accessor img-ref-href
    :initform "https://example.org"
    :type string 
    :documentation "href")
   (alt
    :initarg :alt
    :initform ""
    :accessor img-ref-alt
    :type string 
    :documentation "alter text for image")))

(defun make-img-ref (img-pathname href alt)
  (make-instance 'img-ref
                 :pathname    img-pathname
                 :href        href
                 :alt         alt))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(reblocks/widget:defwidget w-img-ref ()
  ((item :initarg :item
         :type img-ref
         :reader w-img-ref-item)))

(defun make-w-img-ref (img-ref)
  (make-instance 'w-img-ref :item img-ref))

(defmethod reblocks/widget:render ((ref-img-w w-img-ref))
  (let* ((item (w-img-ref-item ref-img-w)))
    (img-ref-pathname item)

    (with-html ()
      (:td (:a :href (img-ref-href item) :target "_blank"
                    (:img :src (file-to-base64-src (img-ref-pathname item))
                          :height "36px"
                          :alt (img-ref-alt item)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(reblocks/widget:defwidget w-img-refs ()
  ((items
    :initarg :items
    :type     (soft-list-of w-img-ref)
    :accessor w-img-refs-items)))

(defun make-w-img-refs (records)
  (let ((items
          (loop :for (img-pname href alt) :in records
                :for img-ref = (make-img-ref img-pname href alt)
                :collect (make-w-img-ref img-ref))))
    (make-instance 'w-img-refs :items items)))

(defmethod reblocks/widget:render ((w-img-refs w-img-refs))
  (with-html ()  
    (:table :style "border: 1px solid black; border-collapse: collapse;"
            (:tr
             (loop :for item :in (w-img-refs-items w-img-refs) :do
               (reblocks/widget:render item))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defparameter *imges*
  '(("MNASoft.png"     "https://mnasoft.ddns.net"           "MNASoft")
    ("ArchLinux.png"   "https://archlinux.org"              "ArchLinux")
    ("Common-Lisp.png" "https://common-lisp.net"            "Common-Lisp")
    ("SBCL.png"        "https://sbcl.org"                   "SBCL")
    ("Emacs.png"       "https://www.gnu.org/software/emacs" "Emacs")
    ("SLY.png"         "https://github.com/joaotavora/sly"  "SLY")
    ("40ants.png"      "https://40ants.com/reblocks"        "Reblocks")))

(defparameter *img-logos-path*
  "~/public_html/images/logos/")

(defparameter *img-ref-data*
  (loop :for (png http name) :in *imges*
        :when (probe-file (mnas-path:pathname-merge *img-logos-path* png))
          :collect 
          (list
           (probe-file (mnas-path:pathname-merge *img-logos-path* png))
           http
           name)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; tests

#+nil
(progn
  (ql:quickload :reblocks-tests)
  (reblocks-tests/utils:with-test-session ()
    (render
     (make-w-img-refs *img-ref-data*))))


