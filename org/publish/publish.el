(progn
  (org-setup "~/public_html/CL" (home-ancestor 2))
  (setq org-publish-project-alist 
        `(
          ,(org-pub-list "README"       "") ;; README
          ,(org-pub-list "org"         "org") ;; Корневой файл
          ,(org-att-list "sql"   "sql" "sql") ;; Корневой файл          
          ))
  (org-web-list))

(progn
  (require 'ox-publish)
  (setq org-publish-use-timestamps-flag nil)
  (setq org-confirm-babel-evaluate nil) ; выполнение всех блоков кода без подтверждения  
  (org-publish-project "website"))
