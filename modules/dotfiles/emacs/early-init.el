;;; early-init.el --- runs before init.el and package.el startup
;; Hybrid Nix + use-package setup: Nix provides packages via
;; `programs.emacs.extraPackages`; prevent package.el from doing anything at
;; startup so Emacs never tries to contact MELPA/ELPA or modify the profile.
(setq package-enable-at-startup nil)

;; Avoid the "Ensuring user-init-file is loaded" package.el dance that would
;; otherwise try to install `package-selected-packages'.
(setq package--init-file-ensured t)

;; Prefer newest versions of compiled files (Nix store paths are immutable,
;; so this is safe and avoids stale elc/eln warnings after rebuilds).
(setq load-prefer-newer t)
