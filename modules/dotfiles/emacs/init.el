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
(expand-file-name "backups/" user-emacs-directory)

(make-directory ugo/emacs-backup-directory t)

(setq backup-directory-alist
`(("." . ,ugo/emacs-backup-directory)))

(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

(setq org-agenda-files
'("~/Documentos/org/"))

(setq org-refile-targets
'((org-agenda-files :maxlevel . 2)))

(setq org-default-notes-file
"~/Documentos/org/01_tasks.org")

(setq org-todo-keywords
'((sequence
"TODO"
"FEEDBACK"
"VERIFY"
"|"
"DONE"
"DELEGATED")))

(setq project-mode-line-format t)

(defvar ugo/logbook-file
"~/Documentos/org/00_logbook.org"
"Path to the daily logbook file.")

(defun ugo/org-capture-logbook-find-today ()
"Find or create today's heading in the logbook.

Returns a marker positioned for org-capture to insert into."
(require 'org)
(set-buffer (org-capture-target-buffer ugo/logbook-file))
(widen)
(goto-char (point-min))

(let* ((today
(format-time-string "%d-%m-%Y"))
     (weekday-pt
      (pcase (format-time-string "%u")
        ("1" "Segunda")
        ("2" "Terça")
        ("3" "Quarta")
        ("4" "Quinta")
        ("5" "Sexta")
        ("6" "Sábado")
        ("7" "Domingo")))

     (heading
      (concat today " - " weekday-pt))

     (heading-re
      (concat "^\\*+ "
              (regexp-quote heading)
              "$")))

(if (re-search-forward heading-re nil t)

    ;; Heading exists — jump to end of its subtree.
    (progn
      (goto-char (match-beginning 0))
      (org-end-of-subtree))

  ;; Heading does not exist — create it at the end.
  (goto-char (point-max))
  (unless (bolp)
    (insert "\n"))
  (insert "\n* " heading "\n"))

;; Ensure that capture text starts on a fresh line.
(unless (bolp)
  (insert "\n"))

(point-marker)))

(setq org-capture-templates
      `(("l" "Logbook" plain
         (file+function ,ugo/logbook-file
                         ugo/org-capture-logbook-find-today)
         "- %(format-time-string \"%H:%M\") --- %^{Descrição}"
         :empty-lines 0)
        ("t" "Todo" entry
         (file "~/Documentos/org/01_tasks.org")
         "* TODO %?\n  %U\n"
         :empty-lines 1)))

(put 'erase-buffer 'disabled nil)
(put 'upcase-region 'disabled nil)
