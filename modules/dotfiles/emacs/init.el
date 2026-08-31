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
:custom
(yas-snippet-dirs '("~/Documentos/org/templates"))
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

;; Collect all auto-save files in a dedicated directory,
;; so they never pollute your project trees.
(defvar ugo/emacs-auto-save-directory
  (expand-file-name "auto-save/" user-emacs-directory)
  "Directory where auto-save files are stored.")

(make-directory ugo/emacs-auto-save-directory t)

(setq auto-save-file-name-transforms
      `((".*" ,ugo/emacs-auto-save-directory t)))

(defvar ugo/emacs-backup-directory
(expand-file-name "backups/" user-emacs-directory))

(make-directory ugo/emacs-backup-directory t)

(setq backup-directory-alist
`(("." . ,ugo/emacs-backup-directory)))

(with-eval-after-load 'org
  (add-to-list 'org-file-apps '("\\.ods\\'" . "xdg-open %s")))

(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

(setq org-agenda-files
'("~/Documentos/org/"))

(setq org-refile-targets
'((org-agenda-files :maxlevel . 3)))

(setq org-default-notes-file
"~/Documentos/org/02_notas.org")

(setq org-todo-keywords
'((sequence
"TODO(t)"
"FEEDBACK(f)"
"VERIFY(v)"
"TO-DELEGATE(e)"
"|"
"DONE(d)"
"DELEGATED(D)"
"MOVED(m)"
"CANCELLED(c)")))

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

(defun ugo/open-daily-note ()
  "Open today's daily note, creating it first if it does not exist."
  (interactive)
  (ugo/create-daily-note)
  (find-file (ugo/daily-note-path ugo/journal-dir)))

(keymap-global-set "C-c d" 'ugo/open-daily-note)

(defun ugo/search-journals ()
  "Interactively search across all journal files.
Restricts counsel-rg to `ugo/journal-dir' so only journals are searched."
  (interactive)
  (counsel-rg nil ugo/journal-dir))

(keymap-global-set "C-c j" #'ugo/search-journals)

(defun ugo/search-org ()
  "Interactively search across all Org files in the org directory."
  (interactive)
  (counsel-rg nil "~/Documentos/org/"))

(keymap-global-set "C-c s" #'ugo/search-org)

(defun ugo/open-adjacent-daily-note (direction)
  "Navigate to the next (DIRECTION=+1) or previous (DIRECTION=-1) daily note.
Skips gaps — jumps directly to the nearest existing journal file in that direction."
  (if-let* ((file (buffer-file-name))
            (dir (expand-file-name ugo/journal-dir))
            (name (file-name-base file))
            ((string-prefix-p dir (expand-file-name file)))
            ((string-match
              "\\`\\([0-9]\\{4\\}\\)\\([0-9]\\{2\\}\\)\\([0-9]\\{2\\}\\)\\'"
              name)))
      (let* ((journals (directory-files dir t "\\`[0-9]\\{8\\}\\.org\\'" nil))
             (sorted (sort journals #'string<))
             (current (expand-file-name file))
             (pos (cl-position current sorted :test #'string=)))
        (cond
         ((not pos)
          (message "Current file not found in journal directory."))
         ((not (nth (+ pos direction) sorted))
          (message "No more daily notes in that direction."))
         (t
          (find-file (nth (+ pos direction) sorted)))))
    (message "Not in a daily note buffer.")))

(defun ugo/open-next-daily-note ()
  "Open the daily note for the day after the current buffer's date."
  (interactive)
  (ugo/open-adjacent-daily-note 1))

(defun ugo/open-previous-daily-note ()
  "Open the daily note for the day before the current buffer's date."
  (interactive)
  (ugo/open-adjacent-daily-note -1))

(keymap-global-set "C-c n" #'ugo/open-next-daily-note)

(keymap-global-set "C-c N" #'ugo/open-previous-daily-note)

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
         (file+headline "~/Documentos/org/01_tasks.org" "inbox")
         "** TODO %?\n  %U")

        ("n" "New Note" entry
         (file+headline "~/Documentos/org/notas/notes.org" "Notes")
         "* %?\n  %U")))

(put 'erase-buffer 'disabled nil)
(put 'upcase-region 'disabled nil)

(defun ugo/openrouter-api-key ()
  "Read the OpenRouter API key from the sops-nix decrypted file."
  (with-temp-buffer
    (insert-file-contents
     (expand-file-name "sops-nix/secrets/openrouter_api_key"
                       (or (getenv "XDG_CONFIG_HOME")
                           (expand-file-name "~/.config"))))
    (string-trim (buffer-string))))

(use-package gptel
  :config
  ;; OpenRouter offers an OpenAI-compatible API
  (gptel-make-openai "OpenRouter"
    :host "openrouter.ai"
    :endpoint "/api/v1/chat/completions"
    :stream t
    :key #'ugo/openrouter-api-key
    :models '(deepseek/deepseek-v4-pro
	      ~deepseek/deepseek-v4-flash-latest
              moonshotai/kimi-k3
              z-ai/glm-5.2)))

(use-package evil
  :init
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package nix-mode
  :mode "\\.nix\\'"
  :hook (nix-mode . lsp-deferred))

(use-package python
  :mode ("\\.py\\'" . python-mode)
  :hook (python-mode . lsp-deferred))

(use-package php-mode
  :mode "\\.php\\'"
  :hook (php-mode . lsp-deferred))

(use-package js2-mode
  :mode "\\.js\\'"
  :hook (js2-mode . lsp-deferred))

(use-package go-mode
  :mode "\\.go\\'"
  :hook (go-mode . lsp-deferred))

(use-package rust-mode
  :mode "\\.rs\\'"
  :hook (rust-mode . lsp-deferred))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
