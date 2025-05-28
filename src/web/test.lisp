(in-package :vse-gost/web)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Участок для тестирования кода
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; postmodern

(defun gost-table (name designation description)
  (postmodern:query (:select '* :from 'gost :where
		          (:and (:ilike 'name (mnas-string/db:prepare-to-query name))
			        (:ilike 'designation (mnas-string/db:prepare-to-query designation))
			        (:ilike 'description (mnas-string/db:prepare-to-query description))))))

(defun list-show-gost-table (name-str designation-str description-str)
  (let ((rez nil))
    (postmodern:doquery (:select 'designation 'name 'local_path :from 'gost :where
		          (:and (:ilike 'name (mnas-string/db:prepare-to-query name-str))
			        (:ilike 'designation (mnas-string/db:prepare-to-query designation-str))
			        (:ilike 'description (mnas-string/db:prepare-to-query description-str))))
	(designation name local_path)
      (setf rez
            (cons
             (list (concatenate
                    'string
                    "http://wp7580.ddns.mksat.net/~namatv/2015-12-21-vsegost.com/" local_path "/" "gost.pdf")
		   designation
		   name)
	     rez)))
    rez))

(postmodern:query (:select '* :from 'gost :where
		          (:and (:ilike 'name (mnas-string/db:prepare-to-query "%"))
			        (:ilike 'designation (mnas-string/db:prepare-to-query "%302%"))
			        (:ilike 'description (mnas-string/db:prepare-to-query "%")))))
(let ((rez nil))
   (postmodern:doquery (:select 'designation 'name 'local_path
                        :from 'gost
                        :where (:not (:like 'designation "%2.30%")))
       (designation name local_path)
     (setf rez (cons (list (concatenate 'string "http://wp7580.ddns.mksat.net/~namatv/2015-12-21-vsegost.com/" local_path "/" "gost.pdf")
			   designation
			   name)
		     rez)))
   rez)

(postmodern:query "ALTER ROLE CURRENT_USER WITH PASSWORD 'gost-password';")

;; Удаление столбца таблицы
(postmodern:query "ALTER TABLE gost DROP COLUMN external_path;")

;; Столбцы таблицы
(postmodern:query "SELECT column_name FROM information_schema.columns WHERE table_name = 'gost';")

(postmodern:query
 "SELECT attname
         FROM pg_catalog.pg_attribute
         WHERE attrelid = 'gost'::regclass AND attnum > 0;")

(postmodern:query
 "SELECT column_name, data_type, is_nullable
        FROM information_schema.columns
        WHERE table_name = 'gost';")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(postmodern:query "SELECT * FROM gost WHERE designation ILIKE '%302%'")

;; Пример извлечения даты
(postmodern:query "SELECT * FROM gost WHERE EXTRACT(YEAR FROM date) = 1992;")
(decode-universal-time 2916345600)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defparameter *gost*
  (make-gost ' (2795
                "ГОСТ 2.304-81"
                "Единая система конструкторской документации. Шрифты чертежные"
                "Настоящий стандарт устанавливает чертежные шрифты, наносимые на чертежи и другие технические документы всех отраслей промышленности и строительства"
                "13/1360"
                2569190400
                "действующий")))

(gost-id *gost*) ; => 2795 
(gost-designation *gost*) ; => "ГОСТ 2.304-81"
(gost-name *gost*) ; => "Единая система конструкторской документации. Шрифты чертежные"
(gost-description *gost*) ; => "Настоящий стандарт устанавливает чертежные шрифты, наносимые на чертежи и другие технические документы всех отраслей промышленности и строительства"
(gost-local_path *gost*)  ; => "13/1360"
(gost-date *gost*) ; => 2569190400 (32 bits, #x9922BC00)
(gost-status *gost*) ; => "действующий"
