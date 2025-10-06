(in-package #:vse-gost/web)

#+nil
(reblocks/app:defapp hw
  :prefix "/apps/hw/"
  :routes ((page ("/" :name "hello-world")
             (make-string-widget "<H1>Hello World!</H1>
<p>Приветствую Вас друзья на З.О.</p>
"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(reblocks/widget:defwidget hw-page ()
  ())

(defun make-hw-page ()
      (make-instance 'hw-page))

(defmethod reblocks/widget:render ((hw-page hw-page))
  (reblocks/html:with-html ()
    (:div ;; :style "display: flex; flex-direction: column;"  gap: 0.25rem
     (:h1 "Hello World!")
     (:p "Приветствую Вас друзья на З.О.")
     (:p (:a :href "/apps/gosts/" "gosts")))))


(reblocks/app:defapp hw
  :prefix "/apps/hw/"
  :routes ((page ("/" :name "hello-world")
             (make-hw-page))))




