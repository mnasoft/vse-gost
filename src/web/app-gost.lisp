(in-package #:vse-gost/web)

(defparameter *vsegost-com-Data*
  (concatenate 'string (uiop:getenv "HOME") "/public_html/vsegost.com/Data/"))

(defun gost-table (name designation status)
  (postmodern:query (:select '* :from 'gost :where
		          (:and (:ilike 'name (mnas-string/db:prepare-to-query name))
			        (:ilike 'designation (mnas-string/db:prepare-to-query designation))
			        (:ilike 'status (mnas-string/db:prepare-to-query status))))))

(defun file-to-base64 (filename)
  (with-open-file (stream filename :element-type '(unsigned-byte 8))
    (let ((data (make-array (file-length stream) :element-type '(unsigned-byte 8))))
      (read-sequence data stream)
      (cl-base64:usb8-array-to-base64-string data))))

(defun file-to-base64-src (filename)
  (let ((type (pathname-type filename))
        (base64-string (file-to-base64 filename)))
    (format nil "data:image/~A;base64,~A" type base64-string)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; gost
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defclass gost ()
  ((id
    :initarg :id
    :initform (error "Field ID is required")
    :accessor gost-id
    :type integer
    :documentation "id integer NO")
   (designation
    :initarg :designation
    :initform ""
    :accessor gost-designation
    :documentation "designation text YES")
   (name
    :initarg :name
    :initform ""
    :accessor gost-name
    :documentation "name text YES")
   (description
    :initarg :description
    :initform ""
    :accessor gost-description
    :documentation "description text YES")
   (local_path
    :initarg :local_path
    :initform ""
    :accessor gost-local_path
    :documentation "local_path text YES")
   (date
    :initarg :date
    :initform (get-universal-time)
    :accessor gost-date
    :type integer
    :documentation "date text YES")
   (status
    :initarg :status
    :initform ""
    :accessor gost-status
    :documentation "status text YES")))

(defun make-gost (record)
  (make-instance 'gost 
                 :id          (nth 0 record)
                 :designation (nth 1 record)
                 :name        (nth 2 record)
                 :description (nth 3 record)
                 :local_path  (nth 4 record)
                 :date        (nth 5 record)
                 :status      (nth 6 record)))

(defun get-gost (id)
  (let ((record
          (first
           (postmodern:query
            (:select '* :from 'gost :where (:= 'id id))))))
    (when record (make-gost record))))

(defmethod gost-gifs ((gost gost))
  (let ((gifs (directory
               (concatenate 'string
                            *vsegost-com-Data*
                            (gost-local_path gost)
                            "/*.gif"))))
  (sort gifs #'<
        :key
        #'(lambda (x) (parse-integer (pathname-name x) :junk-allowed t)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; gost-item
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(reblocks/widget:defwidget gost-item ()
  ((gost :initarg :gost
         :type gost
         :reader gost-item-gost)))

(defun make-gost-item (gost)
  (make-instance 'gost-item :gost gost))

(defmethod reblocks/widget:render ((gost-item gost-item))
  (let* ((gost (gost-item-gost gost-item))
         (details-url
           (route-url "gost-details"
                      :gost-id (gost-id gost))))
    (with-html ()
      (:tr 
       ;;(:td :style "border: 1px solid black;" (gost-designation gost))
       (:td :style "border: 1px solid black;"
            (:a :href details-url (gost-designation gost)))
       (:td :style "border: 1px solid black;" (gost-name        gost))
       (:td :style "border: 1px solid black;" (gost-status      gost))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; gost-page
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(reblocks/widget:defwidget gost-page ()
  ((gost :initarg :gost
         :type gost
         :accessor gost)
   (edit-mode-p :initform nil
                :type boolean
                :accessor edit-mode-p)))

(defun make-gost-page (gost-id)
  (let ((gost (get-gost gost-id)))
    (cond
      (gost (make-instance 'gost-page
                           :gost gost))
      (t
       (reblocks/response:not-found-error
        (format nil "Gost with id ~A not found."
                gost-id))))))

(defmethod render ((gost-page gost-page))
  (let ((gost (gost gost-page))
        ;; This is the way how we can get URL path
        ;; pointing to another page without hardcoding it.
        (list-url (route-url "gosts-list")))
    (reblocks/html:with-html ()
      (:div :style "display: flex; gap: 1rem"
            (:a :href list-url
                "Back to gost list."))
      (:div  ;; :style "display: flex; flex-direction: column;"  gap: 0.25rem
            (:p (:b "ID: ")          (gost-id gost))
            (:p (:b "Designation: ") (gost-designation gost))
            (:p (:b "Name: ")        (gost-name        gost))
            (:p (:b "Description: ") (gost-description gost))
            (:p (:b "Local_Path: ")  (gost-local_path  gost))
            (:p (:b "Status: ")      (gost-status      gost))
            (loop :for gif :in (gost-gifs gost)
                  :do
                     (:div 
                      (:img :src (file-to-base64-src gif)
                            :style "width: 100%;"))))
      (:div :style "display: flex; gap: 1rem"
            (:a :href list-url
                "Back to gost list."))
      (:footer (make-w-img-refs *img-ref-data*)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; gost-list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(reblocks/widget:defwidget gost-list ()
  ((items
    :initarg :gost-list-items
    :type     (soft-list-of gost-item)
    :accessor gost-list-items)))

(defun make-gost-list (records)
  (let ((items (loop :for record :in records
                     :for gost = (make-gost record)
                     :collect (make-gost-item gost))))
    (make-instance 'gost-list :gost-list-items items)))

(defmethod reblocks/widget:render ((gost-list gost-list))
  (with-html ()
    (flet ((on-submit (&key designation name status &allow-other-keys)
             ;;(format t "designation=~A name=~A ~%" designation name)
             (setf (gost-list-items gost-list)
                   (loop :for record :in (gost-table name designation status)
                     :for gost = (make-gost record)
                     :collect (make-gost-item gost)))
             (update gost-list)))
      (:form :onsubmit (make-js-form-action #'on-submit)
             (:input :type "text"
                     :name "designation"
                     :placeholder "Designation")
             (:input :type "text"
                     :name "name"
                     :placeholder "Name")
             (:input :type "text"
                     :name "status"
                     :placeholder "Status")
             (:input :type "submit"
                     :class "button"
                     :value "Select")))    
    (:table :style "border: 1px solid black; border-collapse: collapse;"
     (loop :for item :in (gost-list-items gost-list) :do
       (reblocks/widget:render item)))
    (:footer (make-w-img-refs *img-ref-data*))
    ))
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; defapp gosts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defapp gosts
  :prefix "/apps/gosts/"
  :routes ((page ("/<int:gost-id>" :name "gost-details")
             (make-gost-page gost-id))
           (page ("/" :name "gosts-list")
             #+nil
             (make-gost-list (gost-table "" "2.1" ""))
             (make-gost-list nil))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun detect-interface ()
  (let ((hostname (uiop:getenv "HOSTNAME")))
    (if (eq (char hostname 0) #\N)
        (string-downcase hostname)
        "localhost")))

(defun start-gosts (&key (port 8080))
  (unless (and postmodern:*database*
               (postmodern:connected-p postmodern:*database*))
    (postmodern:connect-toplevel "gost" (uiop:getenv "USER") "" "localhost"))
  (reblocks/server:start :port port
<<<<<<< HEAD
                         :apps '(gosts)
                         :interface (detect-interface)))
=======
                         :apps '(root gosts hw)))
>>>>>>> cf9a26d66ca5c588771da4de08f64adbfea58751

(defun stop-gosts ()
  (reblocks/server:stop)
  (when (postmodern:connected-p postmodern:*database*)
    (postmodern:disconnect postmodern:*database*)))




#+nil (start-gosts)
#+nil (stop-gosts)

<<<<<<< HEAD
#+nil (defparameter *vsegost-com-Data* "//n133906/home/_namatv/public_html/Site/GOST-2025/Data/")
=======

(reblocks/widget:defwidget root-page ()
  ())

(defun make-root-page ()
      (make-instance 'root-page))

(defmethod reblocks/widget:render ((root-page root-page))
  (reblocks/html:with-html ()
    (:div
     (:h1 "Страницы")
     (:p (:a :href "/apps/gosts/" "gosts"))
     (:p (:a :href "/apps/hw/"    "hw"))
     (:p (:a :href "https://mnasoft.ddns.net/common-lisp/systems/docs/"    "Проекты"))
     (:p (:a :href "/common-lisp/systems/docs/"    "Проекты"))
     
     )
    (:footer (make-w-img-refs *img-ref-data*))
    ))



(reblocks/app:defapp root
  :prefix "/"
  :routes ((page ("/" :name "root")
             (make-root-page))))

#+nil
(defapp welcome-screen-app
  :prefix "/")

#+nil
(defmethod reblocks/page:init-page ((app welcome-screen-app) (url-path string) expire-at)
           (check-type expire-at (or null local-time::timestamp))
           "Hello world!")

>>>>>>> cf9a26d66ca5c588771da4de08f64adbfea58751
