;;;; ./src/docs/docs.lisp

(defpackage #:vse-gost/docs
  (:use #:cl ) 
  (:nicknames "VSE-GOST/DOCS")
  (:export make-all)
  (:documentation "Пакет @b(vse-gost/docs) содержит функции
  генерирования и публикации документации."))

(in-package :vse-gost/docs)

(defun make-document ()
  (loop
    :for i :in
    '((:vse-gost          :vse-gost)
      )
    :do (apply #'mnas-package:document i)))

(defun make-graphs ()
  (loop
    :for i :in
    '(:vse-gost
      )
    :do (mnas-package:make-codex-graphs i i)))

(defun make-all (&aux
                   (of (if (find (uiop:hostname)
                                 mnas-package:*intranet-hosts*
                                 :test #'string=)
                           '(:type :multi-html :template :gamma)
                           '(:type :multi-html :template :minima))))
  "@b(Описание:) функция @b(make-all) служит для создания документации.

 Пакет документации формируется в каталоге
~/public_html/Common-Lisp-Programs/vse-gost.
"
  (mnas-package:make-html-path :vse-gost)
  (make-document)
  (make-graphs)
  (mnas-package:make-mainfest-lisp
   '(:vse-gost :vse-gost/docs)
   "Vse-Gost"
   '("Nick Matvyeyev")
   (mnas-package:find-sources "vse-gost")
   :output-format of)
  (codex:document :vse-gost)
  (make-graphs)
  (mnas-package:copy-doc->public-html "vse-gost")
  (mnas-package:rsync-doc "vse-gost"))

;;;; (make-all)
