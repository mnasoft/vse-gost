(in-package :vse-gost)

(directory "/home/mna/public_html/vsegost.com/Catalog/*/*.shtml.html")
(length (directory "/home/mna/public_html/vsegost.com/Catalog/*/*.shtml.html"))

(defun designation (root-node)
  "Обозначение Стандарта"
  (first 
   (loop :for h1 :in (plump-dom:get-elements-by-tag-name root-node "h1")
         :collect (plump:text (aref (plump:children h1) 0))
         )))

(defun name (root-node)
  "Наименование Стандарта"
  (first
   (loop :for h2 :in (plump-dom:get-elements-by-tag-name root-node "h2")
         :collect (plump:text (aref (plump:children h2) 0))
         )))

(defun description (root-node)
  "Краткиое описание Стандарта"
  (first 
   (loop :for p :in (plump-dom:get-elements-by-tag-name root-node "p")
         :collect (plump:text (aref (plump:children p) 1)))))

(defun status (root-node)
  "Статус. Действующий или нет"
  (first
   (loop :for p :in (plump-dom:get-elements-by-tag-name root-node "p")
         :collect (plump:text (aref (plump:children p) 0))
         )))

(defun extract-date (string)
  (cl-ppcre:register-groups-bind (result)
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

(defun out (root-node &optional (stream t))
  (format stream "~{~A~^	~}~%" (list 
                         (local-path root-node)
                         (designation root-node)
                         (date root-node)
                         (name root-node)
                         (description root-node)
                         (status root-node))))

(with-open-file (stream "/home/mna/out.txt" :direction :output :if-exists :supersede)
  (loop :for d :in (directory "/home/mna/public_html/vsegost.com/Catalog/*/*.shtml.html")
        do 
           (out d stream)))
