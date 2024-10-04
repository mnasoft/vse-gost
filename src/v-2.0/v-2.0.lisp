(in-package :vse-gost)

(directory "/home/mna/public_html/vsegost.com/Catalog/*/*.shtml.html")

(defparameter *r*
  (plump:parse (pathname vse-gost::*fn*)))

(defparameter *a*
  (plump:get-elements-by-tag-name *R* "a"))

;; Обозначение
(first 
 (loop :for h1 :in (plump-dom:get-elements-by-tag-name *R* "h1")
       :collect (plump:text (aref (plump:children h1) 0))
       ))

;; Наименование
(first
 (loop :for h2 :in (plump-dom:get-elements-by-tag-name *R* "h2")
       :collect (plump:text (aref (plump:children h2) 0))
       ))

;; Статус
(first
 (loop :for p :in (plump-dom:get-elements-by-tag-name *R* "p")
       :collect (plump:text (aref (plump:children p) 0))
       ))

;; Описание
(first 
 (loop :for p :in (plump-dom:get-elements-by-tag-name *R* "p")
       :collect (plump:text (aref (plump:children p) 1))
       ))
      
;; gif-файлы
(loop :for a :in (plump-dom:get-elements-by-tag-name *R* "a")
      :when (ppcre:scan "\\.\\./\\.\\./Data/" (plump:attribute a "href"))
        :collect
        (plump:attribute a "href"))



