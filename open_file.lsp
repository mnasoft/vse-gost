(defvar str_rez "")

(defun walk-vsegost()
"Прогулка по всем файлам сайта vsegost.com"
  (let
    (
      (output_file (open "/tmp/gost-rez.txt" :direction :output))
    )
    (walk-directory 
      "/media/358289b8-1f08-40ad-b8d9-e0afcfaffa3e/namatv/vsegost.com/Catalog" 
      (function gost-obozn-type))
    (close output_file)
  )
)

(defun gost-obozn-type(gost_path)
""
  (let
    (
      (in_shtml_file (open gost_path :direction :input))
      (out_txt_file t)
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
          (format out_txt_file "~A~C" str_rez #\Tab)
          (setq atag "h2"))
        ( (and (string/= str_rez "") (string= atag "h2"))
          (setq str-h2 str_rez)
          (format out_txt_file "~A~%" str_rez)
          (close in_shtml_file)
          (return 
            (list gost_path str-h1 str-h2)))))
    (list gost_path str-h1 str-h2)))

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

;; (clear-var-list '(s_tag e_tag str_l s_tag_l e_tag_l tag_start tag_end str_rez))

;; (gost-obozn-type "/home/namatv/ftp/vsegost.com/Catalog/69/6976.shtml")
;; (gost-obozn-type "/media/358289b8-1f08-40ad-b8d9-e0afcfaffa3e/namatv/vsegost.com//Catalog/69/6976.shtml")


