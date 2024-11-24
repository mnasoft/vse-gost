(in-package :vse-gost)

*vsegost-Catalog*  ; => #P"/home/mna/public_html/vsegost.com/Catalog/"

*vsegost-Data* ; => #P"/home/mna/public_html/vsegost.com/Data/"


(defparameter *files*
  (directory
   "/home/mna/public_html/vsegost.com/Catalog/*/*.shtml.html")
  "Список файлов, в которых расположенаа информация о ГОСТ."
  )

(length *files*)  ; => 48371 (16 bits, #xBCF3)


(defparameter *out-file*
  (concatenate 'string 
               (uiop:getenv "HOME") "/" "data-out.txt")
  
  )

*out-file* ; => "/home/mna/data-out.txt"


(create-sql-import-file *out-file* (namestring *vsegost-Catalog*))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Участок для тестирования кода

#+nil
(let* ((root-node
         (plump:parse
          #P"/home/mna/public_html/vsegost.com/Catalog/60/60477.shtml.html"
          ;;#P"/home/mna/public_html/vsegost.com/Catalog/60/60476.shtml.html" 
          ))
       (chdrn (plump:children
               (first (plump-dom:get-elements-by-tag-name root-node "h1"))))
       (ad (first (array-dimensions chdrn))))
  (if (> ad 0) (plump:text (aref chdrn 0)) ""))

#+nil 
(loop :for d :in *files*
      :for i :from 0
      :do
         (format t "~6D ~S " i d)
         (out (plump:parse d) t))
