(require 'emacsit)
(require 'use-package)
(require 'package)
(package-initialize)
(defcustom emacsit-repository::packages nil
  "list of packages to be added from repository")

(defcustom emacsit-repository::repository-file (concat emacsit::savedir "/" "SidharthArya/emacsit/emacsit-repositories")
  "list of packages to be added from repository")
(defun emacsit-repository::build-list()
  ""
  (interactive)
  (with-current-buffer (find-file-noselect emacsit-repository::repository-file)
    (mapcar 'emacsit-repository::append (mapcar 'symbol-name emacsit-repository::packages))
    (kill-current-buffer)
    ))
;(mapcar 'emacsit-repository::append '(a b))
(defun emacsit-repository::append(package-name)
  ""
  (goto-char (point-min))
  (if (re-search-forward (format "@%s#\\|^%s@" package-name  package-name) nil t nil)
      (let* ((package-string (thing-at-point 'line))
	    (package-full-name (car (cdr (split-string (car (split-string package-string "#")) "@"))))
	    (package-dependencies (split-string (car (cdr (split-string (string-trim package-string) "#")))))
	    )
	(if (not (equal package-dependencies ""))
		 (mapcar 'emacsit-repository::append  package-dependencies))
	;(message "Emacsit: %s" package-name)
	(add-to-list 'emacsit::packages (intern package-full-name)))
    (progn

	;(message "Emacsit:%s" package-name)
	(add-to-list 'emacsit::packages (intern package-name)))))

(defun emacsit-repository::package-installed-p (package-name)
  (let ((installed (emacsit-repository::emacsit-package-installed-p package-name)))
    
    (if (equal installed -1)
	(package-installed-p  package-name)
    installed)))

(defun emacsit-repository::emacsit-package-installed-p (package-name)
(with-current-buffer (find-file-noselect "/home/arya/.emacs.d/packages/SidharthArya/emacsit/emacsit-repositories")
	(goto-char (point-min))
	(if (re-search-forward (format "@%s#\\|^%s@" (symbol-name package-name)  (symbol-name package-name)) nil t nil)
	    (let* ((package-string (thing-at-point 'line))
		   (package-full-name (car (cdr (split-string (car (split-string package-string "#")) "@")))))
	      (file-exists-p (concat emacsit::savedir package-full-name)))
	  (if (file-exists-p (concat emacsit::savedir (symbol-name package-name)))
	      t
	    -1)
	      )))

(defun emacsit-use-package-ensure (name args _state &optional _no-refresh)
  ;(message "%s:%s:%s:%s" name args _state _no-refresh)
  (let ((ensure-name nil)
	(last-packages emacsit::packages)
	)
    (mapcar (lambda (a)
	      (if (equal a t)
		  (setq ensure-name t)
		(emacsit-ensure-add-to-list a)
		)) args)
    (if (equal ensure-name t)
	(emacsit-ensure-add-to-list name))
	(emacsit-repository::build-list)

	(mapcar 'emacsit::clone (mapcar 'emacsit::getprocess (cl-set-difference emacsit::packages last-packages )))
	(mapcar 'emacsit::loadPackage (mapcar 'emacsit::preprocess (cl-set-difference emacsit::packages last-packages)))
	;(require name)
	))

(defun emacsit-ensure-add-to-list (name)
""
(if (emacsit-repository::package-installed-p name)
      (progn
	;(require name)
	nil)
	  (add-to-list 'emacsit-repository::packages name) 
  ))
;(add-to-list 'use-package-keywords ':emacsit)
;(setq use-package-pre-ensure-function 'emacsit-use-package-pre-ensure-function)			       
(provide 'emacsit-repositories)