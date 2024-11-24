(in-package :vse-gost)

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

(format t "~A" "ИНСТРУКЦИЯ

1. Переход в рабочий каталог для зеркалирования (bash)
cd ~/Downloads

2. Зеркалирование (bash)
wget -m -np http://vsegost.com/

3. Для создания файла импорта '/home/namatv/out.txt' в PostgreSQL выполнте следующее:
(vse-gost:create-sql-import-file
 (concatenate 'string
              (uiop:getenv \"HOME\")
              \"/\"
              \"import-file.txt\")
 (namestring  vse-gost:*vsegost-Catalog*))

3.1 Для импорта в PostgreSQL выполнте в psql следующее:
copy gost (local_path, designation, date, name, description, status) from '/home/namatv/out.txt';

4. Для создания файла скрипта, преобразующего gif-файлы каждого каталога в  файл gost.pdf.
(vse-gost:main-create-bash-script-gif-pdf-convertion vse-gost:*vsegost-Data*)

Примечание: Примерное время выполнения сценария 5 минут.
" )
