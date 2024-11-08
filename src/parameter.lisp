;;;; ./src/parameter.lisp

(in-package :vse-gost)

(defparameter *vsegost-Catalog*
  (uiop:directory-exists-p 
   (concatenate  'string
                 (uiop:getenv "HOME") "/" "public_html/vsegost.com" "/" "Catalog" "/"))
  "@b(Описание:) Каталог в файловой системе, куда отзеркалированы данные
о ГОСТ.")


(defparameter *vsegost-Data*
  (uiop:directory-exists-p 
   (concatenate  'string
                 (uiop:getenv "HOME") "/" "public_html/vsegost.com" "/" "Data" "/"))
  "@b(Описание:) Каталог в файловой системе, куда отзеркалированы
gif-файлы, содержащие отсканированные изображения ГОСТ.")

