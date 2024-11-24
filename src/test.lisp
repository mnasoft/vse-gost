(in-package :vse-gost)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Участок для тестирования кода

(defparameter *files*
           (directory
            (concatenate 'string 
                         (namestring *vsegost-Catalog*)
                         "*/*.shtml.html")))

(let* ((n 32834)
       (root-node 
         (plump:parse (nth n *files*))))

  (print-record root-node)
  ;;(local-path root-node)
  )


