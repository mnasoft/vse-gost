(defvar *h1-was-finded* nil)
(defvar *h2-was-finded* nil)

(defun gost-obozn-type(gost_path)
  (setq assa (open gost_path :direction :input))
  (setq *h1-was-finded* nil)
  (setq *h2-was-finded* nil)
  (setq eof-error-p nil)
  (setq atag "h1")
  (loop until (is-eof)
    do
    (setq str (read-line assa eof-error-p))
    (if (or (not str) eof-error-p) (progn (close assa)(return)))
    (setq str_rez (str-tag str atag))
    (cond 
      ( (and (string/= str_rez "") (string= atag "h1"))
	(format massa "~A~C" str_rez #\Tab)
	(setq atag "h2"))
      ( (and (string/= str_rez "") (string= atag "h2"))
        (format massa "~A~%" str_rez)
        (close assa)
        (return)))))

(defun is-eof() eof-error-p)
(defun is-find-h1() *h1-was-finded*)
(defun is-find-h2() *h2-was-finded*)
(defun is-find() (and (is-find-h1) (is-find-h2)))

(defun str-tag-p(str tag)
  (setq 
    str (string-trim '(#\Space #\Tab #\Newline) str)
    s_tag (string-concat "<" tag ">")
    e_tag (string-concat "</" tag ">")
    str_l (length str)
    s_tag_l (length s_tag)
    e_tag_l (length e_tag))
  (cond
    ( (<= (- str_l s_tag_l e_tag_l) 0)
      (setq str_rez "")
      nil)
    ( t
      (setq
        tag_start (subseq  str 0 s_tag_l)
        tag_end (subseq  str (- str_l e_tag_l) str_l)
        str_rez (subseq  str s_tag_l (- str_l e_tag_l)))
      (and (string= tag_start s_tag) (string= tag_end e_tag))
    )
  )  
)

(defun str-tag(str tag)
  (if (str-tag-p str tag) str_rez "")
)

(defun clear-var-list(var_lst)
  (mapcar 
    (function(lambda(el) (makunbound el )))
    var_lst
  )
)

(defun clear-func-list(func_lst)
  (mapcar 
    (function(lambda(el) (fmakunbound el )))
    var_lst
  )
)

;; (clear-var-list '(s_tag e_tag str_l s_tag_l e_tag_l tag_start tag_end str_rez))

;; (gost-obozn-type "/home/namatv/ftp/vsegost.com/Catalog/69/6976.shtml")
;; (setq massa t)

(defun walk-vsegost()
  (load "/media/358289b8-1f08-40ad-b8d9-e0afcfaffa3e/namatv/git/clisp/Vse_Gost_Scaner/directory.lsp")
  (load "/media/358289b8-1f08-40ad-b8d9-e0afcfaffa3e/namatv/git/clisp/Vse_Gost_Scaner/open_file.lsp")
  (setq massa (open "/tmp/gost-rez.txt" :direction :output))
  (walk-directory "/media/358289b8-1f08-40ad-b8d9-e0afcfaffa3e/namatv/vsegost.com/Catalog" #'gost-obozn-type)
  (close massa)
)