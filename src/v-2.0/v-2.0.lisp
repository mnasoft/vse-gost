(in-package :vse-gost)

(ql:quickload :plump)

(defparameter *files* (directory "/home/mna/public_html/vsegost.com/Catalog/*/*.shtml.html"))


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

(defun out-file (f-name dir-template)
  "
 @b(Пример использования:)
@begin[lang=lisp](code)
 (out-file \"/home/mna/out.txt\" \"/home/mna/public_html/vsegost.com/Catalog/*/*.shtml.html\")
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Участок для тестирования кода

#+nil
(let* ((root-node
         (plump:parse
          #P"/home/mna/public_html/vsegost.com/Catalog/60/60477.shtml.html"
          ;;#P"/home/mna/public_html/vsegost.com/Catalog/60/60476.shtml.html" 
          ))
       (chdrn (plump:children
               (first (plump-dom:get-elements-by-tag-name root-node "h1"))))
       (ad (first (array-dimensions chdrn))))
  (if (> ad 0) (plump:text (aref chdrn 0)) ""))

#+nil 
(loop :for d :in *files*
      :for i :from 0
      :do
         (format t "~6D ~S " i d)
         (out (plump:parse d) t))
