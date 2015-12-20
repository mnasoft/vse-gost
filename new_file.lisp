(in-package #:vse-gost)
 
(defun tag-head(str &key (start 0))
  "Пример использования
(tag-head \" href='../../Data/1/131/0.gif' rel='gb_imageset[g]' title='ГОСТ ЕН 12626-2006 страница 1'\")
=> ((\"title\" . \"ГОСТ ЕН 12626-2006 страница 1\") (\"rel\" . \"gb_imageset[g]\") (\"href\" . \"../../Data/1/131/0.gif\"))
"
  (let ((token "") ; 
	(ks nil)   ; Список ключевых слов
	(vs nil)   ; Список значений для ключевых слов
	(kr t) ; Чтение ключа
	(o-quote nil)
	)
    (dolist (ch (concatenate 'list str) (mapcar #'cons ks vs)) 
;      (break "ch=~S~%token=~S~%ks=~S~%vs=~S~%kr=~S~%o-quote=~S~%" ch token ks vs kr o-quote)
      (cond
	((and  kr (or (eql #\Space ch)(eql #\Tab  ch) (eql #\Return  ch) (eql #\Linefeed ch))))
	((and (null kr)
	      (equal token "")
	      (or (eql #\' ch) (eql #\" ch)))
	 (setf o-quote ch))
	((and (null kr)
	      (null (equal token ""))
	      o-quote
	      (eql o-quote ch))
	 (setf vs (cons token vs)
	       o-quote nil
	       token ""
	       kr t))	
	((eql #\= ch)
	 (setf ks (cons token ks)
	       kr nil
	       token "")	 
	 )
	(t (setf token (concatenate 'string token (list ch))))))))

;;;;(get-tag "a" "<a href='../../Data/1/131/0.gif' rel='gb_imageset[g]' title='ГОСТ ЕН 12626-2006 страница 1'><img src='../../DataTN/1/131/0.gif' alt='' /></a>")
;;;;(tag-head " href='../../Data/1/131/0.gif' rel='gb_imageset[g]' title='ГОСТ ЕН 12626-2006 страница 1'")

(defun is-space(ch)
  (or (eql #\Space ch)(eql #\Tab  ch) (eql #\Return  ch) (eql #\Linefeed ch)))

(defun is-open-tag(ch) (eql #\< ch))

(defun is-close-tag(ch) (eql #\> ch))


(defun parse (str)
  (let ((token "")		   ; 
	(ks nil)		   ; Список ключевых слов
	(vs nil)		   ; Список значений для ключевых слов
	(kr t)			   ; Чтение ключа
	(o-quote nil)		   ;
	(tags nil)		   ; Перечень тегов
	(tag nil)		   ; Режим чтения имени тега
	(tag-is-open nil)          ; Тег является открывающим
	(tag-level 0)		   ; Уровень вложенности тега
	(tag-number 0)		   ; Номер тега по порядку
	)
    (dolist (ch (concatenate 'list str) (mapcar #'cons ks vs)) 
      (break "tags=~S~%tag=~S~%tag-is-open=~S~%tag-level=~S~%tag-number=~S~%ch=~S~%token=~S~%ks=~S~%vs=~S~%kr=~S~%o-quote=~S~%"
	     tags tag tag-is-open tag-level tag-number ch token ks vs kr o-quote)
      (cond
	((and (null tags) (is-space ch))) ;; Игнорирование пробельных символов в начале документа
	((eql #\< ch)			  ;; Начало тега
	 (setf tag t
	       token ""
	       tag-is-open t
	       )
	 )
	((and tag (equal token "") (eql #\/ ch)) ;; Вклюен режим чтения тега, имя тега не определено, стречен символ / ---
	 (setf tag-is-open nil)) ;; Тег является закрывающим
	((and tag tag-is-open (null(equal token ""))  (is-space ch)) ;; Вклюен режим чтения тега, тег открывающий, имя тега непустое, встретился пробельный символ
	 (incf tag-level)	    ; Увеличиваем уровень вложенности 
	 (setf tags (cons token tags)	; Добавляем тег в список 
	       ))
	((and tag tag-is-open (null(equal token ""))  (is-close-tag ch)) ;; Вклюен режим чтения тега, тег открывающий, имя тега непустое, встретился пробельный символ
	 (decf tag-level)	       ; Уменьшаем уровень вложенности
	 (incf tag-number)	       ; 
	 (setf tags (cons  token tags)  ; Добавляем тег в список
	       token ""
	       tag nil 
	       ))	
	((and tag (null tag-is-open) (null(equal token ""))  (is-close-tag ch)) ;; Вклюен режим чтения тега, тег закрывающий, имя тега непустое, встретился пробельный символ
	 (decf tag-level)	       ; Уменьшаем уровень вложенности
	 (incf tag-number)	       ; 
	 (setf tags (cons (list tag-number tag-level token) tags)  ; Добавляем тег в список
	       token ""
	       ))	
	((and  kr (or (eql #\Space ch)(eql #\Tab  ch) (eql #\Return  ch) (eql #\Linefeed ch))))
	((and (null kr)
	      (equal token "")
	      (or (eql #\' ch) (eql #\" ch)))
	 (setf o-quote ch))
	((and (null kr)
	      (null (equal token ""))
	      o-quote
	      (eql o-quote ch))
	 (setf vs (cons token vs)
	       o-quote nil
	       token ""
	       kr t))	
	((eql #\= ch)
	 (setf ks (cons token ks)
	       kr nil
	       token "")	 
	 )
	(t (setf token (concatenate 'string token (list ch))))))))


(defparameter *test-string* "<html>
  <head>
  </head>
  <body>
    <form action=\"http://www.google.com/cse\" id=\"cse-search-box\">
      <div>
      </div>
    </form>
    <h1>ГОСТ ЕН 12626-2006</h1>
    <h2>Безопасность металлообрабатывающих станков. Станки для лазерной обработки</h2>
    <p><span class=\"g\">действующий</span>&nbsp;Настоящий стандарт</p>
    <h2>Текст ГОСТ ЕН 12626-2006</h2>
  </body>
</html>")
;;;(parse *test-string*)

"<html>
  <head>
	<title>ГОСТ ЕН 12626-2006 Безопасность металлообрабатывающих станков. Станки для лазерной обработки</title>
	<meta http-equiv=\"content-type\" content=\"text/html; charset=UTF-8\" />
	<meta name=\"keywords\" content=\"ГОСТ ЕН 12626-2006, ГОСТ, ТУ, СНИП, скачать, бесплатно, полный текст\" />
  </head>
  <body>
    <form action=\"http://www.google.com/cse\" id=\"cse-search-box\">
      <div>
        <input type=\"hidden\" name=\"cx\" value=\"partner-pub-9704762057218573:l5bixljvgev\" />
        <input type=\"hidden\" name=\"ie\" value=\"UTF-8\" />
        <input type=\"text\" name=\"q\" size=\"31\" />
        <input type=\"submit\" name=\"sa\" value=\"&#x041f;&#x043e;&#x0438;&#x0441;&#x043a;\" />
      </div>
    </form>
    <h1>ГОСТ ЕН 12626-2006</h1>
    <h2>Безопасность металлообрабатывающих станков. Станки для лазерной обработки</h2>
    <p><span class=\"g\">действующий</span>&nbsp;Настоящий стандарт описывает опасности, которые вызываются лазерным обрабатывающим оборудованием и определяет требования безопасности по лазерному излучению и вредным веществам, выделяемым при лазерной обработке.<br>   Настоящий стандарт не распространяется на лазерные установки и устройства с использованием лазеров, применяемых в:<br>    - фотолитографии;<br>    - стереолитографии;<br>    - голографии;<br>    - медицине (по МЭК 60601-2-22);<br>    - информационных технологиях</p>
    <h2>Текст ГОСТ ЕН 12626-2006</h2>
  </body>
</html>"


"
1. Проверяем, находится ли курсор в середине тега.
2. Если да, определяем имя тега.
3. Проверяем тип тега: открывающий или закрывающий.
4. К примеру, открывающий. Значит двигаемся вперед относительно закрывающей скобки и проверяем, в середине тега позиция или нет.
5. Если позиция в попала в тег и он открывающий, и имя совпадает с именем, опеределенным в шаге два, увеличиваем счетчик открывающих тегов.
6. Если тег закрывающий, и имя совпадает с именем, опеределенным в шаге два, увеличиваем счетчик закрывающих тегов.
7. Если счетчики открывающих и закрывающих тегов совпали, пара найдена.
8. Подсвечиваем нужные позиции.
"

(defun walk-subdirs (dir)
  (do (
       (cur-dir dir (car d-lst))
       (d-lst (list dir))
       (rez-lst nil)
       )
      ((null d-lst) rez-lst)
;;;;    (break "cur-dir=~S~%d-lst=~S~%rez-lst=~S" cur-dir d-lst rez-lst)
    (setf rez-lst (append rez-lst (list cur-dir)  )
  	  d-lst (cdr d-lst)
	  d-lst (append (uiop:subdirectories cur-dir) d-lst))))

(defparameter *vsegost-Catalog* #p"/home/namatv/Downloads/vsegost.com_1/Catalog/")

(defparameter *vsegost-Catalog-shtml*
  (apply #'append
	 (mapcar #'uiop:directory-files
		 (walk-subdirs *vsegost-Catalog*))))


