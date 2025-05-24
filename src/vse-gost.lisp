;;;; ./src/vse-gost.lisp

(defpackage :vse-gost
  (:use #:cl)
  (:export *vsegost-Catalog*
           *vsegost-Data*)
  (:intern  designation
            name
            description
            status
            extract-date
            date
            gifs
            local-path
            print-record
            )
  (:export create-sql-import-file
           )
  (:documentation "Пакет содержит"))

(in-package :vse-gost)

(defun clean-spaces (str)
  (string-trim
   " "
   (cl-ppcre:regex-replace-all
    " +"
    (cl-ppcre:regex-replace-all "[\\t\\n\\r]" str " ")
    " ")))

(defun designation (root-node)
  "@b(Описание:) функция @b(designation) возвращает обозначение
 стандарта.

 @b(Пример использования:)
@begin[lang=lisp](code)
  (let* ((files 
           (directory
            (concatenate 'string 
                         (namestring *vsegost-Catalog*)
                         \"*/*.shtml.html\")))
         (n (random (length files)))
         (root-node 
           (plump:parse (nth n files))))
    (designation root-node))
@end(code)
"
  (let* ((chdrn (plump:children
                 (first (plump-dom:get-elements-by-tag-name root-node "h1"))))
         (ad (first (array-dimensions chdrn))))
    (if (> ad 0) (clean-spaces (plump:text (aref chdrn 0))) "")))

(defun name (root-node)
  "@b(Описание:) функция @b(name) возвращает наименование стандарта.

 @b(Пример использования:)
@begin[lang=lisp](code)
  (let* ((files 
           (directory
            (concatenate 'string 
                         (namestring *vsegost-Catalog*)
                         \"*/*.shtml.html\")))
         (n (random (length files)))
         (root-node 
           (plump:parse (nth n files))))
    (name root-node))
@end(code)
"
  (let* ((chdrn (plump:children
                 (first (plump-dom:get-elements-by-tag-name root-node "h2"))))
         (ad (first (array-dimensions chdrn))))
    ;;(name root-node)
    (if (> ad 0)
        (clean-spaces (plump:text (aref chdrn 0))) "")))

(defun description (root-node)
  "@b(Описание:) функция @b(name) возвращает краткиое описание стандарта.
 @b(Пример использования:)
@begin[lang=lisp](code)
  (let* ((files 
           (directory
            (concatenate 'string 
                         (namestring *vsegost-Catalog*)
                         \"*/*.shtml.html\")))
         (n (random (length files)))
         (root-node 
           (plump:parse (nth n files))))
    (description root-node))
@end(code)
"
  (let* ((chdrn (plump:children
                 (first
                  (plump-dom:get-elements-by-tag-name root-node "p"))))
         (ad (first (array-dimensions chdrn))))
    (if (> ad 1) (clean-spaces (plump:text (aref chdrn 1))) "")))

(defun status (root-node)
  "@b(Описание:) функция @b(name) возвращает статус стандарта (действующий или нет).

 @b(Пример использования:)
@begin[lang=lisp](code)
  (let* ((files 
           (directory
            (concatenate 'string 
                         (namestring *vsegost-Catalog*)
                         \"*/*.shtml.html\")))
         (n (random (length files)))
         (root-node 
           (plump:parse (nth n files))))
    (status root-node))
@end(code)"
  (let* ((chdrn (plump:children
                 (first (plump-dom:get-elements-by-tag-name root-node "p"))))
         (ad (first (array-dimensions chdrn))))
    (if (> ad 0)
        (clean-spaces (plump:text (aref chdrn 0))) "")))

(defun extract-date (string)
  (ppcre:register-groups-bind (result)
      ("-(\\d*)$" string)
    (let ((year (parse-integer result)))
      (when (<= year 99)  (incf year 1900))
      (format nil "~A-06-01" year))))

(defun date (root-node)
  "@b(Описание:) функция @b(name) возвращает год выпуска.

 @b(Пример использования:)
@begin[lang=lisp](code)
  (let* ((files 
           (directory
            (concatenate 'string 
                         (namestring *vsegost-Catalog*)
                         \"*/*.shtml.html\")))
         (n (random (length files)))
         (root-node 
           (plump:parse (nth n files))))
    (date root-node))
@end(code)"
  (labels ()
    (extract-date (designation root-node))))

(defun gifs (root-node)
  "@b(Описание:) функция @b(name) возвращает относительные пути к
 сканированным страницам.

 @b(Пример использования:)
@begin[lang=lisp](code)
  (let* ((files 
           (directory
            (concatenate 'string 
                         (namestring *vsegost-Catalog*)
                         \"*/*.shtml.html\")))
         (n (random (length files)))
         (root-node 
           (plump:parse (nth n files))))
    (gifs root-node))
@end(code)"
  (loop :for a :in (plump-dom:get-elements-by-tag-name root-node "a")
        :when (ppcre:scan "\\.\\./\\.\\./Data/" (plump:attribute a "href"))
          :collect
          (plump:attribute a "href")))

(defun local-path (root-node)
  "@b(Описание:) функция @b(name) возвращает путь к документу на
локальном сервере.

 @b(Пример использования:)
@begin[lang=lisp](code)
  (let* ((files 
           (directory
            (concatenate 'string 
                         (namestring *vsegost-Catalog*)
                         \"*/*.shtml.html\")))
         (n (random (length files)))
         (root-node 
           (plump:parse (nth n files))))
    (local-path root-node))
@end(code)"
  (ppcre:regex-replace-all "^\\.\\./\\.\\./Data/|/[^/]*$"
                              (first (gifs root-node))
                              ""))

(defun print-record (root-node &optional (stream t))
  "@b(Описание:) функция @b(name) записывает запись в поток @b(stream).

 @b(Пример использования:)
@begin[lang=lisp](code)
  (let* ((files 
           (directory
            (concatenate 'string 
                         (namestring *vsegost-Catalog*)
                         \"*/*.shtml.html\")))
         (n (random (length files)))
         (root-node 
           (plump:parse (nth n files))))
    (print-record root-node))
@end(code)"
  (let ((local-path (local-path root-node))
        (date (date root-node))
        )
    (when (and local-path date)
      (format stream "~{~A~^	~}~%" (list 
                                       local-path ;; Проверено
                                       (designation root-node) ;; Проверено
                                       date   ;; Проверено
                                       (name root-node)  ;; Проверено
                                       (description root-node) ;; Проверено
                                       (status root-node) ;; Проверено
                                       )))))

(defun create-sql-import-file (f-name vsegost-catalog-dir
                               &aux
                                 (dir-template
                                  (concatenate 'string
                                               vsegost-catalog-dir
                                               "/*/*.shtml.html")))
  "@b(Описание:)
@b(create-sql-import-file) выполняет формирование файла для
 импортирования таблицы ГОСТ в PostgreSQL.

 @b(Переменые:)
@begin(list)
 @item(f-name - имя файла, в который выводится информация с данными
 для формирования таблицы, содержащей информацию о ГОСТ.)
 @item(vsegost-catalog-dir - расположение каталога vsegost.com/Catalog
на зеркале сайта;)

@end(list)

 @b(Пример использования:)
@begin[lang=lisp](code)
 (create-sql-import-file \"/home/namatv/out.txt\"
                         \"/home/namatv/public_html/vsegost.com/Catalog\")
@end(code)
"
  (let ((start (get-universal-time)))
  (with-open-file (stream f-name :direction :output :if-exists :supersede)
    (loop :for d :in (directory dir-template)
          :for i :from 0
          :do
             #+nil (format stream "~8D " i) ;; Нужно только для отладки
             (print-record (plump:parse d) stream)))
    (- (get-universal-time) start)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




(defun slynk-string-elision-length (&optional (length nil))
  (setf
   (cdr (assoc 'slynk:*string-elision-length* slynk:*slynk-pprint-bindings*)) length)
  slynk:*slynk-pprint-bindings*)

