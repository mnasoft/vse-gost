(in-package #:vse-gost/web)

(reblocks/app:defapp hw
  :prefix "/"
  :routes ((page ("/" :name "tasks-list")
             (make-string-widget "Hello World!"))))

(defun start (&key (port 8080))
  (reblocks/server:start :port port
                         :apps '(hw)))

#+nil
(start)
#+nil
(reblocks/server:stop)

