(load "/media/358289b8-1f08-40ad-b8d9-e0afcfaffa3e/namatv/git/clisp/Vse_Gost_Scaner/directory.lsp")
(load "/media/358289b8-1f08-40ad-b8d9-e0afcfaffa3e/namatv/git/clisp/Vse_Gost_Scaner/open_file.lsp")

(defun pth-name-format (str_path)
"Выводит на печать переменные, определенные в функции path-name-type."
  (path-name-type str_path)
  (format t "~a~%~a~%~a~%" str_name str_type str_directory)
)

(defun directory-list>directory-string (dlist)
"Выполняет сборку пути к каталогу, основываясь на результате вывода функции pathname-directory."
  (setq str_rez "")
  (mapcar
    (function
      (lambda (el)
        (cond
          ( (equal el :RELATIVE) (setq str_rez "./"))
          ( (equal el :ABSOLUTE) (setq str_rez "/"))
          ( (equal (quote SIMPLE-BASE-STRING) (car (type-of el)))
            (setq str_rez (string-concat str_rez el "/")))
          ( T (format t "~a~%" (type-of el))))))
    dlist
  )
  str_rez
)

(defun pth-name-shtml (str_path)
"По имени shtml файла выполняет поиск каталога в, котором находятся gif файлы, предназначенные для переименования"
  (path-name-type str_path)
  (setq str_directory (trim-directory-from-tail str_directory "vsegost.com"))
  (setq str_rez "")
  (if (null str_type) (return nil))
  (cond
    ( (= 1 (length str_name))
      (setq str_rez (string-concat str_directory "./Data/0/" str_name "/")))
    ( (= 2 (length str_name))
      (setq str_rez (string-concat str_directory "./Data/0/" str_name "/")))
    ( (= 3 (length str_name))
      (setq str_rez (string-concat str_directory "./Data/" (substring str_name 0 1) "/" str_name "/"))
    )
    ( (= 4 (length str_name))
      (setq str_rez (string-concat str_directory "./Data/" (substring str_name 0 2) "/" str_name "/"))
    )
    ( (= 5 (length str_name))
      (setq str_rez (string-concat str_directory "./Data/" (substring str_name 0 3) "/" str_name "/"))
    )
  )
  str_rez
)

(defun rename-gif-file(str_path)
"Возвращает преобразованное имя файла, задаваемого в переменной str_path.
Преобразование заключается в том, что при длине имени в один символ имя предварялось символом 0.
Например: #P\"X.gif\" -> #P\"0X.gif\""
  (path-name-type str_path)
;;(format t "~a~%" str_directory)
  (setq str_rez "")
  (if (null str_type) (return nil))
  (cond
    ( (= 1 (length str_name))
      (setq str_rez (string-concat str_directory "0" str_name "." str_type)))
    ( (<= 2 (length str_name))
      (setq str_rez (string-concat str_directory str_name "." str_type)))
  )
  (pathname str_rez)
)

(defun path-name-type(str_path)
"Разбивает полное имя файла на: str_name - имя файла; str_type - расширение файла; str_directory - путь.
Возвращает путь к файлу.
Например: (path-name-type \"/usr/local/name.ext\") -> \"/usr/local/\"
str_name -> \"name\" ; str_type -> \"ext\" ; str_directory -> \"/usr/local/\". "
  (setq
    str_name (pathname-name str_path)
    str_type (pathname-type str_path)
    str_directory (directory-namestring str_path))
)

(defun walk-vsegost()
  "Прогулка по всем файлам сайта vsegost.com"
  (setq massa (open "/tmp/gost-rez.txt" :direction :output))
  (walk-directory 
    "/media/358289b8-1f08-40ad-b8d9-e0afcfaffa3e/namatv/vsegost.com/Catalog" 
    (function gost-obozn-type))
  (close massa)
)

(defun trim-directory-from-tail(input_path find_directory)
"Возвращает путь, отсекая от пути input_path все каталоги начиная с конца пока не встретится подкаталог с именем find_directory."
  (setq dir_str_list (reverse (pathname-directory input_path)))

  (setq if_vsegost_find nil )
  (mapcar
    (function
      (lambda (el)
        (cond
          ( if_vsegost_find
          )
          ( (string= el find_directory)
            (setq if_vsegost_find T)
          )
          ( (or (eq el :ABSOLUTE) (eq el :RELATIVE)) 
          )
          ( T
            (setq dir_str_list (cdr dir_str_list))
            T
          )
        )
      )
    )
    dir_str_list
  )
  (directory-list>directory-string (reverse dir_str_list))
)

(defun map_shtml_file(file_shtml)
"Для каждого shtml файла выполняет:
1 Поиск имен файлов с расширением gif в подходящем каталоге;
2 Создание отсортированного списка имен gif файлов и переименованных gif файлов;
3 Переименовывает gif фаайлы согласно схемы переименования;
4 При помощи внешней команды создает pdf файл;
5 Переименовывает gif фаайлы обратно схеме переименования.
"
  (setq gif_file_from_to_list
    (sort
      (mapcar
        (function
          (lambda (el)
              (list el (rename-gif-file el))
          )
        ) ;; Создаём список, содержащий пары имен файлов типа gif для переименования.
        (directory
          (string-concat
            (pth-name-shtml file_shtml)
            "*.gif")) ;; Поиск файлов с расширением gif. 
      )
      (function (lambda (el1 el2  )(string< (namestring (cadr el1))(namestring (cadr el2))))))
  ) ;; Сортируем список.
  (mapcar 
    (function
      (lambda (el)
        (if (string/= (namestring(car el)) (namestring(cadr el)))
          (rename-file (car el) (cadr el)))))
    gif_file_from_to_list
  ) ;; Выполняем прямое переименование.
  (format t "~a~%" file_shtml)
  (if gif_file_from_to_list
    (EXT:EXECUTE "/usr/bin/convert" 
      (string-concat (directory-namestring (cadr (car gif_file_from_to_list))) "*.gif") 
      (string-concat (directory-namestring (cadr (car gif_file_from_to_list))) "gost.pdf")))
  (mapcar 
    (function
      (lambda (el)
        (if (string/= (namestring(car el)) (namestring(cadr el)))
          (rename-file (cadr el) (car el)))))
    gif_file_from_to_list
  ) ;; Выполняем обратное переименование.
)

(defun pth-Catalog->Data(str_catalog)
  (setq catalog_shtml_files (directory str_catalog))
  (mapcar
    (function map_shtml_file) 
    catalog_shtml_files)
)

;; (map_shtml_file "/media/358289b8-1f08-40ad-b8d9-e0afcfaffa3e/namatv/vsegost.com/Catalog/11/11623.shtml")
;; (map_shtml_file "/media/358289b8-1f08-40ad-b8d9-e0afcfaffa3e/namatv/vsegost.com/Catalog/12/12615.shtml")

;; (directory #P"/media/358289b8-1f08-40ad-b8d9-e0afcfaffa3e/namatv/vsegost.com/Data/**/*.gif")
;; (directory #P"/media/358289b8-1f08-40ad-b8d9-e0afcfaffa3e/namatv/vsegost.com/Catalog/**/*.shtml")

;; (pth-Catalog->Data "/_storage/otd11/namatv/vsegost.com/Catalog/**/*.shtml")
;; (pth-Catalog->Data "/media/358289b8-1f08-40ad-b8d9-e0afcfaffa3e/namatv/vsegost.com/Catalog/**/*.shtml")