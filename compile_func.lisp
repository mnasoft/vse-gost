(defun compile-func-lst(fnc_lst)
"Выполняет компиляцию функций, задаваемых в списке fnc_lst"
  (mapcar
    (function (lambda (el) (compile el)))
    fnc_lst))

(compile-func-lst '(compile-func-lst))