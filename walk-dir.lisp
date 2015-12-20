(in-package #:vse-gost)

(defparameter *vsegost-Catalog* #p"/home/namatv/Downloads/vsegost.com_1/Catalog/")

(defparameter *vsegost-Data*    #p"/home/namatv/Downloads/vsegost.com_1/Data/")

(defun walk-subdirs (dir)
  "Возвращает список директорий начиная с директория dir.
Пример использования
(walk-subdirs #P\"/home/namatv/My/developer/\")
"
  (do ((cur-dir dir (car d-lst))
       (d-lst (list dir))
       (rez-lst nil))
      ((null d-lst) rez-lst)
    (setf rez-lst (append rez-lst (list cur-dir)  )
  	  d-lst (cdr d-lst)
	  d-lst (append (uiop:subdirectories cur-dir) d-lst))))

(defun walk-subdirs-files(dir)
  "Возвращает список файлов, расположенных в директориях вложенных в директорий dir.
Пример использования:
(walk-subdirs-files \"/home/namatv/My/developer/\")
"
  (apply #'append (mapcar #'uiop:directory-files (walk-subdirs dir))))

(defun main-create-PostgreSQL-import-file(vsegost-catalog-dir &optional (import-file-name #P"/home/namatv/out.txt"))
  "Выполняет формирование файла для импортирования таблицы ГОСТ в PostgreSQL.
vsegost-catalog-dir - расположение каталога vsegost.com/Catalog на зеркале сайта.
Пример использования:
(vse-gost:main-create-PostgreSQL-import-file vse-gost:*vsegost-Catalog*)
"

  (with-open-file 
      (out import-file-name :direction :output :if-exists :supersede )
    (mapc 
     #'(lambda (fn) 
	 (convert-to-postgres (parse-vsegost-shtml fn) out))
     (walk-subdirs-files vsegost-catalog-dir))))

(defun main-create-bash-script-gif-pdf-convertion(vsegost-data-dir &optional (script-file-name #P"/home/namatv/out.sh"))
  "Выполняет формирование файла скрипта для преобразования gif-файлов в файл gost.pdf для каждого каталога.
vsegost-catalog-dir - расположение каталога vsegost.com/Catalog на зеркале сайта.
Пример использования:
(vse-gost:main-create-bash-script-gif-pdf-convertion vse-gost:*vsegost-Data*)
"
  (with-open-file 
      (out script-file-name :direction :output :if-exists :supersede )
    (mapc
     #'(lambda(el)
	 (if (uiop:directory-files el)
	     (progn (format out "cd ~A~%" el)
		    (format out "convert `ls *.gif | sort -n - | xargs echo` gost.pdf~%" el))))
     (walk-subdirs vsegost-data-dir))))

(format t "ИНСТРУКЦИЯ

1. Переход в рабочий каталог для зеркалирования (bash)
cd ~/Downloads

2. Зеркалирование (bash)
wget -m -np http://vsegost.com/

3. Для создания файла импорта в PostgreSQL выполнте следующее:
(vse-gost:main-create-PostgreSQL-import-file vse-gost:*vsegost-Catalog*)

4. Для создания файла скрипта, преобразующего gif-файлы каждого каталога в  файл gost.pdf.
(vse-gost:main-create-bash-script-gif-pdf-convertion vse-gost:*vsegost-Data*)

Примечание: Примерное время выполнения сценария 5 минут.
" )
