(in-package :vse-gost/web)

(sb-ext:save-lisp-and-die "vsegost-web.exe" :executable t :compression t)

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
                          :height "24px"
                          :alt (img-ref-alt item)))))))

(defparameter *w*
  (make-w-img-ref
   (make-img-ref "/home/mna/public_html/images/logos/MNASoft.png"
                 "https://mnasoft.ddns.net"
                 "MNASoft.png")))

(directory "/home/mna/public_html/images/logos/*.png")

(progn
  (ql:quickload :reblocks-tests)
  (reblocks-tests/utils:with-test-session ()
    (render
     (make-w-img-ref
      (make-img-ref "/home/mna/public_html/images/logos/MNASoft.png"
                    "https://mnasoft.ddns.net"
                    "MNASoft.png")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Тестирование
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#+nil
(progn
  (ql:quickload :reblocks-tests)
  (reblocks-tests/utils:with-test-session ()
    (render
     (make-gost-item
      (make-gost
       '(1201
         "ГОСТ 2.306-68"
         "Единая система конструкторской документации. Обозначения графические материалов и правила их нанесения на чертежах"
         "Настоящий стандарт устанавливает графические обозначения материалов в сечениях и на фасадах, а также правила нанесения их на чертежи всех отраслей промышленности и строительства"
         "11/1121"
         2158963200
         "действующий")))))

  (reblocks-tests/utils:with-test-session ()
    (render
     (make-gost-list (gost-table "" "2.30" "")))))


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
