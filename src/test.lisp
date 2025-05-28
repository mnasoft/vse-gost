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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(ql:quickload :postmodern)
(ql:quickload :mnas-string)

(postmodern:connect-toplevel "gost" "mna" "" "localhost")
(postmodern:disconnect postmodern:*database*)

postmodern:disconnect
(postmodern:connected-p postmodern:*database*)


(defun list-show-gost-table (name-str designation-str description-str)
  (let ((rez nil))
    (postmodern:doquery (:select 'designation 'name 'local_path :from 'gost :where
		                 (:and (:ilike 'name (mnas-string/db:prepare-to-query name-str))
			               (:ilike 'designation (mnas-string/db:prepare-to-query designation-str))
			               (:ilike 'description (mnas-string/db:prepare-to-query description-str))))
	(designation name local_path)
      (setf rez (cons (list (concatenate 'string "http://wp7580.ddns.mksat.net/~namatv/2015-12-21-vsegost.com/" local_path "/" "gost.pdf")
			    designation
			    name)
		      rez)))
    rez))

(defun select-from-gost-table (name-str designation-str description-str)
      (postmodern:query (:select '* :from 'gost :where
		        (:and (:ilike 'name (mnas-string/db:prepare-to-query name-str))
			      (:ilike 'designation (mnas-string/db:prepare-to-query designation-str))
			      (:ilike 'description (mnas-string/db:prepare-to-query description-str))))))

(select-from-gost-table "" "2.30" "")

(length
 (list-show-gost-table "" "ГОСТ" "")
 )

(length
 (let ((rez nil))
   (postmodern:doquery (:select 'designation 'name 'local_path
                        :from 'gost
                        :where (:not (:like 'designation "%2.30%")))
       (designation name local_path)
     (setf rez (cons (list (concatenate 'string "http://wp7580.ddns.mksat.net/~namatv/2015-12-21-vsegost.com/" local_path "/" "gost.pdf")
			   designation
			   name)
		     rez)))
   rez))

(postmodern:doquery
    (:select 'designation 'name 'local_path :from 'gost :where (:not-ilike 'designation "%ГОСТ%")))

(postmodern:query (:select 'designation 'name 'local_path
                        :from 'gost
                   :where (:ilike 'designation "%2.30%")))

(postmodern:query "ALTER ROLE CURRENT_USER WITH PASSWORD 'gost-password'")
