(defpackage #:vse-gost/web
  (:use #:cl)
  (:import-from #:reblocks/widget
                #:render
                #:update
                #:defwidget)
  (:import-from #:reblocks/actions
                #:make-js-form-action
                #:make-js-action)
  (:import-from #:reblocks/app
                #:defapp)
  (:import-from #:reblocks/routes
                #:page)
  (:import-from #:serapeum
                #:soft-list-of)
  (:import-from #:40ants-routes/route-url
                #:route-url)
  (:import-from #:reblocks/html
                #:with-html)
  (:import-from #:reblocks/widgets/string-widget
                #:make-string-widget)
  (:shadowing-import-from #:40ants-routes/defroutes
                          #:get)
  (:export start-gosts
           stop-gosts)
  )

(in-package #:vse-gost/web)

;; sbcl
#+nil (asdf:load-system :vse-gost/web)
#+nil (save-lisp-and-die "vse-gost-web.exe"  :executable t :toplevel #'vse-gost/web:start-gosts :compression t)
