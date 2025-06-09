(in-package #:vse-gost/web)

(reblocks/app:defapp hw
  :prefix "/"
  :routes ((page ("/" :name "hello-world")
             (make-string-widget "Hello World!"))))

(defun start (&key (port 8081))
  (reblocks/server:start :port port
                         :apps '(hw)))

#+nil
(start)
#+nil
(reblocks/server:stop)

