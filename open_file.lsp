;; Пример использования
;; (load "gif_to_pdf.lsp")
;; (load "open_file.lsp")
;; (defparameter *html-vsegost* (walk-vsegost #P"/home/namatv/sdb7/namatv/vsegost.com/Catalog/**/*.shtml"))
;; (create-html-vsegost *html-vsegost*)
;; 
;; 
;; 
;; (clear-var-list '(s_tag e_tag str_l s_tag_l e_tag_l tag_start tag_end str_rez))
;; (gost-obozn-type "/home/namatv/ftp/vsegost.com/Catalog/69/6976.shtml")
;; (gost-obozn-type "/media/358289b8-1f08-40ad-b8d9-e0afcfaffa3e/namatv/vsegost.com/Catalog/69/6976.shtml")

(defvar str_rez "")
(defparameter *latin-looks-like-cirillic* "ABCEHKMOPTXaceopxy")
(defparameter *cirillic-looks-like-latin* "АВСЕНКМОРТХасеорху")

(defun create-html-vsegost(dir_gostObozn_gostName_lst)
"Основываясь на списке, передаваемом в параметре dir_gostObozn_gostName_lst,
формирует таблицу, содержащую перечень ГОСТ"
  (let 
    ( (out (open "/tmp/index.php" :direction :output)))
    (format out "<html>~%")
    (format out "<head>~%")
    (format out "<meta http-equiv=\"content-type\" content=\"text/html; charset=UTF-8\" />~%")
    (format out "<title>MNAsoft.ГОСТ</title>~%")
    (format out "<link rel=\"stylesheet\" type=\"text/css\" href=\"http://mnasoft.mksat.net/mnasoft_style.css\" />~%")
    (format out "<meta name=\"keywords\" content=\"MNASoft,ГОСТ\"/>~%")
    (format out "<meta name=\"author\" content=\"Николай Матвеев\"/>~%")
    (format out "<body>~%")
    (php-page-counter out)
    (format out "<table border='2' cols='2'>~%")
    (format out "<caption>Перечень ГОСТ по наименованию</caption>~%")
    (format out "<tbody>~%")
    (format out "<tr><th>~A</th><th>~A</th></tr>~%" "Обозначение" "Наименование")
    (mapcar 
      (function
        (lambda(el)
          (let*
            ( (n-tp-p (path-name-type (car el)))
              (n (car n-tp-p))
              (tp (cadr n-tp-p))
              (p (caddr n-tp-p)))
            (setq p (concatenate 'string "http://www.vsegost.com/" (trim-directory-from-head p "vsegost.com")))
            (format out "<tr>")
            (format out "<td><a href=\"~A~A.~A\">~A</a></td>" p n tp (cadr el))
            (format out "<td>~A</td></tr>" (caddr el))
            (format out "</tr>~%")
          )))
    dir_gostObozn_gostName_lst)
    (format out "</tbody>~%")
    (format out "</table>~%")
    (format out "</body>~%")
    (format out "</html>~%")
    (close out)
  )
)

(defun php-page-counter(output_html_file)
"Выполняет вывод в файл output_html_file код для подсчета числа обращений к файлу."
  (format output_html_file "<?php ~%")
  (format output_html_file "$inc_path=\"/var/www/virtual/mnasoft.mksat.net/htdocs/php/includes\"; ~%")
  (format output_html_file "set_include_path($inc_path); ~%")
  (format output_html_file "include \"counter.php\"; ~%")
  (format output_html_file "?> ~%"))

(defun walk-vsegost(path-to-shtml-files)
"Прогулка по всем файлам сайта vsegost.com"
  (let*
    ( (rez
        (mapcar 
          (function 
            (lambda (el)
              (gost-obozn-type el)))
          (directory path-to-shtml-files))))
    (setq
      rez
      (sort rez
        (function
          (lambda (el1 el2  )
            (string< (caddr el1) (caddr el2))))))))

(defun gost-obozn-type(gost_path)
"Выполняет разбор одиночного shtml файла.
Ищет в тегах h1 и h2 обозначение и наименование ГОСТ.
Волзвращает список, состоящий из:
- пути к обрабатываемому файлу;
- обозначения ГОСТ;
- наименования ГОСТ."
  (let
    (
      (in_shtml_file (open gost_path :direction :input))
      (in_shtml_file_eof-error-p nil)
      (atag "h1")
      (str "")
      (str-h1 "")
      (str-h2 "")
    )
    (loop until in_shtml_file_eof-error-p do
      (setq str (read-line in_shtml_file in_shtml_file_eof-error-p))
      (if (or (not str) in_shtml_file_eof-error-p) 
        (progn 
          (close in_shtml_file)
          (return
            (list gost_path str-h1 str-h2))))
      (setq str_rez (str-tag str atag))
      (cond
        ( (and (string/= str_rez "") (string= atag "h1"))
          (setq str-h1 str_rez)
          (setq atag "h2"))
        ( (and (string/= str_rez "") (string= atag "h2"))
          (setq str-h2 str_rez)
          (close in_shtml_file)
          (return 
            (list gost_path str-h1 str-h2)))))
    (list gost_path str-h1 
      (string-translate 
        (string-trim " " str-h2) 
        *latin-looks-like-cirillic* 
        *cirillic-looks-like-latin*))))

(defun str-tag-p(str tag)
""
  (let*
    (
      (str (string-trim '(#\Space #\Tab #\Newline) str))
      (s_tag (string-concat "<" tag ">"))
      (e_tag (string-concat "</" tag ">"))
      (str_l (length str))
      (s_tag_l (length s_tag))
      (e_tag_l (length e_tag))
      (tag_start nil)
      (tag_end nil)
;;       (str_rez nil)
    )
    (cond
      ( (<= (- str_l s_tag_l e_tag_l) 0)
        (setq str_rez "")
        nil)
      ( t
        (setq
          tag_start (subseq  str 0 s_tag_l)
          tag_end (subseq  str (- str_l e_tag_l) str_l)
          str_rez (subseq  str s_tag_l (- str_l e_tag_l)))
        (and (string= tag_start s_tag) (string= tag_end e_tag))))))

(defun str-tag(str tag)
"!"
  (if (str-tag-p str tag) str_rez "")
)

(defun clear-var-list(var_lst)
""
  (mapcar 
    (function(lambda(el) (makunbound el )))
    var_lst
  )
)

(defun clear-func-list(func_lst)
""
  (mapcar 
    (function(lambda(el) (fmakunbound el )))
    func_lst
  )
)

(defun string-translate(str str-from str-to)
"Выполняет изменение символов строки str,
основываясь на преобразовании заданном словарями str-from и str-to.
Если символ строки присутствует в словаре str-from,
то он заменяется на символ, находящийся на той же позиции в словаре str-to.
Например:
(string-translate \"Это\" \"т\" \"1\")
"
  (loop 
    for ch in (concatenate 'list str)
    for i from 0
    do
    (let
      ((ch-pos (position ch str-from)))
      (if ch-pos 
        (setf (char str i) (char str-to ch-pos)))))
  str)
  
(mapcar ;; Компиляция функций
  (function
    (lambda (el) (compile el)))
  '(create-html-vsegost 
    php-page-counter 
    walk-vsegost 
    gost-obozn-type 
    str-tag-p 
    str-tag 
    clear-var-list 
    clear-func-list 
    string-translate))
