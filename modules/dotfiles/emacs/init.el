;;; init.el --- Emacs init file -*- lexical-binding: t; -*-
;; Packages are managed by Emacs (package.el + use-package :ensure).

;; Package archives.
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))

(require 'use-package)
(setq use-package-always-ensure t)


(use-package markdown-mode
  :mode
  ("\\.md\\'" . markdown-mode)
  ("\\.markdown\\'" . markdown-mode))

(use-package magit
  :bind
  ("C-x g" . magit-status))

(use-package company
  :config
  (global-company-mode 1)
  (setq company-idle-delay 0.2
        company-minimum-prefix-length 2))

(use-package projectile
  :init
  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("C-c p" . projectile-command-map))
  :custom
  (projectile-project-search-path
   '(("~/Projetos")           ; scan all immediate subdirs
     ("~/Documentos/org" . 1) ; treat "org" itself as a project
     ))
  :config
  (projectile-discover-projects-in-search-path))

(use-package gruvbox-theme
             :config
             (load-theme 'gruvbox-dark-medium t))

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

(custom-set-variables '(package-selected-packages nil))
(custom-set-faces)

(make-directory "~/.config/emacs/auto-save/" t)
(setq auto-save-file-name-transforms
      `((".*" "~/.config/emacs/auto-save/" t)))

;;; Apply face/font settings to every frame (including emacsclient frames).
;;; In daemon mode, `set-face-attribute' without a live graphical frame
;;; doesn't propagate to client frames opened later.
(defun ugo/apply-frame-faces (&optional frame)
  "Apply font and face customizations to FRAME (default: selected)."
  (with-selected-frame (or frame (selected-frame))
    (set-face-attribute 'default nil :font "Iosevka Nerd Font" :height 100)))

(add-hook 'after-make-frame-functions #'ugo/apply-frame-faces)
(add-hook 'server-after-make-frame-hook #'ugo/apply-frame-faces)
(ugo/apply-frame-faces)

(put 'erase-buffer 'disabled nil)

;; org mode configs
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)
(put 'upcase-region 'disabled nil)

(setq org-agenda-files '("~/Documentos/org/"))
(setq org-refile-targets '((org-agenda-files :maxlevel . 2)))
(setq org-default-notes-file "~/Documentos/org/01_tasks.org")

;; org-capture: logbook (~/Documentos/org/00_logbook.org)
;; Entries are filed under a daily heading: "DD-MM-YYYY - DiaDaSemana"
(defvar ugo/logbook-file "~/Documentos/org/00_logbook.org"
  "Path to the CYA logbook file.")

(defun ugo/org-capture-logbook-find-today ()
  "Find or create today's heading in the logbook.
Returns a marker positioned for org-capture to insert into."
  (require 'org)
  (set-buffer (org-capture-target-buffer ugo/logbook-file))
  (widen)
  (goto-char (point-min))
  (let* ((today (format-time-string "%d-%m-%Y"))
         (weekday-pt (pcase (format-time-string "%u")
                       ("1" "Segunda")
		       ("2" "Terça")
		       ("3" "Quarta")
                       ("4" "Quinta")
		       ("5" "Sexta")
		       ("6" "Sábado")
                       ("7" "Domingo")))
         (heading (concat today " - " weekday-pt))
         (heading-re (concat "^\\*+ " (regexp-quote heading) "$")))
    (if (re-search-forward heading-re nil t)
        ;; Heading exists — jump to end of its subtree
        (progn
          (goto-char (match-beginning 0))
          (org-end-of-subtree))
      ;; Heading not found — create it at end of buffer
      (goto-char (point-max))
      (unless (bolp) (insert "\n"))
      (insert "\n* " heading "\n"))
    ;; Ensure we are on a fresh line for the template text
    (unless (bolp) (insert "\n"))
    (point-marker)))

(setq org-capture-templates
      '(("l" "Logbook" plain
         (file+function ugo/logbook-file
                        ugo/org-capture-logbook-find-today)
         "- %(format-time-string \"%H:%M\") --- %^{Descrição}"
         :empty-lines 0)

        ("t" "Todo" entry
         (file "~/Documentos/org/01_tasks.org")
         "* TODO %?\n  %U\n"
         :empty-lines 1)))

(setq project-mode-line-format t)

(which-key-mode 1)
