;;; Hybrid Nix + use-package setup
;; Nix provides the packages via programs.emacs.extraPackages; package.el is
;; fully disabled in early-init.el (runs before package.el startup).
(require 'use-package)
(setq use-package-always-ensure nil)


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

;;; Packages
(use-package gruvbox-theme
             :config
             (load-theme 'gruvbox-dark-medium t))
;;; General UI
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
    (set-face-attribute 'default nil :font "Iosevka" :height 100)))

(add-hook 'after-make-frame-functions #'ugo/apply-frame-faces)
(add-hook 'server-after-make-frame-hook #'ugo/apply-frame-faces)
(ugo/apply-frame-faces)

(put 'erase-buffer 'disabled nil)

;; org mode configs
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)
(put 'upcase-region 'disabled nil)

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
         :empty-lines 0)))

(project-mode-line project-mode-line-format)
