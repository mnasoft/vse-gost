(setq gif-file
  (open "/tmp/gif.txt" :direction :output))

(mapcar
  (function 
    (lambda(el)
      (format gif-file "~A~%" el)
    )
  ) 
;  (directory #P"/media/358289b8-1f08-40ad-b8d9-e0afcfaffa3e/namatv/vsegost.com/Data/**/*.gif")
;  (directory #P"/media/358289b8-1f08-40ad-b8d9-e0afcfaffa3e/namatv/vsegost.com/Data/**/*/")
  (directory #P"/tmp/vse/**/*/")
)

(close gif-file)

(when (wild-pathname-p #P"/tmp/")
    (error "Can only list concrete directory names."))