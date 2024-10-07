;;;; ./src/vse-gost.lisp

(defpackage :vse-gost
  (:use #:cl)
  (:export *vsegost-Catalog* *vsegost-Data*
	   main-create-bash-script-gif-pdf-convertion
           create-sql-import-file
           ))

(in-package :vse-gost)

(defun designation (root-node)
  "Обозначение Стандарта"
  (let* ((chdrn (plump:children
               (first (plump-dom:get-elements-by-tag-name root-node "h1"))))
       (ad (first (array-dimensions chdrn))))
  (if (> ad 0) (plump:text (aref chdrn 0)) "")))

(defun name (root-node)
  "Наименование Стандарта"
  (let* ((chdrn (plump:children
                 (first (plump-dom:get-elements-by-tag-name root-node "h2"))))
         (ad (first (array-dimensions chdrn))))
    ;;(name root-node)
    (if (> ad 0) (plump:text (aref chdrn 0)) "")))

(defun description (root-node)
  "Краткиое описание Стандарта"
  (let* ((chdrn (plump:children
                 (first
                  (plump-dom:get-elements-by-tag-name root-node "p"))))
         (ad (first (array-dimensions chdrn))))
    (if (> ad 1) (plump:text (aref chdrn 1)) "")))

(defun status (root-node)
  "Статус. Действующий или нет"
  (let* ((chdrn (plump:children
                 (first (plump-dom:get-elements-by-tag-name root-node "p"))))
         (ad (first (array-dimensions chdrn))))
    (if (> ad 0) (plump:text (aref chdrn 0)) "")))

(defun extract-date (string)
  (ppcre:register-groups-bind (result)
      ("-(\\d*)$" string)
    (let ((year (parse-integer result)))
      (when (< year 99)  (incf year 1900))
      (format nil "~A-06-01" year))))

(defun date (root-node)
  "Год выпуска"
  (labels ()
 (extract-date  (designation root-node))))

(defun gifs (root-node)
  "Относительные пути к сканированным страницам"
  ;; gif-файлы
  (loop :for a :in (plump-dom:get-elements-by-tag-name root-node "a")
        :when (ppcre:scan "\\.\\./\\.\\./Data/" (plump:attribute a "href"))
          :collect
          (plump:attribute a "href")))


(defun remove-after-last-slash (str)
  (cl-ppcre:regex-replace-all "/[^/]*$" str "/"))

(defun local-path (root-node)
  "Путь к документу на локальном сервере"
  (remove-after-last-slash (first (gifs root-node))))

(defun external-path (root-node)
  "Путь к документу на локальном сервере"
  "external-path"
)

(defun print-record (root-node &optional (stream t))
  "Записывает запись в файл."
  (format stream "~{~A~^	~}~%" (list 
                                        (local-path root-node) ;; Проверено
                                        (designation root-node) ;; Проверено
                                        (date root-node) ;; Проверено
                                        (name root-node) ;; Проверено
                                        (description root-node) ;; Проверено
                                        (status root-node) ;; Проверено
                                       )))

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
 @item(vsegost-catalog-dir - расположение каталога vsegost.com/Catalog
на зеркале сайта;)
 @item(f-name - имя файла, в который выводится информация с данными
 для формирования таблицы, содержащей информацию о ГОСТ.)
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
             (format stream "~8D " i)
             (print-record (plump:parse d) stream)))
    (- (get-universal-time) start)))


