(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'markdown-mode)
  (package-refresh-contents)
  (package-install 'markdown-mode))

(unless (package-installed-p 'gruvbox-theme)
  (package-refresh-contents)
  (package-install 'gruvbox-theme))

(load-theme 'gruvbox-dark-medium t)

(global-set-key (kbd "C-c a") 'org-agenda)

(set-face-attribute 'default nil :font "Iosevka" :height 110)
(tool-bar-mode -1)
(custom-set-variables '(package-selected-packages nil))
(custom-set-faces)

(setq auto-save-file-name-transforms
      `((".*" "~/.config/emacs/auto-save/" t)))
