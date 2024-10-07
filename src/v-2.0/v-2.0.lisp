(in-package :vse-gost)

(defparameter *files* (directory "/home/mna/public_html/vsegost.com/Catalog/*/*.shtml.html"))

(defparameter *files* (directory "/home/mna/public_html/vsegost.com/Catalog/*/*.shtml.html"))

(create-sql-import-file "/home/namatv/data-out.txt"
                        "/home/namatv/public_html/vsegost.com/Catalog")

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
