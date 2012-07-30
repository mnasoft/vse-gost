(defvar *fib-summ* 0 )
(defvar *fib-2* 1 )
(defvar *fib-1* 0 )

(defun pth-Catalog->Data(str_catalog)
  (let 
    ((catalog_shtml_files (directory str_catalog)))
    (mapcar (function map_shtml_file) catalog_shtml_files))
)

(defun map_shtml_file(file_shtml)
"Для каждого shtml файла выполняет:
1 Поиск имен файлов с расширением gif в подходящем каталоге;
2 Создание отсортированного списка имен gif файлов и переименованных gif файлов;
3 Переименовывает gif фаайлы согласно схемы переименования;
4 При помощи внешней команды создает pdf файл;
5 Переименовывает gif фаайлы обратно схеме переименования.
"
  (let 
    ( (gif_file_from_to_list
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
        (function (lambda (el1 el2  )(string< (namestring (cadr el1))(namestring (cadr el2))))))));; Сортируем список.
    (mapcar 
      (function
        (lambda (el)
          (let 
            ( (car_el (car el)) (cadr_el (cadr el)))
            (if (string/= (namestring car_el) (namestring cadr_el))
              (rename-file car_el cadr_el)))))
      gif_file_from_to_list) ;; Выполняем прямое переименование.
    (format t "~a~%" file_shtml)
    (if gif_file_from_to_list
      (EXT:EXECUTE "/usr/bin/convert" 
        (string-concat (directory-namestring (cadr (car gif_file_from_to_list))) "*.gif") 
        (string-concat (directory-namestring (cadr (car gif_file_from_to_list))) "gost.pdf")))
    (mapcar 
      (function
        (lambda (el)
          (let ((car_el (car el)) (cadr_el (cadr el)))
            (if (string/= (namestring car_el) (namestring cadr_el))
              (rename-file cadr_el car_el)))))
      gif_file_from_to_list) ;; Выполняем обратное переименование.
  )
)

(defun trim-directory-from-tail(input_path find_directory)
"Возвращает путь, отсекая от пути input_path все каталоги начиная с конца
пока не встретится подкаталог с именем find_directory."
  (let
    (
      (dir_str_list (reverse (pathname-directory input_path)))
      (if_vsegost_find nil)
    )
    (mapcar
      (function
        (lambda (el)
          (cond
            ( if_vsegost_find T)
            ( (string= el find_directory) (setq if_vsegost_find T) T)
            ( (or (eq el :ABSOLUTE) (eq el :RELATIVE)))
            ( T (setq dir_str_list (cdr dir_str_list)) T))))
      dir_str_list
    )
    (directory-list>directory-string (reverse dir_str_list)))
)

(defun path-name-type(str_path)
"Разбивает полное имя файла на: str_name - имя файла; str_type - расширение файла; str_directory - путь.
Возвращает путь к файлу.
Например: (path-name-type \"/usr/local/name.ext\") -> \"/usr/local/\"
str_name -> \"name\" ; str_type -> \"ext\" ; str_directory -> \"/usr/local/\". "
  (let 
    (
      (str_name (pathname-name str_path))
      (str_type (pathname-type str_path))
      (str_directory (directory-namestring str_path)))
      (list str_name str_type str_directory)
   )
)

(defun rename-gif-file(str_path)
"Возвращает преобразованное имя файла, задаваемого в переменной str_path.
Преобразование заключается в том, что при длине имени в один символ имя предварялось символом 0.
Например: #P\"X.gif\" -> #P\"0X.gif\""
  (let 
    (
      (str_rez "")
      (str_name (pathname-name str_path))
      (str_type (pathname-type str_path))
      (str_directory (directory-namestring str_path)))
    (if (null str_type) (setq str_type ""))
    (cond
      ( (<= (length str_name) 6 )
        (setq 
          str_rez 
          (string-concat 
            str_directory 
            (make-string (- 6 (length str_name)) :initial-element  #\0)
            str_name "." str_type)))
      ( (> (length str_name) 6)
        (setq str_rez (string-concat str_directory str_name "." str_type)))
    )
    (pathname str_rez))
)