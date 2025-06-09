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

(defparameter *img-ref-data*
  '((#P"/home/mna/public_html/images/logos/MNASoft.png" "https://mnasoft.ddns.net" "MNASoft")
    (#P"/home/mna/public_html/images/logos/ArchLinux.png" "https://archlinux.org" "ArchLinux")
    (#P"/home/mna/public_html/images/logos/Common-Lisp.png" "https://common-lisp.net" "Common-Lisp")
    (#P"/home/mna/public_html/images/logos/SBCL.png" "https://sbcl.org" "SBCL")
    (#P"/home/mna/public_html/images/logos/Emacs.png" "https://www.gnu.org/software/emacs" "Emacs")
    (#P"/home/mna/public_html/images/logos/SLY.png" "https://github.com/joaotavora/sly" "SLY")
    (#P"/home/mna/public_html/images/logos/40ants.png" "https://40ants.com/reblocks" "Reblocks")
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; tests

#+nil
(progn
  (ql:quickload :reblocks-tests)
  (reblocks-tests/utils:with-test-session ()
    (render
     (make-w-img-refs *img-ref-data*))))


