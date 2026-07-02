;;; Hybrid Nix + use-package setup
;; Nix provides the packages via programs.emacs.extraPackages; package.el is
;; fully disabled in early-init.el (runs before package.el startup).
(require 'use-package)
(setq use-package-always-ensure nil)

;;; Packages
(use-package gruvbox-theme
  :config
  (load-theme 'gruvbox-dark-medium t))

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

;;; General UI
(tool-bar-mode -1)
(custom-set-variables '(package-selected-packages nil))
(custom-set-faces)

(make-directory "~/.config/emacs/auto-save/" t)
(setq auto-save-file-name-transforms
      `((".*" "~/.config/emacs/auto-save/" t)))

;;; Apply face/font settings to every frame (including emacsclient frames).
;;; In daemon mode, `set-face-attribute' without a live graphical frame
;;; doesn't propagate to client frames opened later.
(defun my/apply-frame-faces (&optional frame)
  "Apply font and face customizations to FRAME (default: selected)."
  (with-selected-frame (or frame (selected-frame))
    (set-face-attribute 'default nil :font "Iosevka" :height 110)
    (set-face-attribute 'scroll-bar nil
                        :background "#282828"
                        :foreground "#504945")
    (set-face-attribute 'menu nil
                        :background "#282828"
                        :foreground "#ebdbb2")))

(add-hook 'after-make-frame-functions #'my/apply-frame-faces)
(add-hook 'server-after-make-frame-hook #'my/apply-frame-faces)
(my/apply-frame-faces)

(global-set-key (kbd "C-c a") 'org-agenda)
(put 'erase-buffer 'disabled nil)
