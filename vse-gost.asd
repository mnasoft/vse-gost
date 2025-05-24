;;;; vse-gost.asd

(defsystem "vse-gost"
  :description #.(uiop:read-file-string "doc/long-description.txt")
  :long-description #.(uiop:read-file-string "doc/long-description.txt")
  :perform (load-op (op system)
             (format t "~&Загрузка завершена!~%")
             (format t "~&Описание системы: ~A~%" 
                     (asdf:system-description system)))  
  :author "Mykola Matvyeyev <mnasoft@gmail.com>"
  :license "GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007 or later"  
  :depends-on ("cl-ppcre" "plump")
  :serial nil
  :components ((:module "src"
		:serial t :components ((:file "vse-gost")
                                       (:file "parameter")))))
(defsystem "vse-gost/docs"
  :description "Зависимости для сборки документации"
  :author "Mykola Matvyeyev <mnasoft@gmail.com>"
  :license "GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007 or later"  
  :depends-on ("vse-gost" "codex" "mnas-package")
  :components ((:module "src/docs"
		:serial nil
                :components ((:file "docs")))))
