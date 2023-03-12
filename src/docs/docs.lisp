;;;; ./src/docs/docs.lisp

(defpackage :vse-gost/docs
  (:use #:cl ) 
  (:nicknames "VSE-GOST/DOCS")
  (:export make-all)
  (:documentation "Пакет @b(vse-gost/docs) содержит функции
  генерирования и публикации документации."))

(in-package :vse-gost/docs)

(defun make-document ()
  (loop
    :for j :from 1
    :for i :in
    '((:vse-gost          :vse-gost)
      )
    :do
       (progn
         (apply #'mnas-package:document i)
         (format t "~A ~A~%" j i))))

(defun make-graphs ()
  (loop
    :for j :from 1
    :for i :in
    '(:vse-gost
      )
    :do (progn
          (mnas-package:make-codex-graphs i i)
          (format t "~A ~A~%" j i))))

(defun make-all (&aux
                   (of (if (find (uiop:hostname)
                                 mnas-package:*intranet-hosts*
                                 :test #'string= :key #'first)
                           '(:type :multi-html :template :gamma)
                           '(:type :multi-html :template :minima))))
  (let* ((sys-symbol :vse-gost)
         (sys-string (string-downcase (format nil "~a" sys-symbol))))
    (mnas-package:make-html-path sys-symbol)
    (make-document)
    (mnas-package:make-mainfest-lisp `(,sys-symbol)
                                     (string-capitalize sys-string)
                                     '("Mykola Matvyeyev")
                                     (mnas-package:find-sources sys-symbol)
                                     :output-format of)
    (codex:document sys-symbol)
    (make-graphs)
    (mnas-package:copy-doc->public-html sys-string)
    (mnas-package:rsync-doc sys-string)
    :make-all-finish))

;;;; (make-all)
