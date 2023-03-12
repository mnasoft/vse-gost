(in-package :vse-gost)

(declaim (optimize (debug 3)))
 
(defparameter oab "<")

(defparameter cab ">")

(defparameter sl "/")

(defparameter eol (format nil "~%"))

(defparameter tab (format nil "~A" #\TAB))

(defparameter crlf (format nil "~%"))

(defparameter *fn* "/home/namatv/Downloads/vsegost.com_1/Catalog/65/6548.shtml")
(defparameter *fn* "/home/namatv/Downloads/vsegost.com_1/Catalog/29/2905.shtml")

(defun cat (file)
  (with-open-file (str file :direction :input)
    (do
     ((line (read-line str nil 'eof) (read-line str nil 'eof))
      (str-rez "")
      )
     ((eql line 'eof) str-rez)
      (setf str-rez (concatenate 'string str-rez eol line)))))

;;;;(cat *fn*)

(defun get-tag(tag str &key (start 0))
  "Выполняет разбор парного невложенного тега
Возвращает:
- первым значением содержимое тега;
- вторым значением количество прочитанных символов;
- третьим значением содержимое преамбулы тега
"
  (let*
      ((o-tag (concatenate 'string oab tag))
       (o-tag-len (length o-tag))
       (c-tag (concatenate 'string  oab sl tag))
       (c-tag-len (length c-tag))
       (so nil)
       (sc nil)
       (eo nil)
       (ec nil))
    (if
     (and (setf so (search o-tag str :start2 start))
	  (setf sc (search cab str :start2 (+ so o-tag-len)))
	  (setf eo (search c-tag str :start2 (+ sc (length cab))))
	  (setf ec (search cab str :start2 (+ eo c-tag-len))))
     (values     (subseq str (+ sc (length cab)) eo)
		 (+ ec (length cab))
		 (subseq str (+ so o-tag-len) sc))
     nil)))

(defun parse-vsegost-shtml_bak (file)
  "Выполняет специальный парсинг shtml-файлов сайта vsegost.com
Возвращает список содержащий следующие поля
- относительный путь расположения gif-файлов;
- строку, содержащую обозначение ГОСТ;
- строку, содержащую наименование ГОСТ;
- строку, содержащую описание ГОСТ
Пример использования:
(parse-vsegost-shtml *fn*)
"
  (with-open-file (str file :direction :input)
    (do ((line (read-line str nil 'eof) (read-line str nil 'eof))
	 (oboznach nil)
	 (naimenovan nil)
	 (description nil)
	 (path-to-gifs nil))
	((or (and oboznach naimenovan description path-to-gifs)
	     (eql line 'eof)) (list  path-to-gifs oboznach naimenovan description )) ;;
      (cond
	((null oboznach)
	 (setf oboznach (get-tag "h1" line)))
	((and oboznach (null naimenovan))
	 (setf naimenovan (get-tag "h2" line))
	 (break ":1 ~S" (list line oboznach naimenovan description))
	 )
	((and oboznach naimenovan (null description))
	 (setf description (get-tag "p" line))
	 (break ":2 ~S" (list line oboznach naimenovan description))
	 )
	((and oboznach naimenovan  description (null path-to-gifs))
	 (break ":3 ~S" line)
	 (multiple-value-bind (tag-val ch-num tag-head) (get-tag "a" line)
	   (if tag-val
	       (progn
		 (setf path-to-gifs 
		       (make-pathname :directory (cons :relative (reverse (cdr (reverse (cddr (cl-ppcre:split "/" (second(cl-ppcre:split "'" tag-head))))))))))))))))))

(defun parse-vsegost-shtml (file)
  "Выполняет специальный парсинг shtml-файлов сайта vsegost.com
Возвращает список содержащий следующие поля
- относительный путь расположения gif-файлов;
- строку, содержащую обозначение ГОСТ;
- строку, содержащую наименование ГОСТ;
- строку, содержащую описание ГОСТ
Пример использования:
(parse-vsegost-shtml *fn*)
"
  (with-open-file (str file :direction :input)
    (do ((line (read-line str nil 'eof) (read-line str nil 'eof))
	 (oboznach nil)
	 (naimenovan nil)
	 (description nil)
	 (path-to-gifs nil))
	((or (and oboznach naimenovan description path-to-gifs) (eql line 'eof))
         (if path-to-gifs 
	     (list path-to-gifs oboznach naimenovan description )
             (list "Data/0000/0000/" oboznach naimenovan description )))
      (cond
	((null oboznach)                              (setf oboznach (get-tag "h1" line)))
	((and oboznach (null naimenovan))             (setf naimenovan (get-tag "h2" line)))
	((and oboznach naimenovan (null description)) (setf description (get-tag "p" line)))
	((and oboznach naimenovan description (null path-to-gifs))
	 (multiple-value-bind (tag-val ch-num tag-head) (get-tag "a" line)
	   (let ((tag-spit (cl-ppcre:split "/" (second(cl-ppcre:split "'" tag-head)))))
	     (if (and tag-val
		      (> (length tag-spit)3)
		      (string= ".." (first tag-spit))
		      (string= ".." (second tag-spit))
		      (string= "Data" (third tag-spit)))
		 (setf path-to-gifs (make-pathname :directory (cons :relative (reverse (cdr (reverse (cddr tag-spit)))))))))))))))

(defun string-filter-01(str)
  (setf str (cl-ppcre:regex-replace-all "<br>"  str " ")
	str (cl-ppcre:regex-replace-all tab  str " ")
	str (cl-ppcre:regex-replace-all crlf  str " ")
	str (cl-ppcre:regex-replace-all "   "  str " ")
  	str (cl-ppcre:regex-replace-all "   "  str " ")))

(defun convert-to-postgres(lst &optional (out t))
  "Пример использования:
 (convert-to-postgres (parse-vsegost-shtml *fn*))"
  (let ((pth (first lst))
	(gost (string-filter-01 (second lst)))
	(year (read(make-string-input-stream (car (last (cl-ppcre:split "-" (second lst)))))))
	(name (string-filter-01 (third lst)))
	(descr (string-filter-01 (car (last (cl-ppcre:split "</span>&nbsp;" (fourth lst))))))
	(stat  (get-tag "span" (fourth lst))))
    (setf year (if (<=  year 99) (+ 1900 year) year))
;;;;    (list pth gost year name descr stat)
    (format out "~A	~A	~A-06-01	~A	~A	~A~%" pth gost year name descr stat)
    ))
