(defun pth-name (str_path)
  (setq
    str_name (pathname-name str_path)
    str_type (pathname-type str_path)
    str_directory (directory-list>directory-string (pathname-directory str_path)))
  (format t "~a~%~a~%~a~%" str_name str_type str_directory)
)

(defun directory-list>directory-string (dlist)
  (setq str_rez "")
  (mapcar
    (function
      (lambda (el)
        (cond
          ( (equal el :ABSOLUTE) (setq str_rez "/"))
          ( (equal (quote SIMPLE-BASE-STRING) (car (type-of el)))
            (setq str_rez (string-concat str_rez el "/")))
          ( T (format t "~a~%" (type-of el))))))
    dlist
  )
  str_rez
)

(defun pth-name-shtml (str_path)
  (setq
    str_rez ""
    str_name (pathname-name str_path)
    str_type (pathname-type str_path)
    str_directory (directory-list>directory-string (pathname-directory str_path)))
  (if (null str_type) (return nil))
  (cond
    ( (= 1 (length str_name))
      (setq str_rez (string-concat str_directory "../Data/0/" str_name "/")))
    ( (= 2 (length str_name))
      (setq str_rez (string-concat str_directory "../Data/0/" str_name "/")))
    ( (= 3 (length str_name))
      (setq str_rez (string-concat str_directory "../Data/" (substring str_name 0 1) "/" str_name "/"))
    )
    ( (= 4 (length str_name))
      (setq str_rez (string-concat str_directory "../Data/" (substring str_name 0 2) "/" str_name "/"))
    )
    ( (= 5 (length str_name))
      (setq str_rez (string-concat str_directory "../Data/" (substring str_name 0 3) "/" str_name "/"))
    )
  )
  str_rez
)

;; (directory #P"/media/358289b8-1f08-40ad-b8d9-e0afcfaffa3e/namatv/vsegost.com/Data/**/*.gif")
;; (directory #P"/media/358289b8-1f08-40ad-b8d9-e0afcfaffa3e/namatv/vsegost.com/Catalog/**/*.shtml")

(defun pth-Catalog->Data(str_catalog)
  (mapcar
    (function
      (lambda (el) ( pth-name-shtml el)))
    (list 
      #P"/media/358289b8-1f08-40ad-b8d9-e0afcfaffa3e/namatv/vsegost.com/Catalog/28490.shtml"
      #P"/media/358289b8-1f08-40ad-b8d9-e0afcfaffa3e/namatv/vsegost.com/Catalog/11282.shtml"
      #P"/media/358289b8-1f08-40ad-b8d9-e0afcfaffa3e/namatv/vsegost.com/Catalog/9068.shtml"))
)
