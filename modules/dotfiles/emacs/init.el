(setq package-archives
'(("gnu"   . "https://elpa.gnu.org/packages/")
("melpa" . "https://melpa.org/packages/")))

(require 'use-package)

(setq use-package-always-ensure t)

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

(use-package gruvbox-theme
:config
(load-theme 'gruvbox-dark-medium t))

(defun ugo/apply-frame-faces (&optional frame)
"Apply font and face customizations to FRAME."
(with-selected-frame (or frame (selected-frame))
(set-face-attribute 'default nil
:font "Iosevka"
:height 115)))

(add-hook 'after-make-frame-functions #'ugo/apply-frame-faces)
(add-hook 'server-after-make-frame-hook #'ugo/apply-frame-faces)

(when (display-graphic-p)
(ugo/apply-frame-faces))

(use-package company
:custom
(company-idle-delay 0.2)
(company-minimum-prefix-length 2)
:config
(global-company-mode 1))

(use-package ivy
:diminish
:init
(ivy-mode 1)
:bind
(:map ivy-minibuffer-map
("TAB" . ivy-alt-done)
("C-l" . ivy-alt-done)
("C-j" . ivy-next-line)
("C-k" . ivy-previous-line)
:map ivy-switch-buffer-map
("C-k" . ivy-previous-line)
("C-l" . ivy-done)
("C-d" . ivy-switch-buffer-kill)
:map ivy-reverse-i-search-map
("C-k" . ivy-previous-line)
("C-d" . ivy-reverse-i-search-kill)))

(use-package swiper
:after ivy
:bind
("C-s" . swiper))

(use-package counsel
:after ivy
:config
(counsel-mode 1))

(setq project-mode-line-format t)

(use-package projectile
:init
(projectile-mode +1)

:bind
(:map projectile-mode-map
("C-c p" . projectile-command-map))

:custom
(projectile-project-search-path
'(("~/Projetos")
("~/Documentos/org" . 1)))

:config
(projectile-discover-projects-in-search-path))

(use-package counsel-projectile
:after (counsel projectile)
:config
(counsel-projectile-mode 1))

(use-package magit
:bind
("C-x g" . magit-status))

(use-package rainbow-delimiters)

(use-package yasnippet
:init
(yas-global-mode 1))

(use-package yasnippet-snippets)

(setq yas-snippet-dirs
        '("~/Documentos/org/templates"))

(use-package markdown-mode
:mode
("\.md\'" . markdown-mode)
("\.markdown\'" . markdown-mode))

(use-package which-key
:config
(which-key-mode 1))

(use-package doom-modeline
:custom
(doom-modeline-height 15)
(doom-modeline-project-name t)
:config
(doom-modeline-mode 1))

(defvar ugo/emacs-auto-save-directory
(expand-file-name "auto-save/" user-emacs-directory))

(make-directory ugo/emacs-auto-save-directory t)

(setq auto-save-file-name-transforms
`((".*" ,ugo/emacs-auto-save-directory t)))

(defvar ugo/emacs-backup-directory
(expand-file-name "backups/" user-emacs-directory))

(make-directory ugo/emacs-backup-directory t)

(setq backup-directory-alist
`(("." . ,ugo/emacs-backup-directory)))

(with-eval-after-load 'org
  (add-to-list 'org-file-apps '("\\.ods\\'" . default)))

(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

(setq org-agenda-files
'("~/Documentos/org/"))

(setq org-refile-targets
'((org-agenda-files :maxlevel . 2)))

(setq org-default-notes-file
"~/Documentos/org/02_notas.org")

(setq org-todo-keywords
'((sequence
"TODO"
"FEEDBACK"
"VERIFY"
"|"
"DONE"
"DELEGATED")))

(defvar ugo/journal-dir "~/Documentos/org/journals/")

(defun ugo/daily-note-path (notes-dir)
    "Return today's daily note path inside NOTES-DIR.
    The file name has the form YYYYMMDD.org."
(expand-file-name (format-time-string "%Y%m%d.org") notes-dir))

(defun ugo/create-daily-note ()
  "Create today's daily note file if it does not exist, without visiting it."
  (let ((filename (ugo/daily-note-path ugo/journal-dir)))
    (make-directory (file-name-directory filename) t)
    (unless (file-exists-p filename)
      (with-temp-buffer
        (org-mode)
        (yas-minor-mode 1)
        (insert "dn")
        (yas-expand)
        (write-region (point-min) (point-max) filename)))))

(defun ugo/daily-note-file ()
  "Ensure today's daily note exists and return its path."
  (ugo/create-daily-note)
  (ugo/daily-note-path ugo/journal-dir))



(setq org-capture-templates
      '(("d" "Daily")

        ("dl" "Daily Log" plain
         (file+headline ugo/daily-note-file "Daily Logbook")
         "- %<%H:%M> --- %?"
         :immediate-finish nil)

        ("dt" "Daily Task" entry
         (file+headline ugo/daily-note-file "Daily Tasks")
         "** TODO %?")

        ("dg" "Daily Goal" entry
         (file+headline ugo/daily-note-file "Daily Goals")
         "** %?")

        ("t" "Global Task" entry
         (file+headline "~/Documentos/org/01_tasks.org" "tarefas")
         "** TODO %?\n  %U")))

(put 'erase-buffer 'disabled nil)
(put 'upcase-region 'disabled nil)
