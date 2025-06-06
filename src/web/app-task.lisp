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

(defun toggle (list-item)
  (let ((task (task list-item)))
    (setf (done task)
          (if (done task)
              nil
              t))
    (update list-item)))

;; Новая версия
(defmethod reblocks/widget:render ((list-item list-item))
  (let* ((task (task list-item))
         ;; Here is how URL reversing works:
         (details-url
           (route-url "task-details"
                      :task-id (id task))))
    (with-html ()
      (:p (:input :type "checkbox"
                  :checked (done task)
                  :onclick (make-js-action
                            (lambda (&key &allow-other-keys)
                              (toggle list-item))))
          (:a :href details-url
              (if (done task)
                  (:s (title task))
                  (title task)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; task-list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(reblocks/widget:defwidget task-list ()
  ((items :initarg :items
          :type     (soft-list-of list-item)
          :accessor list-items)))

(defun make-task-list (&rest task-titles)
  (let ((items
          (loop :for title in task-titles
                :for task = (make-task title)
                :collect (make-list-item task))))
    (make-instance
     'task-list :items items)))

(defun add-task (task-list  title)
  (serapeum:push-end (make-list-item (make-task title))
                     (list-items task-list))
  (update task-list))

(defmethod reblocks/widget:render ((task-list task-list))
  (with-html ()
    (:h1 "Tasks")
    (loop :for item :in (list-items task-list) :do
      (reblocks/widget:render item))
    ;; Form for adding a new task
    (flet ((on-submit (&key title &allow-other-keys)
             (add-task task-list title)))
      (:form :onsubmit (make-js-form-action #'on-submit)
             (:input :type "text"
                     :name "title"
                     :placeholder "Task's title")
             (:input :type "submit"
                     :class "button"
                     :value "Add")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Task page
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defwidget task-page ()
  ((task :initarg :task
         :type task
         :accessor task)
   (edit-mode-p :initform nil
                :type boolean
                :accessor edit-mode-p)))

(defun make-task-page (task-id)
  (let ((task (get-task task-id)))
    (cond
      (task (make-instance 'task-page :task task))
      (t    (reblocks/response:not-found-error
             (format nil "Task with id ~A not found."
                     task-id))))))

(defmethod render ((task-page task-page))
  (let ((task (task task-page))
        ;; This is the way how we can get URL path
        ;; pointing to another page without hardcoding it.
        (list-url (route-url "tasks-list")))
    (with-html ()
      (:div :style "display: flex; flex-direction: column; gap: 1rem"
            (:h1 :style "display: flex; gap: 1rem; margin-bottom: 0"
                 (:b (if (done task)
                         "[DONE]"
                         "[TODO]"))
                 (:span :style "font-weight: normal"
                        (title task)))
            (:div (if (string= (description task) "")
                      "No defails on this task."
                      (description task)))
            (:div :style "display: flex; gap: 1rem"
                  (:a :href list-url
                      "Back to task list."))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; defapp tasks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defapp tasks
  :prefix "/"
  :routes ((page ("/<int:task-id>" :name "task-details")
             (make-task-page task-id))
           (page ("/" :name "tasks-list")
             (make-task-list "First"
                             "Second"
                             "Third"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun start-tasks (&key (port 8081))
  (reblocks/server:start :port port
                         :apps '(tasks)))

#+nil
(start-tasks)
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
