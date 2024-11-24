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

