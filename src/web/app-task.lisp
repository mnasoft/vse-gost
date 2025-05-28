(in-package #:vse-gost/web)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; defvar
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar *store* (make-hash-table)
  "Dummy store for tasks: id -> task.")

(defvar *counter* 0
  "Simple counter for the hash table store.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; task
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defclass task ()
  ((id :initarg :id
       :initform (error "Field ID is required")
       :accessor id
       :type integer)
   (title :initarg :title
          :initform ""
          :accessor title)
   (description :initarg :description
                :initform ""
                :accessor description)
   (done :initarg :done
         :initform nil
         :accessor done)))

(defun make-task (title &key done)
  "Create a task and store it by its id."
  (let* ((id (incf *counter*))
         (task (make-instance 'task :title title :done done :id id)))
    (setf (gethash id *store*) task)
    task))

(defun get-task (id)
  (gethash id *store*))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; list-item
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(reblocks/widget:defwidget list-item ()
  ((task :initarg :task
         :type task
         :reader task)))

(defun make-list-item (task)
  (make-instance 'list-item
                 :task task))

(defmethod reblocks/widget:render ((list-item list-item))
  (let ((task (task list-item)))
    (with-html ()
      (:p (:input :type "checkbox"
                  :checked (done task)
                  :onclick (make-js-action
                            (lambda (&key &allow-other-keys)
                              (toggle list-item))))
          (if (done task)
              (:s (title task))
              (title task))))))

(defun toggle (list-item)
  (let ((task (task list-item)))
    (setf (done task)
          (if (done task)
              nil
              t))
    (update list-item)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; task-list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(reblocks/widget:defwidget task-list ()
  ((items
    :initarg :items
    :type     (soft-list-of list-item)
    :accessor list-items)))

(defun make-task-list (&rest task-titles)
  (let ((items (loop :for title in task-titles
                     :for task = (make-task title)
                     :collect (make-list-item task))))
    (make-instance 'task-list :items items)))

(defmethod reblocks/widget:render ((task-list task-list))
  (with-html ()
    (:h1 "Tasks")
    (loop :for item :in (list-items task-list) :do
      (reblocks/widget:render item))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; defapp tasks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(reblocks/app:defapp tasks
  :prefix "/"
  :routes ((page ("/" :name "tasks-list")
             (make-task-list "First"
                             "Second"
                             "Third"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun start (&key (port 8080))
  (reblocks/server:start :port port
                         :apps '(tasks)))

#+nil
(start)
#+nil
(reblocks/server:stop)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; reblocks-tests
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#+nil
(progn
  (ql:quickload :reblocks-tests)
  (reblocks-tests/utils:with-test-session ()
    (render
     (make-list-item
      (make-task "Make my first Reblocks app")))))
